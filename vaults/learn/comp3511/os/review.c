#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

void signal_callback(int sig) {
  printf("DIEEEEE RIGHT NOWWWW\n");
  exit(1);
}
int main(int argc, char *argv[]) {
  pid_t pid = getpid();
  pid_t ppid = getppid();

  printf("current program pid: %d\n", pid);
  printf("parent program pid: %d\n", ppid);

  // sleep
  printf("The program HAJIMERU\n");
  sleep(1);
  printf("After 1 sec\n");
  usleep(0.67);
  printf("After 0.67 sec\n");

  // handle signal
  printf("CTRL-C now or die slowly\n");
  signal(SIGINT, signal_callback);
  sleep(1);
  printf("5\n");
  sleep(1);
  printf("4\n");
  sleep(1);
  printf("3\n");
  sleep(1);
  printf("2\n");
  sleep(1);
  printf("1\n");
  sleep(1);
  printf("0\n");
  printf("BYE\n");

  // forking
  int i;
  pid = fork();

  pid_t childPid;
  int childStat;

  if (pid > 0) { // parent process
    printf("parent %d\n", getpid());
    // wait for child
    childPid = wait(&childStat);
    printf("child %d with status %d\n", childPid, childStat);
  } else {
    printf("I am child inside %d\n", getppid());
  }
  return 0;
}
