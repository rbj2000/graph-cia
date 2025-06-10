// Create locations and place aggregation devices
// Parameters:
//   $layerSizes: List of integers representing the size of each layer
//   Example: [10, 100, 500] for 3 layers with 10, 100, and 500 devices respectively
//   Default: [10, 100, 500]

// First, create locations for L3 devices (one location per L3 device)
WITH coalesce($layerSizes, [10, 100, 500]) AS layerSizes
WITH layerSizes, layerSizes[2] AS l3Count
WITH range(1, l3Count) AS locationIds
UNWIND locationIds AS id
CREATE (l:Location {
    id: "LOC-" + toString(id),
    address: "Street " + toString(id) + ", City " + toString(id % 10 + 1),
    zipCode: toString(10000 + id),
    country: "Country " + toString(id % 5 + 1)
})
WITH collect(l) AS locations

// Match all L3 devices and assign them to locations
MATCH (l3:Aggregation {layer: 3})
WITH l3, locations[toInteger(rand() * size(locations))] AS location
CREATE (l3)-[:LOCATED_AT]->(location)
WITH collect(location) AS usedLocations

// For each L3 location, create 1-3 L2 locations
UNWIND usedLocations AS l3Location
WITH l3Location, toInteger(rand() * 2) + 1 AS l2Count
WITH l3Location, range(1, l2Count) AS l2Ids
UNWIND l2Ids AS l2Id
CREATE (l2:Location {
    id: "LOC-" + l3Location.id + "-L2-" + toString(l2Id),
    address: l3Location.address + ", Building " + toString(l2Id),
    zipCode: l3Location.zipCode,
    country: l3Location.country
})
WITH collect(l2) AS l2Locations

// Match L2 devices and assign them to L2 locations
MATCH (l2:Aggregation {layer: 2})
WITH l2, l2Locations[toInteger(rand() * size(l2Locations))] AS location
CREATE (l2)-[:LOCATED_AT]->(location)
WITH collect(location) AS usedL2Locations

// For each L2 location, create 1-10 L1 locations
UNWIND usedL2Locations AS l2Location
WITH l2Location, toInteger(rand() * 9) + 1 AS l1Count
WITH l2Location, range(1, l1Count) AS l1Ids
UNWIND l1Ids AS l1Id
CREATE (l1:Location {
    id: "LOC-" + l2Location.id + "-L1-" + toString(l1Id),
    address: l2Location.address + ", Floor " + toString(l1Id),
    zipCode: l2Location.zipCode,
    country: l2Location.country
})
WITH collect(l1) AS l1Locations

// Match L1 devices and assign them to L1 locations
MATCH (l1:Aggregation {layer: 1})
WITH l1, l1Locations[toInteger(rand() * size(l1Locations))] AS location
CREATE (l1)-[:LOCATED_AT]->(location) 