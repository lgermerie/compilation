%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>
	#include "utils.c"
	#include"symTable.h"
	int yylex();
	void yyerror(char const *s);
	void id_error(char* id_name);
	void undefined_id_error(char *id_name);
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

%type<code> programme liste_declarations liste_fonctions declaration
%type<code> liste_declarateurs fonction type param_list param
%type<code> liste_instructions instruction iteration selection saut affectation
%type<code> bloc appel variable expression liste_expressions condition
%type<code> binary_op binary_rel binary_comp
%type<code> ';' ',' '(' ')' '{' '}' '[' ']' ':' '='

%union {
    char* id;  /* Pour réccupérer le nom des identificateurs */
		int valeur;
		char* code;
}

%left OP
%left REL
%start programme
%%

programme	:
		liste_declarations liste_fonctions 	{	$$ = concat($1, $2);
																					free($1);
																					free($2);
																					printf("%s", $$);}
;

liste_declarations	:
        liste_declarations declaration 	{
																					$$ = concat($1, $2);
																					/*free($1); Je ne pense pas qu'il faille gérer la mémoire pour yacc, les $X font référence à des champs de structs un peu comlexes...
																					free($2);*/
																					printf("Liste déclarations, $1 : %s\t$2 : %s\t$$ : %s\n", $1, $2, $$);
																				}
	|																			{	$$ = calloc(1, sizeof(char));} //chaine vide pour pouvoir utiliser free
;

liste_fonctions	:
      liste_fonctions fonction						{	$$ = concat($1, $2);
																						free($1);
																						free($2);
																						clean_local();}
	|   fonction														{	char* empty = calloc(1, sizeof(char));
																						$$ = concat($1, empty);
																						free(empty);
																						//print_tables();
																						clean_local();}
;

declaration	:
        type liste_declarateurs ';'				{	char* temp_code = concat($1, $2);
																						$$ = concat(temp_code, ";");
																						/*free($1);
																						free($2);*/
																						free(temp_code);
																						printf("----> Déclaration : %s \n", $$);
																					}
;

liste_declarateurs	:
        liste_declarateurs ',' declarateur  { printf("Liste déclarateur, $1 : %s, \t $2 : %s,\t $3 : %s\n", $1, $2, $3);
																							char* temp = concat($1, ",");
																							$$ = concat(temp, $3);
																							printf("temp : %s,\t $$ : %s\n", temp, $$);
																							/*free($1);
																							free($3);*/
																							free(temp);
																							printf("Liste déclarateurs $$ : %s\n", $$);}
		|		declarateur                         {	//char* empty = calloc(1, sizeof(char));
																							$$ = $1;
																							//free(empty);
																							printf("Liste déclarateur unique id : %s \t niveau : %d\t $$ : %s\n", $1, level, $$);}
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
																						printf("Déclarateur $$ : %s\n", $$);
																						/*char* empty = calloc(1, sizeof(char));
																						$$ = concat($1, empty);
																						free(empty);*/
                                        }

	|	declarateur '[' CONSTANTE ']'				{ char* temp1 = concat($1, $2);
																					char* cste = "CONSTANTE";
																					char* temp2 = concat(temp1, cste);
																					$$ = concat(temp2, $4);
																					free(temp1);
																					free(temp2);}
;

