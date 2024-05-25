%{
#include<bits/stdc++.h>
#include "parser.tab.h"
#include "astnode.hpp"
using namespace std;
int indent_stack[100];
int top = -1;
int dedent_level = 0;  
char firstChar;
char *copyyytext;
char* string_literal_value = NULL;
int lno=1;
%}

%x  DEDENTATION
%option yylineno

COMMENT             [ \t\f]*"#"
LOGICAL_LINE        [^\\]\n
PHYSICAL_LINE       [^\\][\r\n"EOF"]
EXPLICIT_LINE       \\[[\n{COMMENT}]];
IMPLICIT_LINE       [\n{COMMENT}]
BLANK_LINE          ([ \t\f]*\n)|({COMMENT})
KEYWORDS            False|await|else|import|Pass|None|break|except|in|raise|True|class|finally|is|and|continue|for|lambda|try|as|def|from|nonlocal|while|assert|del|global|not|with|async|elif|if|or|yield
SOFT_KEYWORDS       match|case|type|\_
OPERATORS           "+"|"\-"|"\*"|"\*\*"|"/"|"//"|"%"|"@"|"<<"|">>"|"&"|"|"|"\^"|"~"|":="|"<"|">"|"<="|">="|"=="|"!="
DELIMITERS          "("|")"|"\["|"\]"|"\{"|"\}"|","|":"|"\."|";"|"@"|"="|"->"|"\+="|"\-="|"="|"/="|"//="|"%="|"@="|"&="|"|="|"\^="|">>="|"<<="|"\*="

