with aggregated_timesheets as (
    select work_date,
           warehouse_code,
           count(employee_id) as total_hc,
           round(sum(hours_worked), 2) as total_hours_worked,
           round(sum(hourly_rate * hours_worked), 2) as total_labor_cost
    from {{ ref('stg_adp_timesheets') }}
    group by 1, 2
),

aggregated_shipments as (
    select shipment_date,
           warehouse_code,
           round(count(order_id), 0) as total_orders,
           round(count(package_id), 0) as total_packages
    from {{ ref('stg_wms_shipments') }}
    group by 1, 2
),

aggregated_trailers as (
    select dispatch_date,
           origin_wh,
           round(count(trailer_id), 0) as total_trailers
    from {{ ref('stg_ups_trailers') }}
    group by 1, 2
),

final_alignment as (
    select
        -- 使用 coalesce 确保即使某张表缺席，日期和仓库代码依然完整
        coalesce(
            t.work_date,
            s.shipment_date,
            tr.dispatch_date,
            pl.target_date,
            safe_cast(sc.invoice_date as date)
        ) as op_date,
        coalesce(t.warehouse_code, s.warehouse_code, tr.origin_wh, pl.warehouse_code, sc.warehouse_code) as warehouse_code,

        pl.forecast_order_vol,
        coalesce(s.total_orders, 0) as actual_order_vol,

        pl.forecast_package_vol,
        coalesce(s.total_packages, 0) as actual_package_vol,

        pl.forecast_labor_hc,
        coalesce(t.total_hc, 0) as actual_labor_hc,

        pl.forecast_labor_cost,
        coalesce(t.total_labor_cost, 0.0) as actual_labor_cost,
        coalesce(t.total_hours_worked, 0.0) as actual_labor_hours,

        pl.forecast_trailers,
        coalesce(tr.total_trailers, 0) as actual_trailers_dispatched,

        pl.forecast_supply_cost,
        coalesce(sc.total_supply_cost, 0.0) as actual_supply_cost

    from {{ ref('stg_planning_targets') }} pl
    
    full outer join aggregated_timesheets t 
        on pl.target_date = t.work_date and pl.warehouse_code = t.warehouse_code
        
    full outer join aggregated_shipments s 
        on coalesce(pl.target_date, t.work_date) = s.shipment_date 
        and coalesce(pl.warehouse_code, t.warehouse_code) = s.warehouse_code
        
    full outer join aggregated_trailers tr 
        on coalesce(pl.target_date, t.work_date, s.shipment_date) = tr.dispatch_date 
        and coalesce(pl.warehouse_code, t.warehouse_code, s.warehouse_code) = tr.origin_wh
        
    full outer join {{ ref('stg_supply_costs') }} sc 
        on coalesce(pl.target_date, t.work_date, s.shipment_date, tr.dispatch_date) = safe_cast(sc.invoice_date as date) 
        and coalesce(pl.warehouse_code, t.warehouse_code, s.warehouse_code, tr.origin_wh) = sc.warehouse_code
)

-- 5. 生成唯一代理键，输出给 Mart 层
select
    {{ dbt_utils.generate_surrogate_key(['op_date', 'warehouse_code']) }} as ops_summary_id,
    *
from final_alignment