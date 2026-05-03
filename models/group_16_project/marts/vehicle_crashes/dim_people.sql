
-- models/marts/dim_people.sql

WITH people AS (
    SELECT DISTINCT
        CAST(persons_injured AS INT64) AS persons_injured,
        CAST(persons_killed AS INT64) AS persons_killed,
        CAST(pedestrians_injured AS INT64) AS pedestrians_injured,
        CAST(pedestrians_killed AS INT64) AS pedestrians_killed,
        CAST(cyclists_injured AS INT64) AS cyclists_injured,
        CAST(cyclists_killed AS INT64) AS cyclists_killed,
        CAST(motorists_injured AS INT64) AS motorists_injured,
        CAST(motorists_killed AS INT64) AS motorists_killed
    FROM {{ ref('stg_nyc_vehicle_crashes') }}
),

dim_people AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key([
            'persons_injured',
            'persons_killed',
            'pedestrians_injured',
            'pedestrians_killed',
            'cyclists_injured',
            'cyclists_killed',
            'motorists_injured',
            'motorists_killed'
        ]) }} AS people_key,

        persons_injured,
        persons_killed,
        pedestrians_injured,
        pedestrians_killed,
        cyclists_injured,
        cyclists_killed,
        motorists_injured,
        motorists_killed

    FROM people
)

SELECT *
FROM dim_people