
/*

 NOTE: This is still work-in-progress, but is meant to highlight
 a very different kind of matching application.

 PTCaRet is PTLTL + CaRet (call and return). It extends PTLTL with
 the notion of an "abstract trace" using the basic computing
 abstraction: function calls.

 Traces can "call" a function, and the abstact trace will just
 see a call followed by a return: the call abstracts any
 intermediary events while that subroutine executes.

 The subroutine itself sees the full trace in its abstract trace,
 including its own triggered events, but it doesn't see events
 from calls it makes to its subroutines.

 Full trace call appears as:
 call begin ...body... end return
 where `call/return` appear in caller's abstract trace. In the
 callee's abstract trace, `call/begin/end/return`, as well as any
 direct events triggered (i.e. not from inside a subroutine call)
 appear.

 A function call is like a fence. While a fence is a single
 object, it makes sense to talk about both the fence itself
 as well as from which side you're looking at it.

 By anchoring against `begin`, you are specifying formulae over
 your dynamic call stack, as you can see those `begin` but not any
 that were abstracted over by completed function calls. I.e.
 abstract operations paired with this `call/begin/end/return`
 convention allows one to define an emergent "call stack" trace
 and specify properties of that.

 Properties could include "g cannot be called indirectly by f".
 "If f was called, an unfinished call to g must be on the call
 stack", etc.

 Abstract since against begin enforces a function precondition
 that has also held as an invariant up to the present moment
 (or containing formula). `let f = .abstractSince(x, .begin)`
 means `x` held as a precondition at the start of the currently
 executing function, and has held up until... whatever you're
 going to use `f` with.

 Normal PTLTL formulae require 1 global bit per temporal operator.
 PTCaRet requires that monitors have a local bit-stack. Formulae
 require 1 stack bit per abstract temporal operator.

 NOTE: Really really want small-bitvector data structure. Call
 stack can be a single small-bitvector via a AoS->SoA conversion.

 Inspiration: "Synthesizing Monitors for Safety Properties - This Time With Calls and Returns" by Rosu et al.

 */

public enum PTCaRet<Event: Hashable> {}

extension PTCaRet {
  enum Formula {

    // Atoms
    case bool(Bool)
    case event(Event)

    // Custom Predicates
    case customEvent((Event) -> Bool)
    case custom(() -> Bool) // TODO: Matching state to closure

    // Boolean logic
    indirect case not(Formula)
    indirect case and(Formula, Formula)
    indirect case or(Formula, Formula)

    static func xor(_ a: Formula, _ b: Formula) -> Formula {
      .and(.or(a, b), .not(.and(a, b)))
    }

    static func implies(_ a: Formula, _ b: Formula) -> Formula {
      .or(b, .not(a))
    }

    static func equals(_ a: Formula, _ b: Formula) -> Formula {
      .and(.implies(a, b), .implies(b, a))
    }

    // MARK: - temporal operators

    /// `a` held true in prior trace
    ///
    /// Initially false (if trace is empty)
    indirect case previously(Formula)

    /// `a` has held since `b`
    ///
    /// Either `b` holds currently, or `a` holds and
    /// `.previously(.since(a, b))` holds.
    ///
    /// Initially false (if trace is empty)
    ///
    /// TODO: Isn't this a strong since instead of weak since?
    /// Don't we need an `.or(.empty, .since...)` to permit
    /// always `a`?
    indirect case since(Formula, Formula)


    /*

     As a logic, PTLTL is usually specified with just since
     and previously, as all others can be derived from those.

     I'm making always/never/sometime fundamental. This
     dramatically improves the implementation and fixes
     corner-case bugs one tends to find in papers.

     */

    /// `a` has always held
    ///
    ///     .since(a, .bool(false))
    ///
    /// (but I think the since we have is actually strong)
    indirect case always(Formula)

    /// `a` never happened
    ///
    ///     .always(.not(a))
    ///
    indirect case never(Formula)

    /// `a` happened sometime in the past
    ///
    ///     .not(.never(a))
    ///
    indirect case sometime(Formula)

    // Abstract atoms
    case call  // Appears in caller and callee trace
    case begin // Appears in callee trace
               // ... body of function ...
    case end   // Appears in callee trace
    case ret   // Appears in caller and callee trace

    // Abstract custom predicates
    case callSpecific(String)
    // TODO: more


    // MARK: - Abstract temporal operators


    /// `a` held true in prior abstract trace
    ///
    /// Initially false (if abstract trace is empty)
    indirect case abstractPreviously(Formula)

