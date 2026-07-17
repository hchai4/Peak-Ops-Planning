with capacity_alignment as (
    select *
    from {{ ref('int_capacity_alignment') }}
)

select
    ops_summary_id,
    op_date,
    warehouse_code,

    forecast_order_vol,
    actual_order_vol,
    actual_order_vol - forecast_order_vol as order_vol_variance,

    forecast_package_vol,
    actual_package_vol,
    actual_package_vol - forecast_package_vol as package_vol_variance,

    forecast_labor_hc,
    actual_labor_hc,
    actual_labor_hc - forecast_labor_hc as labor_hc_variance,

    forecast_labor_cost,
    actual_labor_cost,
    actual_labor_cost - forecast_labor_cost as labor_cost_variance,
    actual_labor_hours,

    forecast_trailers,
    actual_trailers_dispatched,
    actual_trailers_dispatched - forecast_trailers as trailers_variance,

    forecast_supply_cost,
    actual_supply_cost,
    actual_supply_cost - forecast_supply_cost as supply_cost_variance,

    round(safe_divide(actual_package_vol, actual_labor_hours), 2) as actual_uph,
    round(safe_divide(actual_labor_cost, actual_package_vol), 2) as labor_cost_per_package,
    round(safe_divide(actual_supply_cost, actual_package_vol), 2) as supply_cost_per_package,
    round(safe_divide(actual_package_vol, actual_trailers_dispatched), 2) as average_packages_per_trailer

from capacity_alignment
