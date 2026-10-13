#set page(
  paper: "a4",
  margin: (x: 1.8cm, y: 1.8cm),
  footer: context align(center)[#text(size: 8.5pt)[Page #counter(page).display()]]
)
#set text(
  size: 9.5pt,
  font: ("Adwaita Sans", "FreeSans") 
)

#show raw: set text(font: "JetBrains Mono", size: 8.5pt)

#show math.equation: set text(font: "New Computer Modern Math")

#show raw.where(block: true): block.with(
  stroke: 0.5pt + rgb("#d1d5db"),
  inset: 8pt,
  radius: 3pt,
  width: 100%,
  fill: rgb("#f0f2f5") 
)

#show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 0.6em)[
  #text(size: 12pt, weight: "bold")[#it.body]
  #v(-0.2em)
  #line(length: 100%, stroke: 0.8pt)
]

#show heading.where(level: 2): it => block(above: 0.8em, below: 0.4em)[
  #text(size: 10pt, weight: "bold")[#it.body]
]

#align(center)[
  #text(size: 15pt, weight: "bold")[LAB REPORT: DATA MANIPULATION LANGUAGE (DML)] \
  #v(2pt)
  #text(size: 10pt)[CSBB 204: Database Management Systems]
]

#v(0.5em)
#grid(
  columns: (1fr, 1fr),
  align: (left, right),
  [*Name:* Aryan Nautiyal],
  [*Roll Number:* 251210015]
)
#line(length: 100%, stroke: 0.5pt)

== Aim
To understand and execute Data Manipulation Language (DML) operations: `INSERT`, `UPDATE`, `DELETE`, aliasing, column renaming, and selection queries while evaluating database referential integrity constraints.

== Theory

#table(
  columns: (1fr, 3fr),
  align: (center + horizon, left + horizon),
  stroke: none,
  table.hline(stroke: 0.8pt),
  [*Command / Concept*], [*Description*],
  table.hline(stroke: 0.4pt),
  [`INSERT INTO`], [Adds new tuples into a table specified by explicit values or subqueries.],
  [`UPDATE`], [Modifies existing attribute values of matching records in a table.],
  [`DELETE FROM`], [Removes specific tuples from a table based on logical `WHERE` criteria.],
  [`SELECT`], [Retrieves records from one or more tables based on projection and selection criteria.],
  [`AS` (Aliasing)], [Provides temporary labels to columns or tables during query execution.],
  [`Integrity Constraints`], [Enforces Primary Key uniqueness and Foreign Key referential integrity across related tables.],
  table.hline(stroke: 0.8pt)
)

#v(0.5em)

== Terminal Execution & Results

=== (a) Insert record into `employee` table
```sql
MariaDB [company]> INSERT INTO employee 
    -> VALUES ('Robert', 'F', 'Scott', '943775543', '1952-06-21', '2365 Newcastle Rd, Bellaire, TX', 'M', 58000, '888665555', 1);
Query OK, 1 row affected (0.002 sec)
```

=== (b) Insert record into `project` table
```sql
MariaDB [company]> INSERT INTO project 
    -> VALUES ('ProductA', 4, 'Bellaire', 4);
Query OK, 1 row affected (0.001 sec)
```

=== (c) Insert record into `department` table
```sql
MariaDB [company]> INSERT INTO department 
    -> VALUES ('Production', 2, '943775543', '2000-10-13');
Query OK, 1 row affected (0.003 sec)
```

=== (d) Insert record into `works_on` table
```sql
MariaDB [company]> INSERT INTO works_on 
    -> VALUES ('677678989', 4, 40.0);
ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails (`company`.`works_on`, CONSTRAINT `FK_WorksOn_Emp` FOREIGN KEY (`Essn`) REFERENCES `employee` (`ssn`))
```
Employee SSN `'677678989'` does not exist in `employee`, violating foreign key constraint `FK_WorksOn_Emp`.

=== (e) Insert record into `dependent` table
```sql
MariaDB [company]> INSERT INTO dependent 
    -> VALUES ('453453453', 'John', 'M', '1970-12-12', 'SPOUSE', 'abcd@gmail.com');
Query OK, 1 row affected (0.002 sec)
```

=== (f) Insert multiple records into `dependent` table
```sql
MariaDB [company]> INSERT INTO dependent VALUES
    -> ('363453454', 'Matinez', 'M', '1981-11-17', 'SPOUSE', 'martin@gmail.com'),
    -> ('373453455', 'Joseph',  'M', '1988-04-01', 'SON',    'joseph@gmail.com'),
    -> ('383453456', 'Megan',   'F', '1979-10-12', 'SISTER', 'Megan@yahoo.com');
ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails (`company`.`dependent`, CONSTRAINT `FK_Dependent_Emp` FOREIGN KEY (`Essn`) REFERENCES `employee` (`ssn`))
```
None of the referenced SSNs exist in the parent `employee` table.

=== (g) Insert partial record (`ssn`, `fname`, `lname`) into `employee` table
```sql
MariaDB [company]> INSERT INTO employee (ssn, fname, lname)
    -> VALUES ('765893434', 'Anirudh', 'Periasamy');
Query OK, 1 row affected (0.001 sec)
```
Unspecified column `dno` defaults to `1` as defined by table defaults, and `super_ssn` is assigned `NULL`.

