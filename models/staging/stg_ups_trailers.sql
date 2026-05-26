select *
from {{ source('ops_raw', 'ups_trailers') }}
