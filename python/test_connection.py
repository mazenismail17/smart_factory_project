import os
from pathlib import Path
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

env_path = Path(__file__).resolve().parents[1] / ".env"
load_dotenv(env_path)

db_url = os.getenv("DB_URL")

if not db_url:
    raise ValueError("DB_URL not found in .env")

engine = create_engine(db_url)

with engine.connect() as connection:
    result = connection.execute(
        text("SELECT @@SERVERNAME, DB_NAME(), SUSER_SNAME()")
    )
    print("Connection successful!")
    print(result.fetchone())