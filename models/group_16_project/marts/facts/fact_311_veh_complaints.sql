{{ config(materialized='table') }}

with base as (
    select *
    from {{ ref('stg_nyc_311_vehicle_complaints') }}
),

prep as (
    select
        -- Business ID (staging uses request_id; diagram uses veh_complaints_key)
        request_id as veh_complaints_key,

        -- Timestamps/dates
        created_date,
        closed_date,
        due_date,
        resolution_action_updated_date,

        -- Shared location inputs (must match dim_shared_location)
        borough,
        cast(incident_zip as string) as zip_code,
        street_name,
        cross_street_1 as cross_street_name,
        cast(null as string) as off_street_name,

        -- Problem details inputs (must match dim_problem_details)
        complaint_type,
        complaint_detail,
        additional_detail,

        -- Governing region inputs (must match dim_governing_region)
        community_board,
        cast(council_district as string) as council_district,
        police_precinct,

        -- Diagram attributes (from staging)
        location_type,
        incident_address,
        address_type,
        city,
        status,
        resolution_description,
        bbl,
        x_coordinate_state_plane,
        y_coordinate_state_plane,
        method_of_submission,
        vehicle_type,
        latitude,
        longitude

    from base
),

keys as (
    select
        p.*,

        -- keys used to join to dims (match dim key generation order)
        {{ dbt_utils.generate_surrogate_key([
            "borough",
            "zip_code",
            "street_name",
            "cross_street_name",
            "off_street_name"
        ]) }} as location_key_calc,

        {{ dbt_utils.generate_surrogate_key([
            "cast(created_date as date)"
        ]) }} as date_key_calc,

        {{ dbt_utils.generate_surrogate_key([
            "complaint_type",
            "complaint_detail",
            "additional_detail"
        ]) }} as problem_details_key_calc,

        {{ dbt_utils.generate_surrogate_key([
            "community_board",
            "council_district",
            "police_precinct"
        ]) }} as governing_region_key_calc

    from prep p
),

joined as (
    select
        k.*,
        dloc.location_key,
        ddate.date_key,
        dp.problem_details_key,
        dgr.governing_region_key
    from keys k
    left join {{ ref('dim_shared_location') }} dloc
        on dloc.location_key = k.location_key_calc
    left join {{ ref('dim_shared_date') }} ddate
        on ddate.date_key = k.date_key_calc
    left join {{ ref('dim_problem_details') }} dp
        on dp.problem_details_key = k.problem_details_key_calc
    left join {{ ref('dim_governing_region') }} dgr
        on dgr.governing_region_key = k.governing_region_key_calc
)

select
    -- diagram keys
    veh_complaints_key,
    date_key,
    location_key,
    problem_details_key,
    governing_region_key,

    -- diagram wants these as DATE
    cast(created_date as date) as created_date_key,
    cast(closed_date as date) as closed_date_key,

    -- diagram attributes (snake_case versions)
    location_type,
    incident_address,
    address_type,
    city,
    status,
    due_date,
    resolution_description,
    resolution_action_updated_date,
    bbl,
    cast(x_coordinate_state_plane as int64) as x_coordinate_state_plane,
    cast(y_coordinate_state_plane as int64) as y_coordinate_state_plane,
    method_of_submission as open_data_channel_type,
    vehicle_type,
    cast(latitude as float64) as latitude,
    cast(longitude as float64) as longitude,

    -- diagram "Location" as point
    case
      when latitude is not null and longitude is not null
      then st_geogpoint(cast(longitude as float64), cast(latitude as float64))
      else null
    end as location

from joined