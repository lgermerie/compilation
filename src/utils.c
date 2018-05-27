#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int current_label = 1;
char* label = "L";

char* concat(char* s1, char* s2) {

  int longueur_res = strlen(s1) + strlen(s2) + 1;
  char* res = malloc(longueur_res);

  memset(res, '\0', longueur_res);

  strncat(res, s1, strlen(s1));

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

typedef struct _list list;

struct _list {
  int val;
  list* next;
};

void increment(list* list_to_increment , int value) {
  if (list_to_increment) {
    list_to_increment->val += value;
    increment(list_to_increment->next, value);
  }
}

list* new_list(int value) {

  res_list = malloc(sizeof(list));

  res_list->next = NULL;
  res_list->val = value;

  return res_list;
  
}
