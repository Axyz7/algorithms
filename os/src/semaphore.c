#include <pthread.h>
#include <semaphore.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

//-----------producer_consumer----------------
#define SIZE 5
#define NUM_ITEMS 10

int buffer[SIZE];
int in = 0;  // producer insert here
int out = 0; // consumer consume here
int count = 0;
sem_t empty; // control if there is some empty slot
sem_t full;  // control if there is any full slot
pthread_mutex_t mutex;

void print_buffer_visual(const char *action, int item) {
  printf("%-7s ( Item %2d) | [ ", action, item);

  for (int i = 0; i < SIZE; i++) {
    int index = (out + i) % SIZE;
    if (i < count) {
      printf("%2d ", buffer[index]); // Show item in buffer
    } else {
      printf(" _ "); // Show empty slot
    }
  }
  printf("] (Count: %d/%d)\n", count, SIZE);
}

void *producer(void *arg) {
  int id = (long)arg;
  for (int i = 1; i <= NUM_ITEMS; i++) {
    int item = rand() % 100 + 1;         // produce a random item
    usleep((rand() % 800 + 200) * 1000); // sleep

    sem_wait(&empty);           // wait for an empty slot
    pthread_mutex_lock(&mutex); // CS

    // produce item and insert into buffer
    buffer[in] = item;
    // printf("[producer] produced the item: %d at index %d\n", item, in);
    in = (in + 1) % SIZE;
    count++;

    pthread_mutex_unlock(&mutex); // exit cs
    print_buffer_visual("Produced", item);

    sem_post(&full); // signal that there is a full slot for consumer
  }
  pthread_exit(NULL);
}

void *consumer(void *arg) {
  int id = (long)arg;
  for (int i = 1; i <= NUM_ITEMS; i++) {
    usleep((rand() % 800 + 900) * 1000); // sleep

    sem_wait(&full);            // wait for a full slot
    pthread_mutex_lock(&mutex); // enter cs

    // consume
    int item = buffer[out];
    // printf("  [consumer] consumed the item: %d at index %d\n", item, in);
    out = (out + 1) % SIZE;
    count--;

    pthread_mutex_unlock(&mutex);
    print_buffer_visual("Consumed", item);

    sem_post(&empty);
  }
  pthread_exit(NULL);
}

void producer_consumer() {
  pthread_t prod_thread, cons_thread;

  // init semaphores and mutex
  sem_init(&empty, 0, SIZE); // empty slots = BUFFER_SIZE
  sem_init(&full, 0, 0);     // full slots = 0
  pthread_mutex_init(&mutex, NULL);

  printf("-----------producer_consumer----------\n\n");
  // create the threads
  {
    pthread_create(&prod_thread, NULL, producer, NULL);
    pthread_create(&cons_thread, NULL, consumer, NULL);
  }
  {
    pthread_join(prod_thread, NULL);
    pthread_join(cons_thread, NULL);
  }
  sem_destroy(&empty);
  sem_destroy(&full);
  pthread_mutex_destroy(&mutex);
}

//========dining philosopher======
#define NUM_P 5
sem_t chopsticks[NUM_P]; // 1 semaphore for each chopstick

void *philosopher(void *num) {
  int id = (long)num;
  int left = id;
  int right = (id + 1) % NUM_P;

  printf("philosopher %d is thinking...\n", id);
  sleep(1);

  // deadlock prevention strategy: make the even philosophers choose left then
  // right
  if (id % 2 == 0) {
    sem_wait(&chopsticks[left]);  // Pick up Left chopstick
    sem_wait(&chopsticks[right]); // Pick up Right chopstick
  } else {
    sem_wait(&chopsticks[right]); // Pick up Right chopstick
    sem_wait(&chopsticks[left]);  // Pick up Left chopstick
  }

  // CS is eating
  printf("Philosopher %d is EATNG using chopstick %d and %d\n", id, left,
         right);
  sleep(2);

  // release chopsticks
  sem_post(&chopsticks[left]);
  sem_post(&chopsticks[right]);

  printf("[Philosopher %d]: eaten and put chopsticks down.\n", id);

  pthread_exit(NULL);
}

void dining_philosopher() {
  pthread_t threads[NUM_P];

  printf("\n\n\n ------------Dining philosopher--------\n\n");

  for (int i = 0; i < NUM_P; i++) {
    sem_init(&chopsticks[i], 0, 1);
  }
  for (int i = 0; i < NUM_P; i++) {
    pthread_create(&threads[i], NULL, philosopher, (void *)i);
  }
  for (int i = 0; i < NUM_P; i++) {
    pthread_join(threads[i], NULL);
  }
  for (int i = 0; i < NUM_P; i++) {
    sem_destroy(&chopsticks[i]);
  }
}

int main() {
  producer_consumer();
  dining_philosopher();
  return 0;
}
