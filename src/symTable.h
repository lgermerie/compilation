
typedef struct _symbol {
 char *name;
 int value;
 int is_init;
} symbol;

symbol *fetch_In(char *name, symbol *table[], int max);
symbol *fetch_global(char *name);
symbol *fetch_local(char *name);
void add_symbol(char *name, symbol *table[], int *max);
void add_local(char *name);
void add_global(char *name);
void write_value(symbol *s, int v);
int read_value(symbol s);
int is_initialized(symbol s);
void clean_local();
void clean_global();
void print_tables();
