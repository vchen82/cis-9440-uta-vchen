{{ config(materialized='table') }}

with base as (
    select *
    from {{ ref('stg_nyc_311_vehicle_complaints') }}
),

prep as (
    select
        -- business id
        request_id as unique_key,

        -- dates
        created_date,
        closed_date,

        -- shared location fields (match dim_shared_location logic)
        borough,
        cast(incident_zip as string) as zip_code,
        street_name,
        cross_street_1 as cross_street_name,
        cast(null as string) as off_street_name,

        -- problem detail fields (MUST match dim_problem_details inputs)
        complaint_type,

        -- 👇 CHANGE THESE TWO LINES IF YOUR STAGING USES DIFFERENT COLUMN NAMES
        complaint_detail,
        additional_detail,

        -- governing region fields (match dim_governing_region inputs)
        community_board,
        cast(council_district as string) as council_district,
        police_precinct,

        -- optional attributes (keep if they exist in staging)
        agency,
        status

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
    unique_key,
    date_key,
    location_key,
    problem_details_key,
    governing_region_key,

    cast(created_date as timestamp) as created_ts,
    cast(closed_date as timestamp) as closed_ts,

    agency,
    status

from joined