
-- models/marts/dim_vehicle_type.sql

WITH vehicle_type AS (
    SELECT DISTINCT
        vehicle_type_code1,
        vehicle_type_code2,
        vehicle_type_code_3,
        vehicle_type_code_4,
        vehicle_type_code_5
    FROM {{ ref('stg_nyc_vehicle_crashes') }}
),

dim_vehicle_type AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key([
            'vehicle_type_code1',
            'vehicle_type_code2',
            'vehicle_type_code_3',
            'vehicle_type_code_4',
            'vehicle_type_code_5'
        ]) }} AS vehicle_type_key,

        vehicle_type_code1,
        vehicle_type_code2,
        vehicle_type_code_3,
        vehicle_type_code_4,
        vehicle_type_code_5

    FROM vehicle_type
)

SELECT *
FROM dim_vehicle_type