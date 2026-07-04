import std/tables
import std/unittest

import flowdependency

suite "ready":
  test "source node is ready":
    var graph = initFlowGraph("g")
    graph.addNode(flowNode("a"))

    let decision = graph.readyDecision("a", initTable[string, NodeStatus]())
    check decision.ready
    check decision.reason == "source node"

  test "required dependency waits until succeeded":
    var graph = initFlowGraph("g")
    graph.addNode(flowNode("a"))
    graph.addNode(flowNode("b"))
    graph.addEdge(flowEdge("ab", "a", "b"))

    var statuses = initTable[string, NodeStatus]()
    check not graph.readyDecision("b", statuses).ready

    statuses["a"] = nsSucceeded
    check graph.readyDecision("b", statuses).ready

  test "optional dependency does not block readiness":
    var graph = initFlowGraph("g")
    graph.addNode(flowNode("a"))
    graph.addNode(flowNode("b"))
    graph.addEdge(flowEdge("ab", "a", "b", waitPolicy = wpOptional, required = false))

    let decision = graph.readyDecision("b", initTable[string, NodeStatus]())
    check decision.ready
    check decision.waitingOn == @["a"]

  test "any dependency needs one succeeded predecessor":
    var graph = initFlowGraph("g")
    graph.addNode(flowNode("a"))
    graph.addNode(flowNode("b"))
    graph.addNode(flowNode("c"))
    graph.addEdge(flowEdge("ac", "a", "c", waitPolicy = wpAny))
    graph.addEdge(flowEdge("bc", "b", "c", waitPolicy = wpAny))

    var statuses = initTable[string, NodeStatus]()
    check not graph.readyDecision("c", statuses).ready
    statuses["b"] = nsSucceeded
    check graph.readyDecision("c", statuses).ready

  test "quorum dependency requires enough succeeded predecessors":
    var graph = initFlowGraph("g")
    graph.addNode(flowNode("a"))
    graph.addNode(flowNode("b"))
    graph.addNode(flowNode("c"))
    graph.addEdge(flowEdge("ac", "a", "c", waitPolicy = wpQuorum, quorum = 2))
    graph.addEdge(flowEdge("bc", "b", "c", waitPolicy = wpQuorum, quorum = 2))

    var statuses = initTable[string, NodeStatus]()
    statuses["a"] = nsSucceeded
    check not graph.readyDecision("c", statuses).ready
    statuses["b"] = nsSucceeded
    check graph.readyDecision("c", statuses).ready

  test "readyNodes skips completed nodes":
    var graph = initFlowGraph("g")
    graph.addNode(flowNode("a"))
    graph.addNode(flowNode("b"))
    graph.addEdge(flowEdge("ab", "a", "b"))

    var statuses = initTable[string, NodeStatus]()
    statuses["a"] = nsSucceeded
    check graph.readyNodes(statuses) == @["b"]
