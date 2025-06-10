from faker import Faker
import random
from typing import List, Dict

# Configure Faker to use simpler data
Faker.seed(42)  # For reproducibility
fake = Faker(['en_US'])  # Use US locale which has simpler company names

def generate_location() -> Dict:
    """Generate a realistic location with address details."""
    return {
        'name': f"Company-{fake.company_suffix()}",  # Use company suffix instead of full company name
        'address': fake.building_number() + " " + fake.street_name(),
        'city': fake.city(),
        'state': fake.state_abbr(),  # Use state abbreviations instead of full names
        'zip_code': fake.zipcode(),
        'country': "USA",  # Use fixed country to avoid special characters
        'latitude': float(fake.latitude()),
        'longitude': float(fake.longitude())
    }

def generate_device_name(device_type: str, index: int) -> str:
    """Generate a realistic device name based on type and index."""
    prefixes = {
        'modem': ['CM', 'DOCSIS', 'CABLE'],
        'router': ['RT', 'ROUTER', 'GW'],
        'switch': ['SW', 'SWITCH', 'CORE'],
        'aggregator': ['AGG', 'AGGR', 'HUB']
    }
    
    prefix = random.choice(prefixes.get(device_type.lower(), ['DEV']))
    model = fake.random_element(['1000', '2000', '3000', '4000', '5000'])
    return f"{prefix}-{model}-{index:04d}"

def generate_modem_data(count: int = 10000) -> List[Dict]:
    """Generate realistic modem data."""
    modems = []
    for i in range(count):
        modem = {
            'id': generate_device_name('modem', i),
            'model': fake.random_element(['DOCSIS 3.0', 'DOCSIS 3.1', 'DOCSIS 4.0']),
            'mac_address': fake.mac_address(),
            'ip_address': fake.ipv4(),
            'firmware_version': f"{random.randint(1, 9)}.{random.randint(0, 9)}.{random.randint(0, 9)}",
            'status': random.choices(['ACTIVE', 'DOWN', 'MAINTENANCE'], weights=[0.85, 0.10, 0.05])[0],
            'last_seen': fake.date_time_this_month(),
            'signal_strength': random.uniform(-15, 15),
            'power_level': random.uniform(-10, 10),
            'location': generate_location()
        }
        modems.append(modem)
    return modems

def generate_aggregator_data(layer: int, count: int) -> List[Dict]:
    """Generate realistic aggregator data for each layer."""
    aggregators = []
    for i in range(count):
        aggregator = {
            'id': generate_device_name('aggregator', i),
            'layer': layer,
            'model': fake.random_element(['CORE-1000', 'CORE-2000', 'CORE-3000']),
            'ip_address': fake.ipv4(),
            'status': random.choices(['ACTIVE', 'DOWN', 'MAINTENANCE'], weights=[0.90, 0.05, 0.05])[0],
            'capacity': random.choice([1000, 2000, 5000, 10000]),
            'location': generate_location()
        }
        aggregators.append(aggregator)
    return aggregators

def generate_cypher_queries():
    """Generate Cypher queries to create the nodes with realistic data."""
    # Generate data
    modems = generate_modem_data(10000)
    l1_aggregators = generate_aggregator_data(1, 10)
    l2_aggregators = generate_aggregator_data(2, 100)
    l3_aggregators = generate_aggregator_data(3, 500)
    
    # Start building the Cypher query
    cypher_queries = []
    
    # Create Layer 1 Aggregators
    for i, agg in enumerate(l1_aggregators):
        query = f"""
        CREATE (a1_{i}:Aggregation {{
            id: '{agg['id']}',
            layer: {agg['layer']},
            model: '{agg['model']}',
            ip_address: '{agg['ip_address']}',
            status: '{agg['status']}',
            capacity: {agg['capacity']},
            location_name: '{agg['location']['name']}',
            address: '{agg['location']['address']}',
            city: '{agg['location']['city']}',
            state: '{agg['location']['state']}',
            zip_code: '{agg['location']['zip_code']}',
            country: '{agg['location']['country']}',
            latitude: {agg['location']['latitude']},
            longitude: {agg['location']['longitude']}
        }})
        """
        cypher_queries.append(query)
    
    # Create Layer 2 Aggregators
    for i, agg in enumerate(l2_aggregators):
        query = f"""
        CREATE (a2_{i}:Aggregation {{
            id: '{agg['id']}',
            layer: {agg['layer']},
            model: '{agg['model']}',
            ip_address: '{agg['ip_address']}',
            status: '{agg['status']}',
            capacity: {agg['capacity']},
            location_name: '{agg['location']['name']}',
            address: '{agg['location']['address']}',
            city: '{agg['location']['city']}',
            state: '{agg['location']['state']}',
            zip_code: '{agg['location']['zip_code']}',
            country: '{agg['location']['country']}',
            latitude: {agg['location']['latitude']},
            longitude: {agg['location']['longitude']}
        }})
        """
        cypher_queries.append(query)
    
    # Create Layer 3 Aggregators
    for i, agg in enumerate(l3_aggregators):
        query = f"""
        CREATE (a3_{i}:Aggregation {{
            id: '{agg['id']}',
            layer: {agg['layer']},
            model: '{agg['model']}',
            ip_address: '{agg['ip_address']}',
            status: '{agg['status']}',
            capacity: {agg['capacity']},
            location_name: '{agg['location']['name']}',
            address: '{agg['location']['address']}',
            city: '{agg['location']['city']}',
            state: '{agg['location']['state']}',
            zip_code: '{agg['location']['zip_code']}',
            country: '{agg['location']['country']}',
            latitude: {agg['location']['latitude']},
            longitude: {agg['location']['longitude']}
        }})
        """
        cypher_queries.append(query)
    
    # Create Modems
    for i, modem in enumerate(modems):
        query = f"""
        CREATE (m_{i}:Modem {{
            id: '{modem['id']}',
            model: '{modem['model']}',
            mac_address: '{modem['mac_address']}',
            ip_address: '{modem['ip_address']}',
            firmware_version: '{modem['firmware_version']}',
            status: '{modem['status']}',
            last_seen: datetime('{modem['last_seen'].isoformat()}'),
            signal_strength: {modem['signal_strength']},
            power_level: {modem['power_level']},
            location_name: '{modem['location']['name']}',
            address: '{modem['location']['address']}',
            city: '{modem['location']['city']}',
            state: '{modem['location']['state']}',
            zip_code: '{modem['location']['zip_code']}',
            country: '{modem['location']['country']}',
            latitude: {modem['location']['latitude']},
            longitude: {modem['location']['longitude']}
        }})
        """
        cypher_queries.append(query)
    
    return cypher_queries

if __name__ == "__main__":
    # Generate and print the Cypher queries
    queries = generate_cypher_queries()
    with open("neo4j/create_realistic_nodes.cypher", "w") as f:
        f.write("\n".join(queries))
    print("Generated Cypher queries have been written to neo4j/create_realistic_nodes.cypher") 