import std/sets
import std/strutils

import ./types

type
  ValidationResult* = object
    ok*: bool
    errors*: seq[string]

proc valid*(): ValidationResult =
  ValidationResult(ok: true)

proc invalid*(errors: seq[string]): ValidationResult =
  ValidationResult(ok: false, errors: errors)

proc validate*(node: FlowNode): ValidationResult =
  var errors: seq[string]
  if node.id.len == 0:
    errors.add("node id is required")
  if errors.len == 0:
    return valid()
  invalid(errors)

proc validate*(edge: FlowEdge): ValidationResult =
  var errors: seq[string]
  if edge.id.len == 0:
    errors.add("edge id is required")
  if edge.fromNode.len == 0:
    errors.add("edge fromNode is required")
  if edge.toNode.len == 0:
    errors.add("edge toNode is required")
  if edge.fromNode == edge.toNode:
    errors.add("self edges are not allowed")
  if edge.waitPolicy == wpQuorum and edge.quorum == 0:
    errors.add("quorum edges require quorum > 0")
  if errors.len == 0:
    return valid()
  invalid(errors)

proc validate*(graph: FlowGraph): ValidationResult =
  var errors: seq[string]
  if graph.id.len == 0:
    errors.add("graph id is required")

  var nodeIds = initHashSet[string]()
  for node in graph.nodes:
    let nodeValidation = validate(node)
    for error in nodeValidation.errors:
      errors.add(error)
    if node.id.len > 0 and node.id in nodeIds:
      errors.add("duplicate node id: " & node.id)
    nodeIds.incl(node.id)

  var edgeIds = initHashSet[string]()
  for edge in graph.edges:
    let edgeValidation = validate(edge)
    for error in edgeValidation.errors:
      errors.add(error)
    if edge.id.len > 0 and edge.id in edgeIds:
      errors.add("duplicate edge id: " & edge.id)
    edgeIds.incl(edge.id)
    if edge.fromNode.len > 0 and edge.fromNode notin nodeIds:
      errors.add("edge references missing fromNode: " & edge.fromNode)
    if edge.toNode.len > 0 and edge.toNode notin nodeIds:
      errors.add("edge references missing toNode: " & edge.toNode)

  if errors.len == 0:
    return valid()
  invalid(errors)

proc requireValid*(node: FlowNode) =
  let result = validate(node)
  if not result.ok:
    raise newException(ValueError, result.errors.join("; "))

proc requireValid*(edge: FlowEdge) =
  let result = validate(edge)
  if not result.ok:
    raise newException(ValueError, result.errors.join("; "))

proc requireValid*(graph: FlowGraph) =
  let result = validate(graph)
  if not result.ok:
    raise newException(ValueError, result.errors.join("; "))
