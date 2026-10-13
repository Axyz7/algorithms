#set page(
  paper: "a4",
  margin: (x: 1cm, y: 1cm),
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
  #text(size: 15pt, weight: "bold")[LAB REPORT: COMPLEX SQL QUERIES] \
  #v(2pt)
  #text(size: 10.5pt)[Set Operations, Ordering, Relational Division & Correlated Subqueries] \
  #v(1pt)
  #text(size: 9.5pt)[CSBB 204: Database Management Systems]
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
To understand and execute advanced relational SQL operations on the Company database: Set Theory operations (`UNION`, `INTERSECT`), hierarchical sorting (`ORDER BY`), Relational Division, uncorrelated nested subqueries, and correlated subqueries utilizing `EXISTS`, `NOT EXISTS`, and quantified operators (`ALL`, `ANY`).

== Theory: Advanced Relational SQL Concepts

#table(
  columns: (1.2fr, 3fr),
  align: (center + horizon, left + horizon),
  stroke: none,
  table.hline(stroke: 0.8pt),
  [*Construct / Concept*], [*Theoretical & Functional Description*],
  table.hline(stroke: 0.4pt),
  [`UNION`], [Combines result sets from multiple `SELECT` queries into a single set, eliminating duplicates.],
  [`INTERSECT`], [Returns distinct tuples that appear simultaneously in both input relations.],
  [`ORDER BY`], [Sorts resulting rows ascendingly (`ASC`) or descendingly (`DESC`) across multiple attributes.],
  [`Nested Subquery`], [An independent subquery enclosed in parentheses whose result feeds into the outer `WHERE` / `FROM` clause.],
  [`Correlated Subquery`], [A subquery that evaluates once per candidate tuple of the outer query, referencing outer attributes.],
  [`EXISTS / NOT EXISTS`], [Boolean tests for the presence or absence of at least one tuple returned by a correlated subquery.],
  [`> ALL / > ANY`], [Quantified comparison requiring a scalar value to exceed every value (`ALL`) or at least one value (`ANY`) in a set.],
  [`Relational Division`], [Universal quantification ("for all"); simulated using double `NOT EXISTS` or exact match cardinality counts.],
  table.hline(stroke: 0.8pt)
)

#v(0.5em)

= PART A: Set Operations, Ordering & Relational Division

=== A.1 List project numbers involving an employee named 'Smith' (as worker or manager)
```sql
MariaDB [company]> (SELECT w.pno AS pnumber 
    ->  FROM works_on w 
    ->  INNER JOIN employee e ON w.essn = e.ssn 
    ->  WHERE e.lname = 'Smith')
    -> UNION
    -> (SELECT p.pnumber 
    ->  FROM project p 
    ->  INNER JOIN department d ON p.dnum = d.dnumber 
    ->  INNER JOIN employee e ON d.mgr_ssn = e.ssn 
    ->  WHERE e.lname = 'Smith');
+---------+
| pnumber |
+---------+
|       1 |
|       2 |
+---------+
2 rows in set (0.001 sec)
```

=== A.2 Names of employees who either work on some project OR have at least one dependent
```sql
MariaDB [company]> SELECT e.fname, e.lname 
    -> FROM employee e 
    -> INNER JOIN works_on w ON e.ssn = w.essn
    -> UNION
    -> SELECT e.fname, e.lname 
    -> FROM employee e 
    -> INNER JOIN dependent d ON e.ssn = d.essn;
+----------+---------+
| fname    | lname   |
+----------+---------+
| John     | Smith   |
| Joyce    | English |
| Ramesh   | Narayan |
| Franklin | Wong    |
| Alicia   | Zelaya  |
| Ahmad    | Jabbar  |
| Jennifer | Wallace |
| James    | Borg    |
+----------+---------+
8 rows in set (0.001 sec)
```

=== A.3 Employees who either manage a department OR have at least one dependent
```sql
MariaDB [company]> SELECT e.fname, e.lname 
    -> FROM employee e 
    -> INNER JOIN department d ON e.ssn = d.mgr_ssn
    -> UNION
    -> SELECT e.fname, e.lname 
    -> FROM employee e 
    -> INNER JOIN dependent dp ON e.ssn = dp.essn;
+----------+---------+
| fname    | lname   |
+----------+---------+
| James    | Borg    |
| Robert   | Scott   |
| Jennifer | Wallace |
| John     | Smith   |
| Franklin | Wong    |
+----------+---------+
5 rows in set (0.001 sec)
```

