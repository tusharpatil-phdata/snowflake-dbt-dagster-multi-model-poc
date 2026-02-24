{{ config(schema='MART') }}

{{ config(materialized='table') }}

WITH order_details AS (
    SELECT * FROM {{ ref('int_order_details') }}
),

product_metrics AS (
    SELECT
        part_key,
        part_name,
        manufacturer,
        brand,
        COUNT(DISTINCT order_key) AS times_ordered,
        SUM(quantity) AS total_quantity_sold,
        SUM(net_price) AS total_revenue,
        AVG(net_price / quantity) AS avg_unit_price,
        SUM(extended_price * discount) AS total_discount_given,
        -- Performance indicators
        ROUND(SUM(net_price) / NULLIF(SUM(quantity), 0), 2) AS revenue_per_unit,
        ROUND(SUM(extended_price * discount) / NULLIF(SUM(extended_price), 0) * 100, 2) AS avg_discount_pct
    FROM order_details
    GROUP BY 
        part_key,
        part_name,
        manufacturer,
        brand
)

SELECT * FROM product_metrics
ORDER BY total_revenue DESC
