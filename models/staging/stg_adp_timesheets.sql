select *
from {{ source('ops_raw', 'adp_timesheets') }}
