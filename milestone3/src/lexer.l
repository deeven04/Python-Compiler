%{
#include<bits/stdc++.h>
#include "parser.tab.h"
#include "symbol_table.cpp"
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

[ \t\f\r] {}
[\n]                            {return NEWLINE;}
{COMMENT}{PHYSICAL_LINE}           {return NEWLINE;}
{EXPLICIT_LINE}                 {return NEWLINE;}
({IMPLICIT_LINE})|\[{IMPLICIT_LINE}\]|\{{IMPLICIT_LINE}\} {return NEWLINE;}
{BLANK_LINE}                    {return NEWLINE;}
{FLOAT_NUMBER}                  {yylval.n_terminal=new nonterminal(yytext); return FLOAT;}
{INTEGER}|"0"                   {yylval.n_terminal=new nonterminal(yytext); return INT;}
{STRING_LITERAL} {
    char* s = strdup(yytext);
    for(int i = 0; i < strlen(s); i++){
        if(s[i]=='"'){
            s[i]='\'';}
    } 
    yylval.n_terminal=new nonterminal(s); 
    free(s);
    cout<<"string:"<<yytext<<endl;
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
    free(copyyytext);
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
"."                         {yylval.n_terminal=new nonterminal(yytext);return DOT;}
"/"                         {yylval.n_terminal=new nonterminal(yytext);return DIV; }
"%"                         {yylval.n_terminal=new nonterminal(yytext);return PERCENT;}
"+"                         {yylval.n_terminal=new nonterminal(yytext);return ADD;}
"-"                         {yylval.n_terminal=new nonterminal(yytext);return SUB;}
"\/\/"                      {yylval.n_terminal=new nonterminal(yytext);return DOUBLE_SLASH;}
"\*"                        {yylval.n_terminal=new nonterminal(yytext);return MULTIPLY;}
"="                         {cout<<"equal_to"<<endl;yylval.n_terminal=new nonterminal(yytext);return EQUAL_TO; }
"<="                        {yylval.n_terminal=new nonterminal(yytext);return LTE;}
">="                        {yylval.n_terminal=new nonterminal(yytext);return GTE;}
"=="                        {yylval.n_terminal=new nonterminal(yytext);return EQUAL_EQUAL;}
">"                         {yylval.n_terminal=new nonterminal(yytext);return GT; }
"<"                         {yylval.n_terminal=new nonterminal(yytext);return LT; }
"!="                        {yylval.n_terminal=new nonterminal(yytext);return EXEQ; }
"->"                        {yylval.n_terminal=new nonterminal(yytext);return RIGHT_ARROW; }
"\&"                        {yylval.n_terminal=new nonterminal(yytext);return BITWISE_OPER_AND; }
"|"                         {yylval.n_terminal=new nonterminal(yytext);return BITWISE_OPER_OR; }
"^"                         {yylval.n_terminal=new nonterminal(yytext);return BITWISE_OPER_XOR; }
"~"                         {yylval.n_terminal=new nonterminal(yytext);return BITWISE_OPER_NOT; }
"\<\<"                      {yylval.n_terminal=new nonterminal(yytext);return LTLT;}
"\>\>"                      {yylval.n_terminal=new nonterminal(yytext);return GTGT;}
"\.\.\."                    {yylval.n_terminal=new nonterminal(yytext);return DDDOT;}
"+="|"-="|"*="|"/="|"%="|"**="|"&="|"|="|"^="|"<<="|">>="     {yylval.n_terminal=new nonterminal(yytext);return ASSIGNMENT_OPER;}
"_"                         {yylval.n_terminal=new nonterminal(yytext);return UNDERSCORE;}
"print"                     {yylval.n_terminal=new nonterminal(yytext);return PRINT;}
"False"                     {char str[1000];strcpy(str,"bool");yylval.n_terminal=new nonterminal(yytext,str);return FALSE;}
"await"                     {yylval.n_terminal=new nonterminal(yytext);return AWAIT;}
"else"                      {yylval.n_terminal=new nonterminal(yytext);return ELSE;}
"range"                     {yylval.n_terminal=new nonterminal(yytext);return RANGE;}
"None"                      {yylval.n_terminal=new nonterminal(yytext);return NONE;}
"break"                     {yylval.n_terminal=new nonterminal(yytext);return BREAK;}
"except"                    {yylval.n_terminal=new nonterminal(yytext);return EXCEPT;}
"in"                        {yylval.n_terminal=new nonterminal(yytext);return IN;}
"raise"                     {yylval.n_terminal=new nonterminal(yytext);return RAISE;}
"True"                      {char str[1000];strcpy(str,"bool");yylval.n_terminal=new nonterminal(yytext,str);return TRUE;}
"class"                     {yylval.n_terminal=new nonterminal(yytext);return CLASS;}
"finally"                   {yylval.n_terminal=new nonterminal(yytext);return FINALLY;}
"is"                        {yylval.n_terminal=new nonterminal(yytext);return IS;}
"return"                    {yylval.n_terminal=new nonterminal(yytext);return RETURN;}
"continue"                  {yylval.n_terminal=new nonterminal(yytext);return CONTINUE;}
"for"                       {yylval.n_terminal=new nonterminal(yytext);return FOR;}
"try"                       {yylval.n_terminal=new nonterminal(yytext);return TRY;}
"as"                        {yylval.n_terminal=new nonterminal(yytext);return AS;}
"def"                       {yylval.n_terminal=new nonterminal(yytext);return DEF;}
"from"                      {yylval.n_terminal=new nonterminal(yytext);return FROM;}
"while"                     {yylval.n_terminal=new nonterminal(yytext);return WHILE;}
"assert"                    {yylval.n_terminal=new nonterminal(yytext);return ASSERT;}
"global"                    {yylval.n_terminal=new nonterminal(yytext);return GLOBAL;}
"with"                      {yylval.n_terminal=new nonterminal(yytext);return WITH;}
"elif"                      {yylval.n_terminal=new nonterminal(yytext);return ELIF;}
"if"                        {yylval.n_terminal=new nonterminal(yytext);return IF;}
"and"                       {yylval.n_terminal=new nonterminal(yytext);return AND;}
"or"                        {yylval.n_terminal=new nonterminal(yytext);return OR;}
"not"                       {yylval.n_terminal=new nonterminal(yytext);return NOT;}
"int"                       {char str[1000];strcpy(str,"int");yylval.n_terminal=new nonterminal(yytext,str);return DATA_TYPE;}
"float"                       {char str[1000];strcpy(str,"float");yylval.n_terminal=new nonterminal(yytext,str);return DATA_TYPE;}
"bool"                       {char str[1000];strcpy(str,"bool");yylval.n_terminal=new nonterminal(yytext,str);return DATA_TYPE;}
"str"                       {char str[1000];strcpy(str,"string");yylval.n_terminal=new nonterminal(yytext,str);return DATA_TYPE;}
"("                         {yylval.n_terminal=new nonterminal(yytext);return LEFT_PAR;}
")"                         {yylval.n_terminal=new nonterminal(yytext);return RIGHT_PAR;}
"["                         {yylval.n_terminal=new nonterminal(yytext);return LEFT_SQUARE_BRACE;}
"]"                         {yylval.n_terminal=new nonterminal(yytext);return RIGHT_SQUARE_BRACE;}
"{"                         {yylval.n_terminal=new nonterminal(yytext);return LEFT_CURLY;}
"}"                         {yylval.n_terminal=new nonterminal(yytext);return RIGHT_CURLY;}
","                         {yylval.n_terminal=new nonterminal(yytext);return COMMA;}
":"                         {cout<<"colon"<<endl;yylval.n_terminal=new nonterminal(yytext);return COLON;}
";"                         {yylval.n_terminal=new nonterminal(yytext);return SEMI_COLON;}
[a-zA-Z_][a-zA-Z0-9_]*      {cout<<"name"<<endl;yylval.n_terminal=new nonterminal(yytext);return NAME;}

. {cout << "Invalid Char at "<< yylineno << endl;  return 0;}
%%

int yywrap() {
    return 1;
}