-- Clean and standardize 311 NYP vehicle complaints service request data
-- One row per service request

WITH source AS (
   SELECT * FROM {{ source('raw', 'source_nyc_vehicle_crashes') }}
), -- Easier to refer to the dbt reference to a long name table this way

cleaned AS (
   SELECT
       -- Get all columns from source, except ones we're transforming below
       -- To do cleaning on them or explicitly cast them as types just in case
       * EXCEPT (
           collision_id,
           crash_date,
           crash_time,
           zip_code,
           borough,
           on_street_name,
           cross_street_name,
           off_street_name,
           latitude,
           longitude,
           number_of_persons_injured,
           number_of_persons_killed,
           number_of_pedestrians_injured,
           number_of_pedestrians_killed,
           number_of_cyclist_injured,
           number_of_cyclist_killed,
           number_of_motorist_injured,
           number_of_motorist_killed
           
       ),

       -- Identifiers
       CAST(collision_id AS STRING) AS collision_id,

       -- Date/Time
       CAST(crash_date AS TIMESTAMP) AS crash_date,
       CAST(crash_time AS STRING) AS crash_time,


       -- Humans injured or killed -- recast as integers, not strings
       CAST(number_of_persons_injured AS INT64) AS persons_injured,
       CAST(number_of_persons_killed AS INT64) AS persons_killed,
       CAST(number_of_pedestrians_injured AS INT64) AS pedestrians_injured,
       CAST(number_of_pedestrians_killed AS INT64) AS pedestrians_killed,
       CAST(number_of_cyclist_injured AS INT64) AS cyclists_injured,
       CAST(number_of_cyclist_killed AS INT64) AS cyclists_killed,
       CAST(number_of_motorist_injured AS INT64) AS motorists_injured,
       CAST(number_of_motorist_killed AS INT64) AS motorists_killed,


       -- Location - clean zip code, handling several common zip code data problems
       CASE
           WHEN UPPER(TRIM(CAST(zip_code AS STRING))) IN ('N/A', 'NA') THEN NULL
           WHEN UPPER(TRIM(CAST(zip_code AS STRING))) = 'ANONYMOUS' THEN 'Anonymous'
           WHEN LENGTH(CAST(zip_code AS STRING)) = 5 THEN CAST(zip_code AS STRING)
           WHEN LENGTH(CAST(zip_code AS STRING)) = 9 THEN CAST(zip_code AS STRING)
           WHEN LENGTH(CAST(zip_code AS STRING)) = 10
               AND REGEXP_CONTAINS(CAST(zip_code AS STRING), r'^\d{5}-\d{4}')
           THEN CAST(zip_code AS STRING)
           ELSE NULL
       END AS zip_code,

       -- Location - standardized borough, just in case
       CASE
           WHEN UPPER(TRIM(borough)) IN ('MANHATTAN', 'NEW YORK COUNTY') THEN 'Manhattan'
           WHEN UPPER(TRIM(borough)) IN ('BRONX', 'THE BRONX') THEN 'Bronx'
           WHEN UPPER(TRIM(borough)) IN ('BROOKLYN', 'KINGS COUNTY') THEN 'Brooklyn'
           WHEN UPPER(TRIM(borough)) IN ('QUEENS', 'QUEEN', 'QUEENS COUNTY') THEN 'Queens'
           WHEN UPPER(TRIM(borough)) IN ('STATEN ISLAND', 'RICHMOND COUNTY') THEN 'Staten Island'
           ELSE 'UNKNOWN or CITYWIDE'
       END AS borough,


       CAST(on_street_name AS STRING) AS on_street_name,
       CAST(cross_street_name AS STRING) AS cross_street_name,
       CAST(off_street_name AS STRING) AS off_street_name,


       CAST(latitude AS DECIMAL) AS latitude,
       CAST(longitude AS DECIMAL) AS longitude,

       -- Metadata
       CURRENT_TIMESTAMP() AS _stg_loaded_at

   FROM source

   -- Filters
   WHERE collision_id IS NOT NULL
   AND crash_date IS NOT NULL
   AND CAST(crash_date AS DATETIME) >= DATE_SUB(CURRENT_DATETIME(), INTERVAL 7 YEAR)
   AND borough IS NOT NULL

   -- Deduplicate
   QUALIFY ROW_NUMBER() OVER (PARTITION BY collision_id ORDER BY crash_date DESC) = 1
)

SELECT * FROM cleaned
-- All should be part of this table: stg_nyc_vehicle_crashes