# 📚 Project: Build and Populate a Graph Database of Modems and Aggregation Layers (with Docker + Neo4j)

## 🚀 Project Goal

- Run a **Neo4j** graph database in a **Docker** container.
- **Populate** the database with realistic data:
  - **10,000 modems** with detailed properties (MAC address, IP, firmware, signal strength, etc.)
  - **3 layers** of aggregation devices with realistic properties
  - Each modem connected by:
    - `HAS_SIGNAL`
    - `HAS_POWER`
  - Realistic location data for all devices
- Simulate a **network tree** structure for testing queries, diagnostics, and performance.

---

## 🛠 Prerequisites

- Docker installed: [Install Docker](https://docs.docker.com/get-docker/)
- Docker Compose installed (optional, but useful)
- Python 3.x with pip
- Required Python packages (in requirements.txt):
  - Faker
  - neo4j-driver

---

## ⚙️ Configuration

Create a `.env` file in the `neo4j` directory with the following settings:

```env
# Neo4j Connection Settings
NEO4J_URI=bolt://localhost:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=password123

# Network Configuration Parameters
LAYER_SIZES=[10, 50, 2000]  # Number of devices in each layer [L1, L2, L3]
MODEM_COUNT=10000           # Total number of modems to create
ACTIVE_MODEM_PROBABILITY=0.95  # Probability of a modem being active

# Failure Simulation Parameters
FAILURE_LAYER=2            # Layer to simulate failures in (1-3)
FAILURE_NODE_COUNT=6       # Number of nodes to fail
FAILURE_TYPE="POWER"       # Type of failure (POWER/SIGNAL)
PROPAGATE_TO_MODEMS=true   # Whether to propagate failures to connected modems
RANDOM_MODEM_FAILURES=100  # Number of random modem failures to simulate
```

These parameters control:
- Database connection settings
- Network topology (number of devices in each layer)
- Modem population size and status
- Failure simulation behavior

You can adjust these values to test different network configurations and failure scenarios.

---

## 💂 Project Structure

```
/graph-network-project
│
├── generate_data.py          # Generates realistic device data
├── populate_graph.sh         # Main script to populate the database
├── neo4j/
│   ├── docker-compose.yml    # Neo4j Docker configuration
│   ├── clean.cypher          # Cleans the database
│   ├── create_realistic_nodes.cypher  # Creates nodes with realistic data
│   ├── connect_layers.cypher # Connects aggregation layers
│   └── connect_modems.cypher # Connects modems to aggregators
├── data/                     # Neo4j data directory (gitignored)
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

## 🛠 Step 2: Generate Realistic Data

The project uses `generate_data.py` to create realistic device data with:
- Realistic device names and models
- MAC addresses and IP addresses
- Firmware versions
- Signal strength and power levels
- Location data (addresses, coordinates)
- Status information

Run the data generation:
```bash
python generate_data.py
```

This will create `neo4j/create_realistic_nodes.cypher` with the node creation queries.

---

## 🛠 Step 3: Connect the Network

The project uses two main connection scripts:

1. `connect_layers.cypher` - Connects aggregation layers:
```cypher
// Connect Layer 3 to Layer 2
MATCH (l3:Aggregation {layer: 3})
MATCH (l2:Aggregation {layer: 2})
WITH l3, collect(l2) AS l2Nodes
WITH l3, l2Nodes[toInteger(rand() * size(l2Nodes))] AS selectedL2
CREATE (l3)-[:CONNECTED_TO]->(selectedL2)

// Connect Layer 2 to Layer 1
MATCH (l2:Aggregation {layer: 2})
MATCH (l1:Aggregation {layer: 1})
WITH l2, collect(l1) AS l1Nodes
WITH l2, l1Nodes[toInteger(rand() * size(l1Nodes))] AS selectedL1
CREATE (l2)-[:CONNECTED_TO]->(selectedL1)
```

2. `connect_modems.cypher` - Connects modems to Layer 1 aggregators:
```cypher
// Connect Modems to Layer 1 Aggregation nodes
MATCH (agg:Aggregation {layer: 1})
MATCH (m:Modem)
WITH agg, collect(m) AS allModems
WITH agg, allModems, toInteger(rand() * 20) + 1 AS numConnections
WITH agg, allModems[..numConnections] AS selectedModems
UNWIND selectedModems AS m
MERGE (m)-[:HAS_SIGNAL]->(agg)
MERGE (m)-[:HAS_POWER]->(agg)
```

---

## 🛠 Step 4: Run the Database

In your terminal:

```bash
./populate_graph.sh
```

This script will:
1. Start the Neo4j container
2. Clean the database
3. Create nodes with realistic data
4. Connect the network layers
5. Connect modems to aggregators

---

## 📊 Step 5: Test the Graph

Run queries to verify the network structure:

```cypher
// Check modem connections
MATCH (m:Modem)-[:HAS_SIGNAL]->(l1:Aggregation {layer: 1})<-[:CONNECTED_TO]-(l2:Aggregation {layer: 2})<-[:CONNECTED_TO]-(l3:Aggregation {layer: 3})
RETURN m.id, l1.id, l2.id, l3.id
LIMIT 50;

// Check device counts
MATCH (m:Modem) RETURN count(m) AS TotalModems;
MATCH (a:Aggregation) RETURN a.layer, count(a) AS TotalPerLayer;

// Check signal strength distribution
MATCH (m:Modem)
RETURN m.signal_strength, count(*) AS count
ORDER BY m.signal_strength;
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

You now have a fully running **graph database network model** populated with **10k modems and aggregation layers** with realistic data, ideal for testing:

- Network topology analysis
- Signal and power diagnostics
- Root-cause analysis
- Performance under load
- Geographic distribution analysis

