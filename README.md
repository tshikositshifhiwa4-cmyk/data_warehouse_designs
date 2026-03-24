#  Data Warehouse Designs

![SQL](https://img.shields.io/badge/SQL-Data%20Modeling-blue)
![Schema](https://img.shields.io/badge/Schema-Star%20%26%20Snowflake-orange)
![Status](https://img.shields.io/badge/Project-Active-brightgreen)

---

##  Overview

This repository showcases my work in **data warehouse design and dimensional modeling**, focusing on building scalable schemas for analytical use cases.

It includes structured implementations of:

* ⭐ Star Schema
* ❄️ Snowflake Schema

The goal is to transform raw data into **well-organized, analysis-ready models**.

---

##  Data Modeling Approach

All designs follow **dimensional modeling principles**, where:

* A **fact table** stores measurable business events
* **Dimension tables** provide descriptive context
* Relationships are optimized for **analytical querying and reporting**

---

##  Projects

###  Telco Churn Analysis - Star Schema

####  Schema Overview

This model is designed to analyze **customer churn behavior** in a telecom dataset.

####  Fact Table

**`fact_churn`**

| Column Name      | Description                       |
| ---------------- | --------------------------------- |
| customer_id (FK) | Links to customer                 |
| contract_id (FK) | Links to contract                 |
| payment_id (FK)  | Links to payment                  |
| date_id (FK)     | Links to date                     |
| monthly_charges  | Monthly subscription cost         |
| total_charges    | Total revenue per customer        |
| tenure           | Duration with the company         |
| churn_flag       | Indicates churn (1 = Yes, 0 = No) |

---

####  Dimension Tables

**`dim_customer`**

| Column Name      | Description                     |
| ---------------- | ------------------------------- |
| customer_id (PK) | Unique customer identifier      |
| gender           | Customer gender                 |
| senior_citizen   | Indicates senior status         |
| partner          | Whether customer has a partner  |
| dependents       | Whether customer has dependents |

---

**`dim_contract`**

| Column Name       | Description                |
| ----------------- | -------------------------- |
| contract_id (PK)  | Unique contract identifier |
| contract_type     | Contract duration          |
| paperless_billing | Billing preference         |

---

**`dim_payment`**

| Column Name     | Description               |
| --------------- | ------------------------- |
| payment_id (PK) | Unique payment identifier |
| payment_method  | Payment type              |

---

**`dim_date`**

| Column Name  | Description            |
| ------------ | ---------------------- |
| date_id (PK) | Unique date identifier |
| month        | Month                  |
| year         | Year                   |
| quarter      | Quarter                |

---
![telco_star_schema](https://github.com/user-attachments/assets/f462399b-a659-4583-bfa5-92c58361538c)

##  Key Concepts Demonstrated

* Dimensional modeling
* Fact vs Dimension table design
* Use of primary and foreign keys
* Data structuring for analytics

---

##  Project Structure

```
data-warehouse-designs/
│
├── telco-churn-star-schema/
│   ├── README.md
│   └── schema-design.md
│
└── README.md
```

---

##  Future Improvements

* Add snowflake schema variations
* Expand with additional datasets
* Integrate visualization layers (e.g., Power BI)

---

##  Author

**Tshikosi Tshifhiwa**
Aspiring Data Engineer

