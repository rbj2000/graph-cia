# Graph Network Project

## Overview
This project demonstrates a hierarchical network structure using Neo4j graph database. The network consists of aggregation layers and modems, with various connection types between them.

## Scripts
The project contains several Cypher scripts that can be executed in sequence:

1. `clean.cypher` - Cleans the database
2. `create_layers.cypher` - Creates aggregation layers
3. `connect_layers.cypher` - Connects aggregation layers
4. `create_modems.cypher` - Creates modems
5. `connect_modems.cypher` - Connects modems to the bottom layer
6. `create_locations.cypher` - Creates locations and places aggregation devices
7. `simulate_failures.cypher` - Simulates failures in the network

## Script Execution Sequence

### Basic Setup
To create a complete network, execute the scripts in the following order:

```bash
# 1. Clean the database
python automate_cypher.py clean.cypher

# 2. Create aggregation layers
python automate_cypher.py create_layers.cypher

# 3. Connect the layers
python automate_cypher.py connect_layers.cypher

# 4. Create modems
python automate_cypher.py create_modems.cypher

# 5. Connect modems to the bottom layer
python automate_cypher.py connect_modems.cypher

# 6. Create locations and place devices
python automate_cypher.py create_locations.cypher

# 7. (Optional) Simulate failures in the network
python automate_cypher.py simulate_failures.cypher
```

### Custom Configuration
You can customize the network by passing parameters to specific scripts:

```bash
# Create a smaller network
python automate_cypher.py clean.cypher
python automate_cypher.py create_layers.cypher layerSizes="[5,20,100]"
python automate_cypher.py connect_layers.cypher layerSizes="[5,20,100]"
python automate_cypher.py create_modems.cypher modemCount=1000 activeModemProbability=0.95
python automate_cypher.py connect_modems.cypher layerSizes="[5,20,100]"
python automate_cypher.py create_locations.cypher layerSizes="[5,20,100]"
python automate_cypher.py simulate_failures.cypher layer=3 numberOfNodes=2 failureType="SIGNAL"
```

### Using Environment Variables
The scripts will automatically use values from your `.env` file. For example:
```bash
# .env contents:
LAYER_SIZES=[10, 100, 500]
MODEM_COUNT=10000
ACTIVE_MODEM_PROBABILITY=0.95

# These commands will use the values from .env
python automate_cypher.py create_layers.cypher
python automate_cypher.py connect_layers.cypher
python automate_cypher.py create_modems.cypher
python automate_cypher.py connect_modems.cypher
python automate_cypher.py create_locations.cypher
```

### Individual Script Parameters

#### clean.cypher
- No parameters needed
```bash
python automate_cypher.py clean.cypher
```

#### create_layers.cypher
- `layerSizes`: List of integers (default from .env: [10, 100, 500])
```bash
# Use default from .env
python automate_cypher.py create_layers.cypher

# Custom layer sizes
python automate_cypher.py create_layers.cypher layerSizes="[5,20,100]"
```

#### connect_layers.cypher
- `layerSizes`: List of integers (default from .env: [10, 100, 500])
```bash
# Use default from .env
python automate_cypher.py connect_layers.cypher

# Custom layer sizes
python automate_cypher.py connect_layers.cypher layerSizes="[5,20,100]"
```

#### create_modems.cypher
- `modemCount`: Integer (default from .env: 10000)
- `activeModemProbability`: Float (default from .env: 0.95)
```bash
# Use defaults from .env
python automate_cypher.py create_modems.cypher

# Custom parameters
python automate_cypher.py create_modems.cypher modemCount=1000 activeModemProbability=0.99
```

#### connect_modems.cypher
- `layerSizes`: List of integers (default from .env: [10, 100, 500])
```bash
# Use default from .env
python automate_cypher.py connect_modems.cypher

# Custom layer sizes
python automate_cypher.py connect_modems.cypher layerSizes="[5,20,100]"
```

#### create_locations.cypher
- `layerSizes`: List of integers (default from .env: [10, 100, 500])
```bash
# Use default from .env
python automate_cypher.py create_locations.cypher

# Custom layer sizes
python automate_cypher.py create_locations.cypher layerSizes="[5,20,100]"
```

#### simulate_failures.cypher
- `layer`: Integer layer where failure occurs (1 = top layer, default from .env: 2)
- `numberOfNodes`: Integer number of nodes to fail in the specified layer (default from .env: 3)
- `failureType`: String type of failure, "POWER" or "SIGNAL" (default from .env: "POWER")
- `propagateToModems`: Boolean whether to propagate failure to connected modems (default from .env: true)
- `randomModemFailures`: Integer number of random modems to fail without root cause (default from .env: 100)
```bash
# Use defaults from .env
python automate_cypher.py simulate_failures.cypher

# Custom parameters
python automate_cypher.py simulate_failures.cypher layer=1 numberOfNodes=2 failureType="SIGNAL"

# Combine with other parameters
python automate_cypher.py simulate_failures.cypher layer=3 randomModemFailures=50
```

