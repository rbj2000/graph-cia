// Configuration parameters with default values
WITH 
    CASE 
        WHEN $layer IS NOT NULL THEN $layer 
        WHEN $FAILURE_LAYER IS NOT NULL THEN $FAILURE_LAYER 
        ELSE 2 
    END AS layer,
    CASE 
        WHEN $numberOfNodes IS NOT NULL THEN $numberOfNodes 
        WHEN $FAILURE_NODE_COUNT IS NOT NULL THEN $FAILURE_NODE_COUNT 
        ELSE 3 
    END AS numberOfNodes,
    CASE 
        WHEN $failureType IS NOT NULL THEN $failureType 
        WHEN $FAILURE_TYPE IS NOT NULL THEN $FAILURE_TYPE 
        ELSE "POWER" 
    END AS failureType,
    CASE 
        WHEN $propagateToModems IS NOT NULL THEN $propagateToModems 
        WHEN $PROPAGATE_TO_MODEMS IS NOT NULL THEN $PROPAGATE_TO_MODEMS 
        ELSE true 
    END AS propagateToModems,
    CASE 
        WHEN $randomModemFailures IS NOT NULL THEN $randomModemFailures 
        WHEN $RANDOM_MODEM_FAILURES IS NOT NULL THEN $RANDOM_MODEM_FAILURES 
        ELSE 100 
    END AS randomModemFailures

// Find aggregation nodes in the specified layer
MATCH (agg:Aggregation {layer: layer})
WITH collect(agg) AS allAggs, layer, failureType, propagateToModems, randomModemFailures, numberOfNodes
WITH [agg IN allAggs[0..numberOfNodes] | agg] AS selectedAggs, layer, failureType, propagateToModems, randomModemFailures
UNWIND selectedAggs AS agg
SET agg.status = "FAILED"
WITH layer, failureType, propagateToModems, randomModemFailures, count(agg) AS failedNodes

// If we should propagate to modems
WITH layer, failureType, randomModemFailures, CASE WHEN propagateToModems THEN 1 ELSE 0 END AS shouldPropagate, failedNodes
CALL {
    WITH layer, failureType, shouldPropagate
    MATCH (agg:Aggregation {layer: layer, status: "FAILED"})
    MATCH (m:Modem)
    WHERE shouldPropagate = 1 AND (
        (failureType = "POWER" AND (m)-[:HAS_POWER]->(agg))
        OR (failureType = "SIGNAL" AND (m)-[:HAS_SIGNAL]->(agg))
    )
    SET m.status = "DOWN"
    RETURN count(m) AS affectedModems
}

// Add random modem failures
WITH layer, failureType, randomModemFailures, failedNodes, affectedModems
CALL {
    WITH randomModemFailures
    MATCH (m:Modem)
    WHERE m.status = "ACTIVE"
    WITH collect(m) AS allModems, randomModemFailures
    WITH [m IN allModems[0..randomModemFailures] | m] AS selectedModems
    UNWIND selectedModems AS m
    SET m.status = "DOWN"
    RETURN count(m) AS randomFailures
}

// Return summary of the failure simulation
RETURN 
    layer AS failureLayer,
    failedNodes AS failedNodes,
    failureType AS failureType,
    affectedModems AS affectedModems,
    randomFailures AS randomModemFailures;

// Example queries to verify the changes:
// 1. Check failed aggregation nodes:
// MATCH (agg:Aggregation {status: "FAILED"}) RETURN agg.id, agg.layer;
//
// 2. Check affected modems:
// MATCH (m:Modem {status: "DOWN"}) RETURN count(m) AS downModems;
//
// 3. Check which modems are down due to power vs signal vs random:
// MATCH (m:Modem {status: "DOWN"})
// OPTIONAL MATCH (m)-[:HAS_POWER]->(p:Aggregation {status: "FAILED"})
// OPTIONAL MATCH (m)-[:HAS_SIGNAL]->(s:Aggregation {status: "FAILED"})
// RETURN 
//     m.id, 
//     CASE WHEN p IS NOT NULL THEN p.id ELSE NULL END AS powerFailure,
//     CASE WHEN s IS NOT NULL THEN s.id ELSE NULL END AS signalFailure,
//     CASE WHEN p IS NULL AND s IS NULL THEN 'RANDOM' ELSE NULL END AS failureType; 