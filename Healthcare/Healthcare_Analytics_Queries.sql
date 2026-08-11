/* =====================================================================
   SQL QUESTIONS - SOLUTIONS WITH EXPLANATIONS
   Hospital Database - Queries, View, Window Function, CTE, Trigger,
   and Table Creation
   ===================================================================== */


/* ---------------------------------------------------------------------
   Q1. List the first 10 patients from the city 'Bengaluru', showing
       patient_id, full name, city, and blood group.

   Explanation:
   We filter the patients table for rows where city = 'Bengaluru',
   sort the results by patient_id in ascending order, and use LIMIT 10
   to return only the first 10 matching rows. CONCAT() combines
   first_name and last_name (with a space in between) into a single
   column called full_name.
--------------------------------------------------------------------- */

select
    patient_id,
    CONCAT(first_name, ' ', last_name) as full_name,
    city,
    blood_group
from patients
where city = 'Bengaluru'
order by patient_id asc
limit 10;


/* ---------------------------------------------------------------------
   Q2. Display all doctors who are currently 'Active' and have more
       than 10 years of experience.

   Explanation:
   A simple filter query on the doctors table. The WHERE clause uses
   AND to combine two conditions: status must equal 'Active', and
   experience_years must be greater than 10. Only rows satisfying both
   conditions are returned.
--------------------------------------------------------------------- */

select doctor_id,
       CONCAT(first_name, ' ', last_name) as doctor_name,
       status,
       experience_years
from doctors
where status = "Active" and experience_years > 10;


/* ---------------------------------------------------------------------
   Q3. Find the total number of patients treated by each doctor.
       Display doctor_id, doctor name, and patient_count.

   Explanation:
   Three tables are joined: patients, appointments, and doctors.
   The join goes from patients -> appointments (on patient_id) ->
   doctors (on doctor_id), so we can connect each appointment back to
   both the patient and the doctor involved.
   COUNT(DISTINCT p.patient_id) counts each patient only once per
   doctor, even if that patient had multiple appointments with the
   same doctor. GROUP BY d.doctor_id produces one row per doctor.
--------------------------------------------------------------------- */

select d.doctor_id,
       CONCAT(d.first_name, ' ', d.last_name) as doctor_name,
       COUNT(distinct p.patient_id) as patient_count
from patients as p
join appointments as a
    on p.patient_id = a.patient_id
join doctors as d
    on a.doctor_id = d.doctor_id
group by d.doctor_id;


/* ---------------------------------------------------------------------
   Q4. For each payment mode, find how many bills are 'Paid' and their
       total net_amount.

   Explanation:
   We first filter the bills table to keep only rows where
   payment_status = 'Paid'. Then we GROUP BY payment_mode so that all
   paid bills using the same mode (e.g. Cash, Card, UPI) are grouped
   together. COUNT(bill_id) gives the number of paid bills per mode,
   and SUM(net_amount) gives the total revenue collected through that
   mode.
--------------------------------------------------------------------- */

select payment_mode,
       COUNT(bill_id) as paid_bill_count,
       SUM(net_amount) as total_net_amount
from bills
where payment_status = "Paid"
group by payment_mode
order by payment_mode asc;


/* ---------------------------------------------------------------------
   Q5. Show top 5 departments with the highest total revenue generated
       from patient bills.

   Explanation:
   Bills are linked to appointments (via appointment_id), and
   appointments are linked to departments (via department_id). After
   joining all three tables, we GROUP BY department_name and use
   SUM(net_amount) to calculate each department's total revenue.
   Sorting by total_revenue DESC and applying LIMIT 5 gives the top 5
   revenue-generating departments.
--------------------------------------------------------------------- */

select d.department_name,
       SUM(b.net_amount) as total_revenue
from bills as b
join appointments as a
    on b.appointment_id = a.appointment_id
join departments as d
    on a.department_id = d.department_id
group by d.department_name
order by total_revenue desc
limit 5;


