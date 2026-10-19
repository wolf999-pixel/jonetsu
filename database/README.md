# Database migrations & seeders

This folder contains SQL migrations and seeders for the JŌNETSU project.

Apply the initial migration and seed locally (PostgreSQL):

```bash
# create database (if not created)
createdb -h localhost -p 5432 -U jonetsu jonetsu_db

# run migration
psql -h localhost -p 5432 -U jonetsu -d jonetsu_db -f database/migrations/001_initial_schema.sql

# run seeder
psql -h localhost -p 5432 -U jonetsu -d jonetsu_db -f database/seeders/001_users_seed.sql
```

Notes:
- Seeder inserts an admin user with password `changeme` hashed with SHA-256 using PostgreSQL `digest()` (pgcrypto).
- Ensure PostgreSQL has the `pgcrypto` extension enabled; migrations create it with `CREATE EXTENSION IF NOT EXISTS pgcrypto;`.
- For production, use a secure password and a proper migration tool (e.g., TypeORM migrations, Flyway, Liquibase).
