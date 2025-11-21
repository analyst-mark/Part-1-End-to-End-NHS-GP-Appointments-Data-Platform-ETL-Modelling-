# Part-1-End-to-End-NHS-GP-Appointments-Data-Platform-ETL-Modelling-

📊 NHS GP Appointments – Data Warehouse & Analytics Project

Welcome to the NHS GP Appointments Data Warehouse & Analytics Project! 🚀
This repository demonstrates a full end-to-end data engineering and analytics solution using over 18 million rows of NHS GP appointment data.

It is designed as a portfolio-ready project that showcases industry-level skills in data engineering, SQL development, data modeling, and analytical reporting.

🏗️ Data Architecture

This project is built using a Medallion Architecture (Bronze → Silver → Gold), implemented in SQL Server.

🔶 Bronze Layer – Raw Data

Stores raw CSV files exactly as provided

Zero transformations

Ensures auditability and reproducibility

Ingested using SQL Server bulk insert / import wizard

⚪ Silver Layer – Cleaned & Conformed

Data cleansing (null handling, deduplication, type conversions)

Standardisation of appointment modes, statuses, ICB codes

Validation checks

Indexing and optimisation for large-volume queries

🟡 Gold Layer – Star Schema

Optimised analytical data model:

Dimensions

dim_date

dim_region

dim_sub_icb

dim_hcp_type

dim_appt_status

dim_appt_mode

dim_wait_time_band

Fact Tables

fact_appointments (18M+ rows)

fact_coverage_monthly

📖 Project Overview

This project includes:

1️⃣ Data Architecture

Design and implementation of a modern SQL data warehouse using Medallion design patterns.

2️⃣ ETL Pipelines

End-to-end development of:

Extract (CSV ingestion)

Transform (cleaning, standardisation)

Load (fact/dimension population)

3️⃣ Data Modeling

Creation of a robust star schema that supports efficient analytical queries.

4️⃣ Analytics & Insights

Development of SQL-based analytics covering:

GP appointment demand

DNA (Did Not Attend) rates

Waiting time band trends

Mode of appointment (F2F, Telephone, Video)

Registered patient coverage

Regional & ICB comparison reports

🎯 Skills Demonstrated

This project demonstrates practical experience in:

Skill Area	Description
Data Engineering	ETL pipelines, large-scale CSV ingestion
SQL Development	Window functions, aggregations, joins
Data Modeling	Dimensional modeling, star schema design
Data Architecture	Medallion architecture implementation
Analytics	KPI development, trend analysis

Relevant for roles such as:
Data Engineer, SQL Developer, ETL Developer, Analytics Engineer, BI Developer

🛠️ Tools & Technologies

Everything used in this project is free:

🔧 Database & Query Tools

SQL Server Express

SQL Server Management Studio (SSMS)

💾 Data Sources

NHS GP Appointments Dataset (CSV)

NHS Patient Coverage Dataset (CSV)

📘 Documentation & Diagrams

Notion – project planning

DrawIO – architecture & modeling diagrams

GitHub – version control

🚀 Project Requirements
Part 1 — Data Warehouse (Data Engineering)
Objective

Build a SQL Server data warehouse that consolidates NHS GP appointment and coverage datasets.

Specifications

Ingest 2 source datasets (Appointments + Coverage)

Cleanse & standardise all data

Integrate fields into dimension/fact schema

No historisation required

Provide full documentation of the data model

Part 2 — Analytics & Reporting (Data Analysis)
Objective

Produce SQL-driven insights focusing on GP operational performance.

Key Themes

Appointment volumes and trends

DNA rate analysis

Wait time band distribution

Mode of appointment comparisons

Capacity vs demand (patients vs appointments)

Regional & ICB comparisons

These insights support operational planning, resource allocation, and patient accessibility metrics.