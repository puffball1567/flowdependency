import std/tables

import ./types
import ./validation

proc addNode*(graph: var FlowGraph; node: FlowNode) =
  requireValid(node)
  for existing in graph.nodes:
    if existing.id == node.id:
      raise newException(ValueError, "duplicate node id: " & node.id)
  graph.nodes.add(node)

proc addEdge*(graph: var FlowGraph; edge: FlowEdge) =
  requireValid(edge)
  for existing in graph.edges:
    if existing.id == edge.id:
      raise newException(ValueError, "duplicate edge id: " & edge.id)
  graph.edges.add(edge)
  requireValid(graph)

proc hasNode*(graph: FlowGraph; nodeId: string): bool =
  for node in graph.nodes:
    if node.id == nodeId:
      return true

proc getNode*(graph: FlowGraph; nodeId: string): FlowNode =
  for node in graph.nodes:
    if node.id == nodeId:
      return node
  raise newException(KeyError, "node not found: " & nodeId)

proc incomingEdges*(graph: FlowGraph; nodeId: string): seq[FlowEdge] =
  for edge in graph.edges:
    if edge.toNode == nodeId:
      result.add(edge)

proc outgoingEdges*(graph: FlowGraph; nodeId: string): seq[FlowEdge] =
  for edge in graph.edges:
    if edge.fromNode == nodeId:
      result.add(edge)

proc sourceNodes*(graph: FlowGraph): seq[FlowNode] =
  for node in graph.nodes:
    if graph.incomingEdges(node.id).len == 0:
      result.add(node)

proc terminalNodes*(graph: FlowGraph): seq[FlowNode] =
  for node in graph.nodes:
    if graph.outgoingEdges(node.id).len == 0:
      result.add(node)

proc adjacency*(graph: FlowGraph): Table[string, seq[string]] =
  result = initTable[string, seq[string]]()
  for node in graph.nodes:
    result[node.id] = @[]
  for edge in graph.edges:
    result.mgetOrPut(edge.fromNode, @[]).add(edge.toNode)

proc topologicalOrder*(graph: FlowGraph): seq[string] =
  requireValid(graph)

  var indegree = initTable[string, int]()
  var outgoing = initTable[string, seq[string]]()
  for node in graph.nodes:
    indegree[node.id] = 0
    outgoing[node.id] = @[]
  for edge in graph.edges:
    indegree[edge.toNode] = indegree.getOrDefault(edge.toNode) + 1
    outgoing.mgetOrPut(edge.fromNode, @[]).add(edge.toNode)

  var ready: seq[string]
  for node in graph.nodes:
    if indegree[node.id] == 0:
      ready.add(node.id)

  while ready.len > 0:
    let nodeId = ready[0]
    ready.delete(0)
    result.add(nodeId)
    for next in outgoing.getOrDefault(nodeId):
      indegree[next] = indegree[next] - 1
      if indegree[next] == 0:
        ready.add(next)

  if result.len != graph.nodes.len:
    raise newException(ValueError, "cycle detected")

proc hasCycle*(graph: FlowGraph): bool =
  try:
    discard graph.topologicalOrder()
    false
  except ValueError:
    true

proc activeVariant*(graph: FlowGraph; variantId: string): FlowGraph =
  result = initFlowGraph(graph.id, variantId)
  for node in graph.nodes:
    if node.variantId.len == 0 or node.variantId == variantId:
      result.nodes.add(node)
  for edge in graph.edges:
    if edge.variantId.len == 0 or edge.variantId == variantId:
      result.edges.add(edge)
  requireValid(result)
