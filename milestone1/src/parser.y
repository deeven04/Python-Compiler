%{
#include <bits/stdc++.h>
using namespace std;
#include "astnode.hpp"
int yylex();
extern FILE* yyin;
extern int yylineno;
void yyerror(const char *s);
int nodes=0;
Astnode* root = NULL;
string name;
int n_nodes = 0;
string lexeme;
%}

%union {
 char* str;
 class Astnode* astnode;
 class IdentifierNode* idNode;
 class NumberNode* numnode;
}
%token<str>  INT FLOAT STRING ASSIGNMENT_OPER
%token<astnode> NEWLINE DOT ENDMARKER RIGHT_ARROW INDENT DEDENT AND OR NOT UNDERSCORE
%token<astnode> NAME RELATIONAL_OPER 
%token<astnode> ADD SUB EQUAL_TO MULTIPLY DOUBLE_MULTIPLY DIV PERCENT BITWISE_OPER_AND BITWISE_OPER_OR BITWISE_OPER_XOR BITWISE_OPER_NOT
%token<astnode> DEF AS TRY FOR CONTINUE RETURN IS FINALLY CLASS TRUE RAISE IN EXCEPT BREAK RANGE NONE ELSE AWAIT FALSE YIELD IF ELIF ASYNC WITH GLOBAL ASSERT DEL WHILE NONLOCAL FROM
%token<astnode> LEFT_CURLY RIGHT_CURLY LEFT_SQUARE_BRACE RIGHT_SQUARE_BRACE LEFT_PAR RIGHT_PAR COMMA COLON AT_RATE AT_RATE_EQUAL_TO SEMI_COLON
%token<astnode> EXEQ LT GT EQUAL_EQUAL GTE LTE LTLT GTGT DDDOT DOUBLE_SLASH LTGT 
%token<astnode> DATA_TYPE PRINT 
%right NAME
%left STRING
%left NEWLINE
%left SEMI_COLON
%right COMMA DOT
%left LEFT_PAR LEFT_SQUARE_BRACE
%left COLON 
%start program
%type<astnode>program statements newline_plus statement funcdef v parameters test_op tfpdef simple_stmt small_stmt small_stmt_star expr_stmt annassign test_or_starexp comma_testOrStarexp_star testlist_star_expr flow_stmt break_stmt continue_stmt return_stmt raise_stmt global_stmt comma_name_star assert_stmt comp_iter sync_comp_for comp_if stmt_star comma_test test_brack
%type<astnode> compound_stmt print_stmt assignment_stmt if_stmt a while_stmt for_stmt try_stmt c d b except_clause suite test or_test e and_test f not_test comparison g comp_op star_expr
%type<astnode> xor_expr arith_expr term factor power atom_expr trailer_star atom string_plus testlist_comp namedexprtest_or_starexpr comma_namedexprtest_or_starexpr_star trailer argu arglist subscriptlist comma_subscript_star 
%type<astnode> subscript exp_or_starexp testlist dictorsetmaker com_tcolt_star tcolt_or_dsexpr comma_test_or_starexp_star classdef comma_brack argument
%type<astnode> and_expr shift_expr exprlist comma_exp_or_starexp_star typedargslist test_op_star expr or_xor xor_and and_shift shift_arith shift  op_factor op_factor_plus
%type<astnode> op_term AddOrSub 

%%

program: statements {
    root = $$;
    $$ = $1;
    YYACCEPT;
    }
    ;    
    
statements: statement   {
    name = "statements" + to_string(n_nodes);
    n_nodes = n_nodes + 1;
    $$ = new common_node(name,"statements"); $$->add($1);}
    | statements statement  { if($2){$1->add($2); } $$=$1;}
    ;
newline_plus: NEWLINE        {$$ = NULL;}
    | NEWLINE newline_plus   {}
    ;
statement: compound_stmt     {$$ = $1;}
    | simple_stmt            {$$ = $1;}
    | newline_plus           {}
    ;
funcdef: DEF NAME parameters RIGHT_ARROW test COLON suite  {
        IdentifierNode* idFunc = dynamic_cast<IdentifierNode*>($2);
        name = "funcdef" + to_string(n_nodes);
        n_nodes = n_nodes + 1;
        lexeme = "funcdef(" + idFunc->value + ")";
        $$ = new common_node(name,lexeme);               
        if($3){$$->add($3);} $$->add($5); $$->add($7); 
    }
    | DEF NAME parameters COLON suite {
        IdentifierNode* idFunc = dynamic_cast<IdentifierNode*>($2);
        name = "funcdef" + to_string(n_nodes); n_nodes++;
        lexeme = "funcdef(" + idFunc->value + ")"; 
        $$ = new common_node(name,lexeme);
        if($3){$$->add($3);} $$->add($5);
        }
    |  DEF NAME parameters RIGHT_ARROW test COLON newline_plus suite  {
            IdentifierNode* idFunc = dynamic_cast<IdentifierNode*>($2);
            name = "funcdef" + to_string(n_nodes);
            n_nodes = n_nodes + 1;
            lexeme = "funcdef(" + idFunc->value + ")";
            $$ = new common_node(name,lexeme);               
            if($3){$$->add($3);} $$->add($5); $$->add($8); 
        }
    | DEF NAME parameters COLON newline_plus suite {
        IdentifierNode* idFunc = dynamic_cast<IdentifierNode*>($2);
        name = "funcdef" + to_string(n_nodes); n_nodes++;
        lexeme = "funcdef(" + idFunc->value + ")";
        $$ = new common_node(name,lexeme);
        if($3){$$->add($3);} $$->add($6);
        }

    ;