fonction	:
		type IDENTIFICATEUR '(' param_list ')' '{' liste_declarations liste_instructions '}' {if (fetch_global($2)) {
																																														print_tables();
																																														id_error($2);
																																														}
																																													add_global($2);
																																													char* temp1 = concat($1, $2);
																																													char* temp2 = concat(temp1, $3);
																																													char* temp3 = concat(temp2, $4);
																																													char* temp4 = concat(temp3, $5);
																																													char* temp5 = concat(temp4, $6);
																																													char* newline = "\n";
																																													char* temp6 = concat(temp5, newline);
																																													char* temp7 = concat(temp6, $7);
																																													char* temp8 = concat(temp7, $8);
																																													char* temp9 = concat(temp8, newline);
																																													$$ = concat(temp9, $9);
																																													free($1);
																																													free($4);
																																													free($7);
																																													free($8);
																																													free(temp1);
																																													free(temp2);
																																													free(temp3);
																																													free(temp4);
																																													free(temp5);
																																													free(temp6);
																																													free(temp7);
																																													free(temp8);
																																													free(temp9);
																																												}
	|	EXTERN type IDENTIFICATEUR '(' param_list ')' ';' 	{	char* ext = "extern ";
																													char* temp1 = concat(ext, $2);
																													char* temp2 = concat(temp1, $3);
																													char* temp3 = concat(temp2, $4);
																													char* temp4 = concat(temp3, $5);
																													char* temp5 = concat(temp4, $6);
																													$$ = concat(temp5, $7);
																													free($2);
																													free($5);
																													free(temp1);
																													free(temp2);
																													free(temp3);
																													free(temp4);
																													free(temp5);}

;

type	:
		VOID																								{	char* empty = calloc(1, sizeof(char));
																													char* type_void = "void ";
																												 	$$ = concat(type_void, empty);
																													free(empty);}
	|	INT																									{	char* empty = calloc(1, sizeof(char));
																													char* type_int = "int ";
																													$$ = concat(type_int, empty);
																													free(empty);}
;

param_list	:
		param_list ',' param 																{	level=1;
																													char* temp1 = concat($1, $2);
																													$$ = concat(temp1, $3);
																													free($1);
																													free($3);}
	|	param 																							{	level=1;
																													char* empty = calloc(1, sizeof(char));
																													$$ = concat($1, empty);
																													free(empty);}
	| 																										{	level=1;
																													$$ = calloc(1, sizeof(char));}
;

param	:
		INT IDENTIFICATEUR																	{	char* type_int = "int ";
																													$$ = concat(type_int, $2);}
;

liste_instructions :
		liste_instructions instruction											{	$$ = concat($1, $2);
																													free($1);
																													free($2);}
	|																											{	$$ = calloc(1, sizeof(char));}
;

instruction	:
		iteration																						{ char* empty = calloc(1, sizeof(char));
																													$$ = concat($1, empty);
																													free(empty);
																													free($1);}
	|	selection																						{ char* empty = calloc(1, sizeof(char));
																													$$ = concat($1, empty);
																													free(empty);
																													free($1);}
	|	saut																								{ char* empty = calloc(1, sizeof(char));
																													$$ = concat($1, empty);
																													free(empty);
																													free($1);}
	|	affectation ';'																			{ $$ = concat($1, $2);
																													free($1);}
	|	bloc																								{ char* empty = calloc(1, sizeof(char));
																													$$ = concat($1, empty);
																													free(empty);
																													free($1);}
	|	appel																								{ char* empty = calloc(1, sizeof(char));
																													$$ = concat($1, empty);
																													free(empty);
																													free($1);}
;

iteration	:
		FOR '(' affectation ';' condition ';' affectation ')' instruction			{	char* for_loop = "for(";
																																						char* temp1 = concat(for_loop, $3);
																																						char* temp2 = concat(temp1, $4);
																																						char* temp3 = concat(temp2, $5);
																																						char* temp4 = concat(temp3, $6);
																																						char* temp5 = concat(temp4, $7);
																																						char* temp6 = concat(temp5, $8);
																																						$$ = concat(temp6, $9);
																																						free($3);
																																						free($5);
																																						free($7);
																																						free($9);
																																						free(temp1);
																																						free(temp2);
																																						free(temp3);
																																						free(temp4);
																																						free(temp5);
																																						free(temp6);}
	|	WHILE '(' condition ')' instruction																		{	char* while_loop = "while(";
																																						char* temp1 = concat(while_loop, $3);
																																						char* temp2 = concat(temp1, $4);
																																						$$ = concat(temp2, $5);
																																						free($3);
																																						free($5);
																																						free(temp1);
																																						free(temp2);}
;

