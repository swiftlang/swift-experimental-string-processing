//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2026 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

/// Best-effort attempt to bias the OS scheduler toward giving this
/// process priority.
func elevateSchedulingPriority() {
#if canImport(Darwin)
  pthread_set_qos_class_self_np(QOS_CLASS_USER_INTERACTIVE, 0)
#endif
}

/// A snapshot of system load, recorded alongside benchmark results
/// so that a later comparison can tell whether the two sides were
/// measured under comparable conditions.
struct EnvironmentInfo: Codable {
  /// 1-minute load average when the run started.
  var loadAverageAtStart: Double?
  /// 1-minute load average when the run finished.
  var loadAverageAtEnd: Double?
  /// Number of logical cores, for interpreting the load average above
  /// (a load average of 4 means very different things on a 4-core vs.
  /// 32-core machine).
  var logicalCoreCount: Int?

  static var current: EnvironmentInfo {
    let load = currentLoadAverage()
    return EnvironmentInfo(
      loadAverageAtStart: load,
      loadAverageAtEnd: load,
      logicalCoreCount: currentLogicalCoreCount())
  }
}

/// The 1-minute load average, or `nil` if unavailable on this platform.
func currentLoadAverage() -> Double? {
#if canImport(Darwin) || canImport(Glibc)
  var load = [Double](repeating: 0, count: 3)
  guard getloadavg(&load, 1) == 1 else { return nil }
  return load[0]
#else
  return nil
#endif
}

func currentLogicalCoreCount() -> Int? {
#if canImport(Darwin) || canImport(Glibc)
  let n = sysconf(Int32(_SC_NPROCESSORS_ONLN))
  return n > 0 ? Int(n) : nil
#else
  return nil
#endif
}

/// Prints a warning if the load level suggests the machine is being
/// shared with substantial other work.
func warnIfLoadIsHigh(_ label: String, _ load: Double, cores: Int?) {
  guard let cores else { return }
  guard load > Double(cores) * 0.75 else { return }
  print("""
    ⚠️  WARNING: system load average (\(String(format: "%.1f", load))) is high relative \
    to this machine's \(cores) logical cores \(label). \
    Benchmark results from this run are at elevated risk of contention noise — \
    consider re-running when the machine is quieter, or re-running with more \
    samples, before trusting a comparison against this result.
    """)
}

/// Prints a warning if the change in load suggests the machine is being shared
/// with substantial other work.
func warnIfLoadJumped(during info: EnvironmentInfo) {
  guard let start = info.loadAverageAtStart, let end = info.loadAverageAtEnd,
        start > 0
  else { return }
  let ratio = end / start
  guard ratio > 1.5 || ratio < (1 / 1.5) else { return }
  print("""
    ⚠️  WARNING: system load average moved from \(String(format: "%.1f", start)) to \
    \(String(format: "%.1f", end)) while this run was in progress. Something else on \
    this shared machine started or stopped competing for the CPU partway through — \
    benchmarks measured near the transition are at high risk of being skewed by it, \
    independent of this run's average load. Prefer a result where load stayed stable \
    throughout, or re-run and compare against a second run to see if this reproduces.
    """)
}

/// Prints a warning when the two sides of a comparison were
/// measured under different levels of system contention.
func warnAboutEnvironmentMismatch(
  current: EnvironmentInfo?,
  baseline: EnvironmentInfo?,
  baselineLabel: String
) {
  guard let current, let baseline,
        let currentLoad = current.loadAverageAtStart,
        let baselineLoad = baseline.loadAverageAtStart
  else {
    print("""
      Note: load-average metadata is missing for this run or for \
      '\(baselineLabel)' (older saved results predate this check) — \
      unable to check whether the two sides were measured under \
      comparable system load.
      """)
    return
  }
  // A fixed fraction of core count misses exactly the case that most
  // matters here: a modest-looking load level that nonetheless moved a
  // lot relative to where it was for the *other* side of the comparison.
  // Flag either a large absolute gap or a large relative one, since a
  // 1-vs-2 jump and a 4-vs-8 jump are both "roughly doubled" but only
  // the second trips a fixed-delta-of-2 check.
  let absoluteGap = Swift.abs(currentLoad - baselineLoad)
  let ratio = baselineLoad > 0 ? currentLoad / baselineLoad : .infinity
  guard absoluteGap > 2 || ratio > 1.5 || ratio < (1 / 1.5) else { return }
  print("""
    ⚠️  WARNING: this run's load average (\(String(format: "%.1f", currentLoad))) differs \
    substantially from '\(baselineLabel)''s (\(String(format: "%.1f", baselineLoad))). \
    Differences between these two results may reflect system contention rather than \
    a real change — treat this comparison with extra skepticism.
    """)
}