    /// `a` has held since `b` in the abstract trace
    ///
    /// Either `b` holds currently, or `a` holds and
    /// `.previously(.abstractSince(a, b))` holds.
    ///
    /// Initially false (if trace is empty)
    ///
    /// TODO: Isn't this a strong since instead of weak since?
    /// Don't we need an `.or(.empty, .since...)` to permit
    /// always `a`?
    indirect case abstractSince(Formula, Formula)

    /*

     Again, gonna make others fundamental

    */

    /// `a` has always held in the abstract trace
    ///
    ///     .abstractSince(a, since: .bool(false))
    ///
    /// (but I think the since we have is actually strong)
    indirect case abstractAlways(Formula)

    /// `a` never happened in the abstract trace
    ///
    ///     .abstractAlways(.not(a))
    ///
    indirect case abstractNever(Formula)

    /// `a` happened sometime in the past in the abstract trace
    ///
    ///     .not(.abstractNever(a))
    ///
    indirect case abstractSometime(Formula)

    /*


    */

    // MARK: - Stack operators

    /*

     Again making these otherwise-derived cases fundamental

     */

    /// `a` has held true at the start of every (non-terminated) function
    /// on the call stack since `b` most recently held true at the start of a (non-terminated)
    /// function on the call stack.
    ///
    ///  .abstractCheck(
    ///    a, filteredBy: .begin,
    ///    since: b, filteredBy: .begin)
    ///
    /// I.e. ignore completed function calls
    ///
    indirect case stackSinceOnBegins(Formula, Formula)

    /// `a` has held true at every call of a function (including terminated ones)
    /// since `b` held true at the call of a (non-terminated)
    /// function on the call stack.
    ///
    /// I.e. ignore completed function calls
    ///
    ///  .abstractCheck(
    ///    a, filteredBy: .call,
    ///    since: .previously(b), filteredBy: .begin)
    ///
    indirect case stackSinceOnCalls(Formula, Formula)

    // TODO: Is the above actually a good idea? Should we just
    // have `a` also filtered on begins and do a previously?
    // That would mean we have derived a "stack trace" using
    // begin and we're running formula over the stack trace.

    // TODO: Or, do we want to split things out? How should we do this?

    /// `a` has always held at the start of every (non-terminated) function on the call
    ///  stack
    ///
    indirect case stackAlwaysOnBegins(Formula)

    /// `a` has always held at every call of a function in the abstract trace
    ///
    indirect case stackAlwaysOnCalls(Formula)

  }
}

extension PTCaRet.Formula {
  init(_ a: Formula, since b: Formula) {
    self = .since(a, b)
  }
}



/// A trace is a (finite) sequence of states.
///
/// A non-empty trace can be decomposed into the current
/// state and the trace prior to transitioning into that state.
struct Trace<State> {
  var isEmpty: Bool {
    fatalError()
  }

  var current: State {
    fatalError()
  }

  var prior: Trace<State> {
    fatalError()
  }
}

// Just my attempts at making sane programming tools around this
// logic
extension PTCaRet.Formula {
  typealias Formula = Self

  /// `a` has never held since `b` most recently held.
  ///
  /// `b`, or `¬a`and `.previously(.neverSince(a, b))`
  ///
  static func never(
    _ a: Formula, since b: Formula
  ) -> Formula {
    .since(.not(a), b)
  }

  /// `a` has held sometime since `b` most recently held.
  ///
  /// `b`, or `¬a`and `.previously(.neverSince(a, b))`
  ///
  static func abstractNever(
    _ a: Formula, since b: Formula
  ) -> Formula {
    .abstractSince(.not(a), b)
  }
  /// `a` has held sometime since `b` most recently held.
  ///
  /// `¬b`, and `a` or `.previously(.sometimeSince(a, b))`
  ///
  static func sometime(
    _ a: Formula, since b: Formula
  ) -> Formula {
    .not(.since(.not(a), b))
  }

  /// `a` has held sometime since `b` most recently held.
  ///
  /// `¬b`, and `a` or
  ///   `.previously(.abstractSometimeSince(a, b))`
  ///
  static func abstractSometime(
    _ a: Formula, since b: Formula
  ) -> Formula {
    .not(.abstractSince(.not(a), b))
  }

  // MARK: - compound temporal operators