=== A.4 Employees who are BOTH department managers AND work on some project
```sql
MariaDB [company]> SELECT e.fname, e.lname 
    -> FROM employee e 
    -> INNER JOIN department d ON e.ssn = d.mgr_ssn
    -> INTERSECT
    -> SELECT e.fname, e.lname 
    -> FROM employee e 
    -> INNER JOIN works_on w ON e.ssn = w.essn;
+----------+---------+
| fname    | lname   |
+----------+---------+
| John     | Smith   |
| Jennifer | Wallace |
| James    | Borg    |
+----------+---------+
3 rows in set (0.001 sec)
```

=== A.5 Employees who BOTH work on projects AND have at least one dependent
```sql
MariaDB [company]> SELECT e.fname, e.lname 
    -> FROM employee e 
    -> INNER JOIN works_on w ON e.ssn = w.essn
    -> INTERSECT
    -> SELECT e.fname, e.lname 
    -> FROM employee e 
    -> INNER JOIN dependent d ON e.ssn = d.essn;
+----------+---------+
| fname    | lname   |
+----------+---------+
| John     | Smith   |
| Franklin | Wong    |
| Jennifer | Wallace |
+----------+---------+
3 rows in set (0.001 sec)
```

=== A.6 Employees and projects ordered by department, then last name, then first name
```sql
MariaDB [company]> SELECT d.dname, e.lname, e.fname, p.pname 
    -> FROM employee e 
    -> INNER JOIN department d ON e.dno = d.dnumber
    -> INNER JOIN works_on w ON e.ssn = w.essn
    -> INNER JOIN project p ON w.pno = p.pnumber
    -> ORDER BY d.dname ASC, e.lname ASC, e.fname ASC;
+----------------+---------+----------+-----------------+
| dname          | lname   | fname    | pname           |
+----------------+---------+----------+-----------------+
| Administration | English | Joyce    | ProductX        |
| Administration | English | Joyce    | ProductY        |
| Administration | Wallace | Jennifer | Reorganization  |
| Administration | Wallace | Jennifer | Allbenefits     |
| Administration | Zelaya  | Alicia   | Computerization |
| Administration | Zelaya  | Alicia   | Allbenefits     |
| Headquarters   | Borg    | James    | Reorganization  |
| Headquarters   | Jabbar  | Ahmad    | Computerization |
| Headquarters   | Jabbar  | Ahmad    | Allbenefits     |
| Research       | Narayan | Ramesh   | ProductZ        |
| Research       | Smith   | John     | ProductX        |
| Research       | Smith   | John     | ProductY        |
| Research       | Wong    | Franklin | Computerization |
| Research       | Wong    | Franklin | Reorganization  |
+----------------+---------+----------+-----------------+
14 rows in set (0.001 sec)
```

=== A.7 Employees and salary ordered by department number, then descending salary
```sql
MariaDB [company]> SELECT dno, fname, lname, salary 
    -> FROM employee 
    -> ORDER BY dno ASC, salary DESC;
+-----+----------+-----------+----------+
| dno | fname    | lname     | salary   |
+-----+----------+-----------+----------+
|   1 | Robert   | Scott     | 70040.00 |
|   1 | James    | Borg      | 65900.00 |
|   1 | Ahmad    | Jabbar    | 24500.00 |
|   1 | Anirudh  | Periasamy |     NULL |
|   4 | Jennifer | Wallace   | 49340.00 |
|   4 | Alicia   | Zelaya    | 24500.00 |
|   4 | Joyce    | English   | 24500.00 |
|   5 | Franklin | Wong      | 45200.00 |
|   5 | Ramesh   | Narayan   | 42440.00 |
|   5 | John     | Smith     | 31400.00 |
+-----+----------+-----------+----------+
10 rows in set (0.000 sec)
```

=== A.8 Employees and projects ordered by project number, then employee last name
```sql
MariaDB [company]> SELECT p.pnumber, p.pname, e.lname, e.fname 
    -> FROM project p 
    -> INNER JOIN works_on w ON p.pnumber = w.pno 
    -> INNER JOIN employee e ON w.essn = e.ssn 
    -> ORDER BY p.pnumber ASC, e.lname ASC;
+---------+-----------------+---------+----------+
| pnumber | pname           | lname   | fname    |
+---------+-----------------+---------+----------+
|       1 | ProductX        | English | Joyce    |
|       1 | ProductX        | Smith   | John     |
|       2 | ProductY        | English | Joyce    |
|       2 | ProductY        | Smith   | John     |
|       3 | ProductZ        | Narayan | Ramesh   |
|      10 | Computerization | Jabbar  | Ahmad    |
|      10 | Computerization | Wong    | Franklin |
|      10 | Computerization | Zelaya  | Alicia   |
|      20 | Reorganization  | Borg    | James    |
|      20 | Reorganization  | Wallace | Jennifer |
|      20 | Reorganization  | Wong    | Franklin |
|      30 | Allbenefits     | Jabbar  | Ahmad    |
|      30 | Allbenefits     | Wallace | Jennifer |
|      30 | Allbenefits     | Zelaya  | Alicia   |
+---------+-----------------+---------+----------+
14 rows in set (0.001 sec)
```

