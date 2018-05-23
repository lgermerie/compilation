#include <stdio.h>
#include <stdlib.h>

char* concat(char* s1, char* s2) {

  int longueur_res = strlen(s1) + strlen(s2) + 1;
  char* res = malloc(longueur_res);

  memset(res, '\0', longueur_res);

  strncat(res ,s1, strlen(s1));
  strncat(res, s2, strlen(s2));

  free(s1);
  free(s2);

  return res;


}