=== (h) Create table `employee_bday` and populate from `employee`
```sql
MariaDB [company]> CREATE TABLE employee_bday AS
    -> SELECT fname, lname, bdate FROM employee;
Query OK, 10 rows affected (0.014 sec)
Records: 10  Duplicates: 0  Warnings: 0

MariaDB [company]> SELECT * FROM employee_bday LIMIT 4;
+----------+-------+------------+
| fname    | lname | bdate      |
+----------+-------+------------+
| John     | Smith | 1965-01-09 |
| Franklin | Wong  | 1955-12-08 |
| Robert   | Scott | 1952-06-21 |
| Alicia   | Zelaya| 1968-01-19 |
+----------+-------+------------+
4 rows in set (0.000 sec)
```

=== (i) Insert into `dependent` with dependent name 'Ahmad' and Bdate '1996-01-03'

*Execution without Primary Key (`essn`):*
```sql
MariaDB [company]> INSERT INTO dependent (dependent_name, bdate) VALUES ('Ahmad', '1996-01-03');
ERROR 1364 (HY000): Field 'Essn' doesn't have a default value
```
Fails because `essn` is part of the composite Primary Key `(Essn, Dependent_name)`.

*Execution supplying valid Employee `essn`:*
```sql
MariaDB [company]> INSERT INTO dependent (essn, dependent_name, bdate) VALUES ('943775543', 'Ahmad', '1996-01-03');
Query OK, 1 row affected (0.002 sec)
```

=== (j) Delete record from `dependent` table where dependent name is 'Ahmad'
```sql
MariaDB [company]> DELETE FROM dependent WHERE dependent_name = 'Ahmad';
Query OK, 1 row affected (0.001 sec)
```

=== (k) Delete records from `works_on` table where `essn = '333445555'`
```sql
MariaDB [company]> DELETE FROM works_on WHERE essn = '333445555';
Query OK, 2 rows affected (0.001 sec)
```

=== (l) Delete tuple from `employee` table where `ssn = '987654321'`
```sql
MariaDB [company]> DELETE FROM employee WHERE ssn = '987654321';
ERROR 1451 (23000): Cannot delete or update a parent row: a foreign key constraint fails (`company`.`department`, CONSTRAINT `fk_dept_mgr` FOREIGN KEY (`mgr_ssn`) REFERENCES `employee` (`ssn`))
```
SSN `'987654321'` is assigned as a Manager in `department` and has child rows in `dependent`.

=== (m) Delete tuple from `project` table where `pname = 'ProductX'`
```sql
MariaDB [company]> DELETE FROM project WHERE pname = 'ProductX';
ERROR 1451 (23000): Cannot delete or update a parent row: a foreign key constraint fails (`company`.`works_on`, CONSTRAINT `FK_WorksOn_Proj` FOREIGN KEY (`Pno`) REFERENCES `project` (`Pnumber`))
```
`ProductX` (Pnumber 1) is referenced by active rows in `works_on`.

=== (n) Delete record in `project` table with `pnumber = 20` using RESTRICT and CASCADE

*1. Execution using default RESTRICT:*
```sql
MariaDB [company]> DELETE FROM project WHERE pnumber = 20;
ERROR 1451 (23000): Cannot delete or update a parent row: a foreign key constraint fails (`company`.`works_on`, CONSTRAINT `FK_WorksOn_Proj` FOREIGN KEY (`Pno`) REFERENCES `project` (`Pnumber`))
```
Default `RESTRICT` behavior blocks deletion because referenced child rows exist in `works_on`.

*2. Execution using ON DELETE CASCADE:*
```sql
MariaDB [company]> ALTER TABLE works_on DROP FOREIGN KEY FK_WorksOn_Proj,
    -> ADD CONSTRAINT FK_WorksOn_Proj FOREIGN KEY (Pno) REFERENCES project(Pnumber) ON DELETE CASCADE;
Query OK, 0 rows affected (0.021 sec)

MariaDB [company]> DELETE FROM project WHERE pnumber = 20;
Query OK, 1 row affected (0.003 sec)
```
With `CASCADE`, deleting `pnumber = 20` automatically removes linked rows in `works_on`.

=== (o) Modify `pname` from 'Newbenefits' to 'Allbenefits' in `project` table
```sql
MariaDB [company]> UPDATE project SET pname = 'Allbenefits' WHERE pname = 'Newbenefits';
Query OK, 1 row affected (0.002 sec)
Rows matched: 1  Changed: 1  Warnings: 0
```

=== (p) Modify `mgr_ssn` and `mgr_start_date` for department number 5
```sql
MariaDB [company]> UPDATE department SET mgr_ssn = '123456789', mgr_start_date = '1999-10-01' WHERE dnumber = 5;
Query OK, 1 row affected (0.002 sec)
Rows matched: 1  Changed: 1  Warnings: 0
```

