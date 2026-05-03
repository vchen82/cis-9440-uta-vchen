 SELECT
     unique_key,
     created_date,
     complaint_type,
     borough
 FROM {{ source('raw', 'source_nyc_311_vehicle_complaints') }}
 LIMIT 10