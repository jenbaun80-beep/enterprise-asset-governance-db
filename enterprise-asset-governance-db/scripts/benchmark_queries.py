import os
import time
import psycopg2

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_NAME = os.getenv("DB_NAME", "EnterpriseAssetDB")
DB_USER = os.getenv("DB_USER", "admin_user")
DB_PASS = os.getenv("DB_PASS", "SecurePassword123!")
DB_PORT = os.getenv("DB_PORT", "5432")

def run_benchmark():
	try:
		conn = psycopg2.connect(
			host=DB_HOST, database=DB_NAME, user=DB_USER, password=DB_PASS, port=DB_PORT
		)
		cursor = conn.cursor()

		test_query = """
			SELECT a.serial_number, a.asset_name, a.status, l.facility_name
			FROM assets a
			JOIN locations l ON a.location_id = l.location_id
			WHERE a.status = 'MAINTENANCE_REQUIRED'
			ORDER BY a.last_inspected DESC;
		"""

		print("Executing benchmark query...")
		start_time = time.perf_counter()
		cursor.execute(test_query)
		results = cursor.fetchall()
		end_time = time.perf_counter()

		execution_time_ms = (end_time - start_time) * 1000
		print(f"Retrieved {len(results)} records in {execution_time_ms:.2f} ms.")

		cursor.close()
		conn.close()

	except Exception as e:
		print(f"Benchmark error: {e}")

if __name__ == "__main__":
	run_benchmark()
