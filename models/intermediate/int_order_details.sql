{{ config(materialized='table') }}

WITH orders AS (
    SELECT * FROM {{ ref('stg_tpch_orders') }}
),
lineitems AS (
    SELECT * FROM {{ ref('stg_tpch_lineitems') }}
),
parts AS (
    SELECT * FROM {{ ref('stg_tpch_parts') }}
),
joined AS (
    SELECT
        o.order_key,
        o.customer_key,
        o.order_date,
        o.order_status,
        l.line_number,
        l.part_key,
        p.part_name,
        p.manufacturer,
        p.brand,
        l.quantity,
        l.extended_price,
        l.discount,
        l.tax,
        -- net price after discount
        l.extended_price * (1 - l.discount) AS net_price,
        -- total with tax
        l.extended_price * (1 - l.discount) * (1 + l.tax) AS total_price_with_tax,
        l.ship_date,
        l.ship_mode
    FROM orders o
    JOIN lineitems l ON o.order_key = l.order_key
    JOIN parts p ON l.part_key = p.part_key
)
SELECT * FROM joined