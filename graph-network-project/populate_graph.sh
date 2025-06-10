#!/bin/bash

# Set colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

# Function to print success messages
print_success() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

# Function to print error messages
print_error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

# Activate virtual environment
print_status "Activating virtual environment..."
source venv/bin/activate
if [ $? -ne 0 ]; then
    print_error "Failed to activate virtual environment"
    exit 1
fi

# Function to execute a script and check its result
execute_script() {
    local script_name=$1
    local script_args=$2
    
    print_status "Executing $script_name..."
    
    if [ -z "$script_args" ]; then
        python neo4j/automate_cypher.py "neo4j/$script_name"
    else
        python neo4j/automate_cypher.py "neo4j/$script_name" "$script_args"
    fi
    
    if [ $? -eq 0 ]; then
        print_success "$script_name completed successfully"
    else
        print_error "Failed to execute $script_name"
        exit 1
    fi
}

# Main script execution
print_status "Starting graph database population..."

# 1. Clean the database
execute_script "clean.cypher"

# 2. Generate and create realistic nodes
print_status "Generating realistic node data..."
python generate_data.py
if [ $? -ne 0 ]; then
    print_error "Failed to generate realistic node data"
    exit 1
fi

# 3. Create nodes with realistic data
execute_script "create_realistic_nodes.cypher"

# 4. Connect the layers using existing connection logic
execute_script "connect_layers.cypher"

# 5. (Optional) Simulate failures in the network
read -p "Do you want to simulate failures? (y/n): " simulate_failures
if [[ $simulate_failures =~ ^[Yy]$ ]]; then
    read -p "Enter failure layer (1-3, default: 2): " layer
    read -p "Enter number of nodes to fail (default: 3): " nodes
    read -p "Enter failure type (POWER/SIGNAL, default: POWER): " type
    read -p "Enter number of random modem failures (default: 100): " random_failures
    
    # Set default values if not provided
    layer=${layer:-2}
    nodes=${nodes:-3}
    type=${type:-POWER}
    random_failures=${random_failures:-100}
    
    execute_script "simulate_failures.cypher" "layer=$layer numberOfNodes=$nodes failureType=$type randomModemFailures=$random_failures"
fi

print_success "Graph database population completed successfully!"

# Deactivate virtual environment
print_status "Deactivating virtual environment..."
deactivate 