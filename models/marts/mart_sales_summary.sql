{{ config(
    materialized = 'incremental',
    unique_key   = 'order_date'
) }}

WITH order_details AS (
    SELECT * FROM {{ ref('int_order_details') }}
),

filtered AS (
    SELECT *
    FROM order_details
    WHERE order_date >= to_date('{{ var("min_date", "1993-01-01") }}')
      AND order_date <  to_date('{{ var("max_date", "1994-01-01") }}')
      AND order_date >= DATE '1993-01-01'
      AND order_date <  DATE '1994-01-01'
),

daily_sales AS (
    SELECT
        order_date,
        COUNT(DISTINCT order_key)    AS total_orders,
        COUNT(DISTINCT customer_key) AS unique_customers,
        SUM(quantity)                AS total_items_sold,
        SUM(net_price)               AS total_revenue,
        SUM(extended_price * discount) AS total_discounts,
        AVG(net_price)               AS avg_order_line_value,
        YEAR(order_date)             AS order_year,
        MONTH(order_date)            AS order_month,
        DAYOFWEEK(order_date)        AS order_day_of_week,
        -- IST load timestamp
        CONVERT_TIMEZONE('UTC', 'Asia/Kolkata', CURRENT_TIMESTAMP()) AS loaded_at
    FROM filtered
    GROUP BY order_date
),

final AS (
    {% if is_incremental() %}
        SELECT *
        FROM {{ this }}
        WHERE order_date < to_date('{{ var("min_date", "1993-01-01") }}')

        UNION ALL

        SELECT * FROM daily_sales
    {% else %}
        SELECT * FROM daily_sales
    {% endif %}
)

SELECT * FROM final

-- Partitioning is controlled by order_date and the min_date/max_date vars.
-- loaded_at is purely for observability, indicating when each date’s data was last loaded (IST).