  /// If `a` occurred since `start`, `b` must have held sometime after
  ///
  ///     (¬a S start ∨ ¬(¬b S a))
  ///
  ///     a S_never start ∨ b S_sometime a
  ///
  static func requirement(
    _ a: Formula,
    requiresEventually b: Formula,
    since start: Formula
  ) -> Formula {
    .or(.never(a, since: start), .sometime(b, since: a))
  }

  /// If `a` abstract-occurred since `start`, `b` must have held sometime after
  ///
  ///     (¬a S̅ start ∨ ¬(¬b S̅ a))
  ///
  static func abstractRequirement(
    _ a: Formula,
    requiresEventually b: Formula,
    since start: Formula
  ) -> Formula {
    .or(.abstractNever(a, since: start), .abstractSometime(b, since: a))
  }

  /// If `a` occurred since `start`, `b` must have held sometime after. This
  /// is checked when `trigger` happens.
  ///
  ///     trigger → .requirement(
  ///       a, requiresEventually: b, since: start)
  ///
  static func requirement(
    _ a: Formula,
    requiresEventually b: Formula,
    since start: Formula,
    triggeredBy trigger: Formula
  ) -> Formula {
    .implies(
      trigger,
      .requirement(a, requiresEventually: b, since: start))
  }

  /// If `a` abstract-occurred since `start`, `b` must have held sometime after. This
  /// is checked when `trigger` happens.
  ///
  ///     trigger → (¬a S̅ start ∨ ¬(¬b S̅ a))
  ///
  static func abstractRequirement(
    _ a: Formula,
    requiresEventually b: Formula,
    since start: Formula,
    triggeredBy trigger: Formula
  ) -> Formula {
    .implies(
      trigger,
      .abstractRequirement(a, requiresEventually: b, since: start))
  }

  /// `a` simultaneously held when `b` most recently held.
  ///
  ///     (b → a) ∧ (¬b → ◦(b → a) S b
  ///
  static func simultaneously(
    _ a: Formula,
    during b: Formula
  ) -> Formula {
    // Note: More effient to implement directly
    .and(
      .implies(b, a),
      .implies(.not(b), .since(.previously(.implies(b, a)), b)))
  }

  /// `a` simultaneously held when `b` most recently held.
  ///
  ///     (b → a) ∧ (¬b → ◦(b → a) S̅ b
  ///
  static func abstractSimultaneously(
    _ a: Formula,
    during b: Formula
  ) -> Formula {
    // Note that we don't do abstract previously, it's not necessary
    .and(
      .implies(b, a),
      .implies(.not(b), .abstractSince(.previously(.implies(b, a)), b)))
  }

  /// `a` held at the start of the current function
  static func atFunctionBegin(_ a: Formula) -> Formula {
    .abstractSimultaneously(a, during: .begin)
  }
  /// `a` held during the call of the current function (immediately before start, from caller's context)
  static func atFunctionCall(_ a: Formula) -> Formula {
    .atFunctionBegin(.previously(a))
  }

  /// `a` has held true at every occurence of `filterA` since the
  /// most recent occurrence of both `b` and `filterB`.
  ///
  ///     (filterA → a) S (filterB ∧ b)
  ///
  static func check(
    _ a: Formula, filteredBy filterA: Formula,
    since b: Formula, filteredBy filterB: Formula
  ) -> Formula {
    .since(.implies(filterA, a), .and(filterB, b))
  }

  /// `a` has held true at every occurence of `filterA` since the
  /// most recent occurrence of both `b` and `filterB`.
  ///
  ///     (filterA → a) S̅ (filterB ∧ b)
  ///
  static func abstractCheck(
    _ a: Formula, filteredBy filterA: Formula,
    since b: Formula, filteredBy filterB: Formula
  ) -> Formula {
    .abstractSince(.implies(filterA, a), .and(filterB, b))
  }


}


///
/// Derivations:
///
///     ¬(¬'enter_phase_1' S 'begin')
///     'enter_phase_1' S_sometime 'begin'
///
///     ¬'acquire' S 'enter_phase_1' ∨ ¬(¬'release' S 'acquire')
///     ¬'acquire' S 'enter_phase_1' ∨ 'release' S_sometime 'acquire'
///     'acquire' S_never 'enter_phase_1' ∨ 'release' S_sometime 'acquire'
///
///     (¬acquire S begin ∨ ¬(¬release S acquire))
///     acquire S_never begin ∨ release S_sometime acquire
///
///     @ψ = (begin → ψ) ∧ (¬begin → ◦(begin → ψ) S̅ begin).

