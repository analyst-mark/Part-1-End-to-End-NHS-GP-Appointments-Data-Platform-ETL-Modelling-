# 📊 NHS GP Appointments – Data Warehouse & Analytics Project

Welcome to the **NHS GP Appointments Data Warehouse & Analytics Project**! 🚀  
This repository demonstrates a full end-to-end **data engineering and analytics solution** using over **18 million rows** of NHS GP appointment data.

It is designed as a **portfolio-ready project** showcasing industry-level skills in data engineering, SQL development, data modeling, analytics, and data architecture.

---

## 🏗️ Data Architecture (Medallion Design)

This project is built using the modern **Medallion Architecture** (Bronze → Silver → Gold) implemented in SQL Server.

### 🔶 Bronze Layer – Raw Data
- Stores raw CSV data exactly as received  
- No transformations applied  
- Ingested using SQL Server bulk insert / import wizard  
- Ensures complete auditability and reproducibility  

### ⚪ Silver Layer – Cleaned & Conformed
- Cleansing & validation (null handling, trimming, type conversions)  
- Standardisation of appointment codes, ICB codes, modes, statuses  
- Deduplication where required  
- Indexing & performance optimisation for 18M+ rows  

### 🟡 Gold Layer – Star Schema (Analytics-Ready)
**Dimension tables:**
- `dim_date`
- `dim_region`
- `dim_sub_icb`
- `dim_appt_status`
- `dim_hcp_type`
- `dim_appt_mode`
- `dim_wait_time_band`

**Fact tables:**
- `fact_appointments` (granular appointment metrics)
- `fact_coverage_monthly` (registered patient counts)

---

## 📖 Project Overview

### **1️⃣ Data Architecture**
Design and implementation of an enterprise-grade SQL data warehouse following Medallion principles.

### **2️⃣ ETL Pipelines**
- Extract raw CSV files  
- Transform & cleanse data  
- Load fact and dimension tables  
- Enforced data validations and indexing  

### **3️⃣ Data Modeling**
Robust dimensional star schema design enabling fast analytics and intuitive reporting.

### **4️⃣ Analytics & Insights**
SQL-driven reporting and advanced analytical insights covering:
- Appointment volumes  
- DNA (Did Not Attend) rates  
- Waiting time distribution  
- Appointment mode comparison (F2F, Telephone, Video)  
- Registered capacity vs demand  
- Regional & ICB comparisons  

---

## 🎯 Skills Demonstrated

| Skill Area | Description |
|-----------|-------------|
| **Data Engineering** | ETL pipelines, large dataset ingestion, SQL transformations |
| **SQL Development** | Window functions, aggregations, performance tuning |
| **Data Modeling** | Star schema, dimension/fact design, surrogate keys |
| **Data Architecture** | Medallion architecture, scalable warehouse design |
| **Analytics** | KPI design, trend analysis, reporting |

Perfect for roles such as:  
**Data Engineer • SQL Developer • Analytics Engineer • ETL Developer • BI Developer**

---

## 🛠️ Tools & Technologies

### 🔧 Database & Query Tools
- SQL Server Express  
- SQL Server Management Studio (SSMS)

### 💾 Datasets
- NHS GP Appointments Dataset (CSV)  
- NHS Patient Coverage Dataset (CSV)

### 📘 Documentation & Diagrams
- DrawIO (architecture & schema diagrams)  
- Notion (project planning & task tracking)  
- GitHub (version control & CI documentation)

---

## 🚀 Project Requirements

### **Part 1 — Data Warehouse (Data Engineering)**

#### ⭐ Objective
Build a SQL Server data warehouse that consolidates NHS GP appointment and coverage datasets for analytics.

#### 📌 Specifications
- Import two source datasets (Appointments + Coverage)  
- Clean & standardise raw data  
- Integrate fields into analytical star schema  
- No historisation required (latest version only)  
- Provide full data model documentation  

---

### **Part 2 — Analytics & Reporting (Data Analysis)**

#### ⭐ Objective
Produce analytical insights using SQL queries built on top of the warehouse.

#### 🔍 Key Insights
- Appointment demand & trends  
- DNA rate trends  
- Waiting time band analysis  
- Mode comparisons (Face-to-Face vs Telephone vs Video)  
- Regional & ICB performance insights  
- Capacity vs demand (patients vs appointments)  

These insights support operational decision-making for GP practice management and NHS regional planning.

---

## 📂 Suggested Repository Structure

