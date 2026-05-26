select *
from {{ source('ops_raw', 'supply_costs') }}