v: parameters  {if($1){$$ = $1;}}
   | DOT NAME parameters {
    IdentifierNode* idFunc = dynamic_cast<IdentifierNode*>($2);
    name = "NAME" + to_string(n_nodes);
    n_nodes = n_nodes + 1;
    lexeme = "funcdef(" + idFunc->value + ")";
    $$ = new common_node(name,lexeme);
    if($3){$$->add($3);} 
    }
   ;
parameters: LEFT_PAR typedargslist RIGHT_PAR                                  {$$ = $2;}
   | LEFT_PAR RIGHT_PAR                                                       {$$ = NULL; }  
   ;
typedargslist: tfpdef test_op test_op_star COMMA DIV test_op_star comma_brack {
        name = "parameter" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"parameter"); 
        $$->add($1); if($2){$$->add($2);} $$->add($3); $$->add($6); 
    }
    | tfpdef test_op test_op_star comma_brack {
        name = "parameter" + to_string(n_nodes); 
        n_nodes++;$$ = new common_node(name, "parameter"); 
        $$->add($1); if($2){$$->add($2);} $$->add($3);
    }
    | tfpdef test_op COMMA DIV test_op_star comma_brack {
        name = "parameter" + to_string(n_nodes); 
        n_nodes++;$$ = new common_node(name, "parameter"); 
        $$->add($1); if($2){$$->add($2);} $$->add($5);
    }
    | tfpdef test_op comma_brack {
        name = "parameter" + to_string(n_nodes); 
        n_nodes++;$$ = new common_node(name, "parameter"); 
        $$->add($1); if($2){$$->add($2);}
    }
    | tfpdef test_op COMMA DIV comma_brack {
        name = "parameter" + to_string(n_nodes); 
        n_nodes++;$$ = new common_node(name, "parameter"); 
        $$->add($1); if($2){$$->add($2);} 
    }
    | tfpdef test_op_star COMMA DIV test_op_star comma_brack {
        name = "parameter" + to_string(n_nodes); 
        n_nodes++;$$ = new common_node(name, "parameter"); 
        $$->add($1); if($2){$$->add($2);} $$->add($5); 
    }
    | tfpdef test_op_star comma_brack {
        name = "parameter" + to_string(n_nodes); 
        n_nodes++;$$ = new common_node(name, "parameter"); 
        $$->add($1); if($2){$$->add($2);}
    }
    | tfpdef comma_brack {
        name = "parameter" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name, "parameter"); $$->add($1);
    }                                                     
    | tfpdef COMMA DIV comma_brack {
        name = "parameter" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name, "parameter"); $$->add($1);
    }
    ;
test_op_star:COMMA tfpdef test_op 
    {
        if($3){$3->add($2);$$ = $3;} 
        else{$$ = $2;} ;
    }
    | COMMA tfpdef test_op test_op_star {
        $$ = $4;
        $$->add($2);
        if($3){$$->add($3);}
    }
    ;
test_op:  {$$=NULL;}
    | EQUAL_TO test {
        name = "assign" + to_string(n_nodes); 
        n_nodes++;$$=new common_node(name,"assign(=)");
        $$->add($2);}
    ;
tfpdef: NAME COLON test {
        IdentifierNode* idFunc = dynamic_cast<IdentifierNode*>($1);
        name = "tfpdef" + to_string(n_nodes);
        n_nodes = n_nodes + 1;
        lexeme = "tfpdef(" + idFunc->value + ")";
        $$=new common_node(name,lexeme); $$->add($3);}
    | NAME { 
        IdentifierNode* idFunc = dynamic_cast<IdentifierNode*>($1);
        name = "tfpdef" + to_string(n_nodes);
        n_nodes = n_nodes + 1;
        lexeme = "tfpdef(" + idFunc->value + ")";
        $$=new common_node(name,lexeme); }
    | expr { $$ = $1; } 
    ;
simple_stmt: small_stmt small_stmt_star SEMI_COLON NEWLINE  {
        name = "Simple_stmt" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name, "simple_stmt"); $$->add($1); $$->add($2);
    }
    |small_stmt small_stmt_star NEWLINE  {
        name = "Simple_stmt" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name, "simple_stmt"); $$->add($1); $$->add($2);
    }
    |small_stmt SEMI_COLON NEWLINE {$$ = $1;}
    |small_stmt NEWLINE {$$ = $1;}
    ;
small_stmt_star:SEMI_COLON small_stmt {$$ = $2;}
    | SEMI_COLON small_stmt small_stmt_star {$$ = $2;$$->add($3);}
    ;
small_stmt: expr_stmt { $$ = $1; } 
    | flow_stmt { $$ = $1; }
    | global_stmt { $$ = $1; }
    | assert_stmt { $$ = $1; }
    ;
expr_stmt: testlist_star_expr annassign {
        $$ = $2;
        $$->add($1);
    }
    | testlist_star_expr  ASSIGNMENT_OPER  testlist {
        string s = $2;
        name = "expr_stmt" + to_string(n_nodes); n_nodes++;
        lexeme = "assign_op(" + s.substr(0, 1) + ")";
        $$ = new common_node(name,lexeme);
        $$->add($1);
        $$->add($3);

    }
    ;
annassign: COLON test {
        name = "annassign" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"annassign");
        $$->add($2);
    }
    | COLON test EQUAL_TO testlist_star_expr {
        name = "assign" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"assign(=)");
        $$->add($2);
        $$->add($4);
    }
    ;
testlist_star_expr: test_or_starexp comma_testOrStarexp_star comma_brack {
        name = "test_list" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"test_list");
        $$->add($1);
        $$->add($2);
    }
    | test_or_starexp comma_brack { $$ = $1; }
    ;
