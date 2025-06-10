// Create modems
// Parameters:
//   $modemCount: Integer representing the total number of modems to create
//   $activeModemProbability: Float between 0 and 1 representing the probability of a modem being active
//   Example: $modemCount = 10000, $activeModemProbability = 0.95
//   Default: $modemCount = 10000, $activeModemProbability = 0.95
WITH coalesce($modemCount, 10000) AS modemCount, coalesce($activeModemProbability, 0.95) AS activeModemProbability
WITH range(1, modemCount) AS modem_ids, activeModemProbability
UNWIND modem_ids AS id
CREATE (m:Modem {id: "M-" + toString(id), status: CASE WHEN rand() < activeModemProbability THEN "ACTIVE" ELSE "DOWN" END}) 