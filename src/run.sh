#!/usr/bin/env bash

bison -d -v cfe.y
flex cfe.l

OS="`uname`"
case $OS in
  'Linux')
    OS='Linux'
    gcc lex.yy.c cfe.tab.c -o try -ll
    ;;

  'Darwin')
    OS='Mac'
    gcc lex.yy.c cfe.tab.c -o try -LFL
    ;;
  *) ;;
esac


./try