comma_testOrStarexp_star: COMMA test_or_starexp { $$ = $2; }
    | COMMA test_or_starexp comma_testOrStarexp_star {
        $$ = $3;
        $$->add($2);
    }
    ;
test_or_starexp: test {
        $$ = $1;
    }
    | star_expr { $$ = $1; }
    ;

flow_stmt: break_stmt { $$ = $1; }
    | continue_stmt { $$ = $1; }
    | return_stmt { $$ = $1; }
    | raise_stmt { $$ = $1;}
    ;
break_stmt: BREAK {
        name = "break" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"break");
    }
    ;
continue_stmt: CONTINUE {
    name = "continue" + to_string(n_nodes); n_nodes++;
    $$ = new common_node(name,"continue");
    }
    ;
return_stmt: RETURN  {
        name = "return" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"return");
    }
    | testlist_star_expr { $$ = $1; }
    | RETURN expr {
        name = "return" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"return");
        $$->add($2);
    }

    ;
star_expr: MULTIPLY expr {
    name = "operand" + to_string(n_nodes); n_nodes++;
    $$ = new common_node(name,"operand(*)"); 
    $$->add($2);}
raise_stmt: RAISE test FROM test {
        name = "raise_from" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name, "raise_from");
        $$->add($2); $$->add($4);
    }  
    | RAISE test {
        name = "raise" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"raise");
        $$->add($2); 
    }
    | RAISE {
        name = "raise" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"raise");
    }
    ;
global_stmt: GLOBAL NAME comma_name_star {
        IdentifierNode* idFunc = dynamic_cast<IdentifierNode*>($2);
        name = "global_stmt" + to_string(n_nodes);
        n_nodes = n_nodes + 1;
        lexeme = "global_stmt(" + idFunc->value + ")";
        $$ = new common_node(name,lexeme);
        if ($3) {
           $$->add($3);
        }
    }
    ;
comma_name_star: { $$ = NULL; }
    | COMMA  NAME comma_name_star {
        IdentifierNode* idFunc = dynamic_cast<IdentifierNode*>($2);
        name = "global_stmt" + to_string(n_nodes);
        n_nodes = n_nodes + 1;
        lexeme = "global_stmt(" + idFunc->value + ")";
        $3 = new common_node(name,lexeme);
        $$ = $3;
    }
    ;
assert_stmt: ASSERT test COMMA test {
        name = "assert" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"assert");
        $$->add($2);
        $$->add($4);
    }
    | ASSERT test {
        name = "assert" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"assert");
        $$->add($2);
    }
    ;
compound_stmt: if_stmt { $$ = $1;}
    | while_stmt  { $$ = $1;}
    | for_stmt  { $$ = $1;}
    | try_stmt  { $$ = $1;}
    | funcdef  {$$ = $1;}
    | classdef  {$$ = $1;}
    | print_stmt { $$ = $1;}    
    | assignment_stmt  { $$ = $1; }
    ;
print_stmt : PRINT LEFT_PAR arglist RIGHT_PAR {
        name = "print" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"print");
        $$->add($3);
    }
    ;
assignment_stmt : atom_expr EQUAL_TO expr {
        name = "assign" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"assign");
        $$->add($1);
        $$->add($3);
    }
    | NAME COLON NAME LEFT_SQUARE_BRACE DATA_TYPE RIGHT_SQUARE_BRACE EQUAL_TO atom {
        name = "assign" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name, "assign");
        IdentifierNode* idFunc = dynamic_cast<IdentifierNode*>($1); 
        name = "NAME" + to_string(n_nodes);
        n_nodes = n_nodes + 1;
        lexeme = "assign_stmt(" + idFunc->value + ")";
        $1 = new common_node(name,lexeme);
        IdentifierNode* idFunc2 = dynamic_cast<IdentifierNode*>($3);
        name = "NAME" + to_string(n_nodes);
        n_nodes = n_nodes + 1;
        lexeme = "assign_stmt(" + idFunc2->value + ")";
        $3 = new common_node(name,lexeme);    
        IdentifierNode* idFunc3 = dynamic_cast<IdentifierNode*>($5);
        name = "DATATYPE" + to_string(n_nodes);
        n_nodes = n_nodes + 1;
        lexeme = "datatype(" + idFunc3->value + ")";
        $5 = new common_node(name,lexeme);
        $3->add($5);
        $1->add($3);
        $$->add($1);
        $$->add($8);
        }
    | NAME COLON DATA_TYPE EQUAL_TO atom{
        name = "assign" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"assign");
        IdentifierNode* idFunc = dynamic_cast<IdentifierNode*>($1); 
        name = "NAME" + to_string(n_nodes);
        n_nodes = n_nodes + 1;
        lexeme = "assign_stmt(" + idFunc->value + ")";
        $1 = new common_node(name,lexeme);
        IdentifierNode* idFunc2 = dynamic_cast<IdentifierNode*>($3); 
        name = "DATA_TYPE" + to_string(n_nodes);
        n_nodes = n_nodes + 1;
        lexeme = "datatype(" + idFunc2->value + ")";
        $3 = new common_node(name,lexeme);
        $1->add($3);
        $$->add($1);
        $$->add($5);
    }
    | NAME COLON DATA_TYPE {
        IdentifierNode* idFunc = dynamic_cast<IdentifierNode*>($1);
        name = "NAME" + to_string(n_nodes);
        n_nodes = n_nodes + 1;
        lexeme = "assign_stmt(" + idFunc->value + ")";
        $$ = new common_node(name,lexeme);
        IdentifierNode* idFunc3 = dynamic_cast<IdentifierNode*>($3);
        name = "DATA_TYPE" + to_string(n_nodes);
        n_nodes = n_nodes + 1;
        lexeme = "datatype(" + idFunc3->value + ")";
        $3 = new common_node(name,lexeme);
        $$->add($3);

    }
    | NAME DOT NAME COLON DATA_TYPE EQUAL_TO atom {
        name = "assign" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"NULL");
        IdentifierNode* idFunc = dynamic_cast<IdentifierNode*>($1);
        lexeme = "assign_stmt(" + idFunc->value + ")";
        name = "NAME" + to_string(n_nodes);
        n_nodes = n_nodes + 1; 
        $1 = new common_node(name,lexeme);
        IdentifierNode* idFunc2 = dynamic_cast<IdentifierNode*>($3); 
        lexeme = "assign_stmt(" + idFunc2->value + ")";
        name = "NAME" + to_string(n_nodes);
        n_nodes = n_nodes + 1;
        $3 = new common_node(name,lexeme);
        IdentifierNode* idFunc3 = dynamic_cast<IdentifierNode*>($5); 
        lexeme = "datatype(" + idFunc3->value + ")";
        name = "DATA_TYPE" + to_string(n_nodes);
            n_nodes = n_nodes + 1;
        $5 = new common_node(name,lexeme);
        $3->add($5);
        $1->add($3);
        $$->add($1); $$->add($7);
    }
    | NAME COLON NAME EQUAL_TO atom {
        name = "assign" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"assign");
        IdentifierNode* idFunc = dynamic_cast<IdentifierNode*>($1);
        lexeme = "assign_stmt(" + idFunc->value + ")";
        name = "NAME" + to_string(n_nodes);
        n_nodes = n_nodes + 1; 
        $1 = new common_node(name,lexeme);
        IdentifierNode* idFunc2 = dynamic_cast<IdentifierNode*>($3);
        lexeme = "assign_stmt(" + idFunc2->value + ")"; 
        name = "NAME" + to_string(n_nodes);
        n_nodes = n_nodes + 1;
        $3 = new common_node(name,lexeme);
        $1->add($3);
        $$->add($1);
        $$->add($5);
    }
    ;

