from pathlib import Path
from dagster_dbt import DbtProject

# Point to the dbt project directory relative to this file
dbt_project = DbtProject(
    project_dir=Path(__file__).joinpath("..", "dbt_project").resolve(),
)

# Prepare the dbt project when running in dev environments
dbt_project.prepare_if_dev()


# This tells dagster-dbt where your dbt project is (../dbt_project), so it can load the manifest and run dbt.
