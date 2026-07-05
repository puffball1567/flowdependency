# FlowDependency

FlowDependency is a small Nim library for modeling dependency graphs used by
workflow tools, batch jobs, delivery systems, and observed business flows.

It is part of the **FlowBrigade Toolkit**.

## Status

FlowDependency v0.2.0 is focused on dependency graph modeling and human-readable
graph export. Within that scope, the current version provides:

- node and edge graph primitives
- required, optional, all, any, and quorum wait policies
- ready-node decisions with explicit reasons
- topological ordering
- cycle detection
- graph diff
- variant comparison
- weighted critical path analysis
- variant filtering for A/B/C-style flow plans
- JSON import/export
- Mermaid flowchart export
- Graphviz DOT export
- basic large-graph benchmark
- focused tests for graph validation, readiness, variants, JSON, and diagrams

## Scope

FlowDependency models flow structure. It does not execute tasks, persist run
history, collect metrics, or schedule containers.

Those responsibilities belong to other FlowBrigade Toolkit components:

- FlowLogbook records runs and flow events.
- FlowWorkRunner executes ready nodes.
- FlowSurveyor analyzes graph and logbook data.
- FlowCaptain will coordinate replaceable components.

## Example

```nim
import std/tables
import flowdependency

var graph = initFlowGraph("daily-report")
graph.addNode(flowNode("extract", "Extract"))
graph.addNode(flowNode("transform", "Transform"))
graph.addNode(flowNode("publish", "Publish"))
graph.addEdge(flowEdge("extract-transform", "extract", "transform"))
graph.addEdge(flowEdge("transform-publish", "transform", "publish"))

doAssert graph.topologicalOrder() == @["extract", "transform", "publish"]

var statuses = initTable[string, NodeStatus]()
statuses["extract"] = nsSucceeded

let decision = graph.readyDecision("transform", statuses)
doAssert decision.ready
```

Optional dependencies can be tracked without blocking readiness:

```nim
graph.addEdge(flowEdge(
  id = "optional-input",
  fromNode = "enrich",
  toNode = "publish",
  waitPolicy = wpOptional,
  required = false
))
```

Variants let callers compare alternative flow plans:

```nim
let variantA = graph.activeVariant("A")
let comparison = graph.compareVariants("A", "B")
```

Critical path analysis can use edge durations or weights:

```nim
graph.addEdge(flowEdge("extract-load", "extract", "load", durationMillis = 320))
let path = graph.criticalPath()
```

Mermaid and DOT export can be used to render the graph for humans:

```nim
echo graph.toMermaid()
echo graph.toDot()
```

## Requirements

FlowDependency only depends on Nim's standard library.

## Development

```bash
nimble test
nimble examples
nimble bench
```

## Intellectual Property Notes

FlowDependency intentionally uses general, well-known graph and dependency
concepts: nodes, edges, topological ordering, cycle detection, and explicit wait
policies. It does not copy code, DSL syntax, or internal behavior from workflow
engines.

See [docs/ip-notes.md](docs/ip-notes.md).
