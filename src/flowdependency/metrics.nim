import std/tables

import ./types

type
  GraphMetrics* = object
    nodeCount*: Natural
    edgeCount*: Natural
    sourceCount*: Natural
    sinkCount*: Natural
    requiredEdgeCount*: Natural
    optionalEdgeCount*: Natural
    maxFanIn*: Natural
    maxFanOut*: Natural
    averageFanIn*: float
    averageFanOut*: float
    density*: float

proc graphMetrics*(graph: FlowGraph): GraphMetrics =
  var degree = initTable[string, tuple[fanIn, fanOut: Natural]]()
  for node in graph.nodes:
    degree[node.id] = (0.Natural, 0.Natural)

  for edge in graph.edges:
    if edge.required:
      result.requiredEdgeCount.inc
    else:
      result.optionalEdgeCount.inc
    if degree.hasKey(edge.fromNode):
      degree[edge.fromNode].fanOut.inc
    if degree.hasKey(edge.toNode):
      degree[edge.toNode].fanIn.inc

  result.nodeCount = Natural(graph.nodes.len)
  result.edgeCount = Natural(graph.edges.len)

  var fanInTotal = 0
  var fanOutTotal = 0
  for node in graph.nodes:
    let item = degree.getOrDefault(node.id, (0.Natural, 0.Natural))
    if item.fanIn == 0:
      result.sourceCount.inc
    if item.fanOut == 0:
      result.sinkCount.inc
    result.maxFanIn = max(result.maxFanIn, item.fanIn)
    result.maxFanOut = max(result.maxFanOut, item.fanOut)
    fanInTotal.inc int(item.fanIn)
    fanOutTotal.inc int(item.fanOut)

  if graph.nodes.len > 0:
    result.averageFanIn = fanInTotal.float / graph.nodes.len.float
    result.averageFanOut = fanOutTotal.float / graph.nodes.len.float

  let possibleEdges = graph.nodes.len * max(0, graph.nodes.len - 1)
  if possibleEdges > 0:
    result.density = graph.edges.len.float / possibleEdges.float
