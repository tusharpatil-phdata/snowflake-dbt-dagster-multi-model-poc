from dagster import Definitions, load_assets_from_modules

from . import assets
from .resources import dbt_resource, snowflake_resource

# Load all assets from assets.py (dbt_analytics_assets, mart_sales_summary_partitioned)
all_assets = load_assets_from_modules([assets])

# Root Definitions object for Dagster
defs = Definitions(
    assets=all_assets,
    resources={
        "dbt": dbt_resource,
        "snowflake": snowflake_resource,
    },
)
