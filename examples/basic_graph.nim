import std/tables

import flowdependency

var graph = initFlowGraph("daily-report")
graph.addNode(flowNode("extract", "Extract"))
graph.addNode(flowNode("transform", "Transform"))
graph.addNode(flowNode("publish", "Publish"))
graph.addEdge(flowEdge("extract-transform", "extract", "transform"))
graph.addEdge(flowEdge("transform-publish", "transform", "publish"))

let order = graph.topologicalOrder()
doAssert order == @["extract", "transform", "publish"]

var statuses = initTable[string, NodeStatus]()
statuses["extract"] = nsSucceeded

let transform = graph.readyDecision("transform", statuses)
doAssert transform.ready

echo graph.toMermaid()
