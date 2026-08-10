import os
import time
import psycopg2

def run_benchmarks():
    # Connect to PostgreSQL
    conn = psycopg2.connect(
        dbname=os.getenv("POSTGRES_DB", "governance_db"),
        user=os.getenv("POSTGRES_USER", "postgres"),
        password=os.getenv("POSTGRES_PASSWORD", "postgres"),
        host=os.getenv("POSTGRES_HOST", "localhost"),
        port=os.getenv("POSTGRES_PORT", "5432")
    )
    cursor = conn.cursor()

    queries = [
        ("Select All Active Assets", "SELECT * FROM core_assets.assets WHERE status = 'Active';"),
        ("Count Assets by Classification", "SELECT classification_level, COUNT(*) FROM core_assets.assets GROUP BY classification_level;"),
        ("Fetch Recent Audit Logs", "SELECT * FROM governance_audit.audit_logs ORDER BY action_timestamp DESC LIMIT 5;")
    ]

    print("--- Starting Database Performance Benchmarks ---")
    
    for title, query in queries:
        start_time = time.time()
        cursor.execute(query)
        cursor.fetchall()
        end_time = time.time()
        
        duration_ms = (end_time - start_time) * 1000
        print(f"[BENCHMARK] {title}: {duration_ms:.4f} ms")

    cursor.close()
    conn.close()
    print("--- Benchmarking Completed Successfully ---")

if __name__ == "__main__":
    run_benchmarks()
