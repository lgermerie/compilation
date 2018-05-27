#!/usr/bin/env bash

bison -d -v cfe.y
flex cfe.l
gcc -c symTable.c lex.yy.c cfe.tab.c utils.c
gcc symTable.o lex.yy.o cfe.tab.o utils.o -o try.out -ll

./try.out
