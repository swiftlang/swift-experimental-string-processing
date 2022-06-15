
// todo: make this a proper arg parsing main
// todo: add an option to run an individual benchmark once for profiling purposes
var benchmark = BenchmarkRunner(suiteName: "test benchmark")
benchmark.addReluctantQuant()
benchmark.addBacktracking()
benchmark.addCSS()
benchmark.addFirstMatch()
benchmark.run()
