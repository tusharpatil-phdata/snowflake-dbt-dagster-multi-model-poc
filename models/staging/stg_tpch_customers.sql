{{ config(materialized='table') }}

WITH source AS (
    SELECT * FROM {{ source('tpch', 'customer') }}
),
cleaned AS (
    SELECT
        c_custkey    AS customer_key,
        c_name       AS customer_name,
        c_address    AS customer_address,
        c_nationkey  AS nation_key,
        c_phone      AS phone,
        c_acctbal    AS account_balance,
        c_mktsegment AS market_segment,
        c_comment    AS comment,
        CURRENT_TIMESTAMP() AS _loaded_at
    FROM source
)
SELECT * FROM cleaned