selection	:
		IF '(' condition ')' instruction %prec THEN														{	char* cond = "if(";
																																						char* temp1 = concat(cond, $3);
																																						char* temp2 = concat(temp1, $4);
																																						$$ = concat(temp2, $5);
																																						free($3);
																																						free($5);
																																						free(temp1);
																																						free(temp2);}
	|	IF '(' condition ')' instruction ELSE instruction											{	char* cond = "if(";
																																						char* temp1 = concat(cond, $3);
																																						char* temp2 = concat(temp1, $4);
																																						char* temp3 = concat(temp2, $5);
																																						char* else_kw = " else ";
																																						char* temp4 = concat(temp3, else_kw);
																																						$$ = concat(temp4, $7);
																																						free($3);
																																						free($5);
																																						free($7);
																																						free(temp1);
																																						free(temp2);
																																						free(temp3);
																																						free(temp4);}
	|	SWITCH '(' expression ')' instruction																	{	char* switch_kw = "switch(";
																																						char* temp1 = concat(switch_kw, $3);
																																						char* temp2 = concat(temp1, $4);
																																						$$ = concat(temp2, $5);
																																						free($3);
																																						free($5);
																																						free(temp1);
																																						free(temp2);}
	|	CASE CONSTANTE ':' instruction																				{ char* case_kw = "case ";
																																						char* cste = "CONSTANTE ";
																																						char* temp1 = concat(case_kw, cste);
																																						char* temp2 = concat(temp1, $3);
																																						$$ = concat(temp2, $4);
																																						free($4);
																																						free(temp1);
																																						free(temp2);}
	|	DEFAULT ':' instruction																								{ char* default_kw = "default : ";
																																						$$ = concat(default_kw, $3);
																																						free($3);}
;

saut	:
		BREAK ';'																															{ char* break_kw = "break;";
																																						char* empty = "";
																																						$$ = concat(break_kw, empty);}
	|	RETURN ';'																														{ char* return_kw = "return;";
																																						char* empty = "";
																																						$$ = concat(return_kw, empty);}
	|	RETURN expression ';'																									{	char* return_kw = "return ";
																																						char* temp1 = concat(return_kw, $2);
																																						$$ = concat(temp1, $3);
																																						free($2);}
;

affectation	:
		variable '=' expression																								{	char* temp1 = concat($1, $2);
																																						$$ = concat(temp1, $3);
																																						free($1);
																																						free($3);
																																						free(temp1);}
;

bloc	:
		'{' liste_declarations liste_instructions '}'													{	char* begin_block = "{\n";
																																						char* temp1 = concat(begin_block, $2);
																																						char* temp2 = concat(temp1, $3);
																																						$$ = concat(temp2, $4);
																																						free($2);
																																						free($3);
																																						free(temp1);
																																						free(temp2);
																																					}
;

appel	:
		IDENTIFICATEUR '(' liste_expressions ')' ';'													{	char* temp1 = concat($1, $2);
																																						char* temp2 = concat(temp1, $3);
																																						char* end = ");";
																																						$$ = concat(temp2, end);
																																						free($3);
																																						free(temp1);
																																						free(temp2);}
;

variable	:
		IDENTIFICATEUR											 																	{	if (!fetch_all($1)) { undefined_id_error($1);}
																																						char* empty = calloc(1, sizeof(char));
																																						$$ = concat($1, empty);
																																						free(empty);
																																					}
	|	variable '[' expression ']'																						{	char* temp1 = concat($1, $2);
																																						char* temp2 = concat(temp1, $3);
																																						$$ = concat(temp2, $4);
																																						free($1);
																																						free($3);
																																						free(temp1);
																																						free(temp2);}
;