=== A.9 Dependents ordered by parent employee last name and dependent name
```sql
MariaDB [company]> SELECT e.lname AS parent_lname, e.fname AS parent_fname, 
    ->        d.dependent_name, d.relationship 
    -> FROM employee e 
    -> INNER JOIN dependent d ON e.ssn = d.essn 
    -> ORDER BY e.lname ASC, d.dependent_name ASC;
+--------------+--------------+----------------+--------------+
| parent_lname | parent_fname | dependent_name | relationship |
+--------------+--------------+----------------+--------------+
| English      | Joyce        | John           | SPOUSE       |
| Scott        | Robert       | Ahmad          | SON          |
| Smith        | John         | Alice          | Daughter     |
| Smith        | John         | Elizabeth      | Spouse       |
| Smith        | John         | Michael        | Son          |
| Wallace      | Jennifer     | Abner          | Spouse       |
| Wong         | Franklin     | Alice          | Daughter     |
| Wong         | Franklin     | Joy            | Spouse       |
| Wong         | Franklin     | Theodore       | Son          |
+--------------+--------------+----------------+--------------+
9 rows in set (0.001 sec)
```

=== A.10 Projected 10% raise for all employees working on 'ProductX'
```sql
MariaDB [company]> SELECT DISTINCT e.fname, e.lname, e.salary AS current_salary, 
    ->        ROUND(e.salary * 1.10, 2) AS raised_salary 
    -> FROM employee e 
    -> INNER JOIN works_on w ON e.ssn = w.essn 
    -> INNER JOIN project p ON w.pno = p.pnumber 
    -> WHERE p.pname = 'ProductX';
+-------+---------+----------------+---------------+
| fname | lname   | current_salary | raised_salary |
+-------+---------+----------------+---------------+
| John  | Smith   |       31400.00 |      34540.00 |
| Joyce | English |       24500.00 |      26950.00 |
+-------+---------+----------------+---------------+
2 rows in set (0.000 sec)
```

=== A.11 Employees who work on ALL projects controlled by department 5 (Relational Division)
```sql
MariaDB [company]> SELECT e.fname, e.lname 
    -> FROM employee e 
    -> WHERE NOT EXISTS (
    ->     SELECT p.pnumber 
    ->     FROM project p 
    ->     WHERE p.dnum = 5 
    ->     AND NOT EXISTS (
    ->         SELECT * 
    ->         FROM works_on w 
    ->         WHERE w.essn = e.ssn AND w.pno = p.pnumber
    ->     )
    -> );
+-------+-------+
| fname | lname |
+-------+-------+
| John  | Smith |
+-------+-------+
1 row in set (0.001 sec)
```
*Note:* Implements Relational Division ($text("WORKS\\_ON") div text("PROJECT")_{text("dnum"=5)}$) via double `NOT EXISTS`.

#v(1em)

= PART B: Nested Queries & Correlated Nested Queries

=== B.1 Salary of all employees working on the same project as 'James Borg'
```sql
MariaDB [company]> SELECT DISTINCT e.fname, e.lname, e.salary 
    -> FROM employee e 
    -> INNER JOIN works_on w ON e.ssn = w.essn 
    -> WHERE w.pno IN (
    ->     SELECT w2.pno 
    ->     FROM works_on w2 
    ->     INNER JOIN employee e2 ON w2.essn = e2.ssn 
    ->     WHERE e2.fname = 'James' AND e2.lname = 'Borg'
    -> ) 
    -> AND NOT (e.fname = 'James' AND e.lname = 'Borg');
+----------+---------+----------+
| fname    | lname   | salary   |
+----------+---------+----------+
| Franklin | Wong    | 45200.00 |
| Jennifer | Wallace | 49340.00 |
+----------+---------+----------+
2 rows in set (0.001 sec)
```