/* ---------------------------------------------------------------------
   Q6. Create a view named "vw_doctor_revenue" that displays each
       doctor's total revenue collected from paid bills.

   Explanation:
   A VIEW is a saved/stored query that behaves like a virtual table --
   it does not store data itself, it just stores the query definition.
   Here, vw_doctor_revenue joins doctors with bills, filters only
   payment_status = 'paid' rows, and sums net_amount per doctor.
   Once created, this view can be queried directly like a regular
   table (as shown below, filtering for doctors whose total_revenue is
   greater than 1000) without rewriting the underlying join/aggregation
   logic each time.
--------------------------------------------------------------------- */

create view vw_doctor_revenue as
select d.doctor_id,
       CONCAT(d.first_name, ' ', d.last_name) as doctor_name,
       SUM(net_amount) as total_revenue
from doctors as d
join bills as b
    on d.doctor_id = b.doctor_id
where b.payment_status = "paid"
group by d.doctor_id, d.first_name, d.last_name
order by d.doctor_id asc;

-- Using the view
select *
from vw_doctor_revenue
where total_revenue > 1000
order by doctor_id asc;


/* ---------------------------------------------------------------------
   Q7. Identify the top 5 patients who have paid the highest total
       amount across all their bills. Show patient name and total
       amount paid.

   Explanation:
   patients and bills are joined using the shared column patient_id
   (via USING). We filter for payment_status = 'paid', then GROUP BY
   the patient's name and use SUM(total_amount) to add up everything
   that patient has paid across all their bills. Sorting by
   total_amount_paid DESC and LIMIT 5 gives the top 5 highest-paying
   patients.
--------------------------------------------------------------------- */

select CONCAT(first_name, ' ', last_name) as patient_name,
       SUM(total_amount) as total_amount_paid
from patients
join bills
    using (patient_id)
where payment_status = "paid"
group by first_name, last_name
order by total_amount_paid desc
limit 5;


/* ---------------------------------------------------------------------
   Q8. Show a list of medications prescribed by doctors belonging to
       departments whose name contains 'ology' (like Cardiology,
       Neurology, etc.).

   Explanation:
   medications is joined to doctors (via doctor_id), and doctors is
   joined to departments (via department_id). The WHERE clause uses
   LIKE "%ology%" as a pattern match -- the % wildcards mean "any
   characters before and after ology", so it matches Cardiology,
   Neurology, Gastroenterology-type names, etc. The result lists each
   medication's generic name along with the prescribing doctor and
   their department.
--------------------------------------------------------------------- */

select generic_name,
       CONCAT(d.first_name, ' ', d.last_name) as doctor_name,
       de.department_name
from medications as m
join doctors as d
    on m.doctor_id = d.doctor_id
join departments as de
    on d.department_id = de.department_id
where de.department_name like "%ology%"
order by doctor_name asc;


/* ---------------------------------------------------------------------
   Q9. Using a window function, list the top 3 earning patients per
       city based on total amount paid (net_amount from bills).

   Explanation:
   This uses a WINDOW FUNCTION, specifically RANK(). Unlike GROUP BY
   alone, a window function can rank rows within groups ("windows")
   without collapsing them into one row per group.

   Steps:
   1. An inner (subquery) SELECT joins patients and bills, filters for
      payment_status = 'Paid', and groups by patient to compute each
      patient's total_paid (SUM of net_amount) within their city.
   2. RANK() OVER (PARTITION BY p.city ORDER BY SUM(b.net_amount) DESC)
      assigns a rank (1, 2, 3, ...) to each patient *within their own
      city* (PARTITION BY city), ordered from highest to lowest
      total_paid. So the ranking restarts for every new city.
   3. The outer query then filters rank_in_city <= 3, keeping only the
      top 3 earning (highest-paying) patients per city.
--------------------------------------------------------------------- */

select *
from (
    select
        p.city,
        CONCAT(p.first_name, ' ', p.last_name) as patient_name,
        SUM(b.net_amount) as total_paid,
        RANK() over (
            partition by p.city
            order by SUM(b.net_amount) desc
        ) as rank_in_city
    from patients p
    join bills b
        on p.patient_id = b.patient_id
    where b.payment_status = 'Paid'
    group by
        p.patient_id,
        p.first_name,
        p.last_name,
        p.city
) as ranked_patients
where rank_in_city <= 3
order by city, rank_in_city;


