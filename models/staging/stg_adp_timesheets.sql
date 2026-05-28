with source as (
    select *
    from {{ source('ops_raw', 'adp_timesheets') }}
),

cleaned as (
    select timesheet_id,
           employee_id,
           safe.parse_date('%m/%d/%Y', work_date) as work_date,
           case
               when facility_name = 'Dallas_Warehouse' then 'DAL-01'
               else replace(replace(facility_name, 'US-', ''), 'WH-', '')
           end as warehouse_code,
           hours_worked,
           hourly_rate
    from source

)


select * from cleaned