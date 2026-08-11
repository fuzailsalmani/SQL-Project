-- =========================================================
-- StudentDB_Views.sql
-- 10 useful views built on top of StudentDB
-- Run this AFTER StudentDB_Realistic.sql has been imported
-- =========================================================

USE StudentDB;

-- ---------------------------------------------------------
-- 1. Students who scored a Distinction (marks >= 90)
-- ---------------------------------------------------------
CREATE VIEW vw_distinction_students AS
SELECT s.student_id,
       s.first_name,
       s.last_name,
       c.course_name, m.marks, m.grade
FROM Marks m
JOIN Students s
ON s.student_id = m.student_id
JOIN Courses c 
ON c.course_id  = m.course_id
WHERE m.marks >= 90;

-- ---------------------------------------------------------
-- 2. Students who failed, with course details
-- ---------------------------------------------------------
CREATE VIEW vw_failed_students AS
SELECT s.student_id,
       s.first_name, s.last_name,
       c.course_name, m.marks,
       m.semester, m.exam_date
FROM Marks m
JOIN Students s
ON s.student_id = m.student_id
JOIN Courses c 
ON c.course_id  = m.course_id
WHERE m.result = 'Fail';

-- ---------------------------------------------------------
-- 3. Average marks per course
-- ---------------------------------------------------------
CREATE VIEW vw_avg_marks_per_course AS
SELECT c.course_id, c.course_name,
       ROUND(AVG(m.marks), 2) AS avg_marks,
	COUNT(m.mark_id) AS total_attempts
FROM Courses c
JOIN Marks m
ON m.course_id = c.course_id
GROUP BY c.course_id, c.course_name;

-- ---------------------------------------------------------
-- 4. Topper (highest scorer) in each course
-- ---------------------------------------------------------
CREATE VIEW vw_topper_per_course AS
SELECT m.course_id, c.course_name,
       s.student_id, s.first_name, s.last_name,
       m.marks
FROM Marks m
JOIN Students s
ON s.student_id = m.student_id
JOIN Courses c
ON c.course_id  = m.course_id
WHERE m.marks = (
    SELECT MAX(m2.marks) FROM Marks m2 WHERE m2.course_id = m.course_id
);

-- ---------------------------------------------------------
-- 5. Number of students per city
-- ---------------------------------------------------------
CREATE VIEW vw_students_per_city AS
SELECT city, COUNT(*) AS total_students
FROM Students
GROUP BY city
ORDER BY total_students DESC;

-- ---------------------------------------------------------
-- 6. Number of students per state
-- ---------------------------------------------------------
CREATE VIEW vw_students_per_state AS
SELECT state, COUNT(*) AS total_students
FROM Students
GROUP BY state
ORDER BY total_students DESC;

-- ---------------------------------------------------------
-- 7. Gender-wise Pass/Fail breakdown
-- ---------------------------------------------------------
CREATE VIEW vw_gender_pass_fail AS
SELECT s.gender, m.result, COUNT(*) AS total
FROM Marks m
JOIN Students s
ON s.student_id = m.student_id
GROUP BY s.gender, m.result;

-- ---------------------------------------------------------
-- 8. Enrollment count per course (based on Marks records)
-- ---------------------------------------------------------
CREATE VIEW vw_course_enrollment_count AS
SELECT c.course_id, c.course_name, c.level,
       COUNT(m.mark_id) AS enrolled_students
FROM Courses c
LEFT JOIN Marks m
ON m.course_id = c.course_id
GROUP BY c.course_id, c.course_name, c.level;

-- ---------------------------------------------------------
-- 9. Students taking Advanced level courses
-- ---------------------------------------------------------
CREATE VIEW vw_advanced_level_students AS
SELECT s.student_id, s.first_name, s.last_name,
       c.course_name, c.level, c.instructor
FROM Marks m
JOIN Students s
ON s.student_id = m.student_id
JOIN Courses c 
ON c.course_id  = m.course_id
WHERE c.level = 'Advanced';

-- ---------------------------------------------------------
-- 10. Full student result report
-- ---------------------------------------------------------
CREATE VIEW vw_student_result_report AS
SELECT
    s.student_id, s.first_name, s.last_name, s.gender, s.city, s.state,
    c.course_name, c.level, c.instructor,
    m.marks, m.grade, m.semester, m.exam_date, m.result
FROM Marks m
JOIN Students s
ON s.student_id = m.student_id
JOIN Courses c 
ON c.course_id  = m.course_id;

