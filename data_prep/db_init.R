library(DBI)
library(RPostgres)
library(uuid)

readRenviron("./app/.env.development")
#readRenviron("./app/.env.production")

db_conn <- dbConnect(
  RPostgres::Postgres(),
  dbname = Sys.getenv("DB_NAME"),
  host = Sys.getenv("DB_HOST"),
  password = Sys.getenv("DB_PASSWORD"),
  user = Sys.getenv("DB_USER")
)

# For UUID generate
DBI::dbExecute(db_conn, 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";')
DBI::dbExecute(db_conn, 'CREATE SCHEMA IF NOT EXISTS auth;')

dbExecute(db_conn, "DROP TABLE IF EXISTS auth.users")
dbExecute(
  db_conn,
  "CREATE TABLE IF NOT EXISTS auth.users (
    uid                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email              VARCHAR(255) NOT NULL,
    verification_code  VARCHAR(255),
    is_admin           BOOLEAN NOT NULL DEFAULT FALSE,
    metadata           TEXT,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by         UUID
  )"
)

uid <- UUIDgenerate()

dbExecute(
  db_conn,
  "INSERT INTO auth.users (uid, email, is_admin, created_by) VALUES ($1, $2, $3, $4)",
  params = list(
    uid,
    "andy.merlino@tychobra.com",
    TRUE,
    uid
  )
)

dbExecute(db_conn, "DROP TABLE IF EXISTS auth.sessions")
dbExecute(
  db_conn,
  "CREATE TABLE IF NOT EXISTS auth.sessions (
    uid           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_uid      UUID NOT NULL,
    cookie        VARCHAR(255) NOT NULL,
    is_signed_in  BOOLEAN NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    modified_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
 )"
)

dbDisconnect(db_conn)
