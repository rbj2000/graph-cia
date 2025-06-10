// Connect aggregation layers
// Parameters:
//   $layerSizes: List of integers representing the size of each layer
//   Example: [10, 100, 500] for 3 layers with 10, 100, and 500 devices respectively
//   Default: [10, 100, 500]

WITH coalesce($layerSizes, [10, 100, 500]) AS layerSizes
UNWIND range(size(layerSizes)-1, 1, -1) AS layerIndex
WITH layerSizes, layerIndex + 1 AS lowerLayer, layerIndex AS upperLayer

// First ensure each lower layer node has at least one connection to upper layer
MATCH (lower:Aggregation {layer: lowerLayer})
MATCH (upper:Aggregation {layer: upperLayer})
WITH lower, collect(upper) AS upperNodes
WITH lower, upperNodes[toInteger(rand() * size(upperNodes))] AS selectedUpper
CREATE (lower)-[:CONNECTED_TO]->(selectedUpper)

// Then add additional random connections
WITH coalesce($layerSizes, [10, 100, 500]) AS layerSizes
UNWIND range(size(layerSizes)-1, 1, -1) AS layerIndex
WITH layerSizes, layerIndex + 1 AS lowerLayer, layerIndex AS upperLayer

// For each upper-layer node...
MATCH (upper:Aggregation {layer: upperLayer})
// ...pick a random number of lower-layer nodes to connect to
WITH upperLayer, lowerLayer, upper
MATCH (lower:Aggregation {layer: lowerLayer})
WITH upper, collect(lower) AS allLowers
WITH upper, allLowers, toInteger(rand() * 10) + 1 AS numConnections  // Random number between 1 and 10
WITH upper, allLowers[..numConnections] AS selectedLowers
UNWIND selectedLowers AS lower
MERGE (lower)-[:CONNECTED_TO]->(upper)

WITH coalesce($layerSizes, [10, 100, 500]) AS layerSizes
WITH layerSizes[0] AS lowestLayer

// Connect Modems to Layer 1 Aggregation nodes
MATCH (agg:Aggregation {layer: 1})
// ...pick a random number of modems to connect to
WITH agg
MATCH (m:Modem)
WITH agg, collect(m) AS allModems
WITH agg, allModems, toInteger(rand() * 20) + 1 AS numConnections  // Random number between 1 and 20
WITH agg, allModems[..numConnections] AS selectedModems
UNWIND selectedModems AS m
MERGE (m)-[:HAS_SIGNAL]->(agg)
MERGE (m)-[:HAS_POWER]->(agg)