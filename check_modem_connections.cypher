MATCH (m:Modem)-[r]->(a:Aggregation)
RETURN a.layer, type(r), count(*) ORDER BY a.layer 