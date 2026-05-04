{{ config(materialized='table') }}

with all_dates as (

    -- 311 dates (date only)
    select distinct
        cast(created_date as date) as full_date
    from {{ ref('stg_nyc_311_vehicle_complaints') }}
    where created_date is not null

    union distinct

    -- crash dates (date only)
    select distinct
        cast(crash_date as date) as full_date
    from {{ ref('stg_nyc_vehicle_crashes') }}
    where crash_date is not null
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['full_date']) }} as date_key,

        full_date,
        extract(year from full_date) as year,
        extract(month from full_date) as month,
        extract(day from full_date) as day,
        format_date('%A', full_date) as day_of_week,
        format_date('%B', full_date) as month_name,
        extract(dayofweek from full_date) in (1, 7) as is_weekend

    from all_dates
)

select *
from final