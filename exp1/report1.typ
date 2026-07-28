
#set page(paper: "a4", margin: 2.5cm)
#set text(font: "Jetbrains Mono", size: 12pt)
#set par(justify: true)

// --- TITLE BLOCK ---
#align(center)[
  #text(size: 16pt, weight: "bold")[Experiment 01: Systems Boundary Analysis]
  
  *Name:* Aryan Nautiyal | *Roll No:* 251210015 | *Date:* #datetime.today().display()
]
#line(length: 100%, stroke: 0.5pt)
#v(1em)

// --- CONTENT ---
== 1. Objective
To write and analyze a C program executing low-level system operations, calculating the asymptotic time complexity $O(n^2)$ of the resulting buffer allocation.

== 2. Implementation Code
#block(fill: luma(240), inset: 8pt, radius: 4pt)[
```c
#include <stdio.h>

int main() {
    int buffer[5] = {1, 2, 3, 4, 5};
    for(int i = 0; i < 5; i++) {
        printf("Memory Address: %p\n", (void*)&buffer[i]);
    }
    return 0;
}
```]
