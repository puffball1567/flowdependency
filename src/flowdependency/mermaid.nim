import std/strutils

import ./types
import ./validation

proc escapeLabel(value: string): string =
  value.multiReplace(("[", "("), ("]", ")"), ("\"", "'"))

proc nodeLabel(node: FlowNode): string =
  if node.label.len == 0:
    node.id.escapeLabel()
  else:
    node.label.escapeLabel()

proc edgeLabel(edge: FlowEdge): string =
  var parts: seq[string]
  parts.add($edge.kind)
  parts.add($edge.waitPolicy)
  if not edge.required:
    parts.add("optional")
  if edge.waitPolicy == wpQuorum:
    parts.add("quorum " & $edge.quorum)
  parts.join(", ")

proc toMermaid*(graph: FlowGraph; direction = "TD"): string =
  requireValid(graph)
  result = "flowchart " & direction & "\n"
  for node in graph.nodes:
    result.add("  " & node.id & "[\"" & node.nodeLabel & "\"]\n")
  for edge in graph.edges:
    result.add("  " & edge.fromNode & " -->|\"" & edge.edgeLabel.escapeLabel & "\"| " &
      edge.toNode & "\n")
