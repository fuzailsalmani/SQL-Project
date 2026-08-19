# 🎓 StudentDB - SQL Database Project

A realistic **Student Management Database project** built using **MySQL**. This project simulates a student database containing information about students, courses, and academic performance.

The database includes realistic student data and demonstrates practical SQL concepts such as **JOINs, Views, Aggregate Functions, GROUP BY, HAVING, Subqueries, and Correlated Subqueries**.

## 📌 Project Overview

The purpose of this project is to design and analyze a relational database for managing student academic information.

The database stores:

- Student personal information
- Course details
- Student marks and results
- Academic performance data
- Course-wise and location-wise statistics

The project also includes multiple SQL **Views** that simplify data analysis and generate useful reports.

## 🛠️ Technologies Used

- MySQL
- MySQL Workbench
- SQL

## 📂 Database Structure

Database name:

```sql
StudentDB
```

The project contains three main tables:

### 1. Students

Stores personal and admission information about students.

| Column | Description |
|---|---|
| `student_id` | Unique ID for each student |
| `first_name` | Student's first name |
| `last_name` | Student's last name |
| `gender` | Student gender |
| `date_of_birth` | Date of birth |
| `email` | Unique email address |
| `mobile_number` | Unique mobile number |
| `city` | Student's city |
| `state` | Student's state |
| `admission_date` | Date of admission |

### 2. Courses

Stores information about available courses.

| Column | Description |
|---|---|
| `course_id` | Unique ID for each course |
| `course_name` | Name of the course |
| `level` | Course difficulty level |
| `duration_months` | Course duration |
| `instructor` | Course instructor |
| `credits` | Course credits |

### 3. Marks

Stores student academic performance.

| Column | Description |
|---|---|
| `mark_id` | Unique mark record ID |
| `student_id` | Reference to the student |
| `course_id` | Reference to the course |
| `marks` | Student marks |
| `grade` | Student grade |
| `semester` | Semester information |
| `exam_date` | Date of examination |
| `result` | Pass or Fail |

## 🔗 Database Relationships

```text
Students
    │
    │ student_id
    ▼
   Marks
    ▲
    │ course_id
    │
Courses
```

- Student records are connected to academic marks using `student_id`.
- Course records are connected to academic marks using `course_id`.
- Student, course, and result information can be combined using SQL `JOIN` operations.

## 🔍 SQL Analysis and Views

The project includes SQL views for analyzing student performance:

1. `vw_distinction_students` — Students scoring 90 or above.
2. `vw_failed_students` — Students who failed, along with course and exam details.
3. `vw_avg_marks_per_course` — Average marks and total attempts for each course.
4. `vw_topper_per_course` — Highest-scoring student in every course.
5. `vw_students_per_city` — Number of students from each city.
6. `vw_students_per_state` — Number of students from each state.
7. `vw_gender_pass_fail` — Pass and fail analysis grouped by gender.
8. `vw_course_enrollment_count` — Student record count associated with each course.
9. `vw_advanced_level_students` — Students taking Advanced-level courses.
10. `vw_student_result_report` — Complete student result report.

## 🚀 Bonus SQL Challenges

The project also includes advanced analytical views:

### `vw_city_high_performance`
Finds cities with strong student performance based on student count, average marks, and passing students.

### `vw_top_instructors`
Identifies instructors whose students performed above the overall average.

### `vw_consistent_passers`
Finds students who have never failed a course.

### `vw_below_level_average_courses`
Identifies courses whose average marks are below the average marks of courses in the same difficulty level.

### `vw_top_states_distinction`
Finds the top states with the highest number of distinction students.

## 🧠 SQL Concepts Used

This project demonstrates:

- `CREATE DATABASE`
- `CREATE TABLE`
- Primary Keys
- Foreign Key relationships
- `INSERT INTO`
- `SELECT`
- `WHERE`
- `JOIN`
- `LEFT JOIN`
- `GROUP BY`
- `HAVING`
- `ORDER BY`
- `LIMIT`
- Aggregate Functions
- `COUNT()`
- `AVG()`
- `MAX()`
- `ROUND()`
- `COUNT(DISTINCT ...)`
- Subqueries
- Correlated Subqueries
- `CREATE VIEW`

## 📁 Project Structure

```text
StudentDB/
│
├── StudentDB_Realistic.sql
│   └── Database, tables, and sample data
│
├── studentDB_queries.sql
│   └── Analytical views and SQL challenges
│
└── README.md
    └── Project documentation
```

## ⚙️ How to Run the Project

### Step 1: Clone the Repository

```bash
git clone <your-repository-url>
```

### Step 2: Open MySQL Workbench

Connect to your MySQL server.

### Step 3: Run the Database File

Execute:

```text
StudentDB_Realistic.sql
```

This creates the `StudentDB` database, required tables, and sample data.

### Step 4: Run the Query File

Execute:

```text
studentDB_queries.sql
```

This creates the analytical views and challenge queries.

## 💻 Example Queries

```sql
SELECT * FROM vw_distinction_students;
```

```sql
SELECT *
FROM vw_avg_marks_per_course
ORDER BY avg_marks DESC;
```

```sql
SELECT * FROM vw_topper_per_course;
```

```sql
SELECT * FROM vw_consistent_passers;
```

## 🎯 Learning Objectives

This project was created to practice and improve skills in:

- Database design
- Relational tables
- SQL queries
- JOIN operations
- Data aggregation
- Creating reusable views
- Subqueries
- Analytical SQL problems
- Working with realistic datasets

## 🔮 Future Improvements

Possible future improvements include:

- Adding more foreign key constraints
- Creating stored procedures
- Adding triggers
- Creating indexes for performance optimization
- Adding attendance records
- Adding teacher information
- Creating a student enrollment table
- Building a dashboard using Power BI or Tableau

## 👤 Author

**Fuzail Salmani**

SQL Database Project | StudentDB

---

⭐ If you found this project useful, consider giving the repository a star!