## Passing Parameters to Cypher Scripts

### Using Python Automation
When using the Python automation script (`automate_cypher.py`), parameters can be passed as command-line arguments:

```bash
# Basic example with default parameters
python automate_cypher.py create_layers.cypher

# Example with custom layer sizes
python automate_cypher.py create_layers.cypher layerSizes="[5,20,100]"

# Example with multiple parameters
python automate_cypher.py create_modems.cypher modemCount=1000 activeModemProbability=0.95
```

### Using Neo4j Browser
When using the Neo4j Browser, parameters can be set using the `:param` command:

```cypher
// Set parameters
:param layerSizes => [5,20,100];
:param modemCount => 1000;
:param activeModemProbability => 0.95;

// Then run your query
MATCH (n) RETURN n;
```

### Parameter Descriptions

#### layerSizes
- Type: List of integers
- Description: Number of devices in each layer (from top to bottom)
- Example: `[10, 100, 500]` creates 3 layers with 10, 100, and 500 devices respectively

#### modemCount
- Type: Integer
- Description: Total number of modems to create
- Example: `10000` creates 10,000 modems

#### activeModemProbability
- Type: Float
- Description: Probability of a modem being active (between 0 and 1)
- Example: `0.95` means 95% of modems will be active

#### Failure Simulation Parameters

#### layer
- Type: Integer
- Description: Layer number where failure occurs (1 = top layer)
- Example: `2` will fail nodes in the second layer

#### numberOfNodes
- Type: Integer
- Description: Number of nodes to fail in the specified layer
- Example: `3` will fail three nodes in the specified layer

#### failureType
- Type: String
- Description: Type of failure, can be "POWER" or "SIGNAL"
- Example: `"POWER"` causes power failures, `"SIGNAL"` causes signal failures

#### propagateToModems
- Type: Boolean
- Description: Whether to propagate failure to connected modems
- Example: `true` will propagate failures to connected modems

#### randomModemFailures
- Type: Integer
- Description: Number of random modems to fail without root cause
- Example: `100` will cause 100 random modems to fail

### Example Failure Scenarios

```bash
# Simulate power failures in layer 2 (middle layer)
python automate_cypher.py simulate_failures.cypher layer=2 numberOfNodes=3 failureType="POWER"

# Simulate signal failures in the bottom layer
python automate_cypher.py simulate_failures.cypher layer=3 numberOfNodes=5 failureType="SIGNAL"

# Simulate top-layer failures with many random modem failures
python automate_cypher.py simulate_failures.cypher layer=1 numberOfNodes=1 randomModemFailures=500

# Simulate failures without propagation to modems
python automate_cypher.py simulate_failures.cypher propagateToModems=false
```

## Test Script
The project includes a test script (`test_populate.sh`) that demonstrates different parameter combinations:

```bash
# Run all tests
./test_populate.sh

# Individual test examples
# Test 1: Default configuration
python automate_cypher.py populate.cypher

# Test 2: Smaller network
python automate_cypher.py populate.cypher layerSizes="[5,20,100]" modemCount=1000

# Test 3: Larger network
python automate_cypher.py populate.cypher layerSizes="[20,200,1000]" modemCount=20000

# Test 4: Different layer configuration
python automate_cypher.py populate.cypher layerSizes="[3,30,300,3000]" modemCount=30000

# Test 5: High availability
python automate_cypher.py populate.cypher activeModemProbability=0.99

# Test 6: Low availability
python automate_cypher.py populate.cypher activeModemProbability=0.8
```

## Query Examples

### Network Analysis Queries

#### Basic Network Statistics
```cypher
// Count total devices by type
MATCH (n)
RETURN labels(n) AS deviceType, count(*) AS count
ORDER BY count DESC;

// Count devices by layer
MATCH (a:Aggregation)
RETURN a.layer AS layer, count(a) AS count
ORDER BY layer;

// Count modems by status
MATCH (m:Modem)
RETURN m.status AS status, count(m) AS count
ORDER BY count DESC;
```

