import std/unittest

import flowdependency

suite "graph":
  test "builds graph and returns topological order":
    var graph = initFlowGraph("g")
    graph.addNode(flowNode("a"))
    graph.addNode(flowNode("b"))
    graph.addNode(flowNode("c"))
    graph.addEdge(flowEdge("ab", "a", "b"))
    graph.addEdge(flowEdge("bc", "b", "c"))

    check graph.topologicalOrder() == @["a", "b", "c"]
    check graph.sourceNodes()[0].id == "a"
    check graph.terminalNodes()[0].id == "c"
    check not graph.hasCycle()

  test "rejects missing nodes and duplicate ids":
    var graph = initFlowGraph("g")
    graph.addNode(flowNode("a"))
    expect ValueError:
      graph.addNode(flowNode("a"))
    expect ValueError:
      graph.addEdge(flowEdge("bad", "a", "missing"))

  test "detects cycles":
    var graph = initFlowGraph("g")
    graph.nodes.add(flowNode("a"))
    graph.nodes.add(flowNode("b"))
    graph.edges.add(flowEdge("ab", "a", "b"))
    graph.edges.add(flowEdge("ba", "b", "a"))

    check graph.hasCycle()
    expect ValueError:
      discard graph.topologicalOrder()

  test "filters active variants":
    var graph = initFlowGraph("g")
    graph.addNode(flowNode("source"))
    graph.addNode(flowNode("a", variantId = "A"))
    graph.addNode(flowNode("b", variantId = "B"))
    graph.addNode(flowNode("finish"))
    graph.addEdge(flowEdge("source-a", "source", "a", variantId = "A"))
    graph.addEdge(flowEdge("a-finish", "a", "finish", variantId = "A"))
    graph.addEdge(flowEdge("source-b", "source", "b", variantId = "B"))
    graph.addEdge(flowEdge("b-finish", "b", "finish", variantId = "B"))

    let active = graph.activeVariant("A")
    check active.hasNode("a")
    check not active.hasNode("b")
    check active.edges.len == 2
