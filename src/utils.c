#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char* concat(char* s1, char* s2) {

  int longueur_res = strlen(s1) + strlen(s2) + 2;
  char* res = malloc(longueur_res);
  char* espace = " ";

  memset(res, '\0', longueur_res);

  strncat(res, s1, strlen(s1));
  strncat(res, espace, 1);
  strncat(res, s2, strlen(s2));

  return res;


}
