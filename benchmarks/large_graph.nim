import std/monotimes
import std/strformat
import std/times

import flowdependency

const NodeCount = 5_000

proc elapsedMs(started: MonoTime): float =
  let elapsed = getMonoTime() - started
  elapsed.inNanoseconds.float / 1_000_000.0

var graph = initFlowGraph("large")
for i in 0 ..< NodeCount:
  graph.addNode(flowNode("n" & $i))
for i in 0 ..< NodeCount - 1:
  graph.addEdge(flowEdge("e" & $i, "n" & $i, "n" & $(i + 1), durationMillis = 1))

let started = getMonoTime()
let order = graph.topologicalOrder()
let path = graph.criticalPath()
let ms = elapsedMs(started)

doAssert order.len == NodeCount
doAssert path.edgeIds.len == NodeCount - 1

echo &"large graph: {NodeCount} nodes, {NodeCount - 1} edges, topo+critical path in {ms:.2f} ms"
