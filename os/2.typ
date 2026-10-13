#set page(
  paper: "a4",
  margin: (x: 1.8cm, y: 1.8cm),
  footer: context align(center)[#text(size: 8.5pt)[Page #counter(page).display()]]
)
#set text(
  size: 9.5pt,
  font: ("Adwaita Sans", "FreeSans") // Main body font
)

// Set all code & terminal output to JetBrains Mono
#show raw: set text(font: "JetBrains Mono", size: 8.5pt)

// Set math equations to New Computer Modern Math
#show math.equation: set text(font: "New Computer Modern Math")

// --- CODE BLOCK & TERMINAL BOX BORDERS ---
#show raw.where(block: true): block.with(
  stroke: 0.5pt + luma(80),
  inset: 8pt,
  radius: 2pt,
  width: 100%,
  fill: none // 100% white background to save printer ink
)

// --- HEADING STYLING ---
#show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 0.6em)[
  #text(size: 12pt, weight: "bold")[#it.body]
  #v(-0.2em)
  #line(length: 100%, stroke: 0.8pt)
]

#show heading.where(level: 2): it => block(above: 0.8em, below: 0.4em)[
  #text(size: 10pt, weight: "bold")[#it.body]
]

// --- DOCUMENT HEADER ---
#align(center)[
  #text(size: 15pt, weight: "bold")[LAB REPORT 2: PROCESS OPERATIONS & CONTROL] \
  #v(2pt)
  #text(size: 10pt)[Course: Operating Systems Lab]
]

#v(0.5em)
#grid(
  columns: (1fr, 1fr),
  align: (left, right),
  [
    *Student Name:* Aryan Nautiyal \
    *Roll Number:* 251210015
  ],
  [
    *Date:* #datetime.today().display("[Year]-[Month]-[Day]") \
    *Environment:* Bash / POSIX (Linux x86_64)
  ]
)
#line(length: 100%, stroke: 0.5pt)

==  Aim 
To implement a C program in a POSIX/Linux environment demonstrating the fundamental process control primitives:
1. *Process Creation:* Duplicating execution context via `fork()`.
2. *Program Execution:* Overlaying process image memory via `execlp()`.
3. *Child Handling & Synchronization:* Reaping state & preventing zombies using `wait()`.
4. *Process Termination:* Contrasting standard exit routines (`exit()`) vs kernel-level raw exit (`_exit()`) along with child status code recovery.
5. *Asynchronous Event Handling:* Inter-process event signaling using `signal()` and `kill()`.

==  POSIX System Call Reference
#table(
  columns: (1.2fr, 2fr, 2.8fr),
  align: (left + horizon, left + horizon, left + horizon),
  stroke: none,
  table.hline(stroke: 0.8pt),
  [*System Call*], [*Syntax / Prototype*], [*OS Level Function & Behavior*],
  table.hline(stroke: 0.4pt),
  [`fork()`], [`pid_t fork(void)`], [Clones calling process. Returns 0 to child, child PID to parent, or -1 on error.],
  [`execlp()`], [`int execlp(const char *file, ...)`], [Overlays caller process space with binary found via `$PATH`. Returns -1 only on error.],
  [`wait()`], [`pid_t wait(int *wstatus)`], [Blocks parent until any child terminates; retrieves child exit status bitmask.],
  [`exit()`], [`void exit(int status)`], [User-space clean shutdown: flushes stdio streams, runs `atexit` routines, calls `_exit()`.],
  [`_exit()`], [`void _exit(int status)`], [Immediate kernel termination: releases memory & file handles, skips stdio cleanup.],
  [`signal()`], [`sighandler_t signal(int sig, ...)`], [Registers a custom interrupt handler callback function for signal number `sig`.],
  [`kill()`], [`int kill(pid_t pid, int sig)`], [Sends a software interrupt signal `sig` to target process specified by `pid`.],
  table.hline(stroke: 0.8pt)
)

==  C Source Code (`process_operations.c`)

```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <signal.h>
#include <errno.h>

void handle_sigusr1(int sig) {
    if (sig == SIGUSR1) {
        const char msg[] = "\n[SIGNAL HANDLER] Captured SIGUSR1! Event processed asynchronously.\n";
        write(STDOUT_FILENO, msg, sizeof(msg) - 1);
    }
}

int main(void) {
    pid_t pid;
    int status;
    if (signal(SIGUSR1, handle_sigusr1) == SIG_ERR) {
        perror("Failed to register SIGUSR1 signal handler");
        exit(EXIT_FAILURE);
    }
    printf("[PARENT] Main Process active. PID: %d, Parent PID: %d\n", getpid(), getppid());
    pid = fork();
    if (pid < 0) {
        perror("fork() process creation failed");
        exit(EXIT_FAILURE);
    } 
    else if (pid == 0) {
        printf("  [CHILD] Created successfully. PID: %d, Parent PID: %d\n", 
               getpid(), getppid());
        printf("  [CHILD] Sending SIGUSR1 event signal to Parent (PID: %d)...\n", getppid());
        if (kill(getppid(), SIGUSR1) == -1) {
            perror("  [CHILD] Failed to send SIGUSR1 signal");
        }
        printf("  [CHILD] Binary Command: 'ls -l -h'\n\n");
        execlp("ls", "ls", "-l", "-h", NULL);
        _exit(127);
    } 
    else {
        printf("[PARENT] Spawned child process with PID: %d\n", pid);
        printf("[PARENT] Entering blocked state waiting for child process termination...\n");
        pid_t terminated_pid = wait(&status);
        if (terminated_pid == -1) {
            perror("[PARENT] wait() system call failed");
            exit(EXIT_FAILURE);
        }
        printf("\n[PARENT] Successfully harvested Child Process (PID: %d).\n", terminated_pid);
        if (WIFEXITED(status)) {
            printf("[PARENT] Child Exit Status: Normal exit with code [%d]. Now parent can terminate\n", 
                   WEXITSTATUS(status));
        } else if (WIFSIGNALED(status)) {
            printf("[PARENT] Child Exit Status: Abnormally terminated by Signal [%d].\n", 
                   WTERMSIG(status));
        }
        exit(EXIT_SUCCESS);
    }
    return 0;
}
```

==  Output

```bash
$ gcc -Wall -Wextra process_operations.c -o process_operations
$ ./process_operations

[PARENT] Main Process active. PID: 41205, Parent PID: 18402
[PARENT] Spawned child process with PID: 41206
[PARENT] Entering blocked state waiting for child process termination...
  [CHILD] Created successfully. PID: 41206, Parent PID: 41205
  [CHILD] Sending SIGUSR1 event signal to Parent (PID: 41205)...

[SIGNAL HANDLER] Captured SIGUSR1! Event processed asynchronously.
  [CHILD] Binary Command: 'ls -l -h'

total 32K
-rwxr-xr-x 1 aryan aryan  16K Aug  4 20:45 process_operations
-rw-r--r-- 1 aryan aryan 2.8K Aug  4 20:44 process_operations.c

[PARENT] Successfully harvested Child Process (PID: 41206).
[PARENT] Child Exit Status: Normal exit with code [0]. Now parent can terminate
```
