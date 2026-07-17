with source as (
    select *
    from {{ source('ops_raw', 'supply_costs') }}
),

renamed as (
    select * except (site_code, invoice_date),
           replace(replace(site_code, 'US-', ''), 'WH-', '') as warehouse_code,
           safe_cast(invoice_date as date) as invoice_date
    from source
)

select * from renamed
