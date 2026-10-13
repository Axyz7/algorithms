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
  #text(size: 15pt, weight: "bold")[LAB REPORT: RELATIONAL JOINS & AGGREGATE FUNCTIONS] \
  #v(2pt)
  #text(size: 10pt)[CSBB 204: Database Management Systems | Week 7 (07/09/2026 – 11/09/2026)]
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
To execute relational join operations (Cross Join, Equi-Join, Natural Join, Self Join, Outer Joins) and aggregate calculations (`MIN`, `MAX`, `COUNT`, `SUM`, `AVG`) grouped across relational database entities.

== Theory

#table(
  columns: (1.2fr, 3fr),
  align: (center + horizon, left + horizon),
  stroke: none,
  table.hline(stroke: 0.8pt),
  [*Concept / Function*], [*Functional Description*],
  table.hline(stroke: 0.4pt),
  [`CROSS JOIN`], [Produces the Cartesian product ($M times N$) pairing every row of table $A$ with table $B$.],
  [`INNER / EQUI JOIN`], [Matches rows between tables using an explicit equality predicate (`ON A.id = B.id`).],
  [`SELF JOIN`], [Joins a table to itself to compare records within the same entity relation.],
  [`LEFT / RIGHT JOIN`], [Preserves all records from the prioritized table, populating unmatched outer values with `NULL`.],
  [`FULL OUTER JOIN`], [Preserves all records from both tables; simulated in MariaDB using `LEFT JOIN UNION RIGHT JOIN`.],
  [`Aggregate Functions`], [Calculates single scalar summary values (`COUNT`, `SUM`, `AVG`, `MIN`, `MAX`) across grouped sets.],
  table.hline(stroke: 0.8pt)
)

#v(0.5em)

=== 1. Cartesian product of all employees and all departments
```sql
MariaDB [company]> SELECT e.fname, e.lname, d.dname 
    -> FROM employee e CROSS JOIN department d 
    -> LIMIT 6;
+----------+--------+----------------+
| fname    | lname  | dname          |
+----------+--------+----------------+
| John     | Smith  | Headquarters   |
| John     | Smith  | Production     |
| John     | Smith  | Administration |
| John     | Smith  | Research       |
| Franklin | Wong   | Headquarters   |
| Franklin | Wong   | Production     |
+----------+--------+----------------+
6 rows in set (0.001 sec)
```
 Total combinations produced = $10 text(" employees") times 4 text(" departments") = 40 text(" rows")$.

=== 2. Differences between Cartesian Product and Join Operation

#table(
  columns: (1.2fr, 2fr, 2fr),
  align: (left + horizon, left + horizon, left + horizon),
  stroke: none,
  table.hline(stroke: 0.8pt),
  [*Basis*], [*Cartesian Product (`CROSS JOIN`)*], [*Join Operation (`INNER / EQUI`)*],
  table.hline(stroke: 0.4pt),
  [Predicate / Condition], [No match condition required (`ON` clause omitted).], [Requires an explicit matching condition (`ON` / `WHERE`).],
  [Output Size], [Always returns strictly $M times N$ tuples.], [Returns only tuples that satisfy the join condition ($ M times N$).],
  [Practical Use], [Generates exhaustive permutation matrices.], [Retrieves logically linked relational data across tables.],
  table.hline(stroke: 0.8pt)
)

=== 3. All combinations of employees and projects (Cross Join)
```sql
MariaDB [company]> SELECT e.fname, p.pname 
    -> FROM employee e CROSS JOIN project p 
    -> LIMIT 6;
+-------+-----------------+
| fname | pname           |
+-------+-----------------+
| John  | ProductX        |
| John  | ProductY        |
| John  | ProductZ        |
| John  | ProductA        |
| John  | Computerization |
| John  | Reorganization  |
+-------+-----------------+
6 rows in set (0.001 sec)
```

=== 4. Pairs of employees who work in the same department (Self Join)
```sql
MariaDB [company]> SELECT e1.fname AS emp1, e2.fname AS emp2, e1.dno 
    -> FROM employee e1 
    -> INNER JOIN employee e2 ON e1.dno = e2.dno AND e1.ssn < e2.ssn;
+----------+----------+-----+
| emp1     | emp2     | dno |
+----------+----------+-----+
| Franklin | John     |   5 |
| John     | Ramesh   |   5 |
| Franklin | Ramesh   |   5 |
| Alicia   | Jennifer |   4 |
| Alicia   | Joyce    |   4 |
| Jennifer | Joyce    |   4 |
| Ahmad    | Robert   |   1 |
| James    | Robert   |   1 |
| Ahmad    | James    |   1 |
+----------+----------+-----+
9 rows in set (0.001 sec)
```
 The condition `e1.ssn < e2.ssn` eliminates duplicate inverted pairs (`(A, B)` and `(B, A)`) as well as self-pairings (`(A, A)`).

