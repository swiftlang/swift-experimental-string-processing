
var benchmark = BenchmarkRunner(suiteName: "test benchmark")
benchmark.addReluctantQuant()
benchmark.addBacktracking()
benchmark.addCSS()
benchmark.run()
