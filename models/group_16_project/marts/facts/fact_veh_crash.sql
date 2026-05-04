{{ config(materialized='table') }}

with base as (
    select *
    from {{ ref('stg_nyc_vehicle_crashes') }}
),

prep as (
    select
        -- Business ID (diagram has veh_crash_key + Collision_ID)
        collision_id,

        crash_date,

        -- Shared location inputs (must match dim_shared_location)
        borough,
        cast(zip_code as string) as zip_code,
        on_street_name as street_name,
        cross_street_name,
        off_street_name,

        -- Dim inputs
        contributing_factor_vehicle_1,
        contributing_factor_vehicle_2,
        contributing_factor_vehicle_3,
        contributing_factor_vehicle_4,
        contributing_factor_vehicle_5,

        vehicle_type_code1,
        vehicle_type_code2,
        vehicle_type_code_3,
        vehicle_type_code_4,
        vehicle_type_code_5,

        cast(persons_injured as int64) as persons_injured,
        cast(persons_killed as int64) as persons_killed,
        cast(pedestrians_injured as int64) as pedestrians_injured,
        cast(pedestrians_killed as int64) as pedestrians_killed,
        cast(cyclists_injured as int64) as cyclists_injured,
        cast(cyclists_killed as int64) as cyclists_killed,
        cast(motorists_injured as int64) as motorists_injured,
        cast(motorists_killed as int64) as motorists_killed,

        -- Diagram attributes
        latitude,
        longitude
    from base
),

keys as (
    select
        p.*,

        {{ dbt_utils.generate_surrogate_key([
            "borough",
            "zip_code",
            "street_name",
            "cross_street_name",
            "off_street_name"
        ]) }} as location_key_calc,

        {{ dbt_utils.generate_surrogate_key([
            "cast(crash_date as date)"
        ]) }} as date_key_calc,

        {{ dbt_utils.generate_surrogate_key([
            "contributing_factor_vehicle_1",
            "contributing_factor_vehicle_2",
            "contributing_factor_vehicle_3",
            "contributing_factor_vehicle_4",
            "contributing_factor_vehicle_5"
        ]) }} as contributing_factor_key_calc,

        {{ dbt_utils.generate_surrogate_key([
            "vehicle_type_code1",
            "vehicle_type_code2",
            "vehicle_type_code_3",
            "vehicle_type_code_4",
            "vehicle_type_code_5"
        ]) }} as vehicle_type_key_calc,

        {{ dbt_utils.generate_surrogate_key([
            "persons_injured",
            "persons_killed",
            "pedestrians_injured",
            "pedestrians_killed",
            "cyclists_injured",
            "cyclists_killed",
            "motorists_injured",
            "motorists_killed"
        ]) }} as people_key_calc

    from prep p
),

joined as (
    select
        k.*,
        dloc.location_key,
        ddate.date_key,
        dcf.contributing_factor_key,
        dvt.vehicle_type_key,
        dpeo.people_key
    from keys k
    left join {{ ref('dim_shared_location') }} dloc
        on dloc.location_key = k.location_key_calc
    left join {{ ref('dim_shared_date') }} ddate
        on ddate.date_key = k.date_key_calc
    left join {{ ref('dim_contributing_factors') }} dcf
        on dcf.contributing_factor_key = k.contributing_factor_key_calc
    left join {{ ref('dim_vehicle_type') }} dvt
        on dvt.vehicle_type_key = k.vehicle_type_key_calc
    left join {{ ref('dim_people') }} dpeo
        on dpeo.people_key = k.people_key_calc
)

select
    -- diagram keys/ids
    collision_id as veh_crash_key,

    contributing_factor_key,
    vehicle_type_key,
    people_key,
    location_key,
    date_key,

    collision_id as collision_id,

    cast(latitude as float64) as latitude,
    cast(longitude as float64) as longitude,

    case
      when latitude is not null and longitude is not null
      then st_geogpoint(cast(longitude as float64), cast(latitude as float64))
      else null
    end as location

from joined