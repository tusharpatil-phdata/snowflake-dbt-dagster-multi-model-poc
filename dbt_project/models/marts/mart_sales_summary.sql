{{ 
    config(
        schema='MART',
        materialized='table'
    ) 
}}

{% set min_date = var('min_date', '1993-01-01') %}
{% set max_date = var('max_date', '1994-01-01') %}

WITH order_details AS (
    SELECT * 
    FROM {{ ref('int_order_details') }}
    WHERE order_date >= TO_DATE('{{ min_date }}')
      AND order_date <  TO_DATE('{{ max_date }}')
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
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        DAYOFWEEK(order_date) AS order_day_of_week,
        -- IST-loaded timestamp for auditing
        CONVERT_TIMEZONE('UTC', 'Asia/Kolkata', CURRENT_TIMESTAMP()) AS loaded_at
    FROM order_details
    GROUP BY
        order_date,
        YEAR(order_date),
        MONTH(order_date),
        DAYOFWEEK(order_date)
)

SELECT * FROM daily_sales