if_stmt: IF test COLON suite a ELSE COLON suite {
        name = "if" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"if");
        name = "else" + to_string(n_nodes); n_nodes++;
        $6 = new common_node(name,"else");
        $6->add($8);
        $$->add($2); 
        $$->add($4);
        $$->add($5);
        $$->add($6);     
    }
    |IF test COLON suite ELSE COLON suite{
        name = "else" + to_string(n_nodes); n_nodes++;
        $5 = new common_node(name,"else");
        $5->add($7);
        name = "if" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"if");
        $$->add($2); 
        $$->add($4);
        $$->add($5);
    }
    | IF test COLON suite a {
        name = "if" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"if");
        $$->add($2); 
        $$->add($4);
        $$->add($5); }
    | IF test COLON suite {
        name = "if" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"if");
        $$->add($2); 
        $$->add($4);
    }
    ;
a: ELIF test COLON suite {
        name = "elif" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"elif");
        $$->add($2); 
        $$->add($4);
    }
    | ELIF test COLON suite a {
        name = "elif" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"elif");
        $$->add($2); 
        $$->add($4);
        $$->add($5);
    }
    ;
while_stmt: WHILE test COLON suite ELSE COLON suite{
        name = "while" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"while");
        name = "else" + to_string(n_nodes); n_nodes++;
        $5 = new common_node(name,"else");
        $5->add($7);
        $$->add($2); 
        $$->add($4);
        $$->add($5);
}
    | WHILE test COLON suite {
        name = "while" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"while");
        $$->add($2); 
        $$->add($4);
    }
    ;
for_stmt: FOR exprlist IN testlist COLON suite ELSE COLON suite{
    name = "for" + to_string(n_nodes); n_nodes++;
    $$ = new common_node(name,"for");
    name = "in" + to_string(n_nodes); n_nodes++;
    $3 = new common_node(name,"in");
    name = "else" + to_string(n_nodes); n_nodes++;
    $7 = new common_node(name,"else");
    $7->add($9);
    $3->add($2);$3->add($4); $$->add($3); $$->add($6); $$->add($7);
}
    | FOR exprlist IN testlist COLON suite{
        name = "for" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"for");
        name = "in" + to_string(n_nodes); n_nodes++;
        $3 = new common_node(name,"in");
        $3->add($2);$3->add($4); $$->add($3); $$->add($6);
    }
    | FOR exprlist IN RANGE LEFT_PAR testlist RIGHT_PAR COLON suite {
        name = "for" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"for");
        name = "in_range" + to_string(n_nodes); n_nodes++;
        $3 = new common_node(name,"in_range");
        $3->add($2);$3->add($6); $$->add($3); $$->add($9);
    }
    | FOR exprlist IN RANGE LEFT_PAR testlist RIGHT_PAR COLON suite ELSE COLON suite {
        name = "for" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"for");
        name = "in_range" + to_string(n_nodes); n_nodes++;
        $3 = new common_node(name,"in_range");
        name = "else" + to_string(n_nodes); n_nodes++;
        $10 = new common_node(name,"else");
        $10->add($12);
        $3->add($2);$3->add($6); $$->add($3); $$->add($9); $$->add($10);
    }
    ;
try_stmt:TRY COLON suite b c d {
        name = "try" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"try");
        $$->add($3);
        $$->add($4);
        $$->add($5);
        $$->add($6);
    }
    | TRY COLON suite FINALLY COLON suite {
        name = "try" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"try");
        $$->add($3);
        name = "finally" + to_string(n_nodes); n_nodes++;
        $4 = new common_node(name,"finally");
        $4->add($6);
        $$->add($4);
    }
    ;
