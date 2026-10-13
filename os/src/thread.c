#define _POSIX_C_SOURCE 200809L

#include <pthread.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#ifndef N
#define N 5000000
#endif

#ifndef NUM_THREADS
#define NUM_THREADS 2
#endif

#ifndef SEGMENT_ODDS
#define SEGMENT_ODDS 32768
#endif

/*
 * composite[n / 2] represents odd n.
 * Even numbers are skipped; 2 is counted separately.
 */
static int run_seq(int max_n) {
  if (max_n < 2)
    return 0;

  size_t n = (size_t)max_n;
  unsigned char *composite = calloc(n / 2 + 1, sizeof(*composite));
  if (composite == NULL)
    return -1;

  for (size_t p = 3; p <= n / p; p += 2) {
    if (!composite[p / 2]) {
      for (size_t m = p * p; m <= n; m += 2 * p)
        composite[m / 2] = 1;
    }
  }

  int count = 1; // prime 2
  for (size_t p = 3; p <= n; p += 2) {
    if (!composite[p / 2])
      count++;
  }

  free(composite);
  return count;
}

static int integer_sqrt(int n) {
  int root = 0;
  while ((int64_t)(root + 1) * (root + 1) <= n)
    root++;
  return root;
}

/* Return odd primes <= limit; 2 is not needed for odd-only segments. */
static int make_odd_base_primes(int limit, int **out, size_t *out_count) {
  *out = NULL;
  *out_count = 0;

  if (limit < 3)
    return 0;

  size_t n = (size_t)limit;
  unsigned char *composite = calloc(n / 2 + 1, sizeof(*composite));
  if (composite == NULL)
    return -1;

  for (size_t p = 3; p <= n / p; p += 2) {
    if (!composite[p / 2]) {
      for (size_t m = p * p; m <= n; m += 2 * p)
        composite[m / 2] = 1;
    }
  }

  size_t count = 0;
  for (size_t p = 3; p <= n; p += 2) {
    if (!composite[p / 2])
      count++;
  }

  int *primes = malloc(count * sizeof(*primes));
  if (primes == NULL) {
    free(composite);
    return -1;
  }

  size_t index = 0;
  for (size_t p = 3; p <= n; p += 2) {
    if (!composite[p / 2])
      primes[index++] = (int)p;
  }

  free(composite);
  *out = primes;
  *out_count = count;
  return 0;
}

typedef struct {
  size_t total_odds; // candidates 3, 5, 7, ... <= max_n
  size_t next_index;
  const int *base_primes;
  size_t base_count;
  pthread_mutex_t next_lock;
} sieve_job;

typedef struct {
  sieve_job *job;
  int count;
} worker_arg;

static void *worker(void *arg) {
  worker_arg *worker = arg;
  sieve_job *job = worker->job;
  unsigned char composite[SEGMENT_ODDS];
  int local_count = 0;

  for (;;) {
    size_t first_index;

    pthread_mutex_lock(&job->next_lock);
    if (job->next_index >= job->total_odds) {
      pthread_mutex_unlock(&job->next_lock);
      break;
    }
    first_index = job->next_index;
    job->next_index += SEGMENT_ODDS;
    pthread_mutex_unlock(&job->next_lock);

    size_t len = job->total_odds - first_index;
    if (len > SEGMENT_ODDS)
      len = SEGMENT_ODDS;

    // This segment represents lo, lo+2, lo+4, ...
    uint64_t lo = 3 + 2 * (uint64_t)first_index;
    uint64_t hi = lo + 2 * (uint64_t)(len - 1);

    memset(composite, 0, len);

    for (size_t i = 0; i < job->base_count; i++) {
      uint64_t p = (uint64_t)job->base_primes[i];
      uint64_t first = ((lo + p - 1) / p) * p;
      uint64_t p_squared = p * p;

      if (first < p_squared)
        first = p_squared;
      if ((first & 1u) == 0)
        first += p;

      for (uint64_t m = first; m <= hi; m += 2 * p)
        composite[(size_t)((m - lo) / 2)] = 1;
    }

    for (size_t i = 0; i < len; i++) {
      if (!composite[i])
        local_count++;
    }
  }

  worker->count = local_count;
  return NULL;
}

