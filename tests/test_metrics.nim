import unittest

import flowdependency

suite "metrics":
  test "summarizes graph structure":
    var graph = initFlowGraph("pipeline")
    graph.nodes.add(flowNode("extract"))
    graph.nodes.add(flowNode("transform-a"))
    graph.nodes.add(flowNode("transform-b"))
    graph.nodes.add(flowNode("publish"))
    graph.edges.add(flowEdge("extract-a", "extract", "transform-a"))
    graph.edges.add(flowEdge("extract-b", "extract", "transform-b"))
    graph.edges.add(flowEdge("a-publish", "transform-a", "publish"))
    graph.edges.add(flowEdge("b-publish", "transform-b", "publish", required = false))

    let metrics = graph.graphMetrics()
    check metrics.nodeCount == 4
    check metrics.edgeCount == 4
    check metrics.sourceCount == 1
    check metrics.sinkCount == 1
    check metrics.requiredEdgeCount == 3
    check metrics.optionalEdgeCount == 1
    check metrics.maxFanIn == 2
    check metrics.maxFanOut == 2
    check metrics.averageFanIn == 1.0
    check metrics.averageFanOut == 1.0
    check metrics.density > 0.3
