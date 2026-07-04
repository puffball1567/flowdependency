import std/strutils
import std/unittest

import flowdependency

suite "dot":
  test "exports graphviz dot":
    var graph = initFlowGraph("g")
    graph.addNode(flowNode("a", "A"))
    graph.addNode(flowNode("b", "B"))
    graph.addEdge(flowEdge("ab", "a", "b", durationMillis = 20))

    let text = graph.toDot()
    check text.contains("digraph")
    check text.contains("\"a\" -> \"b\"")
    check text.contains("20ms")