expression	:
		'(' expression ')'																										{	char* temp1 = concat($1, $2);
																																						$$ = concat(temp1, $3);
																																						free($2);}
	|	expression binary_op expression %prec OP															{	char* temp1 = concat($1, $2);
																																						$$ = concat(temp1, $3);
																																						free($1);
																																						free($2);
																																						free($3);
																																						free(temp1);}
	|	MOINS expression																											{	char* moins = "-";
																																						$$ = concat(moins, $2);
																																						free($2);}
	|	CONSTANTE																															{ char* cste = "CONSTANTE";
																																						char* empty = "";
																																						$$ = concat(cste, empty);}
	|	variable																															{ $$ = $1;}
	|	IDENTIFICATEUR '(' liste_expressions ')'															{ char* temp1 = concat($1, $2);
																																						char* temp2 = concat(temp1, $3);
																																						$$ = concat(temp2, $4);
																																						free($3);}
;

liste_expressions	:
		liste_expressions ',' expression																			{ char* temp1 = concat($1, $2);
																																						$$ = concat(temp1, $3);
																																						free($1);
																																						free($3);}
	|   expression																													{	$$ = $1;}
	|																																				{ $$ = calloc(1, sizeof(char));}
;

condition	:
		NOT '(' condition ')'																									{	char* not = "!(";
																																						char* temp1 = concat(not, $3);
																																						$$ = concat(temp1, $4);
																																						free($3);
																																						free(temp1);}
	|	condition binary_rel condition %prec REL															{	char* temp1 = concat($1, $2);
																																						$$ = concat(temp1, $3);
																																						free($1);
																																						free($2);
																																						free($3);
																																						free(temp1);}
	|	'(' condition ')'																											{	char* temp1 = concat($1, $2);
																																						$$ = concat(temp1, $3);
																																						free($2);
																																						free(temp1);}
	|	expression binary_comp expression																			{	char* temp1 = concat($1, $2);
																																						$$ = concat(temp1, $3);
																																						free($1);
																																						free($2);
																																						free($3);
																																						free(temp1);}
;

binary_op	:
		PLUS																																	{ char* op = "+";
																																						char* empty = "";
																																						$$ = concat(op, empty);}
	| MOINS																																	{ char* op = "-";
																																						char* empty = "";
																																						$$ = concat(op, empty);}
	|	MUL																																		{ char* op = "*";
																																						char* empty = "";
																																						$$ = concat(op, empty);}
	|	DIV																																		{ char* op = "/";
																																						char* empty = "";
																																						$$ = concat(op, empty);}
	| LSHIFT																																{ char* op = "<<";
																																						char* empty = "";
																																						$$ = concat(op, empty);}
	| RSHIFT																																{ char* op = ">>";
																																						char* empty = "";
																																						$$ = concat(op, empty);}
	|	BAND																																	{ char* op = "&";
																																						char* empty = "";
																																						$$ = concat(op, empty);}
	|	BOR																																		{ char* op = "|";
																																						char* empty = "";
																																						$$ = concat(op, empty);}
;

binary_rel	:
		LAND																																	{	char* op = "&&";
																																						char* empty = "";
																																						$$ = concat(op, empty);}
	|	LOR																																		{ char* op = "||";
																																						char* empty = "";
																																						$$ = concat(op, empty);}
;

binary_comp	:
		LT																																		{ char* op = "<";
																																						char* empty = "";
																																						$$ = concat(op, empty);}
	|	GT																																		{ char* op = "<";
																																						char* empty = "";
																																						$$ = concat(op, empty);}
	|	GEQ																																		{ char* op = "<";
																																						char* empty = "";
																																						$$ = concat(op, empty);}
	|	LEQ																																		{ char* op = "<";
																																						char* empty = "";
																																						$$ = concat(op, empty);}
	|	EQ																																		{ char* op = "<";
																																						char* empty = "";
																																						$$ = concat(op, empty);}
	|	NEQ																																		{ char* op = "<";
																																						char* empty = "";
																																						$$ = concat(op, empty);}
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

void undefined_id_error(char *id_name) {
	fprintf(stderr, "undefined id on line %i : %s\n", yylineno, id_name);
	exit(1);
}

int main(void) {
	yyparse();
	fprintf(stdout, "alright alright alright \n");

	print_tables();

	clean_local();
	clean_global();
}
