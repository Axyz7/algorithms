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
  #text(size: 15pt, weight: "bold")[LAB REPORT: SET OPERATIONS, SORTING & RELATIONAL DIVISION] \
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
To understand and execute complex relational SQL operations: Set Theory operations (`UNION`, `INTERSECT`), multi-level result sorting (`ORDER BY`), derived calculations, and Relational Division using nested correlated subqueries.

== Theory
#table(
  columns: (1.2fr, 3fr),
  align: (center + horizon, left + horizon),
  stroke: none,
  table.hline(stroke: 0.8pt),
  [*Operation / Concept*], [*Functional Description*],
  table.hline(stroke: 0.4pt),
  [`UNION`], [Combines the results of two queries into a single distinct result set (eliminates duplicates).],
  [`INTERSECT`], [Returns only the distinct rows that appear in the results of both input queries.],
  [`ORDER BY`], [Sorts the result set by one or more attributes in ascending (`ASC`, default) or descending (`DESC`) order.],
  [`Relational Division`], [Represents queries involving universal quantification ("for all"); implemented in SQL using double `NOT EXISTS` or `GROUP BY ... HAVING COUNT(*)` matching.],
  table.hline(stroke: 0.8pt)
)

#v(0.5em)

=== 1. Projects involving an employee named 'Smith' (as worker or department manager)
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

=== 2. Names of employees who work on some project OR have at least one dependent
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

=== 3. Employees who either manage a department OR have at least one dependent
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

=== 4. Employees who are BOTH department managers AND work on some project
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

=== 5. Employees who BOTH work on projects AND have at least one dependent
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

=== 6. Employees and their projects ordered by department, then last name, then first name
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

=== 7. All employees with salary ordered by department number and descending salary
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

=== 8. Employees and projects ordered by project number, then employee last name
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

=== 9. Dependents ordered by parent employee last name and dependent name
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

=== 10. Projected salaries with a 10% raise for employees working on 'ProductX'
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

=== 11. Names of employees who work on all projects controlled by Department 5 (Relational Division)
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
