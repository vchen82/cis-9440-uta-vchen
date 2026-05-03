
-- models/marts/dim_contributing_factor.sql

WITH contributing_factors AS (
    SELECT DISTINCT
        contributing_factor_vehicle_1,
        contributing_factor_vehicle_2,
        contributing_factor_vehicle_3,
        contributing_factor_vehicle_4,
        contributing_factor_vehicle_5
    FROM {{ ref('stg_nyc_vehicle_crashes') }}
),

dim_contributing_factors AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key([
            'contributing_factor_vehicle_1',
            'contributing_factor_vehicle_2',
            'contributing_factor_vehicle_3',
            'contributing_factor_vehicle_4',
            'contributing_factor_vehicle_5'
        ]) }} AS contributing_factor_key,

        contributing_factor_vehicle_1,
        contributing_factor_vehicle_2,
        contributing_factor_vehicle_3,
        contributing_factor_vehicle_4,
        contributing_factor_vehicle_5

    FROM contributing_factors
)

SELECT *
FROM dim_contributing_factors 