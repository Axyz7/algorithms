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
  #text(size: 15pt, weight: "bold")[LAB REPORT: DATABASE DESIGN (EER MODELING)] \
  #text(size: 10pt)[CSBB 204: Database Management Systems — Week 9]
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
To design an Enhanced Entity-Relationship (EER) diagram for a Grade Book database
that models students, instructors, courses, grading components, grade cutoffs,
enrollments, and student scores — capturing generalization/specialization
hierarchies, weak entities, and ternary relationships.

== Theory
#table(
  columns: (1.2fr, 3fr),
  align: (center + horizon, left + horizon),
  stroke: none,
  table.hline(stroke: 0.8pt),
  [*EER Concept*], [*Description*],
  table.hline(stroke: 0.4pt),
  [Supertype / Subtype], [A generalization hierarchy where a supertype entity
    (e.g., Person) shares common attributes with its subtypes (e.g., Student,
    Instructor). Each subtype inherits the supertype's primary key.],
  [Disjoint, Total], [A specialization constraint: {d, t} means every supertype
    instance belongs to exactly one subtype (disjoint) and must belong to some
    subtype (total).],
  [Weak Entity], [An entity that cannot be uniquely identified by its own
    attributes alone. It depends on an identifying (owner) entity and uses a
    partial key (discriminator) combined with the owner's primary key.],
  [Identifying Relationship], [The relationship between a weak entity and its
    owner. Represented with a double diamond in Chen notation.],
  [Ternary Relationship], [A relationship involving three entity types
    simultaneously, modeled as an associative entity.],
  [Composite Key], [A primary key composed of two or more attributes
    (e.g., course\_number + section\_number + term).],
  table.hline(stroke: 0.8pt)
)

#v(0.5em)

== Data Requirements Summary
The Grade Book database captures the following:
+ *Students* are identified by a unique student ID, first name, last name, and email.
+ *Instructors* teach courses each term and define grade cutoffs (A/B/C/D/F) per course.
+ *Courses* are uniquely identified by course number, section number, and term.
+ Each course has multiple *grading components* (mid-term, final, project, etc.)
  with maximum points and percentage weights summing to 100.
+ *Scores* record the points each student earns in each grading component of each course.

== Entity & Attribute Description
#table(
  columns: (1fr, 1.5fr, 2.5fr),
  align: (center + horizon, left + horizon, left + horizon),
  stroke: none,
  table.hline(stroke: 0.8pt),
  [*Entity*], [*Type*], [*Attributes*],
  table.hline(stroke: 0.4pt),
  [Person], [Supertype], [person\_id (PK), first\_name, last\_name, email (UK)],
  [Student], [Subtype of Person], [person\_id (PK, FK → Person)],
  [Instructor], [Subtype of Person], [person\_id (PK, FK → Person), department],
  [Course\_Section], [Strong Entity], [course\_number (PK), section\_number (PK),
    term (PK), instructor\_id (FK)],
  [Grading\_Component], [Weak Entity], [component\_name (Partial Key),
    max\_points, weight; Owner: Course\_Section],
  [Grade\_Cutoff], [Weak Entity], [letter\_grade (Partial Key), cutoff\_score;
    Owner: Course\_Section],
  [Enrollment], [Associative (M:N)], [student\_id (FK), course\_number (FK),
    section\_number (FK), term (FK)],
  [Score], [Associative (Ternary)], [student\_id (FK), course\_number (FK),
    section\_number (FK), term (FK), component\_name (FK), points\_earned],
  table.hline(stroke: 0.8pt)
)

== Enhanced ER Diagram

#figure(
  image("eer_diagram.png", width: 50%),
  caption: [EER Diagram for the Grade Book Database (generated using dbdiagram.io)]
)

#v(0.5em)

== Relationships & Cardinality
#table(
  columns: (1.2fr, 0.8fr, 0.8fr, 0.6fr, 1.5fr),
  align: (left + horizon, center + horizon, center + horizon,
          center + horizon, left + horizon),
  stroke: none,
  table.hline(stroke: 0.8pt),
  [*Relationship*], [*Min:Max (E1)*], [*Min:Max (E2)*], [*Ratio*], [*Notes*],
  table.hline(stroke: 0.4pt),
  [Person → Student / Instructor], [(1,1)], [(0,1)], [Super/Sub], [{d, t} specialization],
  [Instructor → Course\_Section], [(1,N)], [(1,1)], [1 : N], [Every section has exactly one instructor],
  [Student → Course\_Section], [(1,N)], [(0,N)], [M : N], [Via Enrollment entity],
  [Course\_Section → Grading\_Component], [(1,N)], [(1,1)], [1 : N], [Identifying (weak entity)],
  [Course\_Section → Grade\_Cutoff], [(1,N)], [(1,1)], [1 : N], [Identifying (weak entity)],
  [Enrollment → Score], [(1,N)], [(1,1)], [1 : N], [Score per component per enrollment],
  [Grading\_Component → Score], [(1,N)], [(1,1)], [1 : N], [Links component to earned points],
  table.hline(stroke: 0.8pt)
)

#v(0.5em)

== Relational Schema Mapping

Primary keys are #underline[underlined]. Foreign key constraints are listed below each relation.

#let pk(it) = underline(it)
#let relation(name, attrs, fks: ()) = block(
  width: 100%,
  stroke: 0.5pt + rgb("#d1d5db"),
  inset: 8pt,
  radius: 3pt,
  fill: rgb("#f0f2f5"),
  breakable: false,
  spacing: 0.6em,
)[
  #text(weight: "bold")[#name] (#attrs)
  #if fks.len() > 0 {
    v(-0.3em)
    set text(size: 8.8pt, fill: rgb("#4b5563"))
    for fk in fks [
      #h(1em)↳ *FK:* #fk \
    ]
  }
]

#relation(
  "Person",
  [#pk[person\_id], first\_name, last\_name, email],
)

#relation(
  "Student",
  [#pk[person\_id]],
  fks: ([`person_id` references *Person*],),
)

#relation(
  "Instructor",
  [#pk[person\_id], department],
  fks: ([`person_id` references *Person*],),
)

#relation(
  "Course_Section",
  [#pk[course\_number], #pk[section\_number], #pk[term], instructor\_id],
  fks: ([`instructor_id` references *Instructor*],),
)

#relation(
  "Grading_Component",
  [#pk[course\_number], #pk[section\_number], #pk[term], #pk[component\_name], max\_points, weight],
  fks: ([(`course_number`, `section_number`, `term`) references *Course_Section*],),
)

#relation(
  "Grade_Cutoff",
  [#pk[course\_number], #pk[section\_number], #pk[term], #pk[letter\_grade], cutoff\_score],
  fks: ([(`course_number`, `section_number`, `term`) references *Course_Section*],),
)

#relation(
  "Enrollment",
  [#pk[student\_id], #pk[course\_number], #pk[section\_number], #pk[term]],
  fks: (
    [`student_id` references *Student*],
    [(`course_number`, `section_number`, `term`) references *Course_Section*],
  ),
)

#relation(
  "Score",
  [#pk[student\_id], #pk[course\_number], #pk[section\_number], #pk[term], #pk[component\_name], points\_earned],
  fks: (
    [(`student_id`, `course_number`, `section_number`, `term`) references *Enrollment*],
    [(`course_number`, `section_number`, `term`, `component_name`) references *Grading_Component*],
  ),
)
