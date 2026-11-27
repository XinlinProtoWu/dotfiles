/*
    COMP3511 Fall 2026
    PA1: Simplified Linux Shell (MyShell)

    Your name:          Xinlin Wu
    Your ITSC email:    xwudz@connect.ust.hk

    Declaration:

    I declare that I am not involved in plagiarism
    I understand that both parties (i.e., students providing the codes and
   students copying the codes) will receive 0 marks.
*/

/*
    Header files for MyShell
    Necessary header files are included.
    Do not include extra header files
*/
#define _GNU_SOURCE
#include <fcntl.h>  // For open/read/write/close syscalls
#include <signal.h> // For signal handling
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h> // For constants that are required in open/read/write/close syscalls
#include <sys/types.h>
#include <sys/wait.h> // For wait() - suppress warning messages
#include <unistd.h>

#define MYSHELL_MESSAGE "COMP3511 PA1 (Fall 2026)"

// Define template strings so that they can be easily used in printf
//
// Usage: assume pid is the process ID
//
//  printf(TEMPLATE_MYSHELL_START, pid);
//
#define TEMPLATE_MYSHELL_START "Myshell (pid=%d) starts\n"
#define TEMPLATE_MYSHELL_END "Myshell (pid=%d) ends\n"
#define TEMPLATE_MYSHELL_TERMINATE                                             \
  "Myshell (pid=%d) terminates by Ctrl-C with signal: %d\n"
#define TEMPLATE_MYSHELL_CD_ERROR "Myshell cd command error\n"

// Assume that each command line has at most 256 characters (including NULL)
#define MAX_CMDLINE_LENGTH 256

// Assume that we have at most 8 arguments
#define MAX_ARGUMENTS 8

// Assume that we only need to support 2 types of space characters:
// " " (space) and "\t" (tab)
#define SPACE_CHARS " \t"

// The pipe character
#define PIPE_CHAR "|"

// Assume that we only have at most 8 pipe segements,
// and each segment has at most 256 characters
#define MAX_PIPE_SEGMENTS 8

// Assume that we have at most 8 arguments for each segment
// We also need to add an extra NULL item to be used in execvp
// Thus: 8 + 1 = 9
//
// Example:
//   echo a1 a2 a3 a4 a5 a6 a7
//
// execvp system call needs to store an extra NULL to represent the end of the
// parameter list
//
//   char *arguments[MAX_ARGUMENTS_PER_SEGMENT];
//
//   strings stored in the array: echo a1 a2 a3 a4 a5 a6 a7 NULL
//
#define MAX_ARGUMENTS_PER_SEGMENT 9

// Define the standard file descriptor IDs here
#define STDIN_FILENO 0  // Standard input
#define STDOUT_FILENO 1 // Standard output

// This function will be invoked by main()
// TODO: Replace the shell prompt with your own ITSC account name
void show_prompt(char *prompt, char *path) {
  // TODO: replace the shell prompt with your ITSC account name
  // For example, if you ITSC account is cspeter@connect.ust.hk
  // You should replace ITSC with cspeter
  printf("%s %s> ", prompt, path);
  // Flush so the prompt appears immediately and is NOT duplicated when a
  // forked child later flushes its own (inherited) copy of the stdio buffer.
  fflush(stdout);
}

// This function will be invoked by main()
// This function is given
int get_cmd_line(char *cmdline) {
  int i;
  int n;
  if (!fgets(cmdline, MAX_CMDLINE_LENGTH, stdin))
    return -1;
  // Ignore the newline character
  n = strlen(cmdline);
  cmdline[--n] = '\0';
  i = 0;
  while (i < n && cmdline[i] == ' ') {
    ++i;
  }
  if (i == n) {
    // Empty command
    return -1;
  }
  return 0;
}

// parse_arguments function is given
// This function helps you parse the command line
//
// Suppose the following variables are defined:
//
// char *pipe_segments[MAX_PIPE_SEGMENTS]; // character array buffer to store
// the pipe segements int num_pipe_segments; // an output integer to store the
// number of pipe segment parsed by this function char
// cmdline[MAX_CMDLINE_LENGTH]; // The input command line
//
// Sample usage:
// You can use different delimiters. For example:
//
//  parse_arguments(pipe_segments, cmdline, &num_pipe_segments, "|");
//  parse_arguments(pipe_segments, cmdline, &num_pipe_segments, SPACE_CHARS);
//
void parse_arguments(char **argv, char *line, int *numTokens, char *delimiter) {
  int argc = 0;
  char *read = line;

  while (*read != '\0') {
    char *write;
    int at_delimiter;
    int in_quotes = 0;

    while (*read != '\0' && strchr(delimiter, *read) != NULL)
      read++;
    if (*read == '\0')
      break;

    argv[argc++] = read;
    write = read;
    while (*read != '\0') {
      // double-quote text handling is implemented here
      if (*read == '"') {
        in_quotes = !in_quotes;
        read++;
      } else if (!in_quotes && strchr(delimiter, *read) != NULL) {
        break;
      } else {
        *write++ = *read++;
      }
    }
    at_delimiter = *read != '\0';
    *write = '\0';
    if (at_delimiter)
      read++;
  }
  *numTokens = argc;
}

