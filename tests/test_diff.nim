import std/unittest

import flowdependency

suite "diff":
  test "reports added, removed, and changed nodes and edges":
    var base = initFlowGraph("g")
    base.addNode(flowNode("a", "A"))
    base.addNode(flowNode("b", "B"))
    base.addEdge(flowEdge("ab", "a", "b"))

    var target = initFlowGraph("g")
    target.addNode(flowNode("a", "A changed"))
    target.addNode(flowNode("c", "C"))
    target.addEdge(flowEdge("ac", "a", "c", durationMillis = 5))

    let diff = diffGraphs(base, target)
    check diff.addedNodes == @["c"]
    check diff.removedNodes == @["b"]
    check diff.changedNodes == @["a"]
    check diff.addedEdges == @["ac"]
    check diff.removedEdges == @["ab"]

  test "compares active variants":
    var graph = initFlowGraph("g")
    graph.addNode(flowNode("source"))
    graph.addNode(flowNode("fast", variantId = "A"))
    graph.addNode(flowNode("safe", variantId = "B"))
    graph.addNode(flowNode("finish"))
    graph.addEdge(flowEdge("source-fast", "source", "fast", variantId = "A"))
    graph.addEdge(flowEdge("fast-finish", "fast", "finish", variantId = "A"))
    graph.addEdge(flowEdge("source-safe", "source", "safe", variantId = "B"))
    graph.addEdge(flowEdge("safe-finish", "safe", "finish", variantId = "B"))

    let comparison = graph.compareVariants("A", "B")
    check comparison.baseVariant == "A"
    check comparison.targetVariant == "B"
    check "safe" in comparison.diff.addedNodes
    check "fast" in comparison.diff.removedNodes
