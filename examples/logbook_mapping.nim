import flowdependency

var graph = initFlowGraph("observed-flow")
graph.addNode(flowNode("extract", "Extract"))
graph.addNode(flowNode("load", "Load"))
graph.addEdge(flowEdge(
  id = "extract-load",
  fromNode = "extract",
  toNode = "load",
  durationMillis = 320,
  metadata = @[kv("logbookEdgeId", "extract->load")]
))

let path = graph.criticalPath()
doAssert path.edgeIds == @["extract-load"]

# FlowLogbook can record events with matching nodeId or edgeId values. Keeping
# those ids in metadata lets analysis tools join graph structure and log events
# without coupling FlowDependency to FlowLogbook.
doAssert graph.edges[0].metadata[0].value == "extract->load"
