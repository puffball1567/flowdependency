# FlowDependency

FlowDependency is a small Nim library for modeling dependency graphs used by
workflow tools, batch jobs, delivery systems, and observed business flows.

It is part of the **FlowBrigade Toolkit**.

## Status

Early prototype. The current version provides:

- node and edge graph primitives
- required, optional, all, any, and quorum wait policies
- ready-node decisions with explicit reasons
- topological ordering
- cycle detection
- variant filtering for A/B/C-style flow plans
- JSON import/export
- Mermaid flowchart export
- focused tests for graph validation, readiness, variants, JSON, and diagrams

## Scope

FlowDependency models flow structure. It does not execute tasks, persist run
history, collect metrics, or schedule containers.

Those responsibilities belong to other FlowBrigade Toolkit components:

- FlowLogbook records runs and flow events.
- FlowWorkRunner will execute ready nodes.
- FlowSurveyor will analyze graph and logbook data.
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
```

Mermaid export can be used to render the graph for humans:

```nim
echo graph.toMermaid()
```

## Requirements

FlowDependency only depends on Nim's standard library.

## Development

```bash
nimble test
nimble examples
```

## Intellectual Property Notes

FlowDependency intentionally uses general, well-known graph and dependency
concepts: nodes, edges, topological ordering, cycle detection, and explicit wait
policies. It does not copy code, DSL syntax, or internal behavior from workflow
engines.

See [docs/ip-notes.md](docs/ip-notes.md).
