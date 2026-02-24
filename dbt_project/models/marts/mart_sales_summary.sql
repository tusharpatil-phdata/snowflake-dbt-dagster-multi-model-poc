{{ config(schema='MART') }}

{{ config(materialized='table') }}

WITH order_details AS (
    SELECT * FROM {{ ref('int_order_details') }}
),

daily_sales AS (
    SELECT
        order_date,
        COUNT(DISTINCT order_key) AS total_orders,
        COUNT(DISTINCT customer_key) AS unique_customers,
        SUM(quantity) AS total_items_sold,
        SUM(net_price) AS total_revenue,
        SUM(extended_price * discount) AS total_discounts,
        AVG(net_price) AS avg_order_line_value,
        -- Year/Month for time-based analysis
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        DAYOFWEEK(order_date) AS order_day_of_week
    FROM order_details
    GROUP BY order_date
)

SELECT * FROM daily_sales