=== 5. First name, last name, and department name of each employee (Equi-join)
```sql
MariaDB [company]> SELECT e.fname, e.lname, d.dname 
    -> FROM employee e 
    -> INNER JOIN department d ON e.dno = d.dnumber;
+----------+-----------+----------------+
| fname    | lname     | dname          |
+----------+-----------+----------------+
| Robert   | Scott     | Headquarters   |
| Ahmad    | Jabbar    | Headquarters   |
| James    | Borg      | Headquarters   |
| Anirudh  | Periasamy | Headquarters   |
| Alicia   | Zelaya    | Administration |
| Jennifer | Wallace   | Administration |
| Joyce    | English   | Administration |
| John     | Smith     | Research       |
| Franklin | Wong      | Research       |
| Ramesh   | Narayan   | Research       |
+----------+-----------+----------------+
10 rows in set (0.000 sec)
```

=== 6. First name and project name for employees working on projects (Natural Join)
```sql
MariaDB [company]> SELECT e.fname, p.pname 
    -> FROM employee e 
    -> NATURAL JOIN (SELECT essn AS ssn, pno AS pnumber FROM works_on) w 
    -> NATURAL JOIN project p 
    -> LIMIT 6;
+----------+-----------------+
| fname    | pname           |
+----------+-----------------+
| John     | ProductX        |
| John     | ProductY        |
| Franklin | Computerization |
| Franklin | Reorganization  |
| Alicia   | Computerization |
| Alicia   | Allbenefits     |
+----------+-----------------+
6 rows in set (0.001 sec)
```

=== 7. Differences between Equi-Join and Natural Join

#table(
  columns: (1.2fr, 2fr, 2fr),
  align: (left + horizon, left + horizon, left + horizon),
  stroke: none,
  table.hline(stroke: 0.8pt),
  [*Aspect*], [*Equi-Join*], [*Natural Join*],
  table.hline(stroke: 0.4pt),
  [Join Clause], [Requires explicit `ON` or `WHERE` equality condition.], [Implicitly matches on columns having identical names.],
  [Duplicate Columns], [Retains duplicate join columns from both relations.], [Consolidates identical join attributes into a single column.],
  [Column Naming], [Can compare columns with completely different names.], [Strictly requires attributes to share identical names.],
  table.hline(stroke: 0.8pt)
)

=== 8. Left Outer Join: Employees and department names (including unassigned employees)
```sql
MariaDB [company]> SELECT e.fname, e.lname, d.dname 
    -> FROM employee e 
    -> LEFT OUTER JOIN department d ON e.dno = d.dnumber;
+----------+-----------+----------------+
| fname    | lname     | dname          |
+----------+-----------+----------------+
| John     | Smith     | Research       |
| Franklin | Wong      | Research       |
| Robert   | Scott     | Headquarters   |
| Alicia   | Zelaya    | Administration |
| Jennifer | Wallace   | Administration |
| Ramesh   | Narayan   | Research       |
| Joyce    | English   | Administration |
| Ahmad    | Jabbar    | Headquarters   |
| James    | Borg      | Headquarters   |
| Anirudh  | Periasamy | Headquarters   |
+----------+-----------+----------------+
10 rows in set (0.000 sec)
```

=== 9. Right Outer Join: Projects and employee names (including unassigned projects)
```sql
MariaDB [company]> SELECT p.pname, e.fname 
    -> FROM employee e 
    -> INNER JOIN works_on w ON e.ssn = w.essn 
    -> RIGHT OUTER JOIN project p ON w.pno = p.pnumber 
    -> WHERE p.pname = 'ProductA' OR p.pnumber <= 3;
+----------+-------+
| pname    | fname |
+----------+-------+
| ProductX | John  |
| ProductX | Joyce |
| ProductY | John  |
| ProductY | Joyce |
| ProductZ | Ramesh|
| ProductA | NULL  |
+----------+-------+
6 rows in set (0.001 sec)
```
 `ProductA` is preserved despite having no assigned workers, yielding a `NULL` employee value.

=== 10. Full Outer Join: All employees and all projects
```sql
MariaDB [company]> SELECT e.fname, p.pname 
    -> FROM employee e 
    -> LEFT JOIN works_on w ON e.ssn = w.essn 
    -> LEFT JOIN project p ON w.pno = p.pnumber 
    -> UNION 
    -> SELECT e.fname, p.pname 
    -> FROM project p 
    -> LEFT JOIN works_on w ON p.pnumber = w.pno 
    -> LEFT JOIN employee e ON w.essn = e.ssn 
    -> LIMIT 7;
+----------+-----------------+
| fname    | pname           |
+----------+-----------------+
| John     | ProductX        |
| John     | ProductY        |
| Robert   | NULL            |
| Anirudh  | NULL            |
| NULL     | ProductA        |
| Franklin | Computerization |
| Franklin | Reorganization  |
+----------+-----------------+
7 rows in set (0.001 sec)
```
 MariaDB emulates `FULL OUTER JOIN` using `UNION` between corresponding `LEFT` and `RIGHT` queries.

