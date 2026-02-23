{{ config(materialized='table') }}

WITH source AS (
    SELECT * FROM {{ source('tpch', 'part') }}
),
cleaned AS (
    SELECT
        p_partkey     AS part_key,
        p_name        AS part_name,
        p_mfgr        AS manufacturer,
        p_brand       AS brand,
        p_type        AS part_type,
        p_size        AS part_size,
        p_container   AS container,
        p_retailprice AS retail_price,
        p_comment     AS comment,
        CURRENT_TIMESTAMP() AS _loaded_at
    FROM source
)
SELECT * FROM cleaned