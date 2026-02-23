from dagster import DailyPartitionsDefinition

# Daily partitions starting from 1993-01-01, aligned to India timezone (IST)
daily_orders = DailyPartitionsDefinition(
    start_date="1993-01-01",
    timezone="Asia/Kolkata",
    end_offset=0,
)
