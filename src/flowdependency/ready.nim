import std/tables

import ./graph
import ./types
import ./validation

proc edgeSatisfied(edge: FlowEdge; statuses: Table[string, NodeStatus]): bool =
  let status = statuses.getOrDefault(edge.fromNode, nsUnknown)
  case status
  of nsSucceeded, nsSkipped:
    true
  else:
    false

proc edgeFailed(edge: FlowEdge; statuses: Table[string, NodeStatus]): bool =
  statuses.getOrDefault(edge.fromNode, nsUnknown) == nsFailed

proc readyDecision*(graph: FlowGraph; nodeId: string;
    statuses: Table[string, NodeStatus]): ReadyDecision =
  requireValid(graph)
  discard graph.getNode(nodeId)

  let incoming = graph.incomingEdges(nodeId)
  if incoming.len == 0:
    return ReadyDecision(nodeId: nodeId, ready: true, reason: "source node")

  var requiredTotal = 0
  var requiredSatisfied = 0
  var optionalWaiting: seq[string]
  var requiredWaiting: seq[string]
  var quorumSatisfied = 0
  var quorumRequired = 0
  var hasQuorum = false
  var anySatisfied = false
  var hasAny = false

  for edge in incoming:
    if edge.waitPolicy == wpOptional or not edge.required:
      if not edge.edgeSatisfied(statuses) and not edge.edgeFailed(statuses):
        optionalWaiting.add(edge.fromNode)
      continue

    case edge.waitPolicy
    of wpRequired, wpAll:
      requiredTotal.inc
      if edge.edgeSatisfied(statuses):
        requiredSatisfied.inc
      else:
        requiredWaiting.add(edge.fromNode)
    of wpAny:
      hasAny = true
      if edge.edgeSatisfied(statuses):
        anySatisfied = true
      else:
        requiredWaiting.add(edge.fromNode)
    of wpQuorum:
      hasQuorum = true
      quorumRequired = max(quorumRequired, int(edge.quorum))
      if edge.edgeSatisfied(statuses):
        quorumSatisfied.inc
      else:
        requiredWaiting.add(edge.fromNode)
    of wpOptional:
      discard

  if requiredTotal > 0 and requiredSatisfied < requiredTotal:
    return ReadyDecision(
      nodeId: nodeId,
      ready: false,
      reason: "required dependencies are not satisfied",
      waitingOn: requiredWaiting
    )

  if hasAny and not anySatisfied:
    return ReadyDecision(
      nodeId: nodeId,
      ready: false,
      reason: "waiting for any dependency",
      waitingOn: requiredWaiting
    )

  if hasQuorum and quorumSatisfied < quorumRequired:
    return ReadyDecision(
      nodeId: nodeId,
      ready: false,
      reason: "waiting for quorum",
      waitingOn: requiredWaiting
    )

  ReadyDecision(
    nodeId: nodeId,
    ready: true,
    reason: "dependencies are satisfied",
    waitingOn: optionalWaiting
  )

proc readyNodes*(graph: FlowGraph; statuses: Table[string, NodeStatus]): seq[string] =
  requireValid(graph)
  for node in graph.nodes:
    let status = statuses.getOrDefault(node.id, nsPending)
    if status != nsPending and status != nsUnknown:
      continue
    let decision = graph.readyDecision(node.id, statuses)
    if decision.ready:
      result.add(node.id)
