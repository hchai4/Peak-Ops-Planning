with source as (
    select *
    from {{ source('ops_raw', 'wms_shipments') }}
),

renamed as (
    select * except (warehouse_code, wms_timestamp),
           replace(replace(warehouse_code, 'US-', ''), 'WH-', '') as warehouse_code,
           date(wms_timestamp) as shipment_date
    from source
)

select * from renamed
