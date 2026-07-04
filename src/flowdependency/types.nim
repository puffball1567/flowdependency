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
    variantId = ""; metadata: openArray[KeyValue] = []): FlowEdge =
  FlowEdge(
    id: id,
    fromNode: fromNode,
    toNode: toNode,
    kind: kind,
    waitPolicy: waitPolicy,
    required: required,
    quorum: quorum,
    variantId: variantId,
    metadata: @metadata
  )

proc initFlowGraph*(id: string; variantId = ""): FlowGraph =
  FlowGraph(id: id, variantId: variantId)
