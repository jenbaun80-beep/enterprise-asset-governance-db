import os
import psycopg2

def seed_database():
    # Connect to PostgreSQL using environment variables or defaults
    conn = psycopg2.connect(
        dbname=os.getenv("POSTGRES_DB", "governance_db"),
        user=os.getenv("POSTGRES_USER", "postgres"),
        password=os.getenv("POSTGRES_PASSWORD", "postgres"),
        host=os.getenv("POSTGRES_HOST", "localhost"),
        port=os.getenv("POSTGRES_PORT", "5432")
    )
    conn.autocommit = True
    cursor = conn.cursor()

    print("Seeding initial enterprise assets...")

    # Sample assets to insert
    assets_to_add = [
        ("Server Cluster Alpha", "Internal", "IT Infrastructure"),
        ("Global Communications Array", "Restricted", "Operations"),
        ("Logistics Hub Terminal", "Internal", "Supply Chain")
    ]

    for name, classification, owner in assets_to_add:
        cursor.execute(
            "CALL core_assets.register_asset(%s, %s, %s);",
            (name, classification, owner)
        )
        print(f"-> Added asset: {name} ({classification})")

    cursor.close()
    conn.close()
    print("Database seeding completed successfully!")

if __name__ == "__main__":
    seed_database()
