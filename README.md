# Snowflake–dbt–Dagster Multi-Model POC

This repo contains a TPCH-based analytics POC using:

- Snowflake (TPCH sample data)
- dbt Cloud (staging → intermediate → mart models)
- Dagster Cloud (orchestration + daily partitions/backfills)
- GitHub Actions (CI for dbt)

All Snowflake credentials are provided via secrets/env vars, not hardcoded.
