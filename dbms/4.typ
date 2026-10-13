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
  stroke: 0.5pt + luma(80),
  inset: 8pt,
  radius: 2pt,
  width: 100%,
  fill: none 
)

#show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 0.6em)[
  #text(size: 12pt, weight: "bold")[#it.body]
  #v(-0.2em)
  #line(length: 100%, stroke: 0.8pt)
]

#show heading.where(level: 2): it => block(above: 0.8em, below: 0.4em)[
  #text(size: 10pt, weight: "bold")[#it.body]
]
#let mysql-table(headers, ..rows) = {
  let body = rows.pos()
  let nrows = body.len()
  let ncols = headers.len()

  let mono(x, bold: false) = text(
    font: "JetBrains Mono",
    size: 8.5pt,
    weight: if bold { "bold" } else { "regular" }
  )[#x]

  // Table with styling
  block(
    stroke: 0.8pt + luma(100),
    radius: 2pt,
    clip: true,
    )[
    #table(
      columns: (auto,) * ncols,
      stroke: (x, y) => (
        top: none,
        bottom: if y == 0 { 0.8pt + luma(100) } else { none },
        left: none,
        right: none,
      ),
      align: left + horizon,
      inset: (x: 10pt, y: 5pt),
      fill: (x, y) => {
        if y == 0 { white }
        else if calc.rem(y, 2) == 1 { rgb("#e8f3fb") }
        else { white }
      },
      // Header row
      ..headers.map(h => mono(h, bold: true)),
      // Body rows
      ..body.flatten().map(c => mono(c)),
    )
  ]
  
  }

#align(center)[
  #text(size: 15pt, weight: "bold")[LAB REPORT: DATA DEFINITION LANGUAGE (DDL)] \
  #v(2pt)
  #text(size: 10pt)[CSBB 204: Database Management Systems ]
]

#v(0.5em)
#grid(
  columns: (1fr, 1fr),
  align: (left, right),
  [*Name:* Aryan Nautiyal  ],
  [*Roll Number:* 251210015 ]
)
#line(length: 100%, stroke: 0.5pt)

== Aim
To understand and execute Data Definition Language (DDL) commands: `CREATE`, `ALTER`, `RENAME`, `TRUNCATE`, `DROP`, and constraint operations. 

== Theory

#table(
  columns: (1fr, 3fr),
  align: (center + horizon, left + horizon),
  stroke: none,
  table.hline(stroke: 0.8pt),
  [*Command*], [*Description*],
  table.hline(stroke: 0.4pt),
  [`CREATE`], [Defines a new database object such as a table, index, or view.],
  [`ALTER`], [Modifies the structure of an existing object (add/drop/modify columns and constraints).],
  [`RENAME`], [Changes the name of an existing database object.],
  [`TRUNCATE`], [Removes all rows from a table without logging individual row deletions; cannot be rolled back in most DBMSs.],
  [`DROP`], [Deletes an entire object from the database schema.],
  [`DELETE`], [DML command that removes selected rows; can be rolled back and fires triggers.],
  table.hline(stroke: 0.8pt)
)

#v(0.5em)

== SQL Solutions and Output

=== (a) Create `employee_details` and rename to `emp_details`
```sql
CREATE TABLE employee_details (
    eid       INT PRIMARY KEY,
    ename     VARCHAR(50),
    eaddress  VARCHAR(100),
    dob       DATE
);
```

```sql
ALTER TABLE employee_details RENAME TO emp_details;
```

*Verification:*
```sql
SHOW TABLES;
```
#mysql-table(
  ("Tables_in_aryan",),
  ("department",),
  ("dependent",),
  ("dept_locations",),
  ("emp_details",),
  ("employee",),
  ("project",),
  ("works_on",),
)

=== (b) Remove all records from `emp_details`
```sql
TRUNCATE TABLE emp_details;
```

=== (c) Add column `contact_no VARCHAR(10)`
```sql
ALTER TABLE emp_details ADD contact_no VARCHAR(10);
```

*Verification:*
```sql
DESCRIBE emp_details;
```
#mysql-table(
  ("Field", "Type", "Null", "Key", "Default", "Extra"),
  ("eid",         "int",          "NO",  "PRI", "NULL", ""),
  ("ename",       "varchar(50)",  "YES", "",    "NULL", ""),
  ("eaddress",    "varchar(100)", "YES", "",    "NULL", ""),
  ("dob",         "date",         "YES", "",    "NULL", ""),
  ("contact_no",  "varchar(10)",  "YES", "",    "NULL", ""),
)

=== (d) Modify column to accept non-null values only
```sql
ALTER TABLE emp_details MODIFY ename VARCHAR(50) NOT NULL;
```

*Verification:*
```sql
DESCRIBE emp_details;
```
#mysql-table(
  ("Field", "Type", "Null", "Key", "Default", "Extra"),
  ("eid",         "int",         "NO",  "PRI", "NULL", ""),
  ("ename",       "varchar(50)", "NO",  "",    "NULL", ""),
  ("eaddress",    "varchar(100)", "YES", "",    "NULL", ""),
  ("dob",         "date",         "YES", "",    "NULL", ""),
  ("contact_no",  "varchar(10)",  "YES", "",    "NULL", ""),
)

=== (e) Drop column `contact_no`
```sql
ALTER TABLE emp_details DROP COLUMN contact_no;
```

=== (f) Add and drop table constraints
```sql
ALTER TABLE emp_details ADD CONSTRAINT uq_ename UNIQUE (ename);
```

```sql
ALTER TABLE emp_details DROP CONSTRAINT uq_ename;
```

