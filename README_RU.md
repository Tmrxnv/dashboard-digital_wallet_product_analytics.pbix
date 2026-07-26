# Digital Wallet Product Analytics

[![Python](https://img.shields.io/badge/Python-3.11+-blue)](#)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-SQL-blue)](#)
[![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-yellow)](#)

End-to-end portfolio project analysing customer value, RFM segments, inactivity risk and retention priorities for a synthetic digital-wallet dataset.

**Author:** Osim Temurkhonov  
**GitHub:** [Tmrxnv](https://github.com/Tmrxnv)

## Dashboard

![Power BI dashboard pages](dashboard/screenshots/00_dashboard_pages.png)

Individual screenshots are available in [`dashboard/screenshots`](dashboard/screenshots).

## Business questions

- Which customer segments generate the largest share of LTV?
- Which high-value customers show signs of inactivity?
- How do payment method and app usage relate to customer value?
- Which customers should be prioritised in retention campaigns?
- How do support interactions vary across inactivity groups?

## Key results

| Metric | Result |
|---|---:|
| Customers | 7,000 |
| Total LTV | 3.58B dataset units |
| Average LTV | 511.92K dataset units |
| Average transactions | 501.22 |
| High Value at Risk | 2,208 customers |
| Champions | 1,291 customers |
| Dormant proxy group | 5,887 customers |

### Segment concentration

- **High Value at Risk** accounts for **31.54% of customers** and **43.83% of total LTV**.
- **Champions** account for **18.44% of customers** and **34.76% of total LTV**.
- Combined, these segments contain **49.98% of customers** and generate **78.59% of total LTV**.
- The Critical retention tier contains **552 customers** with average LTV of **1.26M** dataset units.

### Analytical caution

`LTV` has a correlation of **0.999949** with `Total_Spent`. A predictive model using Total Spent to estimate LTV would therefore create target leakage. This project focuses on descriptive segmentation and prioritisation rather than a misleading ML model.

## Technology stack

- **Python:** pandas, matplotlib
- **PostgreSQL:** analytical queries, CTEs, window functions, views
- **Power BI:** DAX measures, slicers, navigation, retention dashboard
- **Jupyter Notebook:** reproducible exploratory analysis

## Repository structure

```text
digital-wallet-product-analytics/
├── README.md
├── README_RU.md
├── requirements.txt
├── .env.example
├── data/
│   ├── README.md
│   ├── raw/
│   └── processed/
├── notebooks/
│   ├── 01_product_analytics.ipynb
│   └── 02_postgresql_load.ipynb
├── src/
│   ├── analysis_pipeline.py
│   └── load_postgres.py
├── sql/
│   ├── 01_analysis_queries.sql
│   ├── 02_create_retention_queue_view.sql
│   └── digital_wallet_product_analytics.sql
├── dashboard/
│   ├── README.md
│   ├── DAX_MEASURES.md
│   └── screenshots/
├── outputs/
│   ├── kpi_summary.csv
│   ├── rfm_summary.csv
│   ├── champions_vs_at_risk.csv
│   └── retention_action_summary.csv
└── reports/
    └── ANALYSIS_REPORT.md
```

## Run locally

### 1. Create the environment

```bash
python -m venv .venv
```

Windows:

```bash
.venv\Scripts\activate
```

macOS/Linux:

```bash
source .venv/bin/activate
```

Install dependencies:

```bash
pip install -r requirements.txt
```

### 2. Add the dataset

Place the source file at:

```text
data/raw/digital_wallet_ltv_dataset.csv
```

### 3. Run the Python pipeline

```bash
python src/analysis_pipeline.py
```

### 4. Load processed data into PostgreSQL

Create a PostgreSQL database named `digital_wallet_analytics`, copy `.env.example` to `.env`, enter your credentials, and run:

```bash
python src/load_postgres.py
```

### 5. Open Power BI

Connect Power BI to:

```text
Server: localhost:5432
Database: digital_wallet_analytics
Tables: public.customer_analytics, public.retention_queue
```

The DAX measures are listed in [`dashboard/DAX_MEASURES.md`](dashboard/DAX_MEASURES.md).

## Methodology

1. Checked missing values, duplicate rows and unique customer IDs.
2. Created age, inactivity and LTV groups.
3. Calculated RFM quartile scores.
4. Assigned business-oriented RFM segments.
5. Built a retention priority score for High Value at Risk customers.
6. Loaded the processed table into PostgreSQL.
7. Created a SQL retention queue with CTEs and window functions.
8. Built a six-page Power BI dashboard.

## Limitations

- The dataset is synthetic and intended for educational use.
- Currency is not specified; monetary values are described as dataset units.
- `Inactivity_Risk` is a heuristic, not confirmed churn.
- RFM recency comparisons are partly mechanical because recency is used in segmentation.
- Small category-level LTV differences should not be interpreted as causal.

Detailed findings are available in [`reports/ANALYSIS_REPORT.md`](reports/ANALYSIS_REPORT.md).
