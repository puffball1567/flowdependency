import flowdependency

var graph = initFlowGraph("variant-example")
graph.addNode(flowNode("source", "Source"))
graph.addNode(flowNode("fast-path", "Fast Path", variantId = "A"))
graph.addNode(flowNode("safe-path", "Safe Path", variantId = "B"))
graph.addNode(flowNode("finish", "Finish"))
graph.addEdge(flowEdge("source-fast", "source", "fast-path", variantId = "A"))
graph.addEdge(flowEdge("fast-finish", "fast-path", "finish", variantId = "A"))
graph.addEdge(flowEdge("source-safe", "source", "safe-path", variantId = "B"))
graph.addEdge(flowEdge("safe-finish", "safe-path", "finish", variantId = "B"))

let variantA = graph.activeVariant("A")
doAssert variantA.hasNode("fast-path")
doAssert not variantA.hasNode("safe-path")
doAssert variantA.topologicalOrder() == @["source", "fast-path", "finish"]