=== 11. SSNs of employees who work on project number 1 (Inner Join)
```sql
MariaDB [company]> SELECT DISTINCT e.ssn, e.fname, e.lname 
    -> FROM employee e 
    -> INNER JOIN works_on w ON e.ssn = w.essn 
    -> WHERE w.pno = 1;
+-----------+-------+---------+
| ssn       | fname | lname   |
+-----------+-------+---------+
| 123456789 | John  | Smith   |
| 453453453 | Joyce | English |
+-----------+-------+---------+
2 rows in set (0.000 sec)
```

=== 12. Left Outer Join: Departments and projects starting with 'P'
```sql
MariaDB [company]> SELECT d.dname, p.pname 
    -> FROM department d 
    -> LEFT OUTER JOIN project p ON d.dnumber = p.dnum AND p.pname LIKE 'P%';
+----------------+----------+
| dname          | pname    |
+----------------+----------+
| Headquarters   | NULL     |
| Production     | ProductA |
| Administration | NULL     |
| Research       | ProductX |
| Research       | ProductY |
| Research       | ProductZ |
+----------------+----------+
6 rows in set (0.000 sec)
```
 Placing `AND p.pname LIKE 'P%'` inside the `ON` clause preserves departments having no matching projects as `NULL` instead of eliminating them.

=== 13. Multiple joins: Employee, department, and project names (including unassigned employees)
```sql
MariaDB [company]> SELECT e.fname, e.lname, d.dname, p.pname 
    -> FROM employee e 
    -> LEFT JOIN department d ON e.dno = d.dnumber 
    -> LEFT JOIN works_on w ON e.ssn = w.essn 
    -> LEFT JOIN project p ON w.pno = p.pnumber 
    -> LIMIT 7;
+----------+---------+----------------+-----------------+
| fname    | lname   | dname          | pname           |
+----------+---------+----------------+-----------------+
| John     | Smith   | Research       | ProductX        |
| John     | Smith   | Research       | ProductY        |
| Franklin | Wong    | Research       | Computerization |
| Franklin | Wong    | Research       | Reorganization  |
| Robert   | Scott   | Headquarters   | NULL            |
| Alicia   | Zelaya  | Administration | Computerization |
| Alicia   | Zelaya  | Administration | Allbenefits     |
+----------+---------+----------------+-----------------+
7 rows in set (0.001 sec)
```

=== 14. Department name and average salary for employees in each department
```sql
MariaDB [company]> SELECT d.dname, ROUND(AVG(e.salary), 2) AS avg_salary 
    -> FROM department d 
    -> INNER JOIN employee e ON d.dnumber = e.dno 
    -> GROUP BY d.dname;
+----------------+------------+
| dname          | avg_salary |
+----------------+------------+
| Administration |   32780.00 |
| Headquarters   |   53613.33 |
| Research       |   39680.00 |
+----------------+------------+
3 rows in set (0.000 sec)
```

=== 15. Summary statistics of all employee salaries
```sql
MariaDB [company]> SELECT 
    ->   SUM(salary)        AS total_salary, 
    ->   MAX(salary)        AS max_salary, 
    ->   MIN(salary)        AS min_salary, 
    ->   ROUND(AVG(salary), 2) AS avg_salary 
    -> FROM employee;
+--------------+------------+------------+------------+
| total_salary | max_salary | min_salary | avg_salary |
+--------------+------------+------------+------------+
|    376780.00 |   70040.00 |   24500.00 |   41864.44 |
+--------------+------------+------------+------------+
1 row in set (0.000 sec)
```

=== 16. Count of employees working on projects in the 'Research' department
```sql
MariaDB [company]> SELECT COUNT(DISTINCT w.essn) AS research_proj_workers 
    -> FROM works_on w 
    -> INNER JOIN project p ON w.pno = p.pnumber 
    -> INNER JOIN department d ON p.dnum = d.dnumber 
    -> WHERE d.dname = 'Research';
+-----------------------+
| research_proj_workers |
+-----------------------+
|                     3 |
+-----------------------+
1 row in set (0.001 sec)
```

=== 17. Number of employees in each department
```sql
MariaDB [company]> SELECT d.dname, COUNT(e.ssn) AS num_employees 
    -> FROM department d 
    -> LEFT OUTER JOIN employee e ON d.dnumber = e.dno 
    -> GROUP BY d.dname;
+----------------+---------------+
| dname          | num_employees |
+----------------+---------------+
| Administration |             3 |
| Headquarters   |             4 |
| Production     |             0 |
| Research       |             3 |
+----------------+---------------+
4 rows in set (0.000 sec)
```

=== 18. Maximum salary in each department
```sql
MariaDB [company]> SELECT d.dname, MAX(e.salary) AS max_salary 
    -> FROM department d 
    -> INNER JOIN employee e ON d.dnumber = e.dno 
    -> GROUP BY d.dname;
+----------------+------------+
| dname          | max_salary |
+----------------+------------+
| Administration |   49340.00 |
| Headquarters   |   70040.00 |
| Research       |   45200.00 |
+----------------+------------+
3 rows in set (0.000 sec)
```
