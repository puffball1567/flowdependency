# Design

FlowDependency models the structure of a flow.

## Goals

- Represent nodes and edges as explicit, inspectable values.
- Model required, optional, all, any, and quorum wait policies.
- Decide whether a node is ready from external status information.
- Detect invalid graphs and cycles early.
- Support variant-specific graph views for A/B/C plan comparison.
- Export JSON for machines and Mermaid for humans.

## Non-goals

- Task execution
- Retries, timeouts, rate limits, or locks
- Persistent run records
- Metrics collection
- Container or cloud scheduler integration
- A workflow DSL

Those can be built above FlowDependency.

## Core Model

```text
FlowGraph
  nodes: FlowNode[]
  edges: FlowEdge[]

FlowEdge
  fromNode
  toNode
  waitPolicy
  required
  quorum
  variantId
```

Ready decisions are intentionally computed from a caller-provided status table.
That keeps FlowDependency independent from any runtime, logbook, database, or
workflow engine.

## Wait Policies

- `wpRequired`: the predecessor must succeed or be skipped.
- `wpOptional`: the predecessor is recorded as waiting evidence but does not
  block readiness.
- `wpAll`: every matching required predecessor must be satisfied.
- `wpAny`: at least one matching predecessor must be satisfied.
- `wpQuorum`: at least `quorum` matching predecessors must be satisfied.

## Variants

Nodes and edges can carry `variantId`. Empty `variantId` means shared across
variants. `activeVariant("A")` returns a graph containing shared items and items
specific to variant `A`.

## Relationship To FlowLogbook

FlowDependency describes what should connect to what. FlowLogbook records what
happened. FlowSurveyor can later combine both:

```text
FlowDependency graph + FlowLogbook events -> critical path and bottleneck analysis
```
