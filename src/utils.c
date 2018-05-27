#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "utils.h"

int current_label = 1;
int current_var = 1;
char* label = "L";
char* var_prefix = "_x";

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

char* new_var() {
  char* tostr = int_to_str(current_var);
  char* res = concat(var_prefix, tostr);
  free(tostr);
  current_var++;
  return res;
}


// Remplace toutes les occurences de sub_string_old dans une string par sub_string_new
char* replace_substring(char* string, char* sub_string_old, char* sub_string_new) {

  char* str_res = strndup(string, strlen(string));
  int delta = strlen(sub_string_new) - strlen(sub_string_old);

  char* position;


  while((position = strstr(str_res, sub_string_old)) != NULL) {

    char* new_str = malloc(strlen(str_res) + delta);
    memset(new_str, '\0', strlen(str_res) + delta);

    strncat(new_str, str_res, position - str_res); // On copie tout le début de la chaine jusqu'à l'apparition du motif
    strcat(new_str, sub_string_new);
    strcat(new_str, position + strlen(sub_string_old));

    free(str_res);
    str_res = strdup(new_str);
    free(new_str);

  }

  return str_res;
}

/*
int main(int argc, char const *argv[]) {

  char* test = strdup("T..T..");
  char* toto = strdup("tata");

  char* titi = replace_substring(test, "..", "bite");


  printf("%s\n", titi);
  return 0;
}
*/

/****************************************************************
Fonctions de gestion de la liste d'entiers
****************************************************************/

// Permert d'incrémenter tous les éléments d'une liste par une valeur passée en argument
void increment(list* list_to_increment , int value) {
  if (list_to_increment) {
    list_to_increment->val += value;
    increment(list_to_increment->next, value);
  }
}

// Retourne un élément de liste initialisé à value
list* new_list(int value) {

  list* res_list = malloc(sizeof(list));

  res_list->next = NULL;
  res_list->val = value;

  return res_list;

}
