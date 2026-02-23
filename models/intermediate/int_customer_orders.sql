{{ config(materialized='table') }}

WITH customers AS (
    SELECT * FROM {{ ref('stg_tpch_customers') }}
),
orders AS (
    SELECT * FROM {{ ref('stg_tpch_orders') }}
),
joined AS (
    SELECT
        c.customer_key,
        c.customer_name,
        c.market_segment,
        c.account_balance,
        o.order_key,
        o.order_date,
        o.order_status,
        o.total_price,
        o.order_priority,
        -- example: order size buckets
        CASE
            WHEN o.total_price < 50000 THEN 'Small'
            WHEN o.total_price < 150000 THEN 'Medium'
            WHEN o.total_price < 300000 THEN 'Large'
            ELSE 'Enterprise'
        END AS order_size_category,
        DATEDIFF(day, o.order_date, CURRENT_DATE()) AS order_age_days
    FROM customers c
    JOIN orders o ON c.customer_key = o.customer_key
)
SELECT * FROM joined