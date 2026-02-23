import os
from dagster_dbt import DbtProject

# Use DBT_PROJECT_DIR env var, defaulting to ./dbt_project at the working directory root
DBT_PROJECT_DIR = os.getenv("DBT_PROJECT_DIR", "./dbt_project")

dbt_project = DbtProject(
    project_dir=DBT_PROJECT_DIR,
)

dbt_project.prepare_if_dev()


