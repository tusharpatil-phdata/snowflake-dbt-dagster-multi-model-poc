{{ config(materialized='table') }}

WITH customer_orders AS (
    SELECT * FROM {{ ref('int_customer_orders') }}
),
order_details AS (
    SELECT * FROM {{ ref('int_order_details') }}
),
metrics AS (
    SELECT
        co.customer_key,
        co.customer_name,
        co.market_segment,
        co.account_balance,
        COUNT(DISTINCT co.order_key) AS total_orders,
        SUM(co.total_price)          AS total_revenue,
        AVG(co.total_price)          AS avg_order_value,
        MIN(co.order_date)           AS first_order_date,
        MAX(co.order_date)           AS last_order_date,
        COUNT(DISTINCT od.part_key)  AS unique_products_purchased
    FROM customer_orders co
    LEFT JOIN order_details od ON co.order_key = od.order_key
    GROUP BY
        co.customer_key,
        co.customer_name,
        co.market_segment,
        co.account_balance
)
SELECT * FROM metrics