c: {
        $$ = NULL;
    }
    | ELSE COLON suite {
            name = "else" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"else");
        $$ ->add($3);
    }
    ;
d: {
        $$ = NULL;
    }
    | FINALLY COLON suite {
        name = "finally" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"finally");
        $$->add($3);
    }
    ;
b:except_clause COLON suite { 
        $$ = $1;
        $$->add($3);
    }
    | except_clause COLON suite b {
        $$ = $1;
        $$->add($3); $$->add($4);
    }
    ;
except_clause: EXCEPT test AS NAME{
        name = "expect_as" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"expect_as");
        $$->add($2);
        IdentifierNode* idFunc = dynamic_cast<IdentifierNode*>($4);
        name = "NAME" + to_string(n_nodes);
        n_nodes = n_nodes + 1;
        lexeme = "expect_clause(" + idFunc->value + ")";
        $4 = new common_node(name,lexeme);
        $$->add($4);
}
    | EXCEPT test {
        name = "expect" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"expect");
        $$->add($2);
    }
    | EXCEPT {
        name = "expect" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"expect");
    }
    ;
suite:simple_stmt { name = "suite" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"suite"); if($1){$$->add($1);} }
    | newline_plus INDENT stmt_star DEDENT {$$ = $3;}
    ;
test: or_test IF or_test ELSE test {
        $$ = $5;
        name = "if" + to_string(n_nodes); n_nodes++;
        $1 = new common_node(name,"if");
        $$->add($1);
        $$->add($2);
        $$->add($3);
        name = "else" + to_string(n_nodes); n_nodes++;
        $4 = new common_node(name,"else");
        $$->add($4);
    }
    | or_test {
        $$ = $1;
    }
    ;
or_test: and_test e {
        if($2){
            name = "or" + to_string(n_nodes); n_nodes++;
            $$ = new common_node(name,"or");
            $$->add($1);
            $$->add($2);
        }
        else{ $$ = $1; }
    }
    ;
e: { $$ = NULL;}
    | OR and_test e {
        if($3){
            name = "or" + to_string(n_nodes); n_nodes++;
            $$ = new common_node(name,"ot");
            $$->add($2);
            $$->add($3);
        }
        else{
            $$ = $2;
        }
    }
    ;
and_test: not_test f    {                     
        if($2){
            name = "and" + to_string(n_nodes); n_nodes++;
            $$ = new common_node(name,"and");
            $$->add($1);
            $$->add($2);
        }
        else{
            $$ = $1;
        }
                    }
    ;
f:             {$$ = NULL;} 
    | AND not_test f  {
    if($3){
            name = "and" + to_string(n_nodes); n_nodes++;
            $$ = new common_node(name,"and");
            $$->add($2);
            $$->add($3);
        }
        else{
            $$ = $2;
        }
    }
    ;
not_test: NOT not_test    {
         name = "not" + to_string(n_nodes); n_nodes++;
         $$ = new common_node(name,"not");
         $$ ->add($2);}
    | comparison                                                { $$ = $1;}
    ;
comparison: expr g                                              {if($2){$$ = $2; $$->add($1);} else{$$=$1;}}
    ;
g:                                                              { $$ = NULL;}
    | comp_op expr g                                            { $$ = $1; $$->add($2); if($3){$$->add($3);}}
    ;
comp_op: LT       {name = "operand" + to_string(n_nodes); n_nodes++; $$ = new common_node(name,"operand(<)");}
    |GT           {name = "operand" + to_string(n_nodes); n_nodes++;$$ = new common_node(name,"operand(>)");}
    |EQUAL_EQUAL  {name = "operand" + to_string(n_nodes); n_nodes++;$$ = new common_node(name,"operand(==)");}
    |GTE          {name = "operand" + to_string(n_nodes); n_nodes++; $$ = new common_node(name,"operand(>=)");}
    |LTE          {name = "operand" + to_string(n_nodes); n_nodes++; $$ = new common_node(name,"operand(<=)");}
    |LT GT        {name = "operand" + to_string(n_nodes); n_nodes++; $$ = new common_node(name,"operand(<)");}
    |EXEQ         {name = "operand" + to_string(n_nodes); n_nodes++; $$ = new common_node(name,"operand(!=)");}
    |IN           {name = "operand" + to_string(n_nodes); n_nodes++; $$ = new common_node(name,"IN");}
    |NOT IN       {name = "operand" + to_string(n_nodes); n_nodes++; $$ = new common_node(name,"NOT IN");}
    |IS           {name = "operand" + to_string(n_nodes); n_nodes++; $$ = new common_node(name,"IS");}
    |IS NOT       {name = "operand" + to_string(n_nodes); n_nodes++; $$ = new common_node(name,"IS NOT");}
    ;
    
expr: xor_expr                            {$$ = $1;}
  | xor_expr or_xor                       { $$ =$2; $$->add($1);}
  ;

or_xor: BITWISE_OPER_OR xor_expr          { name = "operand" + to_string(n_nodes); n_nodes++; $$ = new common_node(name, "operand(|)"); $$->add($2);}
  | BITWISE_OPER_OR xor_expr or_xor       { name = "operand" + to_string(n_nodes); n_nodes++; $$ = new common_node(name, "operand(|)"); $$->add($2);$$->add($3);}
  ;

xor_expr: and_expr                        { $$ = $1;}
  | and_expr xor_and                      { name = "xor_expr" + to_string(n_nodes); n_nodes++; $$ = new common_node(name, "expr"); $$->add($1); $$->add($2);}
  ;

