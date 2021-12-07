import Util
import MatchingEngine

extension PEG.VM {
  typealias InIndex = Input.Index

  // Host state and sub-tasks for compiling a PEG
  fileprivate struct Compilation {
    // Input to compilation
    var program: PEG.Program

    // Global state during compilation
    struct State {
      var currentCapture = 0
      var currentRegister = 0
      var currentFunction = 0

      var functions: Dictionary<String, FunctionId> = [:]

      fileprivate var worklist = Worklist()

      mutating func nextCapture() -> CaptureId {
        defer { currentCapture += 1 }
        return CaptureId(currentCapture)
      }
      mutating func nextRegister() -> BoolRegister {
        defer { currentRegister += 1 }
        return BoolRegister(currentRegister)
      }

      mutating func getFunctionId(for s: String) -> FunctionId {
        if let id = functions[s] {
          return id
        }
        defer { currentFunction += 1 }
        let id = FunctionId(rawValue: currentFunction)
        functions[s] = id
        return id
      }

      var isClear: Bool {
        /*self == State()*/
        true
      }
    }
    var state = State()

    // The result of compilation
    struct Output {
      var compiledFunctions: Dictionary<FunctionId, Function> = [:]

      mutating func register(_ id: FunctionId, _ fun: Function) {
        precondition(compiledFunctions[id] == nil)
        compiledFunctions[id] = fun
      }
    }
    var output = Output()

    func dump() {
      print("""
        State:
        \(state)
        Output:
        \(output.compiledFunctions.debugDescription)
      """)
    }
  }

  fileprivate struct FunctionCompilation {
    struct State {
      var currentLabel = 0
      mutating func nextLabel() -> LabelId {
        defer { currentLabel += 1 }
        return LabelId(rawValue: currentLabel)
      }
    }
    var state = State()

    var output: Function

    init(name: String) {
      output = Function(name: name)
    }
  }

  static func compile(_ program: PEG.Program) -> Code {
    var comp = Compilation(program: program)
    return comp.compileImpl()
  }
}


extension PEG.VM.Compilation.State: CustomStringConvertible {
  var description: String {
    """
      fun: \(currentFunction), cap: \(currentCapture), reg: \(currentRegister)
      \(functions)
    """
  }
}

extension PEG.VM.Compilation {
  fileprivate typealias Worklist = Array<PEG.Production>

  typealias Code = PEG.VM<Input>.Code
  typealias Function = Code.Function
  typealias FunctionCompilation = PEG.VM<Input>.FunctionCompilation

  fileprivate mutating func compileImpl() -> PEG.VM<Input>.Code {
    precondition(state.isClear)

    _ = state.getFunctionId(for: program.start)

    state.worklist.append(program.entry)
    while let prod = state.worklist.popLast() {
      guard let id = state.functions[prod.name] else {
        preconditionFailure("Unregistered function")
      }
      guard !output.compiledFunctions.keys.contains(id) else {
        continue
      }

      let fun = compileFunction(prod)
      output.register(id, fun)
    }

    return Code(
      functions: (0..<state.currentFunction).map {
      output.compiledFunctions[FunctionId(rawValue: $0)]!
    })
  }

  mutating func compileFunction(_ prod: PEG.Production) -> Function {
    FunctionCompilation.compile(prod, updating: &self)
  }
}

extension PEG.VM.FunctionCompilation {
  fileprivate typealias Worklist = Array<PEG.Production>

  typealias Code = PEG.VM<Input>.Code
  typealias Function = Code.Function
  typealias Compilation = PEG.VM<Input>.Compilation

  static func compile(
    _ production: PEG.Production, updating globalState: inout Compilation
  ) -> Function {
    var comp = Self(name: production.name)
    comp.compileRec(production.pattern, updating: &globalState)
    comp.output.add(.ret)
    return comp.output
  }

  private mutating func compileImpl(
    _ pattern: PEG.Pattern,
    updating globalState: inout Compilation
  ) {
    compileRec(pattern, updating: &globalState)
  }

  private mutating func compileRec(
    _ pattern: PEG.Pattern,
    updating globalState: inout Compilation
  ) {

    switch pattern {
    case .any: output.add(.any)

    case .success: output.add(.accept)
    case .failure: output.add(.fail)
    case .element(let e): output.add(.element(e))

    case .charactetSet(let p): output.add(.set(p))

    case .literal(let s): s.forEach { output.add(.element($0)) }

    case .orderedChoice(let a, let b):
      let alt = state.nextLabel()
      let done = state.nextLabel()
      output.add(.save(restoringAt: alt))
      compileRec(a, updating: &globalState)
      output.add(.commit(continuingAt: done))

      output.addLabel(alt)
      compileRec(b, updating: &globalState)
      output.addLabel(done)

    case .concat(let ps):
      ps.forEach { compileRec($0, updating: &globalState) }

    case .difference(let p, let not):
      // TODO: might be more efficient to compile directly?
      compileRec(.concat([.not(not), p]), updating: &globalState)

    case .repeat(let p, atLeast: let atLeast):
      // TODO: codegen that will update stack instead of pop/push

      // TODO: codegen that will count

      let start = state.nextLabel()
      let end = state.nextLabel()

      // TODO: Better to count loop iterations...
      for _ in 0 ..< atLeast {
        compileRec(p, updating: &globalState)
      }

      output.addLabel(start)
      output.add(.save(restoringAt: end))
      compileRec(p, updating: &globalState)
      output.add(.commit(continuingAt: start))
      output.addLabel(end)

    case .repeatRange(_, atLeast: _, atMost: _):
      fatalError()

    case .and(let p):
      // TODO: This is convoluted. Surely it can be coded using better
      // low-level interfaces.


      let end = state.nextLabel()
      let removeOne = state.nextLabel()
      let fail = state.nextLabel()

      output.add(.save(restoringAt: end))
      output.add(.save(restoringAt: removeOne))

      compileRec(p, updating: &globalState)

      output.addLabel(removeOne)
      output.add(.commit(continuingAt: fail))

      output.addLabel(fail)
      output.add(.fail)

      output.addLabel(end)

    case .not(let p):

      let end = state.nextLabel()
      let fail = state.nextLabel()

      output.add(.save(restoringAt: end))
      compileRec(p, updating: &globalState)
      output.add(.commit(continuingAt: fail))

      output.addLabel(fail)
      output.add(.fail)

      output.addLabel(end)


    case .capture(let p):
      output.add(.startCapture)
      compileRec(p, updating: &globalState)
      output.add(.endCapture)

    case .variable(let funname):
      let id = globalState.state.getFunctionId(for: funname)
      output.add(.call(id))
      if globalState.output.compiledFunctions[id] == nil
          && !globalState.state.worklist.contains(where: { $0.name == funname } ) {
        globalState.state.worklist.append(
          PEG.Production(name: funname, pattern: globalState.program.environment[funname]!))
      }

    case .end:
      // TODO: compile directly
      compileRec(.not(.any), updating: &globalState)
    }
  }

}

extension PEG.Program {
  public func compile<Input: Collection>(
    for input: Input.Type = Input.self
  ) -> PEG.Consumer<Input> where Input.Element == Element {
    let code = PEG.VM<Input>.compile(self)
    return PEG.Consumer(vm: PEG.VM.load(code))
  }
}
