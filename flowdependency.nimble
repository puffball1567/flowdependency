version       = "0.1.0"
author        = "flowdependency contributors"
description   = "Dependency graph primitives for FlowBrigade Toolkit flows."
license       = "Apache-2.0"
srcDir        = "src"
installExt    = @["nim"]
skipDirs      = @[
  ".github",
  "docs",
  "examples",
  "tests"
]

requires "nim >= 2.2.0"

task test, "Run the test suite":
  exec "nim r --nimcache:/tmp/flowdependency-test-nimcache -p:src tests/all.nim"

task examples, "Check examples":
  exec "nim check --nimcache:/tmp/flowdependency-nimcache -p:src examples/basic_graph.nim"
  exec "nim check --nimcache:/tmp/flowdependency-nimcache -p:src examples/variant_graph.nim"
