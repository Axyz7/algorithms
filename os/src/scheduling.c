#include <limits.h>
#include <stdio.h>

typedef struct {
  int id, at, bt, response, rt, ct, tat, wt, done;
} Process;

void input(Process p[], int n) {
  for (int i = 0; i < n; i++) {
    p[i].id = i + 1;
    printf("AT and BT for process %d: ", i + 1);
    scanf("%d %d", &p[i].at, &p[i].bt);
    p[i].response = -1;
    (p + i)->rt = p[i].bt;
    p[i].done = 0;
  }
}

void print(Process *p, int n) {
  printf("\nPID\tAT\tBT\tCT\tTAT\tWT\n");
  float sumTAT = 0, sumWT = 0;
  for (int i = 0; i < n; i++) {
    printf("%d\t%d\t%d\t%d\t%d\t%d\n", i, p[i].at, p[i].bt, p[i].ct, p[i].tat,
           p[i].wt);
    sumTAT += p[i].tat;
    sumWT += p[i].wt;
  }
  printf("Avg TAT=%.2f\nAvg WT=%.2f", sumTAT / n, sumWT / n);
}

void fcfs(Process p[], int n) {
  int time = 0, completed = 0;
  while (completed < n) {
    int idx = -1;
    for (int i = 0; i < n; i++) {
      if (!p[i].done && p[i].at <= time) {
        if (idx == -1 || p[i].at < p[idx].at ||
            (p[i].at == p[idx].at && i < idx)) {
          idx = i;
        }
      }
    }
    if (idx == -1) {
      time++;
      continue;
    }

    p[idx].response = time;
    time += p[idx].bt;
    p[idx].ct = time;
    p[idx].rt = 0;
    p[idx].tat = time - p[idx].at;
    p[idx].wt = p[idx].tat - p[idx].bt;
    p[idx].done = 1;
    completed++;
  }
}

void sjf(Process p[], int n) {
  int time = 0, completed = 0;
  while (completed < n) {
    int idx = -1;
    for (int i = 0; i < n; i++) {
      if (!p[i].done && p[i].at <= time &&
          (idx == -1 || p[i].bt < p[idx].bt ||
           (p[i].bt == p[idx].bt && p[i].at < p[idx].at)))
        idx = i;
    }

    if (idx == -1) {
      time++;
      continue;
    }

    p[idx].response = time;
    time += p[idx].bt;
    p[idx].ct = time;
    p[idx].rt = 0;
    p[idx].tat = time - p[idx].at;
    p[idx].wt = p[idx].tat - p[idx].bt;
    p[idx].done = 1;
    completed++;
  }
}

void hrrn(Process p[], int n) {
  int time = 0, completed = 0;
  while (completed < n) {
    int idx = -1;
    float max_rr = 0;
    for (int i = 0; i < n; i++) {
      if (!p[i].done && p[i].at <= time) {
        float ratio = 1 + (float)(time - p[i].at) / p[i].bt;
        if (ratio > max_rr) {
          idx = i;
        }
      }
    }
    if (idx == -1) {
      time++;
      continue;
    }

    p[idx].response = time;
    time += p[idx].bt;
    p[idx].ct = time;
    p[idx].tat = time - p[idx].at;
    p[idx].wt = p[idx].tat - p[idx].bt;
    p[idx].done = 1;
    completed++;
  }
}
void srtf(Process p[], int n) {
  int time = 0, completed = 0;
  while (completed < n) {
    int idx = -1;
    for (int i = 0; i < n; i++) {
      if (!p[i].done && p[i].at <= time) {
        if (idx == -1 || p[i].rt < p[idx].rt ||
            (p[i].rt == p[idx].rt && p[i].id < p[idx].id)) {
          idx = i;
        }
      }
    }
    if (idx == -1) {
      time++;
      continue;
    }
    if (p[idx].response == -1) {
      p[idx].response = time;
    }
    time++;
    p[idx].rt--;
    if (p[idx].rt == 0) {
      completed++;
      p[idx].ct = time;
      p[idx].tat = time - p[idx].at;
      p[idx].wt = p[idx].tat - p[idx].bt;
      p[idx].done = 1;
    }
  }
}

void rr(Process p[], int n, int q) {
  int time = 0, completed = 0;
  int queue[n], front = -1, rear = -1;
  int inq[n];

  for (int i = 0; i < n; i++)
    inq[i] = 0;
  while (completed < n) {
    if (front == -1) {
      time++;
      for (int i = 0; i < n; i++) {
        if (!p[i].done && !inq[i] && p[i].at <= time) {
          rear = (rear + 1) % n;
          queue[rear] = i;
          if (front == -1)
            front = rear;
          inq[i] = 1;
        }
      }
      continue;
    }
    int idx = queue[front]; // pop
    if (front == rear)
      front = rear = -1;
    else
      front = (front + 1) % n;

    int slice = p[idx].rt < q ? p[idx].rt : q;

    if (p[idx].response == -1)
      p[idx].response = time;
    time += slice;
    p[idx].rt -= slice;

    for (int i = 0; i < n; i++) {
      if (!p[i].done && !inq[i] && p[i].at <= time) {
        rear = (rear + 1) % n;
        queue[rear] = i;
        if (front == -1)
          front = rear;
        inq[i] = 1;
      }
    }

    if (p[idx].rt == 0) {

      p[idx].ct = time;
      p[idx].tat = time - p[idx].at;
      p[idx].wt = p[idx].tat - p[idx].bt;
      p[idx].done = 1;
      completed++;
    } else {
      rear = (rear + 1) % n;
      queue[rear] = idx;
      if (front == -1)
        front = rear;
    }
  }
}

void rrr(Process p[], int n, int q) {
  int ready[n], head = 0, size = 0;
  int next = 0, time = 0, completed = 0;

#define PUSH(x) (ready[(head + size) % n] = (x), size++)
#define ADMIT()                                                                \
  while (next < n && p[next].at <= time)                                       \
  PUSH(next++)

  while (completed < n) {
    if (size == 0 && time < p[next].at) /* WAIT  */
      time = p[next].at;
    ADMIT(); /* ADMIT */

    int i = ready[head]; /* POP   */
    head = (head + 1) % n;
    size--;

    if (p[i].response == -1)
      p[i].response = time;
    int run = p[i].rt < q ? p[i].rt : q; /* RUN   */
    p[i].rt -= run;
    time += run;

    ADMIT(); /* ADMIT (arrivals during run, before requeue) */

    if (p[i].rt == 0) { /* FINISH or REQUEUE */
      finish(&p[i], time);
      completed++;
    } else {
      PUSH(i);
    }
  }
}

int main() {
  int n, q = 2;
  printf("enter n:");
  scanf("%d", &n);
  Process procs[n];
  input(procs, n);
  srtf(procs, n);
  print(procs, n);
  return 0;
}
