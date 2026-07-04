import std/strutils

import ./types
import ./validation

proc q(value: string): string =
  "\"" & value.replace("\"", "\\\"") & "\""

proc label(edge: FlowEdge): string =
  var parts = @[$edge.kind, $edge.waitPolicy]
  if edge.durationMillis > 0:
    parts.add($edge.durationMillis & "ms")
  elif edge.weight != 1.0:
    parts.add("w=" & $edge.weight)
  parts.join(", ")

proc toDot*(graph: FlowGraph): string =
  requireValid(graph)
  result = "digraph " & q(graph.id) & " {\n"
  result.add("  rankdir=LR;\n")
  for node in graph.nodes:
    result.add("  " & q(node.id) & " [label=" & q(node.label) & "];\n")
  for edge in graph.edges:
    result.add("  " & q(edge.fromNode) & " -> " & q(edge.toNode) &
      " [label=" & q(edge.label) & "];\n")
  result.add("}\n")
