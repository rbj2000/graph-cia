#!/bin/bash

# Activate virtual environment
source venv/bin/activate

echo "Testing populate.cypher with different configurations..."

# Test 1: Default configuration
echo -e "\nTest 1: Default configuration"
python automate_cypher.py neo4j/populate.cypher

# Test 2: Smaller network
echo -e "\nTest 2: Smaller network"
python automate_cypher.py neo4j/populate.cypher layerSizes="[5,20,100]" modemCount=1000

# Test 3: Larger network
echo -e "\nTest 3: Larger network"
python automate_cypher.py neo4j/populate.cypher layerSizes="[20,200,1000]" modemCount=20000

# Test 4: Different layer configuration
echo -e "\nTest 4: Different layer configuration"
python automate_cypher.py neo4j/populate.cypher layerSizes="[3,30,300,3000]" modemCount=30000

# Test 5: High availability
echo -e "\nTest 5: High availability"
python automate_cypher.py neo4j/populate.cypher activeModemProbability=0.99

# Test 6: Low availability
echo -e "\nTest 6: Low availability"
python automate_cypher.py neo4j/populate.cypher activeModemProbability=0.8

echo -e "\nAll tests completed!" 