xor_and: BITWISE_OPER_XOR and_expr          { name = "operand" + to_string(n_nodes); n_nodes++; $$ = new common_node(name, "operand(^)"); $$->add($2);} 
  | BITWISE_OPER_XOR and_expr xor_and       { name = "operand" + to_string(n_nodes); n_nodes++; $$ = new common_node(name, "operand(^)"); $$->add($2); $$->add($3);}
  ;

and_expr: shift_expr                        { $$ = $1;}
  | shift_expr and_shift                    { name = "and_expr" + to_string(n_nodes); lexeme = "expr"; n_nodes++; $$ = new common_node(name, lexeme); $$->add($1); $$->add($2);}
  ;

and_shift: BITWISE_OPER_AND shift_expr      {    name = "operand" + to_string(n_nodes); n_nodes++; $$ = new common_node(name, "operand(&)"); $$->add($2);}
  | BITWISE_OPER_AND shift_expr and_shift   {    name = "operand" + to_string(n_nodes); n_nodes++; $$ = new common_node(name, "operand(&)");$$->add($2); $$->add($3);}
  ;

shift_expr: arith_expr                      { $$ = $1;}
  | arith_expr shift_arith                  { $$ = $1;$$->add($2);}
  ;

shift_arith: shift arith_expr               { $$ = $1;$$->add($2);}
  | shift arith_expr shift_arith            { $$ = $1; $$->add($2); $$->add($3);}
  ;

shift: GTGT                                 {name = "operand" + to_string(n_nodes); n_nodes++; $$ = new common_node(name, "operand(>)>");}
  | LTLT                                    {name = "operand" + to_string(n_nodes); n_nodes++; $$ = new common_node(name, "operand(<)<");}
  ;


arith_expr: term                            { $$ = $1;}
  | term op_term                            { name = "arithm_expr" + to_string(n_nodes); n_nodes++; $$ = new common_node(name, "expr");$$->add($1); $$->add($2);}
  ;

op_term: AddOrSub term                      { $$ = $1; $$->add($2);}
  | AddOrSub term op_term                  { $$ = $1; $$->add($2); $$->add($3);}
  ;

AddOrSub: ADD                               { name = "operand" + to_string(n_nodes); n_nodes++; $$ = new common_node(name, "operand(+)");}
  | SUB                                     { name = "operand" + to_string(n_nodes); n_nodes++; $$ = new common_node(name, "operand(-)");}
  ;

term: factor                                { $$ = $1;}
  | factor op_factor_plus                   { name = "term" + to_string(n_nodes); n_nodes++; $$ = new common_node(name, "term");$$->add($1); $$->add($2);}
  ;

op_factor_plus: op_factor                   { if($1){$$ = $1;}}
  | op_factor op_factor_plus                { if($1){$$ = $1;$$->add($2);}}
  ;

op_factor: MULTIPLY factor                  {name = "operand" + to_string(n_nodes); n_nodes++; $$ = new common_node(name, "operant(*)"); $$->add($2);}
  | DIV factor                              {name = "operand" + to_string(n_nodes); n_nodes++; $$ = new common_node(name, "operant(/)"); $$->add($2);}
  | PERCENT factor                          {name = "operand" + to_string(n_nodes); n_nodes++; $$ = new common_node(name, "operant(%)"); $$->add($2);}
  | DOUBLE_SLASH factor                     {name = "operand" + to_string(n_nodes); n_nodes++; $$ = new common_node(name, "operant(//)"); $$->add($2);}
  ;

factor: ADD factor                          {name = "operand" + to_string(n_nodes); n_nodes++; $$ = new common_node(name, "operant(+)"); $$->add($2);}
  | SUB factor                              {name = "operand" + to_string(n_nodes); n_nodes++; $$ = new common_node(name, "operant(-)"); $$->add($2);}
  | BITWISE_OPER_NOT factor                 {name = "operand" + to_string(n_nodes); n_nodes++; $$ = new common_node(name, "operant(|)"); $$->add($2);}
  | power                                   { if($1){$$ = $1;}}
  ;

power: atom_expr                            { $$ = $1;}
  | atom_expr DOUBLE_MULTIPLY factor        { name = "power" + to_string(n_nodes); n_nodes++; $$ = new common_node(name, "power(**)"); $$->add($1); $$->add($3);}
  ;
atom_expr: atom trailer_star                                    { if($1){$$=$1; if($2){$$->add($2);}} else{if($2){$$ = $2;}}}
    ;
trailer_star:                                                   { $$ = NULL;}
    | trailer trailer_star                                      { if($2){$$ = $2; $$->add($1);} else{$$ = $1;}}
    ;

