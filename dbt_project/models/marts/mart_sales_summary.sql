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
    WHERE order_date >= '{{ min_date }}'::date
      AND order_date <  '{{ max_date }}'::date
),

daily_sales AS (
    SELECT
        order_date,
        COUNT(DISTINCT order_key)       AS total_orders,
        COUNT(DISTINCT customer_key)    AS unique_customers,
        SUM(quantity)                   AS total_items_sold,
        SUM(net_price)                  AS total_revenue,
        SUM(extended_price * discount)  AS total_discounts,
        AVG(net_price)                  AS avg_order_line_value,
        
        -- Load timestamp approximating IST (UTC + 5h30m)
        DATEADD('minute', 330, CURRENT_TIMESTAMP())::timestamp_ntz AS loaded_at
    FROM order_details
    GROUP BY order_date
)

SELECT * FROM daily_sales
