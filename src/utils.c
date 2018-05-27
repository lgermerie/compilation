#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int current_label = 1;
int current_var = 1;
char* label = "L";
char* var_prefix = "_x";
char* concat(char* s1, char* s2) {

  int longueur_res = strlen(s1) + strlen(s2) + 1;
  char* res = malloc(longueur_res);
  char* espace = " ";

  memset(res, '\0', longueur_res);

  strncat(res, s1, strlen(s1));
  //strncat(res, espace, 1);
  strncat(res, s2, strlen(s2));

  return res;
}

char* int_to_str(int n) {
  char* str = calloc(12, sizeof(char));
  sprintf(str, "%d", n);
  return str;
}

char* new_label() {
  char* tostr = int_to_str(current_label);
  char* res = concat(label, tostr);
  free(tostr);
  current_label++;
  return res;
}

char* new_var() {
  char* tostr = int_to_str(current_var);
  char* res = concat(var_prefix, tostr);
  free(tostr);
  current_var++;
  return res;
}
