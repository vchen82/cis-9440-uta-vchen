-- Clean and standardize NYC Open Restaurant applications data
-- One row per application record

WITH source AS (
    SELECT * FROM {{ source('raw', 'source_nyc_open_restaurant_apps') }}
),

cleaned AS (
    SELECT
        * EXCEPT (
            globalid,
            objectid,
            borough,
            zip,
            latitude,
            longitude,
            restaurant_name,
            legal_business_name,
            doing_business_as_dba,
            business_address,
            street,
            time_of_submission
        ),

        -- Identifiers
        CAST(globalid AS STRING) AS global_id,
        CAST(objectid AS STRING) AS object_id,

        -- Business info
        CAST(restaurant_name AS STRING) AS restaurant_name,
        CAST(legal_business_name AS STRING) AS legal_business_name,
        CAST(doing_business_as_dba AS STRING) AS doing_business_as_dba,

        -- Address info
        CAST(business_address AS STRING) AS business_address,
        CAST(street AS STRING) AS street,

        CASE
            WHEN UPPER(TRIM(CAST(zip AS STRING))) IN ('N/A', 'NA', '') THEN NULL
            WHEN LENGTH(TRIM(CAST(zip AS STRING))) = 5 THEN TRIM(CAST(zip AS STRING))
            WHEN LENGTH(TRIM(CAST(zip AS STRING))) = 9 THEN TRIM(CAST(zip AS STRING))
            WHEN LENGTH(TRIM(CAST(zip AS STRING))) = 10
                 AND REGEXP_CONTAINS(TRIM(CAST(zip AS STRING)), r'^\d{5}-\d{4}$')
            THEN TRIM(CAST(zip AS STRING))
            ELSE NULL
        END AS zip,

        CASE
            WHEN UPPER(TRIM(borough)) IN ('MANHATTAN', 'NEW YORK COUNTY') THEN 'Manhattan'
            WHEN UPPER(TRIM(borough)) IN ('BRONX', 'THE BRONX') THEN 'Bronx'
            WHEN UPPER(TRIM(borough)) IN ('BROOKLYN', 'KINGS COUNTY') THEN 'Brooklyn'
            WHEN UPPER(TRIM(borough)) IN ('QUEENS', 'QUEEN', 'QUEENS COUNTY') THEN 'Queens'
            WHEN UPPER(TRIM(borough)) IN ('STATEN ISLAND', 'RICHMOND COUNTY') THEN 'Staten Island'
            ELSE 'UNKNOWN'
        END AS borough,

        -- Coordinates
        SAFE_CAST(latitude AS NUMERIC) AS latitude,
        SAFE_CAST(longitude AS NUMERIC) AS longitude,

        -- Submission timestamp
        SAFE_CAST(time_of_submission AS TIMESTAMP) AS time_of_submission,

        -- Metadata
        CURRENT_TIMESTAMP() AS _stg_loaded_at

    FROM source

    WHERE globalid IS NOT NULL

    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY globalid
        ORDER BY time_of_submission DESC
    ) = 1
)

SELECT * FROM cleaned