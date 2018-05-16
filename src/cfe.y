%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>
	#include"symTable.h"
	int yylex();
	void yyerror(char const *s);
	void id_error(char* id_name);
	int level=0;            // Niveau de déclaration de variables pour la table des symboles -- 0 -> global, 1 -> local
  extern int yylineno;    // Permet de compter les lignes, et d'indiquer où se trouve un erreur
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
    char* id;  /* Pour réccupérer le nom des identificateurs */
}

%left OP
%left REL
%start programme
%%

programme	:
		liste_declarations liste_fonctions {}
;

liste_declarations	:
        liste_declarations declaration
	|
;

liste_fonctions	:
      liste_fonctions fonction						{	print_tables();
																						clean_local();}
	|   fonction														{	print_tables();
																						clean_local();}
;

declaration	:
        type liste_declarateurs ';'
;

liste_declarateurs	:
        liste_declarateurs ',' declarateur  {printf("Déclaration de l'id : %s \t niveau : %d\n", $3, level);}
		|		declarateur                         {printf("Déclaration de l'id : %s \t niveau : %d\n", $1, level);}
;

declarateur	:
        IDENTIFICATEUR                  {
                                            if (level==1) {   // Si on est dans un bloc
																								if (fetch_local($1)) {	// On test si l'identificateur est déjà enregistré
																									printf("local error \n");
																									print_tables();
																									id_error($1);	// Si oui on a une erreur
																								}
																								add_local($1);	// Sinon on l'enregistre
																						}

																						else {	// On est hors d'un bloc
																								if (fetch_global($1)) {
																									printf("global error \n");
																									print_tables();
																									id_error($1);
																								}
																								add_global($1);
																						}
																						$$ = $1;
                                        }

	|	declarateur '[' CONSTANTE ']'   //{$$ = $1;}
;

fonction	:
		type IDENTIFICATEUR '(' param_list ')' '{' liste_declarations liste_instructions '}' {if (fetch_global($2)) {
																																														printf("global error \n");
																																														print_tables();
																																														id_error($2);
																																														}
																																													printf("Id fonction : %s\n", $2);
																																													add_global($2);
																																												}
	|	EXTERN type IDENTIFICATEUR '(' param_list ')' ';'

;

type	:
		VOID
	|	INT
;

param_list	:
		param_list ',' param 									{level=1;}
	|	param 																{level=1;}
	| 																			{level=1;}
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
	|   expression
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

void id_error (char* id_name) {
	fprintf(stderr, "id already declared on line %i : %s\n", yylineno, id_name);
	exit(1);
}

int main(void) {
	yyparse();
	fprintf(stdout, "alright alright alright \n");

	print_tables();

	clean_local();
	clean_global();
}