// This is an example usage of parse arguments
// It helps you quickly learn how to use the provided helper function
// You DON'T need to call this function in your PA1 submission
void example_usage_parse_arguments(char *cmdline) {
  char cmdlineCopy[MAX_CMDLINE_LENGTH];
  char *argv[MAX_ARGUMENTS];
  int numToken = 0;
  printf("=== Sample usage of parse arguments ===\n");
  printf("=== Do not call this function in your PA1 submission\n");

  // parse_arguments will modify the character array
  // it is necessary to make a copy
  strcpy(cmdlineCopy, cmdline);

  // SPACE_CHARS is used as a delimiter
  // You can use other delimiter (e.g., PIPE_CHAR)
  parse_arguments(argv, cmdlineCopy, &numToken, SPACE_CHARS);

  // after parsing, display the array values
  for (int i = 0; i < numToken; i++)
    printf("%d : %s\n", i, argv[i]);
}

// ============================================================================
// Signal handler for Ctrl-C (SIGINT)
// ============================================================================
void sigint_handler(int signum) {
  printf(TEMPLATE_MYSHELL_TERMINATE, getpid(), signum);
  exit(0);
}

// ============================================================================
// Execute one pipe segment (a single command).
//
// This function:
//   1. Parses the segment into words (arguments).
//   2. Removes "< file" (input redirection) and "> file" (output redirection).
//   3. Redirects STDIN/STDOUT to those files if requested.
//   4. Replaces the current process image with execvp().
//
// NOTE: the pipe wiring (STDIN/STDOUT) must already be set up by the caller
//       before this function is called.
// ============================================================================
void execute_command(char *segment) {
  char segment_copy[MAX_CMDLINE_LENGTH];
  char *argv[MAX_ARGUMENTS_PER_SEGMENT];       // tokens before filtering
  char *clean_argv[MAX_ARGUMENTS_PER_SEGMENT]; // final args passed to execvp
  int argc = 0;
  int clean_argc = 0;
  char *input_file = NULL;
  char *output_file = NULL;
  int i;

  // parse_arguments() modifies the string, so work on a copy
  strcpy(segment_copy, segment);
  parse_arguments(argv, segment_copy, &argc, SPACE_CHARS);

  // Separate the redirection operators from the real command arguments
  for (i = 0; i < argc; i++) {
    if (strcmp(argv[i], "<") == 0) {
      // The next token is the input file
      input_file = argv[i + 1];
      i++;
    } else if (strcmp(argv[i], ">") == 0) {
      // The next token is the output file
      output_file = argv[i + 1];
      i++;
    } else {
      clean_argv[clean_argc++] = argv[i];
    }
  }
  clean_argv[clean_argc] = NULL; // execvp needs a NULL terminator

  // Input redirection: replace STDIN with the input file
  if (input_file != NULL) {
    int fd = open(input_file, O_RDONLY);
    if (fd < 0) {
      perror("myshell: input redirection");
      exit(1);
    }
    dup2(fd, STDIN_FILENO);
    close(fd);
  }

  // Output redirection: replace STDOUT with the output file
  if (output_file != NULL) {
    int fd = open(output_file, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd < 0) {
      perror("myshell: output redirection");
      exit(1);
    }
    dup2(fd, STDOUT_FILENO);
    close(fd);
  }

  // Replace this process with the requested command
  execvp(clean_argv[0], clean_argv);

  // execvp only returns on error
  perror("myshell: execvp");
  exit(1);
}

