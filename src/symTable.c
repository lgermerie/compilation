#define SIZE 100
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symTable.h"


symbol *global_Vars[100];
symbol *local_Vars[100];
int max_Global = 0;
int max_Local = 0;

symbol *fetch_In(char *name, symbol *table[], int max) { //symbol to fetch, table to fetch in, number of symbols in table

  //printf("Fetch appellée\n");

  symbol *res;
  for (int i=0; i < max; i++) {
    if (!strcmp(table[i]->name, name)) {
      res = table[i];

      //printf("res trouvé\n");

      break;
    }
  }
/* Test de la comparaison avec NULL du pointeur
  if (res == NULL) {
    printf("Fetch : NULL\n");
  }
  else {
    printf("Fetch : pas NULL\n");
  }
*/
  return res;
}


symbol *fetch_global(char *name) {
  symbol *res = fetch_In(name, global_Vars, max_Global);
  return res;
}


symbol *fetch_local(char *name) {
  symbol *res = fetch_In(name, local_Vars, max_Local);
  if (!res) {   // !res ??
    return fetch_global(name);
  }
  return res;
}


void add_symbol(char *name, symbol *table[], int *max) {
  if (*max < 100) {
    symbol *new_sym = malloc(sizeof(symbol));
    new_sym->name=strdup(name);
    table[*max] = new_sym;
    (*max)++;
  }
}

void add_local(char *name) {
  add_symbol(name, local_Vars, &max_Local);
}

void add_global(char *name) {
  add_symbol(name, global_Vars, &max_Global);
}

void write_value(symbol *s, int v) {
  s->value = v;
  s->is_init=1;
}

int read_value(symbol s) {
  return s.value;
}

int is_initialized(symbol s) {
  return s.is_init;
}

void clean_local() {
  for (int i = 0; i < max_Local; i++) {
    free(local_Vars[i]);
  }
  max_Local = 0;
}

void clean_global() {
  for (int i = 0; i < max_Global; i++) {
    free(global_Vars[i]);
  }
  max_Global = 0;
}


void print_tables() {
  printf("Global vars : \n");
  for (int i = 0; i < max_Global; i++) {
    printf("\t %s", global_Vars[i]->name);
    if (i%5==0) {
      printf("\n");
    }
  }

  printf("Local vars : \n");
  for (int i = 0; i < max_Local; i++) {
    printf("\t %s", local_Vars[i]->name);
    if (i%5==0) {
      printf("\n");
    }
  }
  printf("\n");
}