/* ---------------------------------------------------------------------
   Q10. Increase the discount by 5% for all bills where
        payment_status = 'Pending'.
        Before updating: check how many such records exist, and
        preview a few rows.
        After update: verify that discounts are correctly applied.

   Explanation:
   This is a safe-update workflow -- a good practice before running
   any UPDATE statement that affects multiple rows:
   1. First, COUNT(*) tells us exactly how many rows will be affected
      before we touch any data.
   2. Next, we SELECT a few sample rows (LIMIT 5) to see their current
      discount values, so we have a "before" snapshot to compare
      against later.
   3. Only then do we run the UPDATE, which adds 5 to the existing
      discount value for every row where payment_status = 'pending'.
   4. Finally, we re-run the same SELECT to confirm ("after" snapshot)
      that the discount values increased as expected.
--------------------------------------------------------------------- */

-- 1. Check how many such records exist
select COUNT(*) as pending_bills
from bills
where payment_status = "pending";

-- 2. Preview a few rows (before update)
select bill_id,
       discount,
       payment_status
from bills
where payment_status = "pending"
limit 5;

-- 3. Perform the update
update bills
set discount = discount + 5
where payment_status = "pending";

-- 4. Verify the update (after update)
select bill_id,
       discount,
       payment_status
from bills
where payment_status = "pending"
limit 5;


/* ---------------------------------------------------------------------
   Q11. Part A - CTE:
        Write a CTE (Common Table Expression) to find doctors who have
        handled more than 8 appointments. Display doctor_id,
        doctor_name, and appointment_count.

   Explanation:
   A CTE, defined using WITH ... AS (...), creates a temporary named
   result set that exists only for the duration of the query that
   follows it -- think of it as a "temporary view" that makes complex
   queries more readable.
   Here, doctor_cte joins appointments with doctors and groups by
   doctor to compute appointment_count (COUNT of appointment_id) per
   doctor. The final SELECT then simply filters that CTE's result for
   appointment_count > 8.
--------------------------------------------------------------------- */

with doctor_cte as (
    select a.doctor_id,
           CONCAT(d.first_name, ' ', d.last_name) as doctor_name,
           COUNT(a.appointment_id) as appointment_count
    from appointments as a
    join doctors as d
        using (doctor_id)
    group by a.doctor_id, d.first_name, d.last_name
)
select *
from doctor_cte
where appointment_count > 8;


/* ---------------------------------------------------------------------
   Q11. Part B - Trigger:
        Create a trigger named trg_update_discount that automatically
        updates the discount field in the bills table to 10% of
        net_amount whenever a new bill is inserted with a NULL
        discount.

   Explanation:
   A TRIGGER is a block of SQL code that runs automatically when a
   specified event occurs on a table -- here, BEFORE INSERT on bills,
   meaning it fires just before a new row is actually written.
   NEW.discount refers to the value being inserted for the discount
   column in the new row; the IF checks whether it is NULL, and if so,
   sets it to a calculated value.

   NOTE - BUG IN THE ORIGINAL QUERY:
   The line "set new.discount = new.discount * 0.10;" is incorrect.
   At this point new.discount IS NULL (that's exactly why the IF
   condition is true), and NULL multiplied by anything (NULL * 0.10)
   always evaluates to NULL in SQL. So this trigger would never
   actually set a discount value -- it would keep it NULL.

   The requirement was "10% of net_amount", so the correct line should
   reference NEW.net_amount instead of NEW.discount:

       set new.discount = new.net_amount * 0.10;

   The original (as submitted) version is shown active below; the
   corrected version follows, commented out for reference.
--------------------------------------------------------------------- */

-- Original (buggy) version, as submitted:
delimiter //
create trigger trg_update_discount
before insert
on bills
for each row
begin
    if new.discount is null then
        set new.discount = new.discount * 0.10;   -- BUG: always stays NULL
    end if;
end //
delimiter ;

