#!/usr/bin/env bash

bison -d -v cfe.y
flex cfe.l
gcc lex.yy.c cfe.tab.c -o try.o -ll

./try.o
