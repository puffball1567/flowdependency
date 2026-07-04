import std/sets

import ./graph
import ./types
import ./validation

proc sameMetadata(left, right: seq[KeyValue]): bool =
  if left.len != right.len:
    return false
  for i in 0 ..< left.len:
    if left[i].key != right[i].key or left[i].value != right[i].value:
      return false
  true

proc sameNode(left, right: FlowNode): bool =
  left.label == right.label and
    left.kind == right.kind and
    left.variantId == right.variantId and
    sameMetadata(left.metadata, right.metadata)

proc sameEdge(left, right: FlowEdge): bool =
  left.fromNode == right.fromNode and
    left.toNode == right.toNode and
    left.kind == right.kind and
    left.waitPolicy == right.waitPolicy and
    left.required == right.required and
    left.quorum == right.quorum and
    left.weight == right.weight and
    left.durationMillis == right.durationMillis and
    left.variantId == right.variantId and
    sameMetadata(left.metadata, right.metadata)

proc getEdge(graph: FlowGraph; edgeId: string): FlowEdge =
  for edge in graph.edges:
    if edge.id == edgeId:
      return edge
  raise newException(KeyError, "edge not found: " & edgeId)

proc diffGraphs*(base, target: FlowGraph): GraphDiff =
  requireValid(base)
  requireValid(target)

  var baseNodes = initHashSet[string]()
  var targetNodes = initHashSet[string]()
  for node in base.nodes:
    baseNodes.incl(node.id)
  for node in target.nodes:
    targetNodes.incl(node.id)

  for node in target.nodes:
    if node.id notin baseNodes:
      result.addedNodes.add(node.id)
    elif not sameNode(base.getNode(node.id), node):
      result.changedNodes.add(node.id)

  for node in base.nodes:
    if node.id notin targetNodes:
      result.removedNodes.add(node.id)

  var baseEdges = initHashSet[string]()
  var targetEdges = initHashSet[string]()
  for edge in base.edges:
    baseEdges.incl(edge.id)
  for edge in target.edges:
    targetEdges.incl(edge.id)

  for edge in target.edges:
    if edge.id notin baseEdges:
      result.addedEdges.add(edge.id)
    elif not sameEdge(base.getEdge(edge.id), edge):
      result.changedEdges.add(edge.id)

  for edge in base.edges:
    if edge.id notin targetEdges:
      result.removedEdges.add(edge.id)

proc compareVariants*(graph: FlowGraph; baseVariant, targetVariant: string): VariantComparison =
  let base = graph.activeVariant(baseVariant)
  let target = graph.activeVariant(targetVariant)
  VariantComparison(
    baseVariant: baseVariant,
    targetVariant: targetVariant,
    diff: diffGraphs(base, target)
  )
