%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>
	#include"symTable.h"
	#include "utils.h"

	int yylex();
	void yyerror(char const *s);
	void id_error(char* id_name);
	void undefined_id_error(char *id_name);
	int level=0;            // Niveau de déclaration de variables pour la table des symboles -- 0 -> global, 1 -> local
  extern int yylineno;    // Permet de compter les lignes, et d'indiquer où se trouve un erreur
	char* semicolon = ";";
	char* semicolon_newline = ";\n";
	char* coma = ",";
	char* lpar = "(";
	char* rpar = ")";
	char* lbrace = "{";
	char* rbrace = "}\n";
	char* lbracket = "[";
	char* rbracket = "]";
	char* colon = ":";
	char* equal = "=";
	char* newline = "\n";
	char* go = "goto ";
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

%type<code> programme liste_declarations liste_fonctions declaration
%type<code> liste_declarateurs fonction type param_list param
%type<code> liste_instructions instruction iteration selection saut affectation
%type<code> bloc appel variable expression liste_expressions condition
%type<code> binary_op binary_rel binary_comp declarateur
%type<code> ';' ',' '(' ')' '{' '}' '[' ']' ':' '='
%type<valeur> CONSTANTE
//%type<var> declarateur

/*%code requires {
	typedef	struct New_Var {
	  char* name;
	  char* code;
	  int size;
	} new_var;
}*/

%union {
    /*char* id;  // Pour réccupérer le nom des identificateurs
		int valeur;
		char* code;
		new_var var;*/
		int valeur;
		char* id;
		struct {
		  char* name;
			char* code;
			int size;
		} code;
}

%left OP
%left REL
%start programme
%%

programme	:
		liste_declarations liste_fonctions 	{	$$.code = concat($1.code, $2.code);
																					free($1.code);
																					free($2.code);
																					printf("%s", $$.code);}
;

liste_declarations	:
        liste_declarations declaration 	{
																					$$.code = concat($1.code, $2.code);
																					free($1.code);
																					free($2.code);
																				}
	|																			{	$$.code = calloc(1, sizeof(char));} //chaine vide pour pouvoir utiliser free
;

liste_fonctions	:
      liste_fonctions fonction						{	$$.code = concat($1.code, $2.code);
																						free($1.code);
																						free($2.code);}
	|   fonction														{	char* empty = calloc(1, sizeof(char));
																						$$.code = concat($1.code, empty);
																						free(empty);
																						free($1.code);
																						//print_tables();
																					}
;

declaration	:
        type liste_declarateurs ';'				{	/*char* temp_code = concat($1.code, $2.code);
																						$$.code = concat(temp_code, semicolon_newline);
																						free($1.code);
																						free($2.code);
																						free(temp_code);*/
																						$$.code = $2.code;
																					}
;

liste_declarateurs	:
        liste_declarateurs ',' declarateur  { /*char* temp = concat($1.code, coma);
																							$$.code = concat(temp, $3.code);
																							free($1.code);
																							free($3.code);
																							free(temp);*/
																							char* type_int = "int ";//hardcoded for now
																							char* temp1 = concat($1.code, type_int);
																							char* temp2 = concat(temp1, $3.code);
																							$$.code = concat(temp2, semicolon_newline);
																							free(temp1);
																							free(temp2);
																							free($1.code);
																							free($3.code);}
		|		declarateur                         {	char* empty = calloc(1, sizeof(char));
																							char* type_int = "int ";
																							char* temp1 = concat(type_int, $1.code);
																							$$.code = concat(temp1, semicolon_newline);
																							free($1.code);
																							free(empty);}
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

																						char* empty = "";
																						$$.code = concat($1, empty);
																						$$.name = concat($1, empty);
																						$$.size = 1;
																						free($1);
                                        }

	|	declarateur '[' CONSTANTE ']'				{ char* empty = calloc(1, sizeof(char));
																					$$.size = $3 * $1.size;
																					$$.name = concat($1.name, empty);
																					char* temp1 = concat($1.name, lbracket);
																					char* cste = int_to_str($$.size);
																					char* temp2 = concat(temp1, cste);
																					$$.code = concat(temp2, rbracket);
																					free(empty);
																					free(temp1);
																					free(cste);
																					free(temp2);
																				}
;

