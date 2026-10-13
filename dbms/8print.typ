#set page(
  paper: "a4",
  flipped: false,
  margin: (x: 0.1cm, y: 0.1cm),
  columns: 2
)
#set text(
  size: 7pt,
  font: ("Adwaita Sans")
)

#show raw: set text(font: ("JetBrains Mono"), size: 6.6pt)

#show raw.where(block: true): block.with(
  stroke: 0.5pt + rgb("#9ca3af"),
  inset: 1pt,
  radius: 2pt,
  width: 100%,
  fill: rgb("#f8fafc")
)

#let item(title, code) = block(breakable: false, width: 100%, below: 4pt)[
  #text(weight: "bold", size: 7.2pt)[#title]
  #v(-4pt)
  #code
]

#let section(title) = block(
  breakable: false,
  width: 100%,
  above: 4pt,
  below: 4pt,
  inset: (x: 4pt, y: 2pt),
  radius: 2pt,
)[
  #text(weight: "bold", size: 7.5pt, fill: black)[#title]
]

#section("PART A — Set Operations, Ordering & Relational Division")

#item("A.1 Projects Involving 'Smith' (Worker or Manager) — UNION")[
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
]

#item("A.2 Employees on Projects OR with Dependents — UNION")[
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
]

#item("A.3 Dept Managers OR with Dependents — UNION")[
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
]

#item("A.4 BOTH Dept Managers AND on Projects — INTERSECT")[
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
]

#item("A.5 BOTH on Projects AND with Dependents — INTERSECT")[
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
]

#item("A.6 Emp & Projects Ordered by Dept, Lname, Fname")[
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
]

#item("A.7 Emp & Salary Ordered by Dno ASC, Salary DESC")[
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
]

#item("A.8 Emp & Projects Ordered by Pnumber, Lname")[
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
]

#item("A.9 Dependents Ordered by Parent Lname, Dep Name")[
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
]

#item("A.10 Projected 10% Raise for 'ProductX' Workers")[
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
]

#item("A.11 Relational Division — Work on ALL Dept 5 Projects")[
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
]

#section("PART B — Nested & Correlated Subqueries")

#item("B.1 Salary of Emp on Same Project as 'James Borg'")[
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
]

#item("B.2 Employees Whose Spouse Born Before 1960")[
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
]

#item("B.3 Employees with More Than Two Dependents")[
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
]

#item("B.4 Employees with Salary > Alicia's")[
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
]

#item("B.5 Employees with Total Worked Hours > 20")[
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
]

#item("B.6 Older Than ALL Research Dept Employees")[
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
]

#item("B.7 Dependents of Employees Aged > 65")[
```sql
MariaDB [company]> SELECT d.dependent_name, d.relationship, 
    ->        e.fname AS parent_fname, e.lname AS parent_lname 
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
]

#item("B.8 Salary > ALL Employees in Dept 4")[
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
]

#item("B.9 Employees with NO Dependents — NOT EXISTS")[
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
]

#item("B.10 Emp with Dependent of Same Gender — EXISTS")[
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
]

#item("B.11 Worked on EVERY Stafford Project — Division")[
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
]

#item("B.12 Emp in Depts with Multiple City Locations")[
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
]

#item("B.13 Projects with Total Worked Hours > 50")[
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
]

#item("B.14 Dependents AND Same Dept as 'John Smith'")[
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
]

#item("")[
 #image("eer_diagram.png", width: 100%)
]
