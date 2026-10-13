#include <algorithm>
#include <iomanip>
#include <iostream>
#include <queue>
#include <vector>

using namespace std;

struct Process {
  int id;           // Process ID
  int at;           // Arrival Time
  int bt;           // Burst Time
  int remaining_bt; // Remaining Burst Time (useful for Round Robin)

  int ct;  // Completion Time
  int tat; // Turnaround Time
  int wt;  // Waiting Time
  int rt;  // Response Time

  Process(int id, int at, int bt) {
    this->id = id;
    this->at = at;
    this->bt = bt;
    this->remaining_bt = bt;
    this->ct = 0;
    this->tat = 0;
    this->wt = 0;
    this->rt = -1;
  }
};

void printReport(const vector<Process> &procs, const string &algo_name) {
  cout << "===================================================\n";
  cout << " Algorithm: " << algo_name << "\n";
  cout << "===================================================\n";

  cout << left << setw(6) << "PID" << setw(6) << "AT" << setw(6) << "BT"
       << setw(6) << "CT" << setw(6) << "TAT" << setw(6) << "WT" << setw(6)
       << "RT" << "\n";

  double total_tat = 0, total_wt = 0, total_rt = 0;

  for (const auto &p : procs) {
    cout << left << setw(6) << ("P" + to_string(p.id)) << setw(6) << p.at
         << setw(6) << p.bt << setw(6) << p.ct << setw(6) << p.tat << setw(6)
         << p.wt << setw(6) << p.rt << "\n";

    total_tat += p.tat;
    total_wt += p.wt;
    total_rt += p.rt;
  }

  int n = procs.size();
  cout << fixed << setprecision(2);
  cout << "\nAverage TAT : " << (total_tat / n)
       << "\nAverage WT  : " << (total_wt / n)
       << "\nAverage RT  : " << (total_rt / n) << "\n\n";
}

void calculateHRRN(vector<Process> procs) {
  int current_time = 0;
  int completed = 0;
  int n = procs.size();
  vector<bool> is_completed(n, false);

  while (completed < n) {
    int best_idx = -1;
    double max_rr = -1.0;

    // Find process with highest Response Ratio
    for (int i = 0; i < n; i++) {
      if (!is_completed[i] && procs[i].at <= current_time) {
        double response_ratio =
            (double)((current_time - procs[i].at) + procs[i].bt) / procs[i].bt;

        if (response_ratio > max_rr) {
          best_idx = i;
          max_rr = response_ratio;
        }
      }
    }

    if (best_idx == -1) {
      current_time++;
    } else {
      procs[best_idx].wt = procs[best_idx].rt =
          current_time - procs[best_idx].at;
      procs[best_idx].ct = current_time + procs[best_idx].bt;
      procs[best_idx].tat = procs[best_idx].ct - procs[best_idx].at;

      current_time += procs[best_idx].bt;
      is_completed[best_idx] = true;
      completed++;
    }
  }
  printReport(procs, "Highest Response Ratio Next");
}

void calculateRoundRobin(vector<Process> procs, int quantum) {
  int current_time = 0;
  int completed = 0;
  int n = procs.size();
  queue<int> ready_q;
  vector<bool> in_readyq(n, false);
  while (completed < n) {
    for (int i = 0; i < n; i++) {
      if (!in_readyq[i] && current_time >= procs[i].at) {
        ready_q.push(i);
        in_readyq[i] = true;
      }
    }
    if (!ready_q.empty()) {

      int curr = ready_q.front();
      ready_q.pop();

      if (procs[curr].rt == -1)
        procs[curr].rt = current_time - procs[curr].at;

      int time_slice = min(quantum, procs[curr].remaining_bt);
      current_time += time_slice;
      procs[curr].remaining_bt -= time_slice;

      for (int i = 0; i < n; i++) {
        if (!in_readyq[i] && current_time >= procs[i].at) {
          ready_q.push(i);
          in_readyq[i] = true;
        }
      }

      if (procs[curr].remaining_bt > 0) {
        ready_q.push(curr);
      } else {
        procs[curr].ct = current_time;

        procs[curr].tat = procs[curr].ct - procs[curr].at;
        procs[curr].wt = procs[curr].tat - procs[curr].bt;
        completed++;
      }

    } else {
      current_time++;
    }
  }
  printReport(procs, "Round Robin");
}

int main() {
  vector<Process> processes = {Process(1, 0, 3), Process(2, 2, 6),
                               Process(3, 4, 4), Process(4, 6, 5),
                               Process(5, 8, 2)};

  calculateHRRN(processes);

  calculateRoundRobin(processes, 3);

  return 0;
}