static int run_multi(int max_n, int num_threads) {
  if (max_n < 2)
    return 0;
  if (num_threads < 1)
    return -1;
  if (max_n == 2)
    return 1;

  size_t total_odds = ((size_t)max_n - 1) / 2;
  size_t segment_count = (total_odds + SEGMENT_ODDS - 1) / SEGMENT_ODDS;

  if ((size_t)num_threads > segment_count)
    num_threads = (int)segment_count;

  int *base_primes = NULL;
  size_t base_count = 0;
  if (make_odd_base_primes(integer_sqrt(max_n), &base_primes, &base_count) !=
      0) {
    return -1;
  }

  sieve_job job = {.total_odds = total_odds,
                   .next_index = 0,
                   .base_primes = base_primes,
                   .base_count = base_count};

  if (pthread_mutex_init(&job.next_lock, NULL) != 0) {
    free(base_primes);
    return -1;
  }

  pthread_t *threads = malloc((size_t)num_threads * sizeof(*threads));
  worker_arg *workers = calloc((size_t)num_threads, sizeof(*workers));

  if (threads == NULL || workers == NULL) {
    free(threads);
    free(workers);
    pthread_mutex_destroy(&job.next_lock);
    free(base_primes);
    return -1;
  }

  for (int i = 0; i < num_threads; i++) {
    workers[i].job = &job;

    if (pthread_create(&threads[i], NULL, worker, &workers[i]) != 0) {
      for (int j = 0; j < i; j++)
        pthread_join(threads[j], NULL);

      free(threads);
      free(workers);
      pthread_mutex_destroy(&job.next_lock);
      free(base_primes);
      return -1;
    }
  }

  for (int i = 0; i < num_threads; i++)
    pthread_join(threads[i], NULL);

  int count = 1; // prime 2
  for (int i = 0; i < num_threads; i++)
    count += workers[i].count;

  free(threads);
  free(workers);
  pthread_mutex_destroy(&job.next_lock);
  free(base_primes);

  return count;
}

static double get_time_sec(void) {
  struct timespec ts;
  clock_gettime(CLOCK_MONOTONIC, &ts);
  return (double)ts.tv_sec + (double)ts.tv_nsec / 1e9;
}

int main(int argc, char **argv) {
  int max_n = N;
  int num_threads = NUM_THREADS;

  if (argc > 1)
    max_n = atoi(argv[1]);
  if (argc > 2)
    num_threads = atoi(argv[2]);

  if (max_n < 0 || num_threads < 1) {
    fprintf(stderr, "Usage: %s [max_n >= 0] [threads >= 1]\n", argv[0]);
    return EXIT_FAILURE;
  }

  printf("Counting primes <= %d with %d thread(s)\n\n", max_n, num_threads);

  double start = get_time_sec();
  int seq_count = run_seq(max_n);
  double seq_time = get_time_sec() - start;

  if (seq_count < 0) {
    fprintf(stderr, "Sequential sieve allocation failed\n");
    return EXIT_FAILURE;
  }

  start = get_time_sec();
  int multi_count = run_multi(max_n, num_threads);
  double multi_time = get_time_sec() - start;

  if (multi_count < 0) {
    fprintf(stderr, "Multithreaded sieve failed\n");
    return EXIT_FAILURE;
  }

  printf("Sequential:      %d primes in %.6f seconds\n", seq_count, seq_time);
  printf("Multithreaded:   %d primes in %.6f seconds\n", multi_count,
         multi_time);

  if (seq_count != multi_count) {
    fprintf(stderr, "ERROR: prime counts do not match\n");
    return EXIT_FAILURE;
  }

  if (multi_time > 0.0)
    printf("Speedup:         %.2fx\n", seq_time / multi_time);

  return EXIT_SUCCESS;
}