atom: LEFT_PAR RIGHT_PAR
    | LEFT_SQUARE_BRACE RIGHT_SQUARE_BRACE                      
    | LEFT_CURLY RIGHT_CURLY                                    
    | LEFT_PAR testlist_comp RIGHT_PAR { $$ = $2; }
    | LEFT_SQUARE_BRACE testlist_comp RIGHT_SQUARE_BRACE { $$ = $2; }
    | LEFT_CURLY dictorsetmaker RIGHT_CURLY { $$ = $2; } 
    | INT { 
        name = "int" + to_string(n_nodes);
        n_nodes = n_nodes + 1; string s = $1; 
        lexeme = "int (" + s + ")";
        $$ = new common_node(name,lexeme);
    }
    | FLOAT {
         name = "flaot" + to_string(n_nodes);
         n_nodes = n_nodes + 1;
         string s = $1; lexeme = "float (" + s + ")";
         $$ = new common_node(name,lexeme);
    }
    | string_plus {
         $$ = $1; 
    }
    | DDDOT   {$$ = $1;}                                                  
    | NONE     {name = "None" + to_string(n_nodes);
        n_nodes = n_nodes + 1;
        lexeme = "None";
        $$ = new common_node(name,lexeme);}                                                     
    | NAME {
        IdentifierNode* idFunc = dynamic_cast<IdentifierNode*>($1);
        name = "NAME" + to_string(n_nodes);
        n_nodes = n_nodes + 1;
        lexeme = "atom (" + idFunc->value + ")";
        $$ = new common_node(name, lexeme);
    }
    | NAME v {    
        IdentifierNode* idFunc = dynamic_cast<IdentifierNode*>($1);
        name = "funccall" + to_string(n_nodes);
        n_nodes = n_nodes + 1;
        lexeme = "funccall(" + idFunc->value + ")";
        $$ = new common_node(name,lexeme);
        if($2){$$->add($2);} 
        }
    | TRUE {
            name = "true" + to_string(n_nodes); n_nodes++; $$ = new common_node(name,"true");
    }
    | FALSE {
            name = "false" + to_string(n_nodes); n_nodes++; $$ = new common_node(name,"false");
    }
    | DATA_TYPE {
        IdentifierNode* idFunc = dynamic_cast<IdentifierNode*>($1);
        name = "DATA_TYPE" + to_string(n_nodes);
        n_nodes = n_nodes + 1;
        lexeme = "datatype (" + idFunc->value + ")";
        $$ = new common_node(name,lexeme); }
    | NAME DOT NAME {
         IdentifierNode* idFunc = dynamic_cast<IdentifierNode*>($1);
        name = "funccall" + to_string(n_nodes);
        n_nodes = n_nodes + 1;
        lexeme = "funccall(" + idFunc->value + ")";
        $$ = new common_node(name,lexeme);
        IdentifierNode* idFunc2 = dynamic_cast<IdentifierNode*>($3);
        name = "NAME" + to_string(n_nodes);
        n_nodes = n_nodes + 1;
        lexeme = "name (" + idFunc2->value + ")";
        $3 = new common_node(name, lexeme);
        $$->add($3);
    }
    ;

string_plus: STRING {
        string s = $1;
        name = "string" + to_string(n_nodes); n_nodes++;
        lexeme = "string (" + s + ")";
        $$ = new common_node(name,lexeme);
    }
    | STRING string_plus {
        string s = $1;
        name = "Simple_stmt" + to_string(n_nodes); n_nodes++;
        lexeme = "string (" + s + ")";
        $$ = new common_node(name,lexeme);
        $$->add($2);
        
    }
    ;
testlist_comp: namedexprtest_or_starexpr comma_namedexprtest_or_starexpr_star comma_brack {
        name = "testlist_comp" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name,"testlist");
        $1->add($2);
        $$->add($1);
       
    }
    | namedexprtest_or_starexpr comma_brack { $$ = $1; }
    | namedexprtest_or_starexpr sync_comp_for { $$ = $1; }
    ;
namedexprtest_or_starexpr: test { $$ = $1; }
    | star_expr { $$ = $1; }
    ;
comma_namedexprtest_or_starexpr_star: COMMA namedexprtest_or_starexpr { $$ = $2; }
    | COMMA namedexprtest_or_starexpr comma_namedexprtest_or_starexpr_star { $$ = $2; $$->add($3); }
    ;
trailer: LEFT_PAR arglist RIGHT_PAR { $$ = $2; }
    | LEFT_SQUARE_BRACE subscriptlist RIGHT_SQUARE_BRACE { $$ = $2; }
    | LEFT_PAR RIGHT_PAR {$$ = NULL;}

    ;
argu :COMMA argument  { $$ = $2; }
    | COMMA argument argu  {$$ = $3; $$->add($2); }
    ;
arglist: argument argu comma_brack {
        name = "arglist" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name, "argument");
        $$->add($1);
        $$->add($2);
    }
    | argument comma_brack { $$ = $1; }
    ;
subscriptlist: subscript comma_subscript_star comma_brack {
        name = "subscript" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name, "subscript");
        $$->add($1); $$->add($2);
    }
    | subscript comma_brack { $$ = $1; }
    ;
comma_subscript_star:COMMA subscript { $$ = $2; }
    | COMMA subscript comma_subscript_star {
        $$ = $3;
        $$->add($2);
    }
    ;
subscript: test { $$ = $1; }
    | test_brack COLON test_brack {
        name = "subscript" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name, "subscript");
        $$->add($1);
        $$->add($3);
    }
    ;
exprlist: exp_or_starexp comma_exp_or_starexp_star comma_brack {
        name = "exprlist" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name, "exprlist");
        $$->add($1);
        $$->add($2);
    }
    | exp_or_starexp comma_brack { $$ = $1; }
    ;
exp_or_starexp: expr { $$ = $1; }
    | star_expr { $$ = $1; }
    ;
comma_exp_or_starexp_star:COMMA exp_or_starexp  { $$ = $2; }
    | COMMA exp_or_starexp comma_exp_or_starexp_star { $$ = $3; $$->add($2); }
    ;
testlist: test comma_test comma_brack {
        name = "testlist" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name, "test list");
        $$->add($1);
        $$->add($2);
    }
    | test comma_brack { $$ = $1; }
    ;
dictorsetmaker:  tcolt_or_dsexpr sync_comp_for { $$ = $2; $$->add($1); }
    | tcolt_or_dsexpr com_tcolt_star comma_brack { $$ = $1; $$->add($2); }
    | tcolt_or_dsexpr comma_brack { $$ = $1; }
    | test_or_starexp comma_test_or_starexp_star comma_brack { $$ = $1; $$->add($2); }
    | test_or_starexp comma_brack { $$ = $1; }
    | test_or_starexp sync_comp_for { $$ = $2; $$->add($1); }
    ;
