with source as (
    select *
    from {{ source('ops_raw', 'planning_targets') }}
),

renamed as (
    select * except (wh_code, target_date),
           replace(replace(wh_code, 'US-', ''), 'WH-', '') as warehouse_code,
           safe_cast(target_date as date) as target_date
    from source
)


select * from renamed