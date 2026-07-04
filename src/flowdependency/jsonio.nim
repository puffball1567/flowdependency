import std/json

import ./types
import ./validation

proc nodeKindFromString*(value: string): NodeKind =
  case value
  of "nkTask": nkTask
  of "nkData": nkData
  of "nkDecision": nkDecision
  of "nkExternal": nkExternal
  of "nkGroup": nkGroup
  else:
    raise newException(ValueError, "unknown NodeKind: " & value)

proc edgeKindFromString*(value: string): EdgeKind =
  case value
  of "ekDependsOn": ekDependsOn
  of "ekProduces": ekProduces
  of "ekConsumes": ekConsumes
  of "ekTriggers": ekTriggers
  of "ekObserves": ekObserves
  else:
    raise newException(ValueError, "unknown EdgeKind: " & value)

proc waitPolicyFromString*(value: string): WaitPolicy =
  case value
  of "wpRequired": wpRequired
  of "wpOptional": wpOptional
  of "wpAll": wpAll
  of "wpAny": wpAny
  of "wpQuorum": wpQuorum
  else:
    raise newException(ValueError, "unknown WaitPolicy: " & value)

proc getStringField(node: JsonNode; key: string; default = ""): string =
  if node.hasKey(key):
    return node[key].getStr()
  default

proc getBoolField(node: JsonNode; key: string; default = false): bool =
  if node.hasKey(key):
    return node[key].getBool()
  default

proc getNaturalField(node: JsonNode; key: string; default = 0): Natural =
  var value = default
  if node.hasKey(key):
    value = node[key].getInt()
  if value < 0:
    raise newException(ValueError, key & " must not be negative")
  Natural(value)

proc getArrayField(node: JsonNode; key: string): seq[JsonNode] =
  if not node.hasKey(key):
    return @[]
  if node[key].kind != JArray:
    raise newException(ValueError, key & " must be an array")
  node[key].getElems()

proc toJson*(value: KeyValue): JsonNode =
  %*{
    "key": value.key,
    "value": value.value
  }

proc keyValueFromJson*(node: JsonNode): KeyValue =
  kv(node.getStringField("key"), node.getStringField("value"))

proc toJson*(value: FlowNode): JsonNode =
  result = newJObject()
  result["id"] = %value.id
  result["label"] = %value.label
  result["kind"] = %($value.kind)
  result["variantId"] = %value.variantId
  result["metadata"] = newJArray()
  for item in value.metadata:
    result["metadata"].add(toJson(item))

proc flowNodeFromJson*(node: JsonNode): FlowNode =
  var metadata: seq[KeyValue]
  for item in node.getArrayField("metadata"):
    metadata.add(keyValueFromJson(item))
  flowNode(
    id = node.getStringField("id"),
    label = node.getStringField("label"),
    kind = nodeKindFromString(node.getStringField("kind", "nkTask")),
    variantId = node.getStringField("variantId"),
    metadata = metadata
  )

proc toJson*(value: FlowEdge): JsonNode =
  result = newJObject()
  result["id"] = %value.id
  result["fromNode"] = %value.fromNode
  result["toNode"] = %value.toNode
  result["kind"] = %($value.kind)
  result["waitPolicy"] = %($value.waitPolicy)
  result["required"] = %value.required
  result["quorum"] = %int(value.quorum)
  result["variantId"] = %value.variantId
  result["metadata"] = newJArray()
  for item in value.metadata:
    result["metadata"].add(toJson(item))

proc flowEdgeFromJson*(node: JsonNode): FlowEdge =
  var metadata: seq[KeyValue]
  for item in node.getArrayField("metadata"):
    metadata.add(keyValueFromJson(item))
  flowEdge(
    id = node.getStringField("id"),
    fromNode = node.getStringField("fromNode"),
    toNode = node.getStringField("toNode"),
    kind = edgeKindFromString(node.getStringField("kind", "ekDependsOn")),
    waitPolicy = waitPolicyFromString(node.getStringField("waitPolicy", "wpRequired")),
    required = node.getBoolField("required", true),
    quorum = node.getNaturalField("quorum"),
    variantId = node.getStringField("variantId"),
    metadata = metadata
  )

proc toJson*(value: FlowGraph): JsonNode =
  result = newJObject()
  result["id"] = %value.id
  result["variantId"] = %value.variantId
  result["nodes"] = newJArray()
  for node in value.nodes:
    result["nodes"].add(toJson(node))
  result["edges"] = newJArray()
  for edge in value.edges:
    result["edges"].add(toJson(edge))

proc flowGraphFromJson*(node: JsonNode): FlowGraph =
  result = initFlowGraph(node.getStringField("id"), node.getStringField("variantId"))
  for item in node.getArrayField("nodes"):
    result.nodes.add(flowNodeFromJson(item))
  for item in node.getArrayField("edges"):
    result.edges.add(flowEdgeFromJson(item))
  requireValid(result)

proc toJsonString*(value: FlowNode): string =
  $toJson(value)

proc toJsonString*(value: FlowEdge): string =
  $toJson(value)

proc toJsonString*(value: FlowGraph): string =
  $toJson(value)

proc flowNodeFromJsonString*(text: string): FlowNode =
  flowNodeFromJson(parseJson(text))

proc flowEdgeFromJsonString*(text: string): FlowEdge =
  flowEdgeFromJson(parseJson(text))

proc flowGraphFromJsonString*(text: string): FlowGraph =
  flowGraphFromJson(parseJson(text))