=== B.2 Names of employees whose spouse was born before 1960
```sql
MariaDB [company]> SELECT fname, lname 
    -> FROM employee 
    -> WHERE ssn IN (
    ->     SELECT essn 
    ->     FROM dependent 
    ->     WHERE UPPER(relationship) = 'SPOUSE' AND bdate < '1960-01-01'
    -> );
+----------+---------+
| fname    | lname   |
+----------+---------+
| Franklin | Wong    |
| Jennifer | Wallace |
+----------+---------+
2 rows in set (0.000 sec)
```

=== B.3 Names of employees who have more than two dependents
```sql
MariaDB [company]> SELECT fname, lname 
    -> FROM employee 
    -> WHERE ssn IN (
    ->     SELECT essn 
    ->     FROM dependent 
    ->     GROUP BY essn 
    ->     HAVING COUNT(*) > 2
    -> );
+----------+-------+
| fname    | lname |
+----------+-------+
| John     | Smith |
| Franklin | Wong  |
+----------+-------+
2 rows in set (0.001 sec)
```

=== B.4 Details of employees whose salary is greater than Alicia's salary
```sql
MariaDB [company]> SELECT fname, lname, salary, dno 
    -> FROM employee 
    -> WHERE salary > (
    ->     SELECT salary 
    ->     FROM employee 
    ->     WHERE fname = 'Alicia'
    -> );
+----------+---------+----------+-----+
| fname    | lname   | salary   | dno |
+----------+---------+----------+-----+
| John     | Smith   | 31400.00 |   5 |
| Franklin | Wong    | 45200.00 |   5 |
| Robert   | Scott   | 70040.00 |   1 |
| Jennifer | Wallace | 49340.00 |   4 |
| Ramesh   | Narayan | 42440.00 |   5 |
| James    | Borg    | 65900.00 |   1 |
+----------+---------+----------+-----+
6 rows in set (0.000 sec)
```

=== B.5 Names of employees whose total worked hours exceed 20
```sql
MariaDB [company]> SELECT fname, lname 
    -> FROM employee 
    -> WHERE ssn IN (
    ->     SELECT essn 
    ->     FROM works_on 
    ->     GROUP BY essn 
    ->     HAVING SUM(hours) > 20
    -> );
+----------+---------+
| fname    | lname   |
+----------+---------+
| John     | Smith   |
| Ramesh   | Narayan |
| Joyce    | English |
| Ahmad    | Jabbar  |
| Jennifer | Wallace |
| Alicia   | Zelaya  |
+----------+---------+
6 rows in set (0.001 sec)
```

=== B.6 Employees older than ALL employees working in the Research department
```sql
MariaDB [company]> SELECT fname, lname, bdate 
    -> FROM employee 
    -> WHERE bdate < ALL (
    ->     SELECT bdate 
    ->     FROM employee 
    ->     WHERE dno = (SELECT dnumber FROM department WHERE dname = 'Research')
    -> );
+----------+---------+------------+
| fname    | lname   | bdate      |
+----------+---------+------------+
| Robert   | Scott   | 1952-06-21 |
| Jennifer | Wallace | 1941-06-20 |
| James    | Borg    | 1937-11-10 |
+----------+---------+------------+
3 rows in set (0.001 sec)
```
*Note:* Earlier birth date (`bdate < ALL`) corresponds to greater chronological age.

=== B.7 Dependents of employees whose age exceeds 65 years
```sql
MariaDB [company]> SELECT d.dependent_name, d.relationship, e.fname AS parent_fname, e.lname AS parent_lname 
    -> FROM dependent d 
    -> INNER JOIN employee e ON d.essn = e.ssn 
    -> WHERE e.ssn IN (
    ->     SELECT ssn 
    ->     FROM employee 
    ->     WHERE TIMESTAMPDIFF(YEAR, bdate, '2026-01-01') > 65
    -> );
+----------------+--------------+--------------+--------------+
| dependent_name | relationship | parent_fname | parent_lname |
+----------------+--------------+--------------+--------------+
| Ahmad          | SON          | Robert       | Scott        |
| Franklin       | SON          | Robert       | Scott        |
| Abner          | Spouse       | Jennifer     | Wallace      |
+----------------+--------------+--------------+--------------+
3 rows in set (0.001 sec)
```

=== B.8 Employees whose salary is greater than ALL employees in department 4
```sql
MariaDB [company]> SELECT fname, lname, salary 
    -> FROM employee 
    -> WHERE salary > ALL (
    ->     SELECT salary 
    ->     FROM employee 
    ->     WHERE dno = 4 AND salary IS NOT NULL
    -> );
+--------+-------+----------+
| fname  | lname | salary   |
+--------+-------+----------+
| Robert | Scott | 70040.00 |
| James  | Borg  | 65900.00 |
+--------+-------+----------+
2 rows in set (0.000 sec)
```

