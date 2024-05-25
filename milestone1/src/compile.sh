#!/bin/bash

# Change directory to milestone1/src
cd src

# Compile parser.y using bison
bison -d parser.y

# Compile lexer.l using flex
flex lexer.l

# Compile the generated files using g++
g++ -std=c++11 -o parser lex.yy.c parser.tab.c