=== (g) Drop `emp_details` using CASCADE and RESTRICT

*Using CASCADE:*
```sql
DROP TABLE emp_details CASCADE;
```

*Using RESTRICT:*
```sql
DROP TABLE emp_details RESTRICT;
```

*Difference:*
- *CASCADE:* Automatically drops all dependent objects (views, foreign key constraints, triggers) along with the table. No error is raised even if dependencies exist.
- *RESTRICT:* Refuses to drop the table if any dependent objects exist. The operation fails with an error, protecting against accidental data loss.

=== (h) Difference between `TRUNCATE` and `DELETE`

#table(
  columns: (1.2fr, 1.8fr, 1.8fr),
  align: (left + horizon, left + horizon, left + horizon),
  stroke: none,
  inset: (x: 8pt, y: 5pt),
  table.hline(stroke: 0.8pt),
  [*Aspect*], [*TRUNCATE*], [*DELETE*],
  table.hline(stroke: 0.5pt),
  [Command Type], [DDL], [DML],
  [WHERE Clause], [Not supported (removes all rows)], [Supported (selective removal)],
  [Transaction], [Auto-commit; cannot rollback], [Can be rolled back],
  [Performance], [Faster (deallocates pages)], [Slower (logs each row)],
  [Triggers], [Does not fire triggers], [Fires DELETE triggers],
  [Identity Column], [Resets AUTO_INCREMENT], [Preserves counter value],
  [Locking], [Table-level lock], [Row-level locks],
  table.hline(stroke: 0.8pt)
)

=== (i) Create an index on the Employee table
```sql
CREATE INDEX idx_emp_ename ON employee(ename);
```

*Verification:*
```sql
SHOW INDEX FROM employee;
```
#mysql-table(
  ("Table", "Non_unique", "Key_name", "Seq_in_index", "Column_name", "Index_type"),
  ("employee", "0", "PRIMARY",       "1", "eid",   "BTREE"),
  ("employee", "1", "idx_emp_ename", "1", "ename", "BTREE"),
)

=== (j) Add `email VARCHAR(30)` to the Dependent table
```sql
ALTER TABLE dependent ADD email VARCHAR(30);
```

*Verification:*
```sql
DESCRIBE dependent;
```
#mysql-table(
  ("Field", "Type", "Null", "Key", "Default", "Extra"),
  ("eid",             "int",         "NO",  "PRI", "NULL", ""),
  ("dependent_name",  "varchar(50)", "NO",  "PRI", "NULL", ""),
  ("relationship",    "varchar(20)", "YES", "",    "NULL", ""),
  ("email",           "varchar(30)", "YES", "",    "NULL", ""),
)

=== (k) Create `product_catalog` table
```sql
CREATE TABLE product_catalog (
    prod_id     INT,
    prod_name   VARCHAR(50),
    prod_price  DECIMAL(10, 2),
    stock_qty   INT
);
```

=== (l) Add `category VARCHAR(20)` to `product_catalog`
```sql
ALTER TABLE product_catalog ADD category VARCHAR(20);
```

=== (m) Set `prod_id` as the primary key
```sql
ALTER TABLE product_catalog ADD CONSTRAINT pk_prod_id PRIMARY KEY (prod_id);
```

=== (n) CHECK constraint: `prod_price > 0`
```sql
ALTER TABLE product_catalog
ADD CONSTRAINT chk_price_positive CHECK (prod_price > 0);
```

=== (o) Make `stock_qty` NOT NULL
```sql
ALTER TABLE product_catalog MODIFY stock_qty INT NOT NULL;
```

=== (p) Add `expiry_date` of type DATE
```sql
ALTER TABLE product_catalog ADD expiry_date DATE;
```

=== (q) Default value of 0 for `stock_qty`
```sql
ALTER TABLE product_catalog MODIFY stock_qty INT DEFAULT 0 NOT NULL;
```

=== (r) Add `discount_rate DECIMAL(5,2)`
```sql
ALTER TABLE product_catalog ADD discount_rate DECIMAL(5, 2);
```

=== (s) Default value of 10 for `discount_rate`
```sql
ALTER TABLE product_catalog MODIFY discount_rate DECIMAL(5, 2) DEFAULT 10;
```

=== (t) CHECK constraint: `discount_rate` between 0 and 100
```sql
ALTER TABLE product_catalog
ADD CONSTRAINT chk_discount_range CHECK (discount_rate BETWEEN 0 AND 100);
```

*Final structure:*
```sql
DESCRIBE product_catalog;
```
#mysql-table(
  ("Field", "Type", "Null", "Key", "Default", "Extra"),
  ("prod_id",       "int",           "NO",  "PRI", "NULL",  ""),
  ("prod_name",     "varchar(50)",   "YES", "",    "NULL",  ""),
  ("prod_price",    "decimal(10,2)", "YES", "",    "NULL",  ""),
  ("stock_qty",     "int",           "NO",  "",    "0",     ""),
  ("category",      "varchar(20)",   "YES", "",    "NULL",  ""),
  ("expiry_date",   "date",          "YES", "",    "NULL",  ""),
  ("discount_rate", "decimal(5,2)",  "YES", "",    "10.00", ""),
)

=== (u) Drop `product_catalog` using RESTRICT
```sql
DROP TABLE product_catalog RESTRICT;
```

=== (v) Drop `product_catalog` using CASCADE  
_Note: Table must be recreated before executing CASCADE drop._
```sql
DROP TABLE product_catalog CASCADE;
```

#v(0.5em)
