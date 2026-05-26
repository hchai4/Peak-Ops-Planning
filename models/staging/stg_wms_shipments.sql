select *
from {{ source('ops_raw', 'wms_shipments') }}