#### Network Topology Analysis
```cypher
// Find devices with most connections
MATCH (n)
RETURN n.id, labels(n) AS type, size([(n)--() | 1]) AS connectionCount
ORDER BY connectionCount DESC
LIMIT 10;

// Find isolated modems (not connected to any aggregator)
MATCH (m:Modem)
WHERE NOT (m)-[:HAS_SIGNAL]->() AND NOT (m)-[:HAS_POWER]->()
RETURN m.id, m.status
ORDER BY m.id;

// Find aggregation devices with most connected modems
MATCH (a:Aggregation)<-[:HAS_SIGNAL]-(m:Modem)
RETURN a.id, a.layer, count(m) AS modemCount
ORDER BY modemCount DESC
LIMIT 10;
```

#### Failure Analysis Queries
```cypher
// Find all failed devices and their impact
MATCH (f {status: "FAILED"})
OPTIONAL MATCH (f)<-[:HAS_SIGNAL]-(ms:Modem)
OPTIONAL MATCH (f)<-[:HAS_POWER]-(mp:Modem)
RETURN 
    f.id AS failedDevice,
    labels(f) AS deviceType,
    f.layer AS layer,
    count(DISTINCT ms) AS affectedSignalModems,
    count(DISTINCT mp) AS affectedPowerModems;

// Find modems affected by multiple failures
MATCH (m:Modem {status: "DOWN"})
OPTIONAL MATCH (m)-[:HAS_SIGNAL]->(s:Aggregation {status: "FAILED"})
OPTIONAL MATCH (m)-[:HAS_POWER]->(p:Aggregation {status: "FAILED"})
RETURN 
    m.id AS modemId,
    collect(DISTINCT s.id) AS signalFailures,
    collect(DISTINCT p.id) AS powerFailures
ORDER BY size(signalFailures) + size(powerFailures) DESC;

// Analyze failure propagation
MATCH (a:Aggregation {status: "FAILED"})
MATCH path = (a)<-[:CONNECTED_TO*]-(parent)
RETURN 
    a.id AS failedDevice,
    a.layer AS layer,
    collect(DISTINCT parent.id) AS affectedParents;
```

#### Location-Based Analysis
```cypher
// Find locations with most devices
MATCH (l:Location)<-[:LOCATED_AT]-(d)
RETURN 
    l.id AS locationId,
    l.address AS address,
    count(d) AS deviceCount,
    collect(DISTINCT labels(d)) AS deviceTypes
ORDER BY deviceCount DESC
LIMIT 10;

// Find locations with failed devices
MATCH (l:Location)<-[:LOCATED_AT]-(d {status: "FAILED"})
RETURN 
    l.id AS locationId,
    l.address AS address,
    collect(d.id) AS failedDevices,
    collect(labels(d)) AS deviceTypes;

// Analyze device distribution across locations
MATCH (l:Location)
OPTIONAL MATCH (l)<-[:LOCATED_AT]-(d)
RETURN 
    l.id AS locationId,
    l.address AS address,
    count(d) AS deviceCount,
    collect(DISTINCT labels(d)) AS deviceTypes
ORDER BY deviceCount DESC;
```

#### Performance Monitoring
```cypher
// Monitor connection health
MATCH (m:Modem)
RETURN 
    m.status AS status,
    count(*) AS count,
    CASE 
        WHEN m.status = "ACTIVE" THEN "✅"
        WHEN m.status = "DOWN" THEN "❌"
        ELSE "⚠️"
    END AS statusIcon;

// Track failure rates by layer
MATCH (a:Aggregation)
RETURN 
    a.layer AS layer,
    count(*) AS totalDevices,
    sum(CASE WHEN a.status = "FAILED" THEN 1 ELSE 0 END) AS failedDevices,
    toFloat(sum(CASE WHEN a.status = "FAILED" THEN 1 ELSE 0 END)) / count(*) * 100 AS failureRate
ORDER BY layer;

// Monitor network health over time
MATCH (m:Modem)
RETURN 
    date(datetime()) AS date,
    count(*) AS totalModems,
    sum(CASE WHEN m.status = "ACTIVE" THEN 1 ELSE 0 END) AS activeModems,
    toFloat(sum(CASE WHEN m.status = "ACTIVE" THEN 1 ELSE 0 END)) / count(*) * 100 AS uptimePercentage;
```

#### Advanced Analysis
```cypher
// Find critical paths in the network
MATCH path = (l1:Aggregation {layer: 1})<-[:CONNECTED_TO*]-(l3:Aggregation {layer: 3})
WITH path, length(path) AS pathLength
ORDER BY pathLength DESC
LIMIT 5
RETURN 
    [n IN nodes(path) | n.id] AS path,
    pathLength AS hops;

// Identify potential single points of failure
MATCH (a:Aggregation)
WHERE size((a)<-[:CONNECTED_TO]-()) = 1
RETURN 
    a.id AS deviceId,
    a.layer AS layer,
    [(a)<-[:CONNECTED_TO]-(p) | p.id] AS parent;

// Analyze network redundancy
MATCH (m:Modem)
OPTIONAL MATCH (m)-[:HAS_SIGNAL]->(s:Aggregation)
OPTIONAL MATCH (m)-[:HAS_POWER]->(p:Aggregation)
RETURN 
    count(*) AS totalModems,
    count(DISTINCT s) AS uniqueSignalAggregators,
    count(DISTINCT p) AS uniquePowerAggregators,
    toFloat(count(DISTINCT s)) / count(*) AS avgSignalRedundancy,
    toFloat(count(DISTINCT p)) / count(*) AS avgPowerRedundancy;
```

