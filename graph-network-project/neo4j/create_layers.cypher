// Create aggregation layers
// Parameters:
//   $layerSizes: List of integers representing the size of each layer
//   Example: [10, 100, 500] for 3 layers with 10, 100, and 500 devices respectively
//   Default: [10, 100, 500]
WITH coalesce($layerSizes, [10, 100, 500]) AS layerSizes
UNWIND range(0, size(layerSizes)-1) AS layerIndex
WITH layerSizes, layerIndex, layerSizes[layerIndex] AS layerSize
WITH layerSizes, layerIndex + 1 AS layer, layerSize
WITH layerSizes, layer, range(1, layerSize) AS deviceIds
UNWIND deviceIds AS id
CREATE (:Aggregation {id: "L" + toString(layer) + "-" + toString(id), layer: layer, status: "ACTIVE"}) 