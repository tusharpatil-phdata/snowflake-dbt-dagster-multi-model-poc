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
        COUNT(DISTINCT order_key)     AS times_ordered,
        SUM(quantity)                 AS total_quantity_sold,
        SUM(net_price)                AS total_revenue,
        AVG(net_price / NULLIF(quantity,0)) AS avg_unit_price
    FROM order_details
    GROUP BY part_key, part_name, manufacturer, brand
)
SELECT * FROM product_metrics