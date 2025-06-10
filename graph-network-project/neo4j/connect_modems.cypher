// Connect modems to L3 (lowest) layer with random distribution
// Parameters:
//   $layerSizes: List of integers representing the size of each layer
//   Example: [10, 100, 500]
//   Default: [10, 100, 500]

WITH coalesce($layerSizes, [10, 100, 500]) AS layerSizes
WITH layerSizes[size(layerSizes) - 1] AS bottomLayer

// First ensure each modem has at least one connection to an L3 node
MATCH (m:Modem)
MATCH (bottomAgg:Aggregation {layer: bottomLayer})
WITH m, collect(bottomAgg) AS allAggs
WITH m, allAggs[toInteger(rand() * size(allAggs))] AS selectedAgg
CREATE (m)-[:HAS_SIGNAL]->(selectedAgg)
CREATE (m)-[:HAS_POWER]->(selectedAgg)

// Then add additional random connections
WITH coalesce($layerSizes, [10, 100, 500]) AS layerSizes
WITH layerSizes[size(layerSizes) - 1] AS bottomLayer

// For each L3 Aggregation node
MATCH (bottomAgg:Aggregation {layer: bottomLayer})
// ...pick a random number of modems to connect to
WITH bottomAgg, bottomLayer
MATCH (m:Modem)
WITH bottomAgg, collect(m) AS allModems
WITH bottomAgg, allModems, toInteger(rand() * 20) + 1 AS numConnections  // Random number between 1 and 20
WITH bottomAgg, allModems[..numConnections] AS selectedModems
UNWIND selectedModems AS m
MERGE (m)-[:HAS_SIGNAL]->(bottomAgg)
MERGE (m)-[:HAS_POWER]->(bottomAgg)