fonction	:
		type IDENTIFICATEUR '(' param_list ')' '{' liste_declarations liste_instructions '}' {	clean_local();
																																														if (fetch_global($2)) {
																																														print_tables();
																																														id_error($2);
																																														}
																																													add_global($2);
																																													char* temp1 = concat($1.code, $2);
																																													char* temp2 = concat(temp1, lpar);
																																													char* temp3 = concat(temp2, $4.code);
																																													char* temp4 = concat(temp3, rpar);
																																													char* temp5 = concat(temp4, lbrace);
																																													char* newline = "\n";
																																													char* temp6 = concat(temp5, newline);
																																													char* temp7 = concat(temp6, $7.code);
																																													char* temp8 = concat(temp7, $8.code);
																																													char* temp9 = concat(temp8, newline);
																																													$$.code = concat(temp8, rbrace);
																																													free($1.code);
																																													free($4.code);
																																													free($7.code);
																																													free($8.code);
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
	|	EXTERN type IDENTIFICATEUR '(' param_list ')' ';' 	{	if (fetch_global($3)) {
																														printf("global error \n");
																														print_tables();
																														id_error($3);
																													}
																													add_global($3);
																													char* ext = "extern ";
																													char* temp1 = concat(ext, $2.code);
																													char* temp2 = concat(temp1, $3);
																													char* temp3 = concat(temp2, lpar);
																													char* temp4 = concat(temp3, $5.code);
																													char* temp5 = concat(temp4, rpar);
																													$$.code = concat(temp5, semicolon_newline);
																													free($2.code);
																													free($5.code);
																													free(temp1);
																													free(temp2);
																													free(temp3);
																													free(temp4);
																													free(temp5);
																													clean_local();//on nettoie les variables locales introduites par param_list
																												}

;

type	:
		VOID																								{	char* empty = calloc(1, sizeof(char));
																													char* type_void = "void ";
																												 	$$.code = concat(type_void, empty);
																													free(empty);}
	|	INT																									{	char* empty = calloc(1, sizeof(char));
																													char* type_int = "int ";
																													$$.code = concat(type_int, empty);
																													free(empty);}
;

param_list	:
		param_list ',' param 																{	level=1;
																													char* temp1 = concat($1.code, coma);
																													$$.code = concat(temp1, $3.code);
																													free($1.code);
																													free($3.code);}
	|	param 																							{	level=1;
																													char* empty = calloc(1, sizeof(char));
																													$$.code = concat($1.code, empty);
																													free(empty);}
	| 																										{	level=1;
																													$$.code = calloc(1, sizeof(char));}
;

param	:
		INT IDENTIFICATEUR																	{	char* type_int = "int ";
																													if (fetch_local($2)) {	// On test si l'identificateur est déjà enregistré
																														printf("local error \n");
																														print_tables();
																														id_error($2);	// Si oui on a une erreur
																													}
																													add_local($2);	// Sinon on l'enregistre
																													$$.code = concat(type_int, $2);
																													free($2);}
;

liste_instructions :
		liste_instructions instruction											{	$$.code = concat($1.code, $2.code);
																													free($1.code);
																													free($2.code);}
	|																											{	$$.code = calloc(1, sizeof(char));}
;

instruction	:
		iteration																						{ char* empty = calloc(1, sizeof(char));
																													$$.code = concat($1.code, empty);
																													free(empty);
																													free($1.code);}
	|	selection																						{ char* empty = calloc(1, sizeof(char));
																													$$.code = concat($1.code, empty);
																													free(empty);
																													free($1.code);}
	|	saut																								{ char* empty = calloc(1, sizeof(char));
																													$$.code = concat($1.code, empty);
																													free(empty);
																													free($1.code);}
	|	affectation ';'																			{ $$.code = concat($1.code, semicolon_newline);
																													free($1.code);}
	|	bloc																								{ char* empty = calloc(1, sizeof(char));
																													$$.code = concat($1.code, empty);
																													free(empty);
																													free($1.code);}
	|	appel																								{ char* empty = calloc(1, sizeof(char));
																													$$.code = concat($1.code, empty);
																													free(empty);
																													free($1.code);}
;

iteration	:
		FOR '(' affectation ';' condition ';' affectation ')' instruction			{	char* for_loop = "for(";
																																						char* temp1 = concat(for_loop, $3.code);
																																						char* temp2 = concat(temp1, semicolon);
																																						char* temp3 = concat(temp2, $5.code);
																																						char* temp4 = concat(temp3, semicolon);
																																						char* temp5 = concat(temp4, $7.code);
																																						char* temp6 = concat(temp5, rpar);
																																						$$.code = concat(temp6, $9.code);
																																						free($3.code);
																																						free($5.code);
																																						free($7.code);
																																						free($9.code);
																																						free(temp1);
																																						free(temp2);
																																						free(temp3);
																																						free(temp4);
																																						free(temp5);
																																						free(temp6);}
	|	WHILE '(' condition ')' instruction																		{	/* ORIGINAL
																																						char* while_loop = "while(";
																																						char* temp1 = concat(while_loop, $3);
																																						char* temp2 = concat(temp1, rpar);
																																						$$ = concat(temp2, $5);
																																						free($3);
																																						free($5);
																																						free(temp1);
																																						free(temp2);*/
																																						char* label1 = new_label();
																																						char* label2 = new_label();
																																						char* temp1 = concat(go, label1);
																																						char* temp2 = concat(temp1, newline);
																																						char* temp3 = concat(label2, colon);
																																						char* temp4 = concat(temp3, newline);
																																						char* temp5 = concat(temp4, $5.code);
																																						char* temp6 = concat(temp5, newline);
																																						char* temp7 = concat(temp6, label1);
																																						char* temp8 = concat(temp7, colon);
																																						char* iftest = " if(";
																																						char* temp9 = concat(temp8, iftest);
																																						char* temp10 = concat(temp9, $3.code);
																																						char* rpargoto = ") goto ";
																																						char* temp11 = concat(temp10, rpargoto);
																																						char* temp12 = concat(temp11, label2);
																																						$$.code = concat(temp12, semicolon_newline);
																																						free(temp1);
																																						free(temp2);
																																						free(temp3);
																																						free(temp4);
																																						free(temp5);
																																						free(temp6);
																																						free(temp7);
																																						free(temp8);
																																						free(temp9);
																																						free(temp10);
																																						free(temp11);
																																						free(temp12);
																																						free($3.code);
																																						free($5.code);
																																						free(label1);
																																						free(label2);}
;

selection	:
		IF '(' condition ')' instruction %prec THEN														{	/*ORIGINAL
																																						char* cond = "if(";
																																						char* temp1 = concat(cond, $3);
																																						char* temp2 = concat(temp1, rpar);
																																						$$ = concat(temp2, $5);
																																						free($3);
																																						free($5);
																																						free(temp1);
																																						free(temp2);*/
																																						char* ifnot = "if(!(";
																																						char* temp1 = concat(ifnot, $3.code);
																																						char* double_rpar = ")) goto ";
																																						char* temp2 = concat(temp1, double_rpar);
																																						char* label1 = new_label();
																																						char* temp3 = concat(temp2, label1);
																																						char* temp4 = concat(temp3, semicolon_newline);
																																						char* temp5 = concat(temp4, $5.code);
																																						char* temp6 = concat(temp5, label1);
																																						char* colon_nl = ":\n";
																																						$$.code = concat(temp6, colon_nl);
																																						free(temp1);
																																						free(temp2);
																																						free(temp3);
																																						free(temp4);
																																						free(temp5);
																																						free(temp6);
																																						free(label1);
																																						free($3.code);
																																						free($5.code);}
	|	IF '(' condition ')' instruction ELSE instruction											{	/*ORIGINAL
																																						char* cond = "if(";
																																						char* temp1 = concat(cond, $3);
																																						char* temp2 = concat(temp1, rpar);
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
																																						free(temp4);*/
																																						char* ifnot = "if(!(";
																																						char* temp1 = concat(ifnot, $3.code);
																																						char* double_rpar = ")) goto ";
																																						char* temp2 = concat(temp1, double_rpar);
																																						char* label1 = new_label();
																																						char* label2 = new_label();
																																						char* temp3 = concat(temp2, label1);
																																						char* temp4 = concat(temp3, semicolon_newline);
																																						char* temp5 = concat(temp4, $5.code);
																																						char* temp6 = concat(temp5, go);
																																						char* temp7 = concat(temp6, label2);
																																						char* temp8 = concat(temp7, semicolon_newline);
																																						char* temp9 = concat(temp8, label1);
																																						char* colon_nl = ":\n";
																																						char* temp10 = concat(temp9, colon_nl);
																																						char* temp11 = concat(temp10, $7.code);
																																						char* temp12 = concat(temp11, label2);
																																						$$.code = concat(temp12, colon_nl);
																																						free(temp1);
																																						free(temp2);
																																						free(temp3);
																																						free(temp4);
																																						free(temp5);
																																						free(temp6);
																																						free(temp7);
																																						free(temp8);
																																						free(temp9);
																																						free(temp10);
																																						free(temp11);
																																						free(temp12);
																																						free(label1);
																																						free(label2);
																																						free($3.code);
																																						free($5.code);
																																						free($7.code);}
	|	SWITCH '(' expression ')' instruction																	{	/* ORIGINAL
																																						char* switch_kw = "switch(";
																																						char* temp1 = concat(switch_kw, $3.code);
																																						char* temp2 = concat(temp1, rpar);
																																						$$.code = concat(temp2, $5.code);
																																						free($3.code);
																																						free($5.code);
																																						free(temp1);
																																						free(temp2);*/

																																						char* switch_expr = strdup($3.code);
																																						char* code = strdup($5.code);

																																						$$.code = replace_substring(code, "...", switch_expr);

																																						free(code);
																																						free(switch_expr);


																																					}
	|	CASE CONSTANTE ':' instruction																		{ /*char* case_kw = "case ";
																																						char* cste = int_to_str($2);
																																						char* temp1 = concat(case_kw, cste);
																																						char* temp2 = concat(temp1, colon);
																																						$$.code = concat(temp2, $4.code);
																																						free($4.code);
																																						free(temp1);
																																						free(temp2);*/
																																						char* subst = "...";
																																						char* iflpar = "if(";
																																						char* nequals = " != ";
																																						char* rpargoto = ") goto ";
																																						char* temp1 = concat(iflpar, subst/*$$.switch_expr**/);
																																						char* temp2 = concat(temp1, nequals);
																																						char* cste = int_to_str($2);
																																						char* temp3 = concat(temp2, cste);
																																						char* temp4 = concat(temp3, rpargoto);
																																						char* label1 = new_label();
																																						char* temp5 = concat(temp4, label1);
																																						char* temp6 = concat(temp5, semicolon_newline);
																																						char* temp7 = concat(temp6, $4.code);
																																						char* temp8 = concat(temp7, label1);
																																						char* colon_nl = " :\n";
																																						$$.code = concat(temp8, colon_nl);
																																						free(temp1);
																																						free(temp2);
																																						free(temp3);
																																						free(temp4);
																																						free(temp5);
																																						free(temp6);
																																						free(temp7);
																																						free(temp8);
																																						free(label1);
																																						free(cste);
																																						free($4.code);}
	|	DEFAULT ':' instruction																								{ char* default_kw = "default : ";
																																						$$.code = concat(default_kw, $3.code);
																																						free($3.code);}
;

saut	:
		BREAK ';'																															{ char* break_kw = "break;\n";
																																						char* empty = "";
																																						$$.code = concat(break_kw, empty);}
	|	RETURN ';'																														{ char* return_kw = "return;\n";
																																						char* empty = "";
																																						$$.code = concat(return_kw, empty);}
	|	RETURN expression ';'																									{	char* return_kw = "return ";
																																						char* temp1 = concat(return_kw, $2.code);
																																						$$.code = concat(temp1, semicolon_newline);
																																						free($2.code);}
;

affectation	:
		variable '=' expression																								{	char* temp1 = concat($1.code, equal);
																																						$$.code = concat(temp1, $3.code);
																																						free($1.code);
																																						free($3.code);
																																						free(temp1);}
;

bloc	:
		'{' liste_declarations liste_instructions '}'													{	char* begin_block = "{\n";
																																						char* temp1 = concat(begin_block, $2.code);
																																						char* temp2 = concat(temp1, $3.code);
																																						$$.code = concat(temp2, rbrace);
																																						free($2.code);
																																						free($3.code);
																																						free(temp1);
																																						free(temp2);
																																					}
;

appel	:
		IDENTIFICATEUR '(' liste_expressions ')' ';'													{	char* temp1 = concat($1, lpar);
																																						char* temp2 = concat(temp1, $3.code);
																																						char* end = ");\n";
																																						$$.code = concat(temp2, end);
																																						free($1);
																																						free($3.code);
																																						free(temp1);
																																						free(temp2);}
;

variable	:
		IDENTIFICATEUR											 																	{	if (!fetch_all($1)) { printf("failed to fetch %s",$1); print_tables(); undefined_id_error($1);}
																																						char* empty = calloc(1, sizeof(char));
																																						$$.code = concat($1, empty);
																																						free(empty);
																																					}
	|	variable '[' expression ']'																						{	char* temp1 = concat($1.code, lbracket);
																																						char* temp2 = concat(temp1, $3.code);
																																						$$.code = concat(temp2, rbracket);
																																						free($1.code);
																																						free($3.code);
																																						free(temp1);
																																						free(temp2);}
;

expression	:
		'(' expression ')'																										{	char* temp1 = concat(lpar, $2.code);
																																						$$.code = concat(temp1, rpar);
																																						free($2.code);}
	|	expression binary_op expression %prec OP															{	char* temp1 = concat($1.code, $2.code);
																																						$$.code = concat(temp1, $3.code);
																																						free($1.code);
																																						free($2.code);
																																						free($3.code);
																																						free(temp1);}
	|	MOINS expression																											{	char* moins = "-";
																																						$$.code = concat(moins, $2.code);
																																						free($2.code);}
	|	CONSTANTE																															{ char* cste = int_to_str($1);
																																						char* empty = "";
																																						$$.code = concat(cste, empty);}
	|	variable																															{ $$.code = $1.code;}
	|	IDENTIFICATEUR '(' liste_expressions ')'															{ char* temp1 = concat($1, lpar);
																																						char* temp2 = concat(temp1, $3.code);
																																						$$.code = concat(temp2, rpar);
																																						free($3.code);}
;

liste_expressions	:
		liste_expressions ',' expression																			{ char* temp1 = concat($1.code, coma);
																																						$$.code = concat(temp1, $3.code);
																																						free($1.code);
																																						free($3.code);}
	|   expression																													{	$$.code = $1.code;}
	|																																				{ $$.code = calloc(1, sizeof(char));}
;

condition	:
		NOT '(' condition ')'																									{	char* not = "!(";
																																						char* temp1 = concat(not, $3.code);
																																						$$.code = concat(temp1, rpar);
																																						free($3.code);
																																						free(temp1);}
	|	condition binary_rel condition %prec REL															{	char* temp1 = concat($1.code, $2.code);
																																						$$.code = concat(temp1, $3.code);
																																						free($1.code);
																																						free($2.code);
																																						free($3.code);
																																						free(temp1);}
	|	'(' condition ')'																											{	char* temp1 = concat(lpar, $2.code);
																																						$$.code = concat(temp1, rpar);
																																						free($2.code);
																																						free(temp1);}
	|	expression binary_comp expression																			{	char* temp1 = concat($1.code, $2.code);
																																						$$.code = concat(temp1, $3.code);
																																						free($1.code);
																																						free($2.code);
																																						free($3.code);
																																						free(temp1);}
;

binary_op	:
		PLUS																																	{ char* op = "+";
																																						char* empty = "";
																																						$$.code = concat(op, empty);}
	| MOINS																																	{ char* op = "-";
																																						char* empty = "";
																																						$$.code = concat(op, empty);}
	|	MUL																																		{ char* op = "*";
																																						char* empty = "";
																																						$$.code = concat(op, empty);}
	|	DIV																																		{ char* op = "/";
																																						char* empty = "";
																																						$$.code = concat(op, empty);}
	| LSHIFT																																{ char* op = "<<";
																																						char* empty = "";
																																						$$.code = concat(op, empty);}
	| RSHIFT																																{ char* op = ">>";
																																						char* empty = "";
																																						$$.code = concat(op, empty);}
	|	BAND																																	{ char* op = "&";
																																						char* empty = "";
																																						$$.code = concat(op, empty);}
	|	BOR																																		{ char* op = "|";
																																						char* empty = "";
																																						$$.code = concat(op, empty);}
;

binary_rel	:
		LAND																																	{	char* op = "&&";
																																						char* empty = "";
																																						$$.code = concat(op, empty);}
	|	LOR																																		{ char* op = "||";
																																						char* empty = "";
																																						$$.code = concat(op, empty);}
;

binary_comp	:
		LT																																		{ char* op = "<";
																																						char* empty = "";
																																						$$.code = concat(op, empty);}
	|	GT																																		{ char* op = ">";
																																						char* empty = "";
																																						$$.code = concat(op, empty);}
	|	GEQ																																		{ char* op = ">=";
																																						char* empty = "";
																																						$$.code = concat(op, empty);}
	|	LEQ																																		{ char* op = "<=";
																																						char* empty = "";
																																						$$.code = concat(op, empty);}
	|	EQ																																		{ char* op = "==";
																																						char* empty = "";
																																						$$.code = concat(op, empty);}
	|	NEQ																																		{ char* op = "!=";
																																						char* empty = "";
																																						$$.code = concat(op, empty);}
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
	fprintf(stdout, "\n\n---------------------------\n\nalright alright alright \n");

	//print_tables();

	clean_local();
	clean_global();
}
