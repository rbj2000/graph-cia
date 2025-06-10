// Clean database and create network
MATCH (n) DETACH DELETE n
WITH $layerSizes AS layerSizes
UNWIND range(0, size(layerSizes)-1) AS layerIndex
WITH layerSizes, layerIndex, layerSizes[layerIndex] AS layerSize
WITH layerSizes, layerIndex + 1 AS layer, layerSize
WITH layerSizes, layer, range(1, layerSize) AS deviceIds
UNWIND deviceIds AS id
CREATE (:Aggregation {id: "L" + toString(layer) + "-" + toString(id), layer: layer, status: "ACTIVE"})
WITH layerSizes
UNWIND range(size(layerSizes)-1, 1, -1) AS layerIndex
WITH layerSizes, layerIndex, layerSizes[layerIndex] AS lowerLayerSize, layerSizes[layerIndex-1] AS upperLayerSize
WITH layerSizes, layerIndex + 1 AS lowerLayer, layerIndex AS upperLayer
MATCH (lower:Aggregation {layer: lowerLayer})
MATCH (upper:Aggregation {layer: upperLayer})
WITH layerSizes, lower, upper ORDER BY rand() LIMIT 1
CREATE (lower)-[:CONNECTED_TO]->(upper)
WITH layerSizes, $modemCount AS modemCount, $activeModemProbability AS activeModemProbability
WITH layerSizes, range(1, modemCount) AS modem_ids, activeModemProbability
UNWIND modem_ids AS id
CREATE (m:Modem {id: "M-" + toString(id), status: CASE WHEN rand() < activeModemProbability THEN "ACTIVE" ELSE "DOWN" END})
WITH layerSizes, size(layerSizes) AS bottomLayer
MATCH (m:Modem)
MATCH (bottomAgg:Aggregation {layer: bottomLayer})
WITH m, bottomAgg ORDER BY rand() LIMIT 1
CREATE (m)-[:HAS_SIGNAL]->(bottomAgg)
WITH m, bottomLayer
MATCH (bottomAgg:Aggregation {layer: bottomLayer})
WITH m, bottomAgg ORDER BY rand() LIMIT 1
CREATE (m)-[:HAS_POWER]->(bottomAgg) 