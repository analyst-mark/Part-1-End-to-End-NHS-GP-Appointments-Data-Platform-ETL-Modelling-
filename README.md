📊 NHS GP Appointments – Data Warehouse & Analytics Project

Welcome to the NHS GP Appointments Data Warehouse & Analytics Project! 🚀
This project demonstrates a full end-to-end data engineering and analytics solution using 18 million rows of real NHS open data (GP appointment datasets).
It is designed as a portfolio-grade project showcasing industry best practices in:

Data Engineering

Data Modeling

Data Warehousing (Medallion Architecture)

SQL Development

Analytical Reporting

🏗️ Data Architecture

This project follows a modern Medallion Architecture using Bronze → Silver → Gold layers inside SQL Server:

🔶 Bronze Layer – Raw Data

Stores the raw CSV data exactly as ingested (Appointments & Coverage datasets)

No transformations

Used as the single source of truth

Ideal for auditability

Ingested using SQL Server Bulk Insert / SSMS import

⚪ Silver Layer – Cleaned & Standardised

Includes transformations required to make data usable:

Converting dates, numerical fields, code fields

Standardising appointment status, mode, ICB codes

Deduplication

Data quality rules (null handling, validation)

Indexing for performance (needed for 18M rows)

🟡 Gold Layer – Star Schema for Analytics

Houses fully business-ready analytical data:

Dimension Tables:

Date

Region

Sub-ICB Location

Appointment Status

HCP Type

Appointment Mode

Wait Time Band

Fact Tables:

fact_appointments – granular appointment counts

fact_coverage_monthly – registered patient counts per month

Designed for BI dashboards, Power BI, and SQL analytics.

📖 Project Overview

This project includes:

1️⃣ Data Architecture

Structured Medallion-based warehouse using SQL Server.

2️⃣ ETL Pipelines

End-to-end Extract → Transform → Load pipelines including:

Bulk loading of raw CSV files

Cleansing and conforming 18M appointment rows

Building surrogate keys

Standardising dimensions

Populating fact tables

3️⃣ Data Modeling

A fully implemented star schema optimised for analytical queries:

Fact and dimension tables

Surrogate key strategy

High-performance indexing

Clear table naming conventions

4️⃣ Analytics & Reporting

Advanced analysis answering critical operational questions:

GP appointment trends over time

DNA (Did Not Attend) rates

Appointment mode changes (Face-to-Face vs Telephone vs Video)

Average waiting times

Capacity vs demand (per registered patients)

Region and ICB-level comparisons

🎯 Skills Demonstrated

This repository showcases real-world expertise in:

🔹 Data Engineering

Large-scale ingestion (18M records)

SQL Server ETL

Data standardisation & quality checks

Dimensional modeling (Kimball)

🔹 SQL Development

Complex joins

Aggregations over large datasets

CTEs, windows functions

Performance tuning

🔹 Data Architecture

Designing bronze/silver/gold layers

Building scalable warehouse structures

🔹 Data Analysis

Statistical analysis through SQL

Operational insights

KPI development

Perfect for roles like:

✔️ Data Engineer
✔️ SQL Developer
✔️ ETL Developer
✔️ Analytics Engineer
✔️ BI Developer

🛠️ Important Links & Tools

Everything used in this project is free:

📂 Datasets

NHS GP Appointments & Coverage Open Data (CSV files)

🗃️ SQL Server Express

Lightweight free database for implementing the warehouse.

🧰 SQL Server Management Studio (SSMS)

To manage, query, and build your database.

📘 Git Repository

For version-controlled SQL scripts, ETL stages, and documentation.

📐 DrawIO

To create architecture diagrams and data models.

🧩 Notion Project Template

To track tasks, design epics, and plan the project (Bronze–Silver–Gold flow).

🚀 Project Requirements
Part 1 — Building the Data Warehouse (Data Engineering)
Objective

Develop a modern SQL Server data warehouse to consolidate NHS GP appointment and coverage data for analytical reporting.

Specifications

Data Sources: Two datasets (Appointments + Coverage), delivered as CSV files

Data Quality: Clean and standardise raw data

Integration: Combine both datasets into unified, analytics-ready tables

Modeling: Build star schema with fact & dimension tables

Documentation: Provide clear schema & ETL documentation

Scope: No SCD / historisation required (latest version only)

📊 Part 2 — Analytics & Reporting (Data Analysis)
Objective

Develop SQL-based insights across key healthcare metrics:

Examples:

Appointment volumes by month, region, ICB

DNA rate trends over time

Appointment modes (Face-to-Face, Telephone, Video)

Waiting time band distributions

Capacity vs demand using registered patient counts

These insights inform:

Operational planning

Staffing decisions

Patient demand management

GP accessibility metrics