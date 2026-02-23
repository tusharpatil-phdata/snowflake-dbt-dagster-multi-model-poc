from dagster import EnvVar
from dagster_dbt import DbtCliResource
from dagster_snowflake import SnowflakeResource
from .project import dbt_project

# Resource for running dbt commands via CLI
dbt_resource = DbtCliResource(
    project_dir=dbt_project,
)

# Resource for connecting to Snowflake using environment vars
snowflake_resource = SnowflakeResource(
    account=EnvVar("SNOWFLAKE_ACCOUNT"),
    user=EnvVar("SNOWFLAKE_USER"),
    password=EnvVar("SNOWFLAKE_PASSWORD"),
    database=EnvVar("SNOWFLAKE_DATABASE"),
    warehouse=EnvVar("SNOWFLAKE_WAREHOUSE"),
    schema=EnvVar("SNOWFLAKE_SCHEMA"),
)


