#ifndef UTILS
#define UTILS
typedef struct _list list;

struct _list {
  int val;
  list* next;
};


void increment(list* list_to_increment , int value);
list* new_list(int value);

char* new_var();
char* new_label();
char* int_to_str(int n);
char* concat(char* s1, char* s2);
#endif
