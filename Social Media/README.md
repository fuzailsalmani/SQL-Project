# Social Media Analytics — SQL Project 📊

A practical **Social Media Analytics database project** built with **MySQL/SQL** to analyze users, social activity, engagement, and content-related data.

This project demonstrates how SQL can be used to transform relational data into meaningful analytical insights through database design, data loading, and analytical queries.

## 📌 Project Overview

The project is divided into three SQL files:

1. **`social_media_analytics_schema.sql`** — creates the database structure and tables.
2. **`social_media_analytics_data.sql`** — loads the project dataset.
3. **`social_media_analytics_queries.sql`** — contains analytical SQL queries used to answer business-style questions.

### Database Tables

The schema contains the following tables:

`users`, `posts`, `comments`, `likes`, `followers`, `hashtags`, `post_hashtags`

## 🎯 Project Objectives

- Analyze social-media activity and user behavior
- Measure engagement and interaction patterns
- Identify high-performing content/users
- Practice multi-table SQL analysis
- Convert raw relational data into useful business insights
- Build a portfolio-ready SQL analytics project

## 🧠 SQL Skills Demonstrated

- JOINs
- GROUP BY
- HAVING
- Subqueries
- CTEs
- CASE Statements

Additional concepts used across the project include:

- `SELECT`, `WHERE`, `ORDER BY`
- Aggregate functions such as `COUNT()`, `SUM()`, `AVG()`, `MAX()`, and `MIN()`
- Data filtering and aggregation
- Relational database concepts
- Primary and foreign key relationships
- Analytical reporting

## 📂 Project Structure

```text
Social-Media-Analytics/
│
├── README.md
├── social_media_analytics_schema.sql
├── social_media_analytics_data.sql
└── social_media_analytics_queries.sql
```

### 1️⃣ Schema File

`social_media_analytics_schema.sql`

Contains the database and table definitions used by the project.

### 2️⃣ Data File

`social_media_analytics_data.sql`

Contains the SQL statements required to populate the database with the project data.

### 3️⃣ Queries File

`social_media_analytics_queries.sql`

Contains the SQL analysis and reporting queries.

## ▶️ How to Run the Project

### Step 1 — Open MySQL Workbench

Open the three SQL files in MySQL Workbench.

### Step 2 — Create the Database

Run:

```sql
SOURCE social_media_analytics_schema.sql;
```

### Step 3 — Load the Data

Run:

```sql
SOURCE social_media_analytics_data.sql;
```

### Step 4 — Run the Analysis

Execute:

```text
social_media_analytics_queries.sql
```

You can then inspect the query results directly in MySQL Workbench.

## 📊 Analytics Covered

The project is designed around questions such as:

- Which users/content generate the highest engagement?
- What patterns can be identified from social-media activity?
- How does engagement vary across users or content?
- Which records represent strong or weak performance?
- What aggregate insights can be derived from the database?
- How can SQL joins and aggregations combine information from multiple tables?

## 💼 Business Value

Social-media analytics can help organizations understand:

- User engagement
- Content performance
- Audience behavior
- Interaction patterns
- High-value users/content
- Overall platform activity

This project demonstrates how a data analyst can use SQL to move from **raw relational data → analysis → actionable insights**.

## 🛠️ Tools & Technologies

- **SQL**
- **MySQL**
- **MySQL Workbench**
- **Git**
- **GitHub**

## 📈 What I Learned

Through this project, I practiced:

- Designing relational database structures
- Loading and working with structured data
- Writing analytical SQL queries
- Combining data using joins
- Aggregating and filtering data
- Solving real-world-style analytical problems
- Organizing SQL projects professionally for GitHub

## 🚀 Future Improvements

Possible future enhancements:

- Build a Power BI/Tableau dashboard
- Connect the database with Python
- Add advanced window-function analysis
- Add stored procedures and triggers where appropriate
- Add query-performance benchmarking
- Add visual screenshots of important query results
- Add an ER diagram to the repository

## 👨‍💻 Author

**Fuzail Salmani**

Aspiring Data Analyst | SQL | Python | Data Science | AI/ML

---

⭐ If you find this project useful, consider giving the repository a star.
