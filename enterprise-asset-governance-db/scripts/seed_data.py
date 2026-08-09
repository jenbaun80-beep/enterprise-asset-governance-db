import os
import random
import psycopg2
from faker import Faker

fake = Faker()

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_NAME = os.getenv("DB_NAME", "EnterpriseAssetDB")
DB_USER = os.getenv("DB_USER", "admin_user")
DB_PASS = os.getenv("DB_PASS", "SecurePassword123!")
DB_PORT = os.getenv("DB_PORT", "5432")

def seed_database(num_records=1000):
	try:
		conn = psycopg2.connect(
			host=DB_HOST, database=DB_NAME, user=DB_USER, password=DB_PASS, port=DB_PORT
		)
		cursor = conn.cursor()
		print(f"Connected to {DB_NAME}. Seeding {num_records} records...")

		locations = ["JOC San Diego", "Camp Pendleton MTF", "NIWC Pacific Edge Node", "USS NIMITZ Afloat"]
		location_ids = []
		for loc in locations:
			cursor.execute(
				"INSERT INTO locations (facility_name, region_code) VALUES (%s, %s) RETURNING location_id;",
				(loc, "PAC-REG-01")
			)
			location_ids.append(cursor.fetchone()[0])

		categories = ["Medical Telemetry", "Tactical Router", "Field Server", "Biosurveillance Sensor"]
		statuses = ["OPERATIONAL", "MAINTENANCE_REQUIRED", "DEGRADED", "OFFLINE"]

		for _ in range(num_records):
			serial = fake.unique.bothify(text="SN-####-????-2026")
			name = f"{random.choice(categories)} Unit"
			category = random.choice(categories)
			status = random.choice(statuses)
			loc_id = random.choice(location_ids)

			cursor.execute(
				"""
				INSERT INTO assets (serial_number, asset_name, category, status, location_id)
				VALUES (%s, %s, %s, %s, %s);
				""",
				(serial, name, category, status, loc_id)
			)

		conn.commit()
		print(f"Successfully seeded {num_records} asset records.")
		cursor.close()
		conn.close()

	except Exception as e:
		print(f"Database error during seeding: {e}")

if __name__ == "__main__":
	seed_database(1000)
