with source as (
    select *
    from {{ source('ops_raw', 'supply_costs') }}
),

renamed as (
    select * except (site_code),
           replace(replace(site_code, 'US-', ''), 'WH-', '') as warehouse_code
    from source
)

select * from renamed
