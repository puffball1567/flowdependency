type
  NodeKind* = enum
    nkTask,
    nkData,
    nkDecision,
    nkExternal,
    nkGroup

  EdgeKind* = enum
    ekDependsOn,
    ekProduces,
    ekConsumes,
    ekTriggers,
    ekObserves

  WaitPolicy* = enum
    wpRequired,
    wpOptional,
    wpAll,
    wpAny,
    wpQuorum

  NodeStatus* = enum
    nsUnknown,
    nsPending,
    nsRunning,
    nsSucceeded,
    nsFailed,
    nsSkipped

  KeyValue* = object
    key*: string
    value*: string

  FlowNode* = object
    id*: string
    label*: string
    kind*: NodeKind
    variantId*: string
    metadata*: seq[KeyValue]

  FlowEdge* = object
    id*: string
    fromNode*: string
    toNode*: string
    kind*: EdgeKind
    waitPolicy*: WaitPolicy
    required*: bool
    quorum*: Natural
    weight*: float
    durationMillis*: Natural
    variantId*: string
    metadata*: seq[KeyValue]

  FlowGraph* = object
    id*: string
    variantId*: string
    nodes*: seq[FlowNode]
    edges*: seq[FlowEdge]

  ReadyDecision* = object
    nodeId*: string
    ready*: bool
    reason*: string
    waitingOn*: seq[string]

  GraphDiff* = object
    addedNodes*: seq[string]
    removedNodes*: seq[string]
    changedNodes*: seq[string]
    addedEdges*: seq[string]
    removedEdges*: seq[string]
    changedEdges*: seq[string]

  VariantComparison* = object
    baseVariant*: string
    targetVariant*: string
    diff*: GraphDiff

  CriticalPath* = object
    nodeIds*: seq[string]
    edgeIds*: seq[string]
    totalWeight*: float
    totalDurationMillis*: Natural

proc kv*(key, value: string): KeyValue =
  KeyValue(key: key, value: value)

proc flowNode*(id: string; label = ""; kind = nkTask; variantId = "";
    metadata: openArray[KeyValue] = []): FlowNode =
  FlowNode(
    id: id,
    label: label,
    kind: kind,
    variantId: variantId,
    metadata: @metadata
  )

proc flowEdge*(id, fromNode, toNode: string; kind = ekDependsOn;
    waitPolicy = wpRequired; required = true; quorum: Natural = 0;
    weight = 1.0; durationMillis: Natural = 0;
    variantId = ""; metadata: openArray[KeyValue] = []): FlowEdge =
  FlowEdge(
    id: id,
    fromNode: fromNode,
    toNode: toNode,
    kind: kind,
    waitPolicy: waitPolicy,
    required: required,
    quorum: quorum,
    weight: weight,
    durationMillis: durationMillis,
    variantId: variantId,
    metadata: @metadata
  )

proc initFlowGraph*(id: string; variantId = ""): FlowGraph =
  FlowGraph(id: id, variantId: variantId)
