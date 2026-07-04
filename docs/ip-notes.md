# IP Notes

FlowDependency is designed around public, general software engineering concepts:

- directed graphs
- nodes and edges
- dependency readiness checks
- topological ordering
- cycle detection
- graph diff
- longest-path analysis in a directed acyclic graph
- optional and required dependencies
- quorum-style readiness
- JSON, Mermaid, and Graphviz DOT export

The implementation is intentionally original and small. It does not copy code,
data structures, DSL syntax, or internal behavior from Nextflow, Airflow,
Argo, Temporal, or other workflow systems.

If a credible concern is raised, the maintainers should review the affected
feature, document the finding, and remove or redesign the feature if needed.