com_tcolt_star: COMMA tcolt_or_dsexpr { $$ = $2; }
    | COMMA tcolt_or_dsexpr com_tcolt_star { $$ = $2; $$->add($1); }
    ;
tcolt_or_dsexpr: test COLON test { 
        name = "tcolt_or_dsexpr" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name, "test list");
        $$->add($1); $$->add($2);
    }
    | DOUBLE_MULTIPLY expr {
        name = "power" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name, "power(**)");
        $$->add($2);
    }
    ;
comma_test_or_starexp_star: COMMA test_or_starexp { $$ = $2; }
    | COMMA test_or_starexp comma_test_or_starexp_star { $$ = $3; $$->add($2); }
    ;
classdef: CLASS NAME COLON suite {
        IdentifierNode* idFunc = dynamic_cast<IdentifierNode*>($2);
        name = "NAME" + to_string(n_nodes);
        n_nodes = n_nodes + 1;
        lexeme = "class def(" + idFunc->value + ")";
        $$ = new common_node(name, lexeme);
        $$->add($4);
    }
    | CLASS NAME LEFT_PAR arglist RIGHT_PAR COLON suite {
        IdentifierNode* idFunc = dynamic_cast<IdentifierNode*>($2);
        name = "NAME" + to_string(n_nodes);
        n_nodes = n_nodes + 1;
        lexeme = "class def(" + idFunc->value + ")";
        $$ = new common_node(name,lexeme);
        $$->add($4); $$->add($7);
    }
    | CLASS NAME LEFT_PAR RIGHT_PAR COLON suite {
        IdentifierNode* idFunc = dynamic_cast<IdentifierNode*>($2);
        name = "NAME" + to_string(n_nodes);
        n_nodes = n_nodes + 1;
        lexeme = "class def(" + idFunc->value + ")";
        $$ = new common_node(name, lexeme);
        $$->add($6);
    } 
    | CLASS NAME COLON newline_plus suite {
        IdentifierNode* idFunc = dynamic_cast<IdentifierNode*>($2);
        name = "NAME" + to_string(n_nodes);
        n_nodes = n_nodes + 1;
        lexeme = "class def(" + idFunc->value + ")";
        $$ = new common_node(name, lexeme);
        $$->add($5);
    }
    | CLASS NAME LEFT_PAR arglist RIGHT_PAR COLON newline_plus suite {
        IdentifierNode* idFunc = dynamic_cast<IdentifierNode*>($2);
        name = "NAME" + to_string(n_nodes);
        n_nodes = n_nodes + 1;
        lexeme = "class def(" + idFunc->value + ")";
        $$ = new common_node(name,lexeme);
        $$->add($4); $$->add($8);
    }
    | CLASS NAME LEFT_PAR RIGHT_PAR COLON newline_plus suite {
        IdentifierNode* idFunc = dynamic_cast<IdentifierNode*>($2);
        name = "NAME" + to_string(n_nodes);
        n_nodes = n_nodes + 1;
        lexeme = "class def(" + idFunc->value + ")";
        $$ = new common_node(name, lexeme);
        $$->add($7);
    } 
    ; 
comma_brack: { $$ = NULL; }
    | COMMA { $$ = NULL; }
    ;
argument: test sync_comp_for {
        name = "argument" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name, "argument");
        $$->add($1); $$->add($2);
    }  
    | test EQUAL_TO test  {
        name = "assign" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name, "assign(=)");
        $$->add($1); $$-> add($3);
    }
    | DOUBLE_MULTIPLY test  {
        name = "power" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name, "power(**)");
        $$->add($2);
    }
    | MULTIPLY test {
        name = "operand" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name, "operand(*)");
        $$->add($2);
    }
    | test { $$ = $1; }
    ;

comp_iter: sync_comp_for { $$ = $1; }
    | comp_if { $$ = $1; }
    ;
sync_comp_for: FOR exprlist IN or_test comp_iter {
        name = "for" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name, "for");
        $$->add($2); 
        name = "in" + to_string(n_nodes); n_nodes++;
        $3 = new common_node(name,"for");
        $$->add($3);
        $$->add($4);
        $$->add($5);
    }
    | FOR exprlist IN or_test {
        name = "for" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name, "for");
        $$->add($2); 
        name = "in" + to_string(n_nodes); n_nodes++;
        $3 = new common_node(name, "for");
        $$->add($3);
        $$->add($4);
    }
    ;
comp_if: IF or_test comp_iter {
        name = "if" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name, "if");
        $$->add($2); 
        $$->add($3);
    }
    | IF or_test {
        name = "if" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name, "if");
        $$->add($2); 
    }
stmt_star: statement  {  name = "stmts" + to_string(n_nodes); n_nodes++;
        $$ = new common_node(name, "stmts");
        if($1){$$->add($1);}  }
    |  stmt_star statement { if($2){$1->add($2); } if($1){$$=$1;} }
    ;

comma_test: COMMA test  { $$ = $2;  }
    | COMMA test comma_test  { $$ = $3; $$->add($2); }
    ;
test_brack: { $$ = NULL;  }
    | test { $$ = $1;}
    ;
    
%%

void yyerror(const char* s) {
    fprintf(stderr, "Error: %s and %d\n", s,yylineno);
    exit(EXIT_FAILURE);
}

int main(int argc, char* argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        return 1;
    }
    extern FILE* yyin;
    FILE* f = fopen(argv[1], "r");
    if (!f) {
        perror(argv[1]);
        return 1;
    }

    yyin = f;
    yyparse();

    fclose(f);

    if (root != NULL) {
            AST ast(root);
            ast.Print();
      }
      return 0;
}