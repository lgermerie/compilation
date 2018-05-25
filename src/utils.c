#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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
