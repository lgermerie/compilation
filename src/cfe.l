D                       [0-9]
L                       [a-zA-Z_]
H                       [a-fA-F0-9]
E                       [Ee][+-]?{D}+
FS                      (f|F|l|L)
IS                      (u|U|l|L)*

%{
#include <stdio.h>
#include "cfe.tab.h"
%}

%x IN_COMMENT

%%
"break"                 {return BREAK;}
"case"                  {return CASE;}
"default"               {return DEFAULT;}
"else"                  {return ELSE;}
"extern"                {return EXTERN;}
"for"                   {return FOR;}
"if"                    {return IF;}
"int"                   {return INT;}
"return"                {return RETURN;}
"switch"                {return SWITCH;}
"void"                  {return VOID;}
"while"                 {return WHILE;}

{L}({L}|{D})*           {   /* Mentionner problème dans la soutenance : l'affectation yylval.id = yytext ne fonctionne pas du tout, elle inclue le caractère suivant… */
                            yylval.id = malloc(strlen(yytext) + 1);         // On affecte au pointeur de la place, peut être faut il faire un free quelque part ?
                            memset(yylval.id, '\0', strlen(yytext) + 1);
                            strncpy(yylval.id, yytext, strlen(yytext)); // puis on copie juste la longueur de l'identifiant reconnu
                            printf("Lex : %s\n", yylval.id);
                            return IDENTIFICATEUR;      // enfin on renvoit le token
                        }

<INITIAL>{
"/*"                    {printf("FOUND COMMENT\n");
                        BEGIN(IN_COMMENT);}
}
<IN_COMMENT>{
"*/"                    {printf("END COMMENT\n");   /*mentionner dans la soutenance*/
                        BEGIN(INITIAL);}
[^*\n]+                 // eat comment in chunks
"*"                     // eat the lone star
\n                      yylineno++;
}

{D}+                    {return CONSTANTE;}

">>"                    {return RSHIFT;}
"<<"                    {return LSHIFT;}
"&&"                    {return LAND;}
"||"                    {return LOR;}
"<="                    {return LEQ;}
">="                    {return GEQ;}
"=="                    {return EQ;}
"!="                    {return NEQ;}
"!"                     {return NOT;}
"+"                     {return PLUS;}
"-"                     {return MOINS;}
"*"                     {return MUL;}
"/"                     {return DIV;}
"&"                     {return BAND;}
"|"                     {return BOR;}
"<"                     {return LT;}
">"                     {return GT;}

[ \t\v\f]               { /* Ignore */ }
\n                      {yylineno++;}
.                       { return yytext[0]; }
%%