-- Corrected version:
-- delimiter //
-- create trigger trg_update_discount
-- before insert
-- on bills
-- for each row
-- begin
--     if new.discount is null then
--         set new.discount = new.net_amount * 0.10;   -- FIXED
--     end if;
-- end //
-- delimiter ;


/* ---------------------------------------------------------------------
   Q12. Create a new database named 'Hospital_Training_DB' and inside
        it create two tables: test_doctors and test_patients.

        test_doctors:
          doctor_id (INT, Primary Key, Auto Increment)
          first_name (VARCHAR(50), Not Null)
          last_name (VARCHAR(50), Not Null)
          specialization (VARCHAR(100))
          experience_years (INT)

        test_patients:
          patient_id (INT, Primary Key, Auto Increment)
          first_name (VARCHAR(50), Not Null)
          last_name (VARCHAR(50), Not Null)
          doctor_id (INT, Foreign Key references test_doctors(doctor_id))
          city (VARCHAR(100))

        Insert two records in each table and verify the relationship
        using a JOIN query.

   Explanation:
   First, a brand-new database Hospital_Training_DB is created and
   selected with USE, so all following statements run inside it.
   test_doctors is created with doctor_id as an auto-incrementing
   primary key. test_patients is created with its own auto-incrementing
   primary key (patient_id), plus a doctor_id column that is declared
   as a FOREIGN KEY referencing test_doctors(doctor_id) -- this
   establishes a relationship, ensuring every patient's doctor_id
   should correspond to a real doctor in test_doctors.

   Records are inserted using two styles: a plain VALUES() insert that
   supplies every column in table order (including an explicit
   doctor_id/patient_id), and a column-list insert that lets
   AUTO_INCREMENT assign the ID automatically.

   Finally, a JOIN between test_doctors and test_patients (using the
   shared doctor_id column) confirms that patients are correctly
   linked to their doctors.

   NOTE - DATA ISSUE:
   The last patient inserted, "Vivek Yadav", is given doctor_id = 103,
   but no doctor with doctor_id = 103 was ever inserted into
   test_doctors (only 101 and two auto-incremented IDs were created).
   If the foreign key constraint is strictly enforced by the database
   engine (e.g. InnoDB with foreign key checks on), this INSERT
   statement would fail with a foreign key constraint error, because
   103 does not exist in test_doctors.doctor_id.
--------------------------------------------------------------------- */

create database Hospital_Training_DB;
use Hospital_Training_DB;

create table test_doctors (
    doctor_id int primary key auto_increment,
    first_name varchar(50) not null,
    last_name varchar(50) not null,
    specialization varchar(100),
    experience_years int
);

create table test_patients (
    patient_id int primary key auto_increment,
    first_name varchar(50) not null,
    last_name varchar(50) not null,
    doctor_id int,
    city varchar(100),
    foreign key (doctor_id) references test_doctors(doctor_id)
);

-- Insert into test_doctors
insert into test_doctors
value (101, "Fuzail", "Salmani", "General Medicine", 12);

insert into test_doctors (first_name, last_name, specialization, experience_years)
value ("Ashta", "Jadhav", "Hematology", 1),
      ("Kshitij", "Panday", "Gastroenterology", 4);

select * from test_doctors;

-- Insert into test_patients
insert into test_patients
value (101, "Aaliya", "Khan", 102, "Mumbai");

insert into test_patients (first_name, last_name, doctor_id, city)
value ("Shivang", "Talati", 101, "Mumbai"),
      ("Ashu", "Singh", 101, "Mumbai");

-- NOTE: doctor_id 103 does not exist in test_doctors -- see explanation above.
insert into test_patients (first_name, last_name, doctor_id, city)
value ("Vivek", "Yadav", 103, "Mumbai");

select * from test_patients;

-- Verify the relationship with a JOIN
select tp.doctor_id,
       CONCAT(td.first_name, ' ', td.last_name) as Doctor_name,
       CONCAT(tp.first_name, ' ', tp.last_name) as patient_name
from test_doctors as td
join test_patients as tp
    using (doctor_id)
group by tp.doctor_id,
         tp.first_name,
         tp.last_name,
         td.first_name,
         td.last_name;