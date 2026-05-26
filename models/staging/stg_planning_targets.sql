select *
from {{ source('ops_raw', 'planning_targets') }}
