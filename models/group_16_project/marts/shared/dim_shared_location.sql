with
    locations as (

        select distinct
            borough,
            incident_zip as zip_code,
            street_name,
            cross_street_1 as cross_street_name,
            cast(null as string) as off_street_name
        from {{ ref("stg_nyc_311_vehicle_complaints") }}
        where
            borough is not null and incident_zip is not null and street_name is not null

        union distinct

        select distinct
            borough,
            zip_code,
            on_street_name as street_name,
            cross_street_name,
            off_street_name
        from {{ ref("stg_nyc_vehicle_crashes") }}
        where
            borough is not null and zip_code is not null and on_street_name is not null
    ),

    final as (

        select
            {{
                dbt_utils.generate_surrogate_key(
                    [
                        "borough",
                        "zip_code",
                        "street_name",
                        "cross_street_name",
                        "off_street_name",
                    ]
                )
            }} as location_key,
            borough,
            zip_code,
            street_name,
            cross_street_name,
            off_street_name
        from locations
    )

select *
from final