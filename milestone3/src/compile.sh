#!/bin/bash

# Change directory to milestone1/src
cd src

# Compile parser.y using bison
bison -d parser.y

# Compile lexer.l using flex
flex lexer.l

# Compile the generated files using g++
g++ -o parser lex.yy.c parser.tab.c 2> output.txt 

#./src/parser tests/test1.py > docoutput/out1.dot

#dot -Tpng docoutput/out1.dot -o ast/out1.png