=== B.9 Employees who have NO dependents (Correlated NOT EXISTS)
```sql
MariaDB [company]> SELECT e.fname, e.lname 
    -> FROM employee e 
    -> WHERE NOT EXISTS (
    ->     SELECT 1 
    ->     FROM dependent d 
    ->     WHERE d.essn = e.ssn
    -> );
+---------+-----------+
| fname   | lname     |
+---------+-----------+
| Alicia  | Zelaya    |
| Ramesh  | Narayan   |
| Ahmad   | Jabbar    |
| James   | Borg      |
| Anirudh | Periasamy |
+---------+-----------+
5 rows in set (0.001 sec)
```

=== B.10 Employees who have a dependent with the same gender (Correlated EXISTS)
```sql
MariaDB [company]> SELECT e.fname, e.lname, e.gender 
    -> FROM employee e 
    -> WHERE EXISTS (
    ->     SELECT 1 
    ->     FROM dependent d 
    ->     WHERE d.essn = e.ssn AND d.gender = e.gender
    -> );
+----------+-------+--------+
| fname    | lname | gender |
+----------+-------+--------+
| John     | Smith | M      |
| Franklin | Wong  | M      |
| Robert   | Scott | M      |
+----------+-------+--------+
3 rows in set (0.001 sec)
```

=== B.11 Salaries of employees who have worked on EVERY project located in Stafford
```sql
MariaDB [company]> SELECT e.fname, e.lname, e.salary 
    -> FROM employee e 
    -> WHERE NOT EXISTS (
    ->     SELECT p.pnumber 
    ->     FROM project p 
    ->     WHERE p.plocation = 'Stafford' 
    ->     AND NOT EXISTS (
    ->         SELECT 1 
    ->         FROM works_on w 
    ->         WHERE w.essn = e.ssn AND w.pno = p.pnumber
    ->     )
    -> );
+---------+--------+----------+
| fname   | lname  | salary   |
+---------+--------+----------+
| Alicia  | Zelaya | 24500.00 |
| Ahmad   | Jabbar | 24500.00 |
+---------+--------+----------+
2 rows in set (0.001 sec)
```

=== B.12 Employees whose department has locations in more than one city
```sql
MariaDB [company]> SELECT e.fname, e.lname, d.dname 
    -> FROM employee e 
    -> INNER JOIN department d ON e.dno = d.dnumber 
    -> WHERE e.dno IN (
    ->     SELECT dnumber 
    ->     FROM dept_locations 
    ->     GROUP BY dnumber 
    ->     HAVING COUNT(DISTINCT dlocation) > 1
    -> );
+----------+---------+----------+
| fname    | lname   | dname    |
+----------+---------+----------+
| John     | Smith   | Research |
| Franklin | Wong    | Research |
| Ramesh   | Narayan | Research |
+----------+---------+----------+
3 rows in set (0.001 sec)
```
*Note:* Department 5 ('Research') is established across Bellaire, Sugarland, and Houston.

=== B.13 Projects with total worked hours exceeding 50
```sql
MariaDB [company]> SELECT pnumber, pname 
    -> FROM project 
    -> WHERE pnumber IN (
    ->     SELECT pno 
    ->     FROM works_on 
    ->     GROUP BY pno 
    ->     HAVING SUM(hours) > 50
    -> );
+---------+-----------------+
| pnumber | pname           |
+---------+-----------------+
|      10 | Computerization |
|      30 | Allbenefits     |
+---------+-----------------+
2 rows in set (0.001 sec)
```

=== B.14 Employees having at least one dependent AND in the same department as 'John Smith'
```sql
MariaDB [company]> SELECT e.fname, e.lname, e.dno 
    -> FROM employee e 
    -> WHERE e.dno = (
    ->     SELECT dno 
    ->     FROM employee 
    ->     WHERE fname = 'John' AND lname = 'Smith'
    -> ) 
    -> AND EXISTS (
    ->     SELECT 1 
    ->     FROM dependent d 
    ->     WHERE d.essn = e.ssn
    -> );
+----------+-------+-----+
| fname    | lname | dno |
+----------+-------+-----+
| John     | Smith |   5 |
| Franklin | Wong  |   5 |
+----------+-------+-----+
2 rows in set (0.001 sec)
```