// ============================================================================
// Process a command line. Called by the child process forked in main().
//
//   1. Split the command line into pipe segments (by '|').
//   2. If there is a single segment, just run it.
//   3. Otherwise create pipes, fork one child per segment, wire STDIN/STDOUT
//      between consecutive segments, and wait for all of them.
// ============================================================================
void process_cmd(char *cmdline) {
  char *pipe_segments[MAX_PIPE_SEGMENTS];
  int num_pipe_segments = 0;
  int fds[MAX_PIPE_SEGMENTS - 1][2];
  int i, j;

  parse_arguments(pipe_segments, cmdline, &num_pipe_segments, PIPE_CHAR);

  // Single command (no pipe)
  if (num_pipe_segments == 1) {
    execute_command(pipe_segments[0]);
    exit(1); // execute_command never returns on success
  }

  // Create the pipes between consecutive segments
  for (i = 0; i < num_pipe_segments - 1; i++) {
    if (pipe(fds[i]) == -1) {
      perror("myshell: pipe");
      exit(1);
    }
  }

  // Fork one child process for each pipe segment
  for (i = 0; i < num_pipe_segments; i++) {
    pid_t pid = fork();
    if (pid == -1) {
      perror("myshell: fork");
      exit(1);
    }

    if (pid == 0) {
      // Child process
      //
      // Segment i reads from the previous pipe (if any) and writes to the
      // next pipe (if any). The first segment reads STDIN and the last
      // segment writes to STDOUT.
      int in_fd = (i == 0) ? STDIN_FILENO : fds[i - 1][0];
      int out_fd = (i == num_pipe_segments - 1) ? STDOUT_FILENO : fds[i][1];

      // Wire the pipe ends to STDIN/STDOUT
      if (in_fd != STDIN_FILENO) {
        dup2(in_fd, STDIN_FILENO);
      }
      if (out_fd != STDOUT_FILENO) {
        dup2(out_fd, STDOUT_FILENO);
      }

      // Close every pipe file descriptor in this child.
      // This is critical: if a child keeps the write end of the pipe it reads
      // from open, it will never see EOF and will hang forever.
      for (j = 0; j < num_pipe_segments - 1; j++) {
        close(fds[j][0]);
        close(fds[j][1]);
      }

      execute_command(pipe_segments[i]);
      exit(1); // execute_command never returns on success
    }
  }

  // Parent: close all pipe ends, then wait for all children
  for (j = 0; j < num_pipe_segments - 1; j++) {
    close(fds[j][0]);
    close(fds[j][1]);
  }
  for (i = 0; i < num_pipe_segments; i++) {
    wait(NULL);
  }
  exit(0);
}

/* The main function implementation */
int main(void) {
  // Make stdin unbuffered.
  //
  // Without this, when commands are piped into the shell, fgets() reads a
  // large chunk of the input at once. If the shell then fork()s a child that
  // exec()s ANOTHER shell (e.g., the nested-myshell hidden test), those
  // buffered lines are lost and the inner shell sees EOF and spins forever.
  // Unbuffered stdin makes fgets() pull exactly one line at a time.
  setvbuf(stdin, NULL, _IONBF, 0);

  printf("%s\n\n", MYSHELL_MESSAGE);
  fflush(stdout);

  // Associate the interrupt (Ctrl-C) signal with our handler
  signal(SIGINT, sigint_handler);

  // TODO: replace the shell prompt with your ITSC account name
  // For example, if you ITSC account is cspeter@connect.ust.hk
  // You should replace ITSC with cspeter
  char *prompt = "ITSC";
  char cmdline[MAX_CMDLINE_LENGTH];
  printf(TEMPLATE_MYSHELL_START, getpid());
  fflush(stdout);
  char path[256];

  // The main event loop
  while (1) {
    getcwd(path, 256);
    show_prompt(prompt, path);
    if (get_cmd_line(cmdline) == -1)
      continue; /* empty line handling */

    // ---- Built-in commands: exit and cd ----
    // They cannot be run through fork + execvp, so handle them directly.
    //
    // Only the first two words are needed. Using parse_arguments() here with
    // a small buffer is dangerous: a pipe command can contain many more
    // space-separated tokens than MAX_ARGUMENTS_PER_SEGMENT and would
    // overflow the stack. So we tokenize at most 2 words manually.
    {
      char buf[MAX_CMDLINE_LENGTH];
      char *tokens[2];
      int ntok = 0;
      char *q;

      strcpy(buf, cmdline);
      q = buf;
      while (ntok < 2) {
        while (*q == ' ' || *q == '\t')
          q++;
        if (*q == '\0')
          break;
        tokens[ntok++] = q;
        while (*q != '\0' && *q != ' ' && *q != '\t')
          q++;
        if (*q != '\0') {
          *q = '\0';
          q++;
        }
      }

      if (ntok > 0) {
        // Feature 1: exit command
        if (strcmp(tokens[0], "exit") == 0) {
          break; // leave the loop and print the ending message
        }

        // Feature 3: cd command
        if (strcmp(tokens[0], "cd") == 0) {
          if (ntok == 2 && chdir(tokens[1]) == 0) {
            // success: prompt will show the new directory on next iteration
          } else {
            printf(TEMPLATE_MYSHELL_CD_ERROR);
            fflush(stdout);
          }
          continue;
        }
      }
    }

    // ---- External command ----
    // Fork a child; the child runs the command (and pipes, if any).
    // The parent waits for the child to finish before showing the prompt again.
    pid_t pid = fork();
    if (pid == 0) {
      // Child process handles the command
      process_cmd(cmdline);
      exit(0); // safety: process_cmd always exits, this is just a guard
    } else {
      // Parent simply waits for the child and does nothing
      wait(NULL);
    }
  }

  printf(TEMPLATE_MYSHELL_END, getpid());
  fflush(stdout);
  return 0;
}
