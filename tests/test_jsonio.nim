import std/unittest

import flowdependency

suite "json io":
  test "graph round trips through json":
    var graph = initFlowGraph("g", variantId = "A")
    graph.addNode(flowNode("a", "A", metadata = @[kv("owner", "team")]))
    graph.addNode(flowNode("b", "B"))
    graph.addEdge(flowEdge("ab", "a", "b", waitPolicy = wpRequired, durationMillis = 42))

    let restored = flowGraphFromJsonString(toJsonString(graph))
    check restored.id == "g"
    check restored.variantId == "A"
    check restored.nodes[0].metadata[0].key == "owner"
    check restored.edges[0].fromNode == "a"
    check restored.edges[0].durationMillis == 42

  test "unknown enum values are rejected":
    expect ValueError:
      discard flowGraphFromJsonString("""{"id":"g","nodes":[{"id":"a","kind":"bad"}],"edges":[]}""")

  test "negative natural fields are rejected":
    expect ValueError:
      discard flowGraphFromJsonString("""{"id":"g","nodes":[{"id":"a"}],"edges":[{"id":"e","fromNode":"a","toNode":"b","quorum":-1}]}""")

  test "array fields reject wrong json types":
    expect ValueError:
      discard flowGraphFromJsonString("""{"id":"g","nodes":{},"edges":[]}""")
