%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>
	#include"symTable.h"
	int yylex();
	void yyerror(char const *s);
	int level=0;//niveau de déclaration de variables pour la table des symboles -- 0 -> global, 1 -> local
    extern int yylineno;
%}

%error-verbose

%token <id> IDENTIFICATEUR
%token CONSTANTE VOID INT FOR WHILE IF ELSE SWITCH CASE DEFAULT
%token BREAK RETURN PLUS MOINS MUL DIV LSHIFT RSHIFT BAND BOR LAND LOR LT GT
%token GEQ LEQ EQ NEQ NOT EXTERN
%left PLUS MOINS
%left MUL DIV
%left LSHIFT RSHIFT
%left BOR BAND
%left LAND LOR
%nonassoc THEN
%nonassoc ELSE
%type<id> declarateur

%union {
    int id;  /* Pour réccupérer le nom de l'identificateur */
}

%left OP
%left REL
%start programme
%%
programme	:
		liste_declarations liste_fonctions
;
liste_declarations	:
        liste_declarations declaration
	|
;
liste_fonctions	:
        liste_fonctions fonction
	|   fonction
;
declaration	:
        type liste_declarateurs ';' {printf("declaration\n");}
;
liste_declarateurs	:
        liste_declarateurs ',' declarateur  {printf("Id : %d\n", $3);}
	|	declarateur
;
declarateur	:
        IDENTIFICATEUR                  {$$ = $1;}
	|	declarateur '[' CONSTANTE ']'   {$$ = $1;}
;
fonction	:
		type IDENTIFICATEUR '(' param_list ')' '{' liste_declarations liste_instructions '}' {level=1;//passage aux déclarations internes
																																														///actions...
																																													level=0;}
	|	EXTERN type IDENTIFICATEUR '(' param_list ')' ';'

;
type	:
		VOID
	|	INT
;
param_list	:
		param_list ',' param
	|	param
	|
;
param	:
		INT IDENTIFICATEUR
;
liste_instructions :
		liste_instructions instruction
	|
;
instruction	:
		iteration
	|	selection
	|	saut
	|	affectation ';'
	|	bloc
	|	appel
;
iteration	:
		FOR '(' affectation ';' condition ';' affectation ')' instruction
	|	WHILE '(' condition ')' instruction
;
selection	:
		IF '(' condition ')' instruction %prec THEN
	|	IF '(' condition ')' instruction ELSE instruction
	|	SWITCH '(' expression ')' instruction
	|	CASE CONSTANTE ':' instruction
	|	DEFAULT ':' instruction
;
saut	:
		BREAK ';'
	|	RETURN ';'
	|	RETURN expression ';'
;
affectation	:
		variable '=' expression
;
bloc	:
		'{' liste_declarations liste_instructions '}'
;
appel	:
		IDENTIFICATEUR '(' liste_expressions ')' ';'
;
variable	:
		IDENTIFICATEUR
	|	variable '[' expression ']'
;
expression	:
		'(' expression ')'
	|	expression binary_op expression %prec OP
	|	MOINS expression
	|	CONSTANTE
	|	variable
	|	IDENTIFICATEUR '(' liste_expressions ')'
;
liste_expressions	:
		liste_expressions ',' expression
	| expression
	|
;
condition	:
		NOT '(' condition ')'
	|	condition binary_rel condition %prec REL
	|	'(' condition ')'
	|	expression binary_comp expression
;
binary_op	:
		PLUS
	| MOINS
	|	MUL
	|	DIV
	| LSHIFT
	| RSHIFT
	|	BAND
	|	BOR
;
binary_rel	:
		LAND
	|	LOR
;
binary_comp	:
		LT
	|	GT
	|	GEQ
	|	LEQ
	|	EQ
	|	NEQ
;
%%

void yyerror (char const *s) {
	fprintf(stderr, "syntax error at %i: %c\n", yylineno, yychar);
    exit(1);
}

int main(void) {
	yyparse();
	fprintf(stdout, "alright alright alright \n");
	char *test_global = "var1";
	char *test_local = "var2";
	char *test_local2 = "var3";

	add_global(test_global);
	add_local(test_local);
	add_local(test_local2);

	print_tables();

	clean_local();
	clean_global();
}
