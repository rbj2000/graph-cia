# 📚 Project: Build and Populate a Graph Database of Modems and Aggregation Layers (with Docker + Neo4j)

## 🚀 Project Goal

- Run a **Neo4j** graph database in a **Docker** container.
- **Populate** the database with:
  - **10,000 modems**.
  - **3 layers** of aggregation devices.
  - Each modem connected by:
    - `HAS_SIGNAL`
    - `HAS_POWER`
- Simulate a **network tree** structure for testing queries, diagnostics, and performance.

---

## 🛠 Prerequisites

- Docker installed: [Install Docker](https://docs.docker.com/get-docker/)
- Docker Compose installed (optional, but useful)

---

## 💂 Project Structure

```
/graph-network-project
│
├── docker-compose.yml
├── populate.cypher
└── README.md
```

---

## 📦 Step 1: Setup Docker with Neo4j

Create a file called `docker-compose.yml`:

```yaml
version: '3.8'

services:
  neo4j:
    image: neo4j:5.15
    container_name: graph-network-neo4j
    ports:
      - "7474:7474"   # Neo4j Browser
      - "7687:7687"   # Bolt protocol
    environment:
      - NEO4J_AUTH=neo4j/password123
      - NEO4J_dbms_security_procedures_unrestricted=apoc.*
      - NEO4J_PLUGINS=["apoc"]
    volumes:
      - ./data:/data
      - ./plugins:/plugins
```

> This will expose the Neo4j browser at [http://localhost:7474](http://localhost:7474)  
> Login with `neo4j / password123`.

---

## 🛠 Step 2: Create the Population Script

Create a file called `populate.cypher`:

```cypher
// Clean database
MATCH (n) DETACH DELETE n;

// 1. Create Layer 1 (Top-level Aggregators)
WITH range(1, 10) AS layer1_ids
UNWIND layer1_ids AS id
CREATE (:Aggregation {id: "L1-" + id, layer: 1, status: "ACTIVE"});

// 2. Create Layer 2 (Middle Aggregators) and connect to Layer 1
WITH range(1, 100) AS layer2_ids
UNWIND layer2_ids AS id
CREATE (a2:Aggregation {id: "L2-" + id, layer: 2, status: "ACTIVE"});

WITH a2
MATCH (a1:Aggregation {layer: 1})
WITH a2, a1 ORDER BY rand() LIMIT 1
CREATE (a2)-[:CONNECTED_TO]->(a1);

// 3. Create Layer 3 (Access Aggregators) and connect to Layer 2
WITH range(1, 500) AS layer3_ids
UNWIND layer3_ids AS id
CREATE (a3:Aggregation {id: "L3-" + id, layer: 3, status: "ACTIVE"});

WITH a3
MATCH (a2:Aggregation {layer: 2})
WITH a3, a2 ORDER BY rand() LIMIT 1
CREATE (a3)-[:CONNECTED_TO]->(a2);

// 4. Create Modems and connect by HAS_SIGNAL and HAS_POWER
WITH range(1, 10000) AS modem_ids
UNWIND modem_ids AS id
CREATE (m:Modem {id: "M-" + id, status: CASE rand() < 0.95 THEN "ACTIVE" ELSE "DOWN" END});

WITH m
MATCH (signalAgg:Aggregation {layer: 3})
WITH m, signalAgg ORDER BY rand() LIMIT 1
CREATE (m)-[:HAS_SIGNAL]->(signalAgg);

WITH m
MATCH (powerAgg:Aggregation {layer: 3})
WITH m, powerAgg ORDER BY rand() LIMIT 1
CREATE (m)-[:HAS_POWER]->(powerAgg);
```

---

## 🛠 Step 3: Run the Database

In your terminal:

```bash
docker-compose up -d
```

- This will pull the **Neo4j** image if you don't have it already.
- It will start the **Neo4j Browser** at `http://localhost:7474`.

---

## 📥 Step 4: Load the Population Script

1. Open your browser and go to [http://localhost:7474](http://localhost:7474).
2. Log in with:
   - **Username**: `neo4j`
   - **Password**: `password123`
3. Open the **`populate.cypher`** file.
4. Copy-paste its content into the Neo4j browser console.
5. Execute.

Neo4j will now create:
- 10,000 modems
- 500 L3 aggregators
- 100 L2 aggregators
- 10 L1 top-level aggregators
- Full tree structure with signal and power connections.

---

## 📊 Step 5: Test the Graph

Run a simple query to visualize:

```cypher
MATCH (m:Modem)-[:HAS_SIGNAL]->(l3)-[:CONNECTED_TO]->(l2)-[:CONNECTED_TO]->(l1)
RETURN m.id, l3.id, l2.id, l1.id
LIMIT 50;
```

Or check counts:

```cypher
MATCH (m:Modem) RETURN count(m) AS TotalModems;
MATCH (a:Aggregation) RETURN a.layer, count(a) AS TotalPerLayer;
```

---

## 📈 Optional: Profile Performance

Use `PROFILE` before your queries to check performance details:

```cypher
PROFILE
MATCH (m:Modem)-[:HAS_SIGNAL]->(agg)
RETURN count(*);
```

---

## 🏁 Conclusion

You now have a fully running **graph database network model** populated with **10k modems and aggregation layers**, ideal for testing:

- Traversals
- Diagnostics (signal vs power)
- Root-cause analysis
- Performance under load