=== (q) Increment salary of all employees by 15% and list updated values
```sql
MariaDB [company]> UPDATE employee SET salary = salary * 1.15;
Query OK, 8 rows affected (0.003 sec)
Rows matched: 10  Changed: 8  Warnings: 0

MariaDB [company]> SELECT fname, lname, salary FROM employee;
+----------+-----------+----------+
| fname    | lname     | salary   |
+----------+-----------+----------+
| John     | Smith     | 34500.00 |
| Franklin | Wong      | 46000.00 |
| Robert   | Scott     | 66700.00 |
| Alicia   | Zelaya    | 28750.00 |
| Jennifer | Wallace   | 49450.00 |
| Ramesh   | Narayan   | 43700.00 |
| Joyce    | English   | 28750.00 |
| Ahmad    | Jabbar    | 28750.00 |
| James    | Borg      | 63250.00 |
| Anirudh  | Periasamy |     NULL |
+----------+-----------+----------+
10 rows in set (0.000 sec)
```

=== (r) Modify `super_ssn` for employee with `ssn = '999887777'` to '943775543'
```sql
MariaDB [company]> UPDATE employee SET super_ssn = '943775543' WHERE ssn = '999887777';
Query OK, 1 row affected (0.001 sec)
Rows matched: 1  Changed: 1  Warnings: 0
```

=== (s) List names of all employees who work in department 5
```sql
MariaDB [company]> SELECT fname, minit, lname FROM employee WHERE dno = 5;
+----------+-------+---------+
| fname    | minit | lname   |
+----------+-------+---------+
| John     | B     | Smith   |
| Franklin | T     | Wong    |
| Ramesh   | K     | Narayan |
+----------+-------+---------+
3 rows in set (0.000 sec)
```

=== (t) List names of all female employees
```sql
MariaDB [company]> SELECT fname, minit, lname FROM employee WHERE sex = 'F';
+----------+-------+---------+
| fname    | minit | lname   |
+----------+-------+---------+
| Alicia   | J     | Zelaya  |
| Jennifer | S     | Wallace |
| Joyce    | A     | English |
+----------+-------+---------+
3 rows in set (0.001 sec)
```

=== (u) List all records of `department` with aliased column names
```sql
MariaDB [company]> SELECT dname AS Domain, dnumber AS Area, mgr_ssn, mgr_start_date FROM department;
+----------------+------+-----------+----------------+
| Domain         | Area | mgr_ssn   | mgr_start_date |
+----------------+------+-----------+----------------+
| Headquarters   |    1 | 888665555 | 1981-06-19     |
| Production     |    2 | 943775543 | 2000-10-13     |
| Administration |    4 | 987654321 | 1995-01-01     |
| Research       |    5 | 123456789 | 1999-10-01     |
+----------------+------+-----------+----------------+
4 rows in set (0.000 sec)
```

=== (v) List record of `project` table using table and column aliases for `pnumber = 20`
```sql
MariaDB [company]> SELECT Pro.pname AS Pn, Pro.pnumber AS Pnm, Pro.plocation AS Plc, Pro.dnum AS Dnm
    -> FROM project AS Pro WHERE Pro.pnumber = 20;
+----------------+-----+---------+-----+
| Pn             | Pnm | Plc     | Dnm |
+----------------+-----+---------+-----+
| Reorganization |  20 | Houston |   1 |
+----------------+-----+---------+-----+
1 row in set (0.000 sec)
```

=== (w) Rename `address` column to `home_address` in `employee` table
```sql
MariaDB [company]> ALTER TABLE employee RENAME COLUMN address TO home_address;
Query OK, 0 rows affected (0.015 sec)
Records: 0  Duplicates: 0  Warnings: 0
```

=== (x) Rename `sex` column to `gender`

*i. `dependent` table:*
```sql
MariaDB [company]> ALTER TABLE dependent RENAME COLUMN sex TO gender;
Query OK, 0 rows affected (0.012 sec)
Records: 0  Duplicates: 0  Warnings: 0
```

*ii. `employee` table:*
```sql
MariaDB [company]> ALTER TABLE employee RENAME COLUMN sex TO gender;
Query OK, 0 rows affected (0.015 sec)
Records: 0  Duplicates: 0  Warnings: 0
```

*Schema Verification:*
```sql
MariaDB [company]> DESCRIBE employee;
+--------------+---------------+------+-----+---------+-------+
| Field        | Type          | Null | Key | Default | Extra |
+--------------+---------------+------+-----+---------+-------+
| fname        | varchar(15)   | NO   |     | NULL    |       |
| minit        | char(1)       | YES  |     | NULL    |       |
| lname        | varchar(15)   | NO   |     | NULL    |       |
| ssn          | char(9)       | NO   | PRI | NULL    |       |
| bdate        | date          | YES  |     | NULL    |       |
| home_address | varchar(50)   | YES  |     | NULL    |       |
| gender       | char(1)       | YES  |     | NULL    |       |
| salary       | decimal(10,2) | YES  |     | NULL    |       |
| super_ssn    | char(9)       | YES  | MUL | NULL    |       |
| dno          | int(11)       | NO   | MUL | 1       |       |
+--------------+---------------+------+-----+---------+-------+
10 rows in set (0.001 sec)
```
