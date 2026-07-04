import std/strutils
import std/unittest

import flowdependency

suite "mermaid":
  test "exports flowchart":
    var graph = initFlowGraph("g")
    graph.addNode(flowNode("a", "Start"))
    graph.addNode(flowNode("b", "Finish"))
    graph.addEdge(flowEdge("ab", "a", "b"))

    let text = graph.toMermaid()
    check text.contains("flowchart TD")
    check text.contains("a[\"Start\"]")
    check text.contains("a -->")