### Using the Neo4j Browser

1. **Access the Browser**:
   - Open http://localhost:7474 in your web browser
   - Log in with your Neo4j credentials (default: neo4j/password123)

2. **Running Queries**:
   - Copy and paste any of the above queries into the query editor
   - Click the "Play" button to execute
   - Use the "Table" view for structured results
   - Use the "Graph" view for visual representation

3. **Saving Queries**:
   - Click the "Save" button to store frequently used queries
   - Organize queries into folders for easy access

4. **Exporting Results**:
   - Use the "Export" button to save results as CSV or JSON
   - Copy results directly from the table view

### Performance Tips

1. **Indexing**:
   ```cypher
   // Create indexes for frequently queried properties
   CREATE INDEX layer_index IF NOT EXISTS FOR (a:Aggregation) ON (a.layer);
   CREATE INDEX status_index IF NOT EXISTS FOR (n) ON (n.status);
   CREATE INDEX location_index IF NOT EXISTS FOR (l:Location) ON (l.id);
   ```

2. **Query Optimization**:
   - Use `PROFILE` to analyze query performance
   - Limit result sets with `LIMIT`
   - Use `WHERE` clauses before `MATCH` when possible
   - Avoid unnecessary path traversals

3. **Monitoring**:
   ```cypher
   // Check query performance
   PROFILE
   MATCH (m:Modem)-[:HAS_SIGNAL]->(a:Aggregation)
   RETURN count(*);

   // Monitor database size
   CALL dbms.components() YIELD name, versions, edition
   RETURN name, versions, edition;
   ```

## Requirements
- Neo4j Database
- Python 3.x
- Neo4j Python Driver

## Project Structure

```
/graph-network-project
│
├── docker-compose.yml    # Docker configuration for Neo4j
├── populate.cypher       # Cypher script to populate the database
├── simulate_failures.cypher # Script to simulate network failures
├── automate_cypher.py    # Python script to automate Cypher execution
├── requirements.txt      # Python dependencies
├── setup.sh             # Script to set up virtual environment
└── README.md            # This file
```

## Prerequisites

- Docker and Docker Compose
  - [Install Docker](https://docs.docker.com/get-docker/)
  - [Install Docker Compose](https://docs.docker.com/compose/install/)
- Python 3.6+
- Virtual Environment (recommended)

## Quick Start

1. Clone the repository and navigate to the project directory:
   ```bash
   git clone <repository-url>
   cd graph-network-project
   ```

2. Set up the virtual environment:
   ```bash
   # Make the setup script executable
   chmod +x setup.sh
   
   # Run the setup script
   ./setup.sh
   ```

3. Start the Neo4j database:
   ```bash
   docker-compose up -d
   ```

4. Activate the virtual environment (if not already activated):
   ```bash
   source venv/bin/activate  # On Unix/macOS
   # OR
   .\venv\Scripts\activate  # On Windows
   ```

5. Populate the database:
   ```bash
   python automate_cypher.py populate.cypher
   ```

6. Access the Neo4j Browser at [http://localhost:7474](http://localhost:7474)
   - Username: `neo4j`
   - Password: `password123`

## Virtual Environment Management

### Automatic Setup

The easiest way to set up the virtual environment is using the provided `setup.sh` script:

```bash
# Make the script executable
chmod +x setup.sh

# Run the setup script
./setup.sh
```

This will:
1. Create a new virtual environment in the `venv` directory
2. Activate the virtual environment
3. Upgrade pip to the latest version
4. Install all required dependencies from `requirements.txt`

### Manual Setup

If you prefer to set up the virtual environment manually:

```bash
# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate  # On Unix/macOS
# OR
.\venv\Scripts\activate  # On Windows

# Upgrade pip
pip install --upgrade pip

# Install dependencies
pip install -r requirements.txt
```

### Working with the Virtual Environment

#### Activating the Environment

Before running any Python scripts, make sure to activate the virtual environment:

```bash
source venv/bin/activate  # On Unix/macOS
# OR
.\venv\Scripts\activate  # On Windows
```

You'll know the environment is activated when you see `(venv)`