#!/usr/bin/env python3

import os
import sys
import time
import json
from neo4j import GraphDatabase
from dotenv import load_dotenv

class Neo4jAutomation:
    def __init__(self, uri, user, password):
        self.driver = GraphDatabase.driver(uri, auth=(user, password))

    def close(self):
        self.driver.close()

    def execute_script(self, script_path, parameters=None):
        """Execute a Cypher script file with optional parameters"""
        try:
            with open(script_path, 'r') as file:
                cypher_script = file.read()

            with self.driver.session() as session:
                # Execute the main script with parameters
                result = session.run(cypher_script, parameters or {})
                return result.consume()
        except Exception as e:
            print(f"Error executing script {script_path}: {str(e)}")
            raise

def parse_parameter_value(value):
    """Parse parameter value from string to appropriate type"""
    try:
        # Try to parse as JSON first (for lists, etc.)
        return json.loads(value)
    except json.JSONDecodeError:
        # If not JSON, handle boolean values
        if value.lower() == 'true':
            return True
        elif value.lower() == 'false':
            return False
        # Try to parse as number
        try:
            return float(value) if '.' in value else int(value)
        except ValueError:
            # If not a number, return as string
            return value

def get_default_parameters():
    """Get default parameters from environment variables"""
    params = {
        # Network configuration parameters
        'layerSizes': parse_parameter_value(os.getenv('LAYER_SIZES', '[10, 100, 500]')),
        'modemCount': int(os.getenv('MODEM_COUNT', '10000')),
        'activeModemProbability': float(os.getenv('ACTIVE_MODEM_PROBABILITY', '0.95')),
        
        # Failure simulation parameters
        'layer': int(os.getenv('FAILURE_LAYER', '2')),
        'numberOfNodes': int(os.getenv('FAILURE_NODE_COUNT', '3')),
        'failureType': os.getenv('FAILURE_TYPE', 'POWER'),
        'propagateToModems': parse_parameter_value(os.getenv('PROPAGATE_TO_MODEMS', 'true')),
        'randomModemFailures': int(os.getenv('RANDOM_MODEM_FAILURES', '100')),
        
        # Also pass the environment variables directly
        'FAILURE_LAYER': int(os.getenv('FAILURE_LAYER', '2')),
        'FAILURE_NODE_COUNT': int(os.getenv('FAILURE_NODE_COUNT', '3')),
        'FAILURE_TYPE': os.getenv('FAILURE_TYPE', 'POWER'),
        'PROPAGATE_TO_MODEMS': parse_parameter_value(os.getenv('PROPAGATE_TO_MODEMS', 'true')),
        'RANDOM_MODEM_FAILURES': int(os.getenv('RANDOM_MODEM_FAILURES', '100'))
    }
    return params

def main():
    # Load environment variables
    load_dotenv()
    
    # Neo4j connection details
    uri = os.getenv("NEO4J_URI", "bolt://localhost:7687")
    user = os.getenv("NEO4J_USER", "neo4j")
    password = os.getenv("NEO4J_PASSWORD", "password123")

    # Create automation instance
    automation = Neo4jAutomation(uri, user, password)

    try:
        # Example usage
        if len(sys.argv) < 2:
            print("Usage: python automate_cypher.py <script_path> [param1=value1 param2=value2 ...]")
            sys.exit(1)

        script_path = sys.argv[1]
        
        # Start with default parameters from environment
        parameters = get_default_parameters()

        # Parse additional parameters if provided
        for arg in sys.argv[2:]:
            if '=' in arg:
                key, value = arg.split('=', 1)
                parameters[key] = parse_parameter_value(value)

        print(f"Executing script: {script_path}")
        print(f"Using parameters: {parameters}")

        # Execute the script
        result = automation.execute_script(script_path, parameters)
        print(f"Script executed successfully. {result.counters}")

    finally:
        automation.close()

if __name__ == "__main__":
    main() 