import std/unittest
import flowdependency

suite "memory model":
  test "uses Nim ARC memory manager":
    when defined(gcArc):
      check true
    else:
      check false

  test "creates and releases graph values under ARC":
    var totalNodes = 0
    for i in 0 ..< 200:
      var graph = initFlowGraph("flow-" & $i, variantId = "A")
      graph.nodes.add flowNode("extract-" & $i, metadata = [kv("stage", "extract")])
      graph.nodes.add flowNode("load-" & $i, metadata = [kv("stage", "load")])
      graph.edges.add flowEdge("edge-" & $i, graph.nodes[0].id, graph.nodes[1].id, durationMillis = Natural(i))
      totalNodes += graph.nodes.len
    check totalNodes == 400
