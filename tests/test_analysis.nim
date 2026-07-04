import std/unittest

import flowdependency

suite "analysis":
  test "critical path prefers larger duration":
    var graph = initFlowGraph("g")
    graph.addNode(flowNode("start"))
    graph.addNode(flowNode("fast"))
    graph.addNode(flowNode("slow"))
    graph.addNode(flowNode("finish"))
    graph.addEdge(flowEdge("start-fast", "start", "fast", durationMillis = 10))
    graph.addEdge(flowEdge("fast-finish", "fast", "finish", durationMillis = 10))
    graph.addEdge(flowEdge("start-slow", "start", "slow", durationMillis = 5))
    graph.addEdge(flowEdge("slow-finish", "slow", "finish", durationMillis = 100))

    let path = graph.criticalPath()
    check path.nodeIds == @["start", "slow", "finish"]
    check path.edgeIds == @["start-slow", "slow-finish"]
    check path.totalDurationMillis == 105

  test "critical path uses weight when duration is absent":
    var graph = initFlowGraph("g")
    graph.addNode(flowNode("a"))
    graph.addNode(flowNode("b"))
    graph.addNode(flowNode("c"))
    graph.addEdge(flowEdge("ab", "a", "b", weight = 2.5))
    graph.addEdge(flowEdge("bc", "b", "c", weight = 3.0))

    let path = graph.criticalPath()
    check path.edgeIds == @["ab", "bc"]
    check path.totalWeight == 5.5
