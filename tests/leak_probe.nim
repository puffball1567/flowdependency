import flowdependency

proc main() =
  var totalEdges = 0
  for i in 0 ..< 1000:
    var graph = initFlowGraph("flow-" & $i, variantId = "A")
    graph.nodes.add flowNode("extract-" & $i, metadata = [kv("stage", "extract")])
    graph.nodes.add flowNode("transform-" & $i, metadata = [kv("stage", "transform")])
    graph.nodes.add flowNode("load-" & $i, metadata = [kv("stage", "load")])
    graph.edges.add flowEdge("edge-a-" & $i, graph.nodes[0].id, graph.nodes[1].id, durationMillis = Natural(i))
    graph.edges.add flowEdge("edge-b-" & $i, graph.nodes[1].id, graph.nodes[2].id, durationMillis = Natural(i + 1))
    discard validate(graph)
    discard topologicalOrder(graph)
    discard criticalPath(graph)
    totalEdges += graph.edges.len

  doAssert totalEdges == 2000

main()
