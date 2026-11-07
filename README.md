# Peak Ops Planning

This repository contains a dbt project for operational planning and performance analysis across warehouse locations. It brings together planning targets with actual operational results to provide a daily view of throughput, labor, trailer movement, and supply cost performance.

## Overview

The project is designed to answer questions such as:

- How does actual warehouse performance compare with plan?
- Which facilities are below or above expected order and package volume?
- How are labor hours, labor cost, and trailer utilization trending day over day?
- What are the key operational efficiency KPIs by warehouse and date?

The data model is built around a daily operational summary that aligns:

- Planning targets
- WMS shipment data
- ADP timesheet data
- UPS trailer dispatch data
- Supply cost data

## Data Sources

The raw data is mapped under the `ops_raw` source in `models/staging/src_ops.yml`:

- `wms_shipments`: order/package shipment activity from warehouse management system
- `adp_timesheets`: employee labor hours and rate information
- `ups_trailers`: trailer dispatch and origin warehouse details
- `supply_costs`: warehouse supply spend by invoice date and site
- `planning_targets`: forecast planning targets by date and warehouse

## Model Layers

### 1. Staging models

The staging layer standardizes source data into consistent warehouse fields and cleans naming conventions.

Key files:

- `models/staging/stg_wms_shipments.sql`
- `models/staging/stg_adp_timesheets.sql`
- `models/staging/stg_ups_trailers.sql`
- `models/staging/stg_supply_costs.sql`
- `models/staging/stg_planning_targets.sql`

These models:

- normalize warehouse codes
- convert raw date fields to useable date types
- clean naming and source field differences
- prepare the data for downstream joining and aggregation

### 2. Intermediate model

`models/Intermediate/int_capacity_alignment.sql` aligns forecast and actual data to a common daily warehouse grain using a full outer join across key operational datasets.

This model produces a single daily view that includes:

- `op_date`
- `warehouse_code`
- forecast order/package/labor/trailer/supply metrics
- actual order/package/labor/trailer/supply metrics
- variance calculations between plan and actuals

### 3. Mart model

`models/Mart/mart_daily_warehouse_ops.sql` exposes the final business-facing dataset for reporting and analysis.

This mart includes KPIs such as:

- order volume variance
- package volume variance
- labor headcount variance
- labor cost variance
- trailer variance
- supply cost variance
- actual UPH
- labor cost per package
- supply cost per package
- average packages per trailer

## Project Structure

```text
.
├── README.md
├── dbt_project.yml
├── packages.yml
├── models/
│   ├── Intermediate/
│   │   └── int_capacity_alignment.sql
│   ├── Mart/
│   │   └── mart_daily_warehouse_ops.sql
│   └── staging/
│       ├── src_ops.yml
│       ├── stg_adp_timesheets.sql
│       ├── stg_planning_targets.sql
│       ├── stg_supply_costs.sql
│       ├── stg_ups_trailers.sql
│       ├── stg_wms_shipments.sql
└── .vscode/
```

## dbt Project Configuration

The project is configured in `dbt_project.yml` with:

- project name: `Peak_Ops_Planning`
- profile: `Peak_Ops_Planning`
- model paths defined under `models/`
- staging models materialized as views
- dbt utils package enabled for helper functions

## Dependencies

The project uses the following dbt packages:

- `dbt-labs/dbt_utils`
- `brooklyn-data/dbt_artifacts`
- `dbt-labs/dbt-codegen` (via git)

See `packages.yml` for the exact package configuration.

## Getting Started

Prerequisites:

- dbt installed and configured
- warehouse credentials configured for the `Peak_Ops_Planning` profile
- access to the source datasets in the warehouse

Typical commands:

```bash
dbt deps
dbt debug
dbt run
```

To build the full project and refresh the models:

```bash
dbt build
```

## Intended Use

This project is intended to support operational planning analysis and executive reporting for daily warehouse performance. It provides a consistent, analytics-friendly data model that can be used for:

- dashboarding
- operational scorecards
- weekly and daily variance analysis
- labor and cost efficiency reviews
- planning and forecasting validation

## Notes

The project follows a standard dbt transformation pattern:

- source ingestion via raw warehouse tables
- staging cleanup and standardization
- intermediate business logic alignment
- final mart layer for consumption by BI tools and downstream reporting

This design keeps the data pipeline easy to extend and maintain as more operational datasets are added.
