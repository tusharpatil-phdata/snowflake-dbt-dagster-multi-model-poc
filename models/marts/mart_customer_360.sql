{{ config(schema='MART') }}

{{ config(materialized='table') }}

WITH customer_orders AS (
    SELECT * FROM {{ ref('int_customer_orders') }}
),

order_details AS (
    SELECT * FROM {{ ref('int_order_details') }}
),

customer_metrics AS (
    SELECT
        co.customer_key,
        co.customer_name,
        co.market_segment,
        co.account_balance,
        -- Order metrics
        COUNT(DISTINCT co.order_key) AS total_orders,
        SUM(co.total_price) AS total_revenue,
        AVG(co.total_price) AS avg_order_value,
        MAX(co.order_date) AS last_order_date,
        MIN(co.order_date) AS first_order_date,
        DATEDIFF(day, MIN(co.order_date), MAX(co.order_date)) AS customer_lifetime_days,
        -- Product metrics
        COUNT(DISTINCT od.part_key) AS unique_products_purchased,
        SUM(od.quantity) AS total_items_purchased,
        -- Status breakdown
        SUM(CASE WHEN co.order_status = 'F' THEN 1 ELSE 0 END) AS completed_orders,
        SUM(CASE WHEN co.order_status = 'O' THEN 1 ELSE 0 END) AS open_orders,
        SUM(CASE WHEN co.order_status = 'P' THEN 1 ELSE 0 END) AS pending_orders,
        -- Customer segmentation
        CASE
            WHEN SUM(co.total_price) > 500000 THEN 'VIP'
            WHEN SUM(co.total_price) > 200000 THEN 'Premium'
            WHEN SUM(co.total_price) > 50000 THEN 'Standard'
            ELSE 'Basic'
        END AS customer_tier
    FROM customer_orders co
    LEFT JOIN order_details od ON co.order_key = od.order_key
    GROUP BY 
        co.customer_key,
        co.customer_name,
        co.market_segment,
        co.account_balance
)

SELECT * FROM customer_metrics
