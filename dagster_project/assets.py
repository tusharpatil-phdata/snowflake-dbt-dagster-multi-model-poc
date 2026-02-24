from dagster import AssetExecutionContext, asset
from dagster_dbt import DbtCliResource

from .partitions import daily_orders

@asset
def dbt_project_build(
    context: AssetExecutionContext,
    dbt: DbtCliResource,
):
    """
    Run `dbt build` for the entire dbt project.

    This shows Dagster orchestrating the full dbt DAG:
    staging -> intermediate -> marts.
    """
    context.log.info("Running full dbt build for project")
    # Important: do NOT pass context into dbt.cli() here
    yield from dbt.cli(["build"]).stream()

@asset(
    partitions_def=daily_orders,
)
def mart_sales_summary_partitioned(
    context: AssetExecutionContext,
    dbt: DbtCliResource,
):
    """
    Daily-partitioned orchestration for mart_sales_summary (1993, IST-based).

    For each partition (one IST day), Dagster:
    - Computes min_date and max_date from the partition's time window
    - Calls `dbt build` for mart_sales_summary with those vars

    The dbt model:
    - Filters to that [min_date, max_date) window
    - Rebuilds only that day's metrics
    - Sets loaded_at in IST, so you can see when that day's data
      was last loaded/backfilled.
    """

    time_window = context.partition_time_window
    min_date = time_window.start.strftime("%Y-%m-%d")
    max_date = time_window.end.strftime("%Y-%m-%d")

    context.log.info(f"Running dbt mart_sales_summary for {min_date} -> {max_date}")

    vars_arg = f'{{min_date: "{min_date}", max_date: "{max_date}"}}'

    # Important: do NOT pass context into dbt.cli() here either
    yield from dbt.cli(
        ["build", "--select", "mart_sales_summary", "--vars", vars_arg]
    ).stream()
