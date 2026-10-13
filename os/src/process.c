#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

void handle_sigusr1(int sig) {
  if (sig == SIGUSR1) {
    const char msg[] = "\n[SIGNAL HANDLER] Captured SIGUSR1! Event processed "
                       "asynchronously.\n ";
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
  printf("[PARENT] Main Process active. PID: %d, Parent PID: %d\n", getpid(),
         getppid());
  pid = fork();
  if (pid < 0) {
    perror("fork() process creation failed");
    exit(EXIT_FAILURE);
  } else if (pid == 0) {
    printf("  [CHILD] Created successfully. PID: %d, Parent PID: %d\n",
           getpid(), getppid());
    printf("  [CHILD] Sending SIGUSR1 event signal to Parent (PID: %d)...\n",
           getppid());
    if (kill(getppid(), SIGUSR1) == -1) {
      perror("  [CHILD] Failed to send SIGUSR1 signal");
    }
    printf("  [CHILD] Binary Command: 'ls -l -h'\n\n");
    execlp("ls", "ls", "-l", "-h", NULL);
    _exit(127);
  } else {
    printf("[PARENT] Spawned child process with PID: %d\n", pid);
    printf("[PARENT] Entering blocked state waiting for child process "
           "termination...\n");
    pid_t terminated_pid = wait(&status);
    if (terminated_pid == -1) {
      perror("[PARENT] wait() system call failed");
      exit(EXIT_FAILURE);
    }
    printf("\n[PARENT] Successfully harvested Child Process (PID: %d).\n",
           terminated_pid);
    if (WIFEXITED(status)) {
      printf("[PARENT] Child Exit Status: Normal exit with code [%d]. Now "
             "parent can terminate\n ",
             WEXITSTATUS(status));
    } else if (WIFSIGNALED(status)) {
      printf(
          "[PARENT] Child Exit Status: Abnormally terminated by Signal [%d].\n",
          WTERMSIG(status));
    }
    exit(EXIT_SUCCESS);
  }
  return 0;
}
