import std/tables

import ./graph
import ./types
import ./validation

proc edgeCost(edge: FlowEdge): float =
  if edge.durationMillis > 0:
    return edge.durationMillis.float
  edge.weight

proc criticalPath*(graph: FlowGraph): CriticalPath =
  requireValid(graph)
  let order = graph.topologicalOrder()

  var best = initTable[string, float]()
  var previousNode = initTable[string, string]()
  var previousEdge = initTable[string, string]()

  for nodeId in order:
    if not best.hasKey(nodeId):
      best[nodeId] = 0.0
    for edge in graph.outgoingEdges(nodeId):
      let candidate = best[nodeId] + edge.edgeCost()
      if candidate > best.getOrDefault(edge.toNode, -1.0):
        best[edge.toNode] = candidate
        previousNode[edge.toNode] = nodeId
        previousEdge[edge.toNode] = edge.id

  var endNode = ""
  var total = -1.0
  for nodeId, value in best:
    if value > total:
      total = value
      endNode = nodeId

  if endNode.len == 0:
    return CriticalPath()

  var reverseNodes = @[endNode]
  var reverseEdges: seq[string]
  var current = endNode
  while previousNode.hasKey(current):
    reverseEdges.add(previousEdge[current])
    current = previousNode[current]
    reverseNodes.add(current)

  for i in countdown(reverseNodes.high, 0):
    result.nodeIds.add(reverseNodes[i])
  for i in countdown(reverseEdges.high, 0):
    result.edgeIds.add(reverseEdges[i])
  result.totalWeight = total
  result.totalDurationMillis =
    if total < 0:
      0
    else:
      Natural(total)
