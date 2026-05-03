{{ config(materialized='table') }}

with base as (
    select *
    from {{ ref('stg_nyc_311_vehicle_complaints') }}
),

prep as (
    select
        -- Business identifier
        unique_key,

        -- Event timestamps (keep for analysis / auditing)
        created_date,
        closed_date,

        -- Fields needed for DIM KEYS (match dim SQL exactly)
        borough,
        cast(incident_zip as string) as zip_code,
        street_name,
        cross_street_1 as cross_street_name,
        cast(null as string) as off_street_name,

        complaint_type,
        complaint_detail,
        additional_detail,

        community_board,
        cast(council_district as string) as council_district,
        police_precinct,

        -- Any other fields you want to keep in the fact (degenerate dimensions)
        agency,
        status

    from base
),

keys as (
    select
        p.*,

        -- Must match dim_shared_location surrogate key input order
        {{ dbt_utils.generate_surrogate_key([
            "borough",
            "zip_code",
            "street_name",
            "cross_street_name",
            "off_street_name"
        ]) }} as location_key_calc,

        -- Must match dim_shared_date (date-only key)
        {{ dbt_utils.generate_surrogate_key([
            "cast(created_date as date)"
        ]) }} as date_key_calc,

        -- Must match dim_problem_details
        {{ dbt_utils.generate_surrogate_key([
            "complaint_type",
            "complaint_detail",
            "additional_detail"
        ]) }} as problem_details_key_calc,

        -- Must match dim_governing_region
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
    -- Grain: 1 row per 311 request
    unique_key,

    -- Foreign keys
    date_key,
    location_key,
    problem_details_key,
    governing_region_key,

    -- Useful timestamps/attributes
    cast(created_date as timestamp) as created_ts,
    cast(closed_date as timestamp) as closed_ts,
    agency,
    status

from joined
;