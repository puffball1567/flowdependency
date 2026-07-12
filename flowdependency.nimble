version       = "0.3.1"
author        = "flowdependency contributors"
description   = "Dependency graph primitives for FlowBrigade Toolkit flows."
license       = "Apache-2.0"
srcDir        = "src"
installExt    = @["nim"]
skipDirs      = @[
  ".github",
  "benchmarks",
  "docs",
  "examples",
  "tests"
]

requires "nim >= 2.2.0"

task test, "Run the test suite":
  exec "nim r --nimcache:/tmp/flowdependency-test-nimcache -p:src tests/all.nim"

task leak, "Run the ARC leak probe under Valgrind":
  exec "nim c -d:release --nimcache:/tmp/flowdependency-leak-nimcache -p:src --out:/tmp/flowdependency-leak-probe tests/leak_probe.nim"
  exec "valgrind --leak-check=full --show-leak-kinds=definite,indirect --errors-for-leak-kinds=definite,indirect --error-exitcode=99 /tmp/flowdependency-leak-probe"

task examples, "Check examples":
  exec "nim check --nimcache:/tmp/flowdependency-nimcache -p:src examples/basic_graph.nim"
  exec "nim check --nimcache:/tmp/flowdependency-nimcache -p:src examples/variant_graph.nim"
  exec "nim check --nimcache:/tmp/flowdependency-nimcache -p:src examples/logbook_mapping.nim"

task bench, "Run basic local benchmarks":
  exec "nim r -d:release --nimcache:/tmp/flowdependency-bench-nimcache -p:src benchmarks/large_graph.nim"
