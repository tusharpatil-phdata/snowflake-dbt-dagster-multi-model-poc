from dagster import AssetExecutionContext, asset
from dagster_dbt import dbt_assets, DbtCliResource

from .project import dbt_project
from .partitions import daily_orders

@dbt_assets(
    manifest=dbt_project.manifest_path,
)
def dbt_analytics_assets(
    context: AssetExecutionContext,
    dbt: DbtCliResource,
):
    """
    Expose all dbt models as Dagster assets using the dbt manifest.

    When you materialize this asset group, Dagster will effectively run
    `dbt build` across the entire dbt project and respect the dbt DAG.
    """
    yield from dbt.cli(["build"], context=context).stream()

@asset(
    partitions_def=daily_orders,
    required_resource_keys={"dbt"},
)
def mart_sales_summary_partitioned(
    context: AssetExecutionContext,
    dbt: DbtCliResource,
):
    """
    Daily-partitioned orchestration for mart_sales_summary (1993).

    For each partition (one IST day), Dagster:
    - Computes min_date and max_date from the partition's time window,
      based on Asia/Kolkata timezone from daily_orders
    - Calls `dbt build` for mart_sales_summary with those vars

    The dbt model:
    - Filters the data to that [min_date, max_date) window
    - Rebuilds metrics only for that date slice
    - Sets loaded_at using CONVERT_TIMEZONE('UTC','Asia/Kolkata', CURRENT_TIMESTAMP()),
      so you can see in IST when that day's data was last loaded/backfilled.
    """

    # Time window for this partition (IST-based, via daily_orders)
    time_window = context.partition_time_window
    min_date = time_window.start.strftime("%Y-%m-%d")
    max_date = time_window.end.strftime("%Y-%m-%d")

    context.log.info(f"Running dbt mart_sales_summary for {min_date} -> {max_date}")

    vars_arg = f'{{min_date: "{min_date}", max_date: "{max_date}"}}'

    # Trigger dbt to build only mart_sales_summary for this window
    yield from dbt.cli(
        ["build", "--select", "mart_sales_summary", "--vars", vars_arg],
        context=context,
    ).stream()