STRING_PREFIX       "r"|"u"|"R"|"U"|"f"|"F"|"fr"|"Fr"|"fR"|"FR"|"rf"|"rF"|"Rf"|"RF"
SHORT_STRING_ITEM   [\']([^\n\\]*|\\[.]*)[\']|[\"]([^\n\\]*|\\[.]*)[\"]
LONG_STRING_ITEM    \'\'\'([^\\]*|\\[.]*)\'\'\'|\"\"\"([^\\]*|\\[.]*)\"\"\"
STRING_LITERAL      {STRING_PREFIX}?{SHORT_STRING_ITEM}|{STRING_PREFIX}?{SHORT_STRING_ITEM}|{STRING_PREFIX}?{LONG_STRING_ITEM}|{STRING_PREFIX}?{LONG_STRING_ITEM}
BYTES_PREFIX        "b"|"B"|"br"|"Br"|"bR"|"BR"|"rb"|"rB"|"Rb"|"RB"
BYTES_LITERAL       {BYTES_PREFIX}?{SHORT_STRING_ITEM}|{BYTES_PREFIX}?{SHORT_STRING_ITEM}|{BYTES_PREFIX}?{LONG_STRING_ITEM}|{BYTES_PREFIX}?{LONG_STRING_ITEM}
IDENTIFIER          [_A-Za-z][_A-Za-z0-9]*[A-Za-z0-9]+[_A-Za-z0-9]*|[A-Za-z]
RESERVED_IDENTIFIERS    "\\"[]"\\"|"\_"[]|"_"|"\\"[]*
ESCAPE_SEQUENCES    [^rR][\n]|[\\]|[\a]|[\b]|[\f]|[\n]|[\r]|[\t]|[\v]|[\ooo]|[\xhh]|[\']|[\"]
bindigit            [01]
octdigit            [0-7]
hexdigit            [0-9a-fA-F]
decinteger          ([1-9][0-9]*([\_][0-9]+)*)|("0"+([\_]"0")*)
bininteger          ["0"][bB]([\_]{bindigit})+
octinteger          ["0"][oO]([\_]{octdigit})+
hexinteger          ["0"][xX]([\_]{hexdigit})+
INTEGER             [\+\-]?({decinteger}|{bininteger}|{hexinteger}|{octinteger})
DIGITPART           [0-9]+(["_"][0-9]+)* 
FRACTION            "."{DIGITPART}
POINTFLOAT          ({DIGITPART}{FRACTION})|({DIGITPART}".")
EXPONENTFLOAT       [{DIGITPART}{POINTFLOAT}]{EXPONENT}
EXPONENT            [eE][\+\-]{0,1}{DIGITPART}
FLOAT_NUMBER        [+-]?({POINTFLOAT}|{EXPONENTFLOAT})
IMAGINARY_LITERALS  [{FLOAT_NUMBER}|{DIGITPART}]["J"|"j"]

%%

%{
    if(top==-1){
        indent_stack[++top] = 0;
    }
%}

[ \t\f\r] {;}
[\n]                            {return NEWLINE;}
{COMMENT}{PHYSICAL_LINE}           {return NEWLINE;}
{EXPLICIT_LINE}                 {return NEWLINE;}
({IMPLICIT_LINE})|\[{IMPLICIT_LINE}\]|\{{IMPLICIT_LINE}\} {return NEWLINE;}
{BLANK_LINE}                    {return NEWLINE;}
{FLOAT_NUMBER}                  {yylval.str = yytext;  return FLOAT;}
{INTEGER}|"0"                   {yylval.str = yytext; return INT;}
{STRING_LITERAL} {
    char* s = yytext; 
    for(int i = 0; i < strlen(yytext); i++){
        if(s[i]=='"'){
            s[i]='\'';}
    } 
    yytext = s;
    yylval.str = yytext; 
    return STRING;
}
^[^ \t\n]+ {
    if (indent_stack[top]!= 0){
        copyyytext=strdup(yytext);
        firstChar = yytext[0];
        unput(yytext[0]);
        BEGIN(DEDENTATION);
    }
    else
    {
        REJECT;
    }
}
^[ ]+  {
    if (indent_stack[top] < yyleng) {
        indent_stack[++top] = yyleng;
        return INDENT;
    } else if (indent_stack[top] > yyleng) {
        dedent_level=yyleng;
        unput(32);/*32 for space*/
        BEGIN(DEDENTATION);
    }
}
<DEDENTATION>[ ] {
        if (top >= 0 && indent_stack[top] != dedent_level) {
            top = top -1;
            unput(32);return DEDENT;
        }
        else
        {
            dedent_level=0;
            BEGIN(INITIAL);
        }
        if (top == -1) {
            fprintf(stderr, "Error: Incorrect indentation on line %d\n", yylineno);
            exit(1);
        }
}
<DEDENTATION>[^ \t\n] {
    if (indent_stack[top] != 0) {
        top--;
        unput(yytext[0]);  
        return DEDENT;
    }
    else
    {
        for (int i = strlen(copyyytext) - 1; i >= 0; i--) {
            unput(copyyytext[i]);
        }
    BEGIN(INITIAL);
    }  
}
<<EOF>>    {
        while (top >0) {
        top = top -1;
        return DEDENT;
    }
    yyterminate();
    }
[ \t]  {;}
"."                         {return DOT;}
"/"                         {return DIV; }
"%"                         {return PERCENT;}
"+"                         {return ADD;}
"-"                         {return SUB;}
"\/\/"                      {return DOUBLE_SLASH;}
"\*"                        {return MULTIPLY;}
"="                         {return EQUAL_TO; }
"<="                        {return LTE;}
">="                        {return GTE;}
"=="                        {return EQUAL_EQUAL;}
">"                         {return GT; }
"<"                         {return LT; }
"!="                        {return EXEQ; }
"->"                        {return RIGHT_ARROW; }
"\&"                        {return BITWISE_OPER_AND; }
"|"                         {return BITWISE_OPER_OR; }
"^"                         {return BITWISE_OPER_XOR; }
"~"                         {return BITWISE_OPER_NOT; }
"\<\<"                      {return LTLT;}
"\>\>"                      {return GTGT;}
"\.\.\."                    {return DDDOT;}
"+="|"-="|"*="|"/="|"%="|"**="|"&="|"|="|"^="|"<<="|">>="     {yylval.str = yytext;   return ASSIGNMENT_OPER;}
"_"                         {return UNDERSCORE;}
"print"                     {return PRINT;}
"False"                     {return FALSE;}
"await"                     {return AWAIT;}
"else"                      {return ELSE;}
"range"                     {return RANGE;}
"None"                      {return NONE;}
"break"                     {return BREAK;}
"except"                    {return EXCEPT;}
"in"                        {return IN;}
"raise"                     {return RAISE;}
"True"                      {return TRUE;}
"class"                     {return CLASS;}
"finally"                   {return FINALLY;}
"is"                        {return IS;}
"return"                    {return RETURN;}
"continue"                  {return CONTINUE;}
"for"                       {return FOR;}
"try"                       {return TRY;}
"as"                        {return AS;}
"def"                       {return DEF;}
"from"                      {return FROM;}
"while"                     {return WHILE;}
"assert"                    {return ASSERT;}
"global"                    {return GLOBAL;}
"with"                      {return WITH;}
"elif"                      {return ELIF;}
"if"                        {return IF;}
"and"                       {return AND;}
"or"                        {return OR;}
"not"                       {return NOT;}
"int"|"float"|"bool"|"str"  {yylval.astnode = new IdentifierNode(yytext); return DATA_TYPE;}
"("                         {return LEFT_PAR;}
")"                         {return RIGHT_PAR;}
"["                         {return LEFT_SQUARE_BRACE;}
"]"                         {return RIGHT_SQUARE_BRACE;}
"{"                         {return LEFT_CURLY;}
"}"                         {return RIGHT_CURLY;}
","                         {return COMMA;}
":"                         {return COLON;}
";"                         {return SEMI_COLON;}
[a-zA-Z_][a-zA-Z0-9_]*      {yylval.astnode = new IdentifierNode(yytext);  return NAME;}
. {cout << "Invalid Char at "<< yylineno << endl;  return 0;}
%%

int yywrap() {
    return 1;
}