with source as (
    select *
    from {{ source('ops_raw', 'ups_trailers') }}
),

renamed as (
    select * except (dispatch_timestamp),
           date(dispatch_timestamp) as dispatch_date
    from source
)

select * from renamed