-- =========================================================
-- Example usage:
-- SELECT * FROM vw_distinction_students;
-- SELECT * FROM vw_avg_marks_per_course ORDER BY avg_marks DESC;
-- SELECT * FROM vw_topper_per_course;
-- =========================================================



-- =========================================================
-- StudentDB_BonusChallenges.sql
-- 5 Bonus Challenge Views
-- Each combines: SELECT, FROM, JOIN, WHERE, SUBQUERY,
--                 GROUP BY, HAVING, ORDER BY
-- Run AFTER StudentDB_Realistic.sql
-- =========================================================

USE StudentDB;

-- ---------------------------------------------------------
-- 1. vw_city_high_performance
-- Cities (with more than 15 students) where the average
-- passing marks exceed 70, with at least 5 passers.
-- ---------------------------------------------------------
CREATE VIEW vw_city_high_performance AS
SELECT
    s.city,
    ROUND(AVG(m.marks), 2) AS avg_marks,
    COUNT(*) AS pass_count
FROM Students s
JOIN Marks m ON m.student_id = s.student_id
WHERE m.result = 'Pass'
  AND s.city IN (
        SELECT city FROM Students GROUP BY city HAVING COUNT(*) > 15
      )
GROUP BY s.city
HAVING AVG(m.marks) > 70 AND COUNT(*) >= 5
ORDER BY avg_marks DESC;

-- ---------------------------------------------------------
-- 2. vw_top_instructors
-- Instructors whose students' marks (on results above the
-- overall average) show strong average performance,
-- taught to at least 3 distinct students.
-- ---------------------------------------------------------
CREATE VIEW vw_top_instructors AS
SELECT
    c.instructor,
    ROUND(AVG(m.marks), 2) AS avg_marks,
    COUNT(DISTINCT m.student_id) AS students_taught
FROM Courses c
JOIN Marks m ON m.course_id = c.course_id
WHERE m.marks > (SELECT AVG(marks) FROM Marks)
GROUP BY c.instructor
HAVING COUNT(DISTINCT m.student_id) >= 3
ORDER BY avg_marks DESC;

-- ---------------------------------------------------------
-- 3. vw_consistent_passers
-- Students who have never failed any course, with their
-- total attempted courses and average marks.
-- ---------------------------------------------------------
CREATE VIEW vw_consistent_passers AS
SELECT
    s.student_id,
    s.first_name,
    s.last_name,
    COUNT(m.mark_id) AS total_courses,
    ROUND(AVG(m.marks), 2) AS avg_marks
FROM Students s
JOIN Marks m ON m.student_id = s.student_id
WHERE s.student_id NOT IN (
        SELECT student_id FROM Marks WHERE result = 'Fail'
      )
GROUP BY s.student_id, s.first_name, s.last_name
HAVING COUNT(m.mark_id) >= 1
ORDER BY avg_marks DESC;

-- ---------------------------------------------------------
-- 4. vw_below_level_average_courses
-- Courses whose average marks are below the average marks
-- of ALL courses at the same difficulty level
-- (correlated subquery).
-- ---------------------------------------------------------
CREATE VIEW vw_below_level_average_courses AS
SELECT
    c.course_id,
    c.course_name,
    c.level,
    ROUND(AVG(m.marks), 2) AS course_avg
FROM Courses c
JOIN Marks m ON m.course_id = c.course_id
WHERE m.marks IS NOT NULL
GROUP BY c.course_id, c.course_name, c.level
HAVING AVG(m.marks) < (
    SELECT AVG(m2.marks)
    FROM Marks m2
    JOIN Courses c2 ON c2.course_id = m2.course_id
    WHERE c2.level = c.level
)
ORDER BY course_avg ASC;

-- ---------------------------------------------------------
-- 5. vw_top_states_distinction
-- Top 5 states with the highest number of Distinction
-- (marks >= 90) students.
-- ---------------------------------------------------------
CREATE VIEW vw_top_states_distinction AS
SELECT
    s.state,
    COUNT(*) AS distinction_count
FROM Students s
JOIN Marks m ON m.student_id = s.student_id
WHERE m.marks >= 90
  AND s.state IN (
        SELECT state FROM Students GROUP BY state HAVING COUNT(*) > 10
      )
GROUP BY s.state
HAVING COUNT(*) >= 2
ORDER BY distinction_count DESC
LIMIT 5;

-- =========================================================
-- Example usage:
-- SELECT * FROM vw_city_high_performance;
-- SELECT * FROM vw_top_instructors;
-- SELECT * FROM vw_consistent_passers;
-- SELECT * FROM vw_below_level_average_courses;
-- SELECT * FROM vw_top_states_distinction;
-- =========================================================