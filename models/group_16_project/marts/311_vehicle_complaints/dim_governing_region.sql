-- models/marts/dim_governing_region.sql

WITH governing_region AS (
    SELECT DISTINCT
        community_board,
        CAST(council_district AS STRING) AS council_district,
        police_precinct
    FROM {{ ref('stg_nyc_311_vehicle_complaints') }}
    WHERE community_board IS NOT NULL
      AND police_precinct IS NOT NULL
),
dim_governing_region AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key([
            'community_board',
            'council_district',
            'police_precinct'
        ]) }} AS governing_region_key,
        community_board,
        council_district,
        police_precinct
    FROM governing_region
)

SELECT *
FROM dim_governing_region