-- Clean and standardize 311 DOT service request data
-- One row per service request

WITH source AS (
   SELECT * FROM {{ source('raw', 'source_dot_service_requests_history') }}
), -- Easier to refer to the dbt reference to a long name table this way

cleaned AS (
   SELECT
       -- Get all columns from source, except ones we're transforming below
       -- To do cleaning on them or explicitly cast them as types just in case
       * EXCEPT (
           unique_key,
           created_date,
           closed_date,
           agency,
           agency_name,
           complaint_type,
           descriptor,
           status,
           incident_zip,
           borough,
           incident_address,
           street_name,
           cross_street_1,
           cross_street_2,
           latitude,
           longitude,
           open_data_channel_type
       ),

       -- Identifiers
       CAST(unique_key AS STRING) AS request_id,

       -- Date/Time
       CAST(created_date AS TIMESTAMP) AS created_date,
       CAST(closed_date AS TIMESTAMP) AS closed_date,

       -- Request details
       CAST(agency AS STRING) AS agency,
       CAST(agency_name AS STRING) AS agency_name,
       CAST(complaint_type AS STRING) AS complaint_type,
       CAST(descriptor AS STRING) AS descriptor,
       UPPER(TRIM(CAST(status AS STRING))) AS status,

       -- Location - clean zip code, handling several common zip code data problems
       CASE
           WHEN UPPER(TRIM(CAST(incident_zip AS STRING))) IN ('N/A', 'NA') THEN NULL
           WHEN UPPER(TRIM(CAST(incident_zip AS STRING))) = 'ANONYMOUS' THEN 'Anonymous'
           WHEN LENGTH(CAST(incident_zip AS STRING)) = 5 THEN CAST(incident_zip AS STRING)
           WHEN LENGTH(CAST(incident_zip AS STRING)) = 9 THEN CAST(incident_zip AS STRING)
           WHEN LENGTH(CAST(incident_zip AS STRING)) = 10
               AND REGEXP_CONTAINS(CAST(incident_zip AS STRING), r'^\d{5}-\d{4}')
           THEN CAST(incident_zip AS STRING)
           ELSE NULL
       END AS incident_zip,

       -- Location - standardized borough, just in case
       CASE
           WHEN UPPER(TRIM(borough)) IN ('MANHATTAN', 'NEW YORK COUNTY') THEN 'Manhattan'
           WHEN UPPER(TRIM(borough)) IN ('BRONX', 'THE BRONX') THEN 'Bronx'
           WHEN UPPER(TRIM(borough)) IN ('BROOKLYN', 'KINGS COUNTY') THEN 'Brooklyn'
           WHEN UPPER(TRIM(borough)) IN ('QUEENS', 'QUEEN', 'QUEENS COUNTY') THEN 'Queens'
           WHEN UPPER(TRIM(borough)) IN ('STATEN ISLAND', 'RICHMOND COUNTY') THEN 'Staten Island'
           ELSE 'UNKNOWN or CITYWIDE'
       END AS borough,

       CAST(incident_address AS STRING) AS incident_address,
       CAST(street_name AS STRING) AS street_name,
       CAST(cross_street_1 AS STRING) AS cross_street_1,
       CAST(cross_street_2 AS STRING) AS cross_street_2,
       CAST(latitude AS DECIMAL) AS latitude,
       CAST(longitude AS DECIMAL) AS longitude,

       -- Clearer column name as well for this one
       CAST(open_data_channel_type AS STRING) AS method_of_submission,

       -- Metadata
       CURRENT_TIMESTAMP() AS _stg_loaded_at

   FROM source

   -- Filters
   WHERE (agency = 'DOT' OR agency_name LIKE '%Transportation%')
   AND unique_key IS NOT NULL
   AND created_date IS NOT NULL
   AND CAST(created_date AS DATE) >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 YEAR)
   AND borough IS NOT NULL

   -- Deduplicate
   QUALIFY ROW_NUMBER() OVER (PARTITION BY unique_key ORDER BY created_date DESC) = 1
)

SELECT * FROM cleaned
-- All should be part of this table: stg_nyc_311_dot

