%{
#include <bits/stdc++.h>
#include "symbol_table.cpp"

using namespace std;
int yylex();
extern FILE* yyin;
extern int yylineno;
void yyerror(const char *s);
int testlist_size = 0;
int sublist_size = 0;
int arglist_size = 0;
int test_size = 0;
int func_param = 0;
int csv = 0;
void enter_symbol(symbol_table*current,char token[1000],char type[1000],int line){
    cout<<"entered enter_symbol"<<endl;
    cout<<token<<endl;
    if(type!="function" && type!="class"){
        symbol_entry* entry;
        entry=new symbol_entry();
        strcpy(entry->token,token);
        strcpy(entry->type,type);
        entry->line=line;
        entry->isfunc=true;
        if(current->table.find(token) != current->table.end()){
                cout<<"error due to redeclaration of variable"<<token<<" at line no:"<<line<<endl;
                exit(0);
        }
        current->table[token]=entry;
        // current->table[token]=entry;
        cout<<current->table[token]->token<<endl;
        cout<<current->table[token]->type<<endl;
    }
    else{
        if (token=="print"||token == "range" ||token == "len") {
                cout<<"error due to redeclaration of built in function "<<token<<" at line no:"<<line<<endl;//in piazza
            }
        symbol_entry* entry;
        entry=new symbol_entry();

        strcpy(entry->token,token);
        // entry->token=token;
        strcpy(entry->type,type);
        // entry->type=type;
        entry->line=line;
        if(current->table.find(token) != current->table.end()){
                cout<<"error due to redeclaration of"<<token<<" at line no:"<<line<<endl;
                exit(0);
        
        }current->table[token]=entry;
        // current->table[token]=entry;
    }
    }
    symbol_entry* entry_lookup(symbol_table*current,char token[1000]){
    for(auto it=current; it!=NULL; it=it->parent){
            if(it->table.find(token) != it->table.end()){
            return it->table[token];
            }
        }return NULL;
}
symbol_table* func_table_lookup(symbol_table*current,char token[1000]){
   for(auto it=current; it!=NULL; it=it->parent){
        if(it->table.find(token) != it->table.end()){
            cout<<"created table in func_table_lookup"<<endl;
            symbol_table*t =new symbol_table(0,token,current);
            it->children.insert({token,t});
            cout << "it->children..."<<it->children[token]->token<<endl;
            return t;
        }
    }return NULL;
}
//functions for type compatibility
bool allowed_types(string a,string b){
    if(a == "int" &&  b =="float"){return 1;}
    if(a == "float" &&  b =="int"){return 1;}
    if(a == "int" &&  b =="int"){return 1;}
    if(a == "float" &&  b =="float"){return 1;}
    if(a == "bool" &&  b =="bool"){return 1;}
    if(a == "string" &&  b =="string"){return 1;}
     if(a == "" &&  b ==""){return 1;}
    return 0;
}
void print(symbol_table*temp){
    if (temp == nullptr) {
            return;
        }
    if(temp!=NULL){
        string filename = to_string(csv) + "output_" + temp->token + ".csv"; csv++;
        ofstream outfile(filename);
        outfile<<"token,"<<"type,"<<"line no,"<<"scope"<<endl;
        for(auto i:temp->table){
            if (!outfile.is_open()) {
                cerr << "Error: Unable to open file " << filename << endl;
                continue;
            }
            outfile<<i.second->token<<",";
            if(strcmp(i.second->type2,"")){outfile<<i.second->type2 << "[" << i.second->type << "]";}
            else {outfile <<i.second->type;}
            outfile <<","<<i.second->line<<","<<temp->token;
            outfile<<endl;
        }
        outfile.close();
        if (temp->children.empty()) {
            cout<<"no children"<<endl;
            return;
        }
        for(auto i:temp->children){
            
            print(i.second);
        }
    }
}

symbol_table* global=new symbol_table();//global table with parent null
symbol_table* current=global;
void temp(symbol_entry* entry,nonterminal* t){
 strcpy(t->type,entry->type);
 t->no_args=entry->no_args;
 strcpy(t->return_type,entry->return_type);
}

%}

 %union {
   class nonterminal* n_terminal;
}

%token<n_terminal> INT FLOAT STRING ASSIGNMENT_OPER
%token<n_terminal> NEWLINE DOT ENDMARKER RIGHT_ARROW INDENT DEDENT AND OR NOT UNDERSCORE
%token<n_terminal> NAME RELATIONAL_OPER 
%token<n_terminal> ADD SUB EQUAL_TO MULTIPLY DOUBLE_MULTIPLY DIV PERCENT BITWISE_OPER_AND BITWISE_OPER_OR BITWISE_OPER_XOR BITWISE_OPER_NOT
%token<n_terminal> DEF AS TRY FOR CONTINUE RETURN IS FINALLY CLASS TRUE RAISE IN EXCEPT BREAK RANGE NONE ELSE AWAIT FALSE YIELD IF ELIF ASYNC WITH GLOBAL ASSERT DEL WHILE NONLOCAL FROM
%token<n_terminal> LEFT_CURLY RIGHT_CURLY LEFT_SQUARE_BRACE RIGHT_SQUARE_BRACE LEFT_PAR RIGHT_PAR COMMA COLON AT_RATE AT_RATE_EQUAL_TO SEMI_COLON
%token<n_terminal> EXEQ LT GT EQUAL_EQUAL GTE LTE LTLT GTGT DDDOT DOUBLE_SLASH LTGT 
%token<n_terminal> DATA_TYPE PRINT 

%type<n_terminal> program statements newline_plus statement funcdef v parameters test_op tfpdef simple_stmt small_stmt small_stmt_star expr_stmt annassign test_or_starexp comma_testOrStarexp_star testlist_star_expr flow_stmt break_stmt continue_stmt return_stmt raise_stmt global_stmt comma_name_star assert_stmt comp_iter sync_comp_for comp_if comma_test test_brack
%type<n_terminal> compound_stmt print_stmt assignment_stmt if_stmt a while_stmt for_stmt try_stmt c d b except_clause suite test or_test e and_test f not_test comparison g comp_op star_expr
%type<n_terminal> xor_expr arith_expr term factor power atom_expr atom string_plus testlist_comp namedexprtest_or_starexpr comma_namedexprtest_or_starexpr_star trailer argu arglist subscriptlist comma_subscript_star 
%type<n_terminal> subscript exp_or_starexp testlist dictorsetmaker com_tcolt_star tcolt_or_dsexpr comma_test_or_starexp_star classdef comma_brack argument
%type<n_terminal> and_expr shift_expr exprlist comma_exp_or_starexp_star typedargslist test_op_star expr or_xor xor_and and_shift shift_arith shift  op_factor op_factor_plus
%type<n_terminal> op_term AddOrSub funcdef_def classdef_def in_range func_suite


%right NAME
%left STRING
%left NEWLINE
%left SEMI_COLON
%right COMMA DOT
%left LEFT_PAR LEFT_SQUARE_BRACE
%left COLON 
%start program


%%

program: statements {
   char str1[1000];
    char str2[1000];

    strcpy(str2, "hello2");  // Copy "hello2" to str2
    strcpy(str1, str2);      // Copy str2 to str1

    cout<<str1<<endl;
    }
    ;    
    
statements: statement   { cout<<"statements1"<<endl; }
    | statements statement  {cout<<"statements2"<<endl;   }
    ;
newline_plus: NEWLINE        {cout<<"n1"<<endl;}
    | NEWLINE newline_plus   {cout<<"n2"<<endl;}
    ;
statement: compound_stmt     {cout<<"statement1"<<endl;}
    | simple_stmt            {cout<<"statement2"<<endl;}
    | newline_plus           {cout<<"statement3"<<endl;}
    ;
funcdef: funcdef_def parameters func_suite {
        current=current->parent;
    }
    | funcdef_def parameters RIGHT_ARROW test {
        char str[1000];
        strcpy(str,$4->type);
        strcpy(current->type, str);
        } func_suite {
            current=current->parent;
            symbol_entry *entry=entry_lookup(current,$1->token);
            strcpy(entry->type,$4->type);
            strcpy(entry->type2, "function");
        }
    ;
func_suite: COLON suite{}
    | COLON newline_plus suite{}
funcdef_def:
     DEF NAME {
        cout<<"def1"<<endl;
        if(($2)->token=="init") {//use this if error occurs in type
         if(current->type!="class"){
          cout<<"func init cannot be in class declaration at line no:"<<yylineno<<endl;
         exit(EXIT_FAILURE);
         }
        }
        if(entry_lookup(current,$2->token)!=NULL){
            cout<<"current->token: "<<current->token<<endl;
           cout<<"redundant function "<<$2->token<<" at line no:"<<yylineno<<endl;
          exit(EXIT_FAILURE);
        }
        $2->declared=true;
        char str[1000];
        strcpy(str,"function");
        cout<<"enter_symbol1"<<endl;
        enter_symbol(current,($2)->token,str,yylineno);
        cout<<"symbol_table1"<<endl;
        current=func_table_lookup(current,($2)->token);
        strcpy($$->token, $2->token);
    }
v: parameters  {cout<<"v1"<<endl;}
   | DOT NAME parameters {
      cout<<"v2"<<endl;
    }
   ;
parameters: LEFT_PAR typedargslist RIGHT_PAR   {cout<<"parameters1"<<endl;}
   | LEFT_PAR RIGHT_PAR    {cout<<"parameters2"<<endl;}
   ;
typedargslist: tfpdef test_op test_op_star COMMA DIV test_op_star comma_brack {
       cout<<"typedargslist1"<<endl;
       current->no_args++;func_param++;
    }
    | tfpdef test_op test_op_star comma_brack {
        cout<<"typedargslist2"<<endl;
        current->no_args++;func_param++;
        
    }
    | tfpdef test_op COMMA DIV test_op_star comma_brack {
        cout<<"typedargslist3"<<endl;
        current->no_args++;func_param++;
    }
    | tfpdef test_op comma_brack {
        cout<<"typedargslist4"<<endl;
      current->no_args++;func_param++;
    }
    | tfpdef test_op COMMA DIV comma_brack {
        cout<<"typedargslist5"<<endl;
        current->no_args++;func_param++; 
    }
    | tfpdef test_op_star COMMA DIV test_op_star comma_brack {
        cout<<"typedargslist6"<<endl;
       current->no_args++;func_param++;
    }
    | tfpdef test_op_star comma_brack {
        cout<<"typedargslist7"<<endl;
        current->no_args++;func_param++;
    }
    | tfpdef comma_brack {
        cout<<"typedargslist8"<<endl;
        current->no_args++;func_param++;
    }                                                     
    | tfpdef COMMA DIV comma_brack {
        cout<<"typedargslist9"<<endl;
        current->no_args++;func_param=1;
    }
    ;
test_op_star:COMMA tfpdef test_op {
    cout<<"test_op_star1"<<endl;
      current->no_args++;func_param++;
    }
    | COMMA tfpdef test_op test_op_star {
        cout<<"test_op_star2"<<endl;
       current->no_args++;func_param++;
    }
    ;
test_op:  {}
    | EQUAL_TO test {
        cout<<"test_op1"<<endl;
       if($2->isfunc){
        if(current->children.find($2->token)==(current->children).end()){
            cout<<"function used but not declared at line no:"<<yylineno<<endl;
        }
       }
        }
    ;
tfpdef: NAME COLON test {
         cout<<"tfpdef1"<<endl;
        if(current->table.find($1->token)==current->table.end()){
            cout<<"enter_symbol5"<<endl;
            cout<<"tfpdef test type:"<<$3->type<<endl;
            strcpy($1->type,$3->type);
            enter_symbol(current,$1->token,$3->type,yylineno);
        }else{
            cout<<"invalid declaration at lineno:"<<yylineno<<endl;
        }
        }
    | NAME {cout<<"tfpdef2"<<endl; }
    | expr {cout<<"tfpdef3"<<endl; } 
    ;
simple_stmt: small_stmt small_stmt_star SEMI_COLON newline_plus {cout<<"simple_stmt1"<<endl;}
    |small_stmt small_stmt_star newline_plus {cout<<"simple_stmt1"<<endl;}
    |small_stmt SEMI_COLON newline_plus     {cout<<"simple_stmt1"<<endl;}
    |small_stmt newline_plus   {cout<<"simple_stmt2"<<endl;}
    ;
small_stmt_star:SEMI_COLON small_stmt  {cout<<"small_stmt_star1"<<endl;}
    | SEMI_COLON small_stmt small_stmt_star   {cout<<"small_stmt_star2"<<endl;}
    ;
small_stmt: expr_stmt {cout<<"small_stmt1"<<endl;}  
    | flow_stmt {cout<<"small_stmt2"<<endl;  }
    | global_stmt {cout<<"small_stmt3"<<endl;  }
    | assert_stmt {  cout<<"small_stmt4"<<endl;}
    ;
expr_stmt: testlist_star_expr annassign {
        cout<<"expr_stmt1"<<endl;
        cout<<"enter_symbol6"<<endl;
        enter_symbol(current,$1->token,$1->type,yylineno);
        
        if (allowed_types($1->type, $2->type)) {
           strcpy($$->type, $1->type);
        } else {
            cout << "1) Arguments are not of same type at line no: "<< yylineno << endl;
            exit(EXIT_FAILURE);
        }
    }
    | testlist_star_expr  ASSIGNMENT_OPER  testlist {
        cout<<"expr_stmt2"<<endl;
        if (allowed_types($1->type, $3->type)) {
           strcpy($$->type, $1->type);
        } else {
            cout << "2) Arguments are not of same type at line no: "<< yylineno << endl;
            exit(EXIT_FAILURE);
        }
    }
    | testlist_star_expr {cout<<"expr_stmt3"<<endl;}
    ;
annassign: COLON test {
    cout<<"annassign1"<<endl;
       strcpy($$->type, $2->type);

    }
    | COLON test EQUAL_TO testlist_star_expr {
        cout<<"annassign1"<<endl;
        //a:int=9
        if (allowed_types($1->type, $3->type)) {
           strcpy($$->type, $1->type);
        } else {
            cout << "3) Arguments are not of same type at line no: "<< yylineno << endl;
            exit(EXIT_FAILURE);
        }
    }
    ;
testlist_star_expr: test_or_starexp comma_testOrStarexp_star comma_brack {
         cout<<"testlist_star_expr1"<<endl;
        if (allowed_types($1->type, $2->type)) {
           strcpy($$->type, $1->type);
        } else {
            cout << "4) Arguments are not of same type at line no: "<< yylineno << endl;
            exit(EXIT_FAILURE);
        }
    }
    | test_or_starexp comma_brack {
        cout<<"testlist_star_expr2"<<endl;
        strcpy($$->type , $1->type); }
    ;
comma_testOrStarexp_star: COMMA test_or_starexp {
    cout<<"comma_testOrStarexp_star1"<<endl;
    strcpy($$->type, $2->type); }
    | COMMA test_or_starexp comma_testOrStarexp_star {
        cout<<"comma_testOrStarexp_star2"<<endl;
        if (allowed_types($2->type, $3->type)) {
           strcpy($$->type, $2->type);
        } else {
            cout << "5) Arguments are not of same type at line no: "<< yylineno << endl;
            exit(EXIT_FAILURE);
        }
    }
    ;
test_or_starexp: test {
    cout<<"test_or_starexp1"<<endl;
    strcpy($$->type, $1->type); }
    | star_expr {
        cout<<"test_or_starexp2"<<endl;
        strcpy($$->type , $1->type); }
    ;

flow_stmt: break_stmt { cout<<"flow_stmt1"<<endl;  }
    | continue_stmt {cout<<"flow_stmt2"<<endl;}
    | return_stmt {cout<<"flow_stmt3"<<endl;}
    | raise_stmt { cout<<"flow_stmt4"<<endl;}
    ;
break_stmt: BREAK {cout<<"break_stmt1"<<endl;}
    ;
continue_stmt: CONTINUE {cout<<"continue_stmt1"<<endl;}
    ;
return_stmt: RETURN  {cout<<"return_stmt1"<<endl;}
    | RETURN testlist_star_expr { 
        cout<<"return_stmt1"<<endl;
        for(auto i:current->table){
            if(i.second->isfunc){
                if(!allowed_types(i.second->type, $2->type)){cout<<"error return type, line no: " << yylineno <<endl;exit(EXIT_FAILURE);}
            }
        }
    }
    | RETURN expr { 
        cout<<"return_stmt2"<<endl;
        for(auto i:current->table){
            if(i.second->isfunc){
                if(!allowed_types(i.second->type, $2->type)){cout<<"error return type, line no: " << yylineno <<endl;}
            }
        }
    }
    ;
star_expr: MULTIPLY expr {
        cout<<"star_expr1"<<endl;
        {strcpy($$->type, $2->type); }
    }
    ;
raise_stmt: RAISE test FROM test
    | RAISE test
    | RAISE
    ;
global_stmt: GLOBAL NAME comma_name_star {
        cout<<"global_stmt1"<<endl;
        if(entry_lookup(current, $2->token) != NULL) {
            cout << "Redeclaration of the variable "<< $2->token <<" at line no: " << yylineno << endl;
            exit(EXIT_FAILURE);
        }
        char str[1000];
        strcpy(str,"global");
        cout<<"enter_symbol7"<<endl;
        enter_symbol(current,($2)->token,str,yylineno);
    }
    ;
comma_name_star: { cout<<"comma_name_star1"<<endl; }
    | COMMA  NAME comma_name_star {
        cout<<"comma_name_star2"<<endl;
        if(entry_lookup(current, $2->token) != NULL) {
            cout << "Redeclaration of the variable "<< $2->token <<" at line no: " << yylineno << endl;
            exit(EXIT_FAILURE);
        }char str[1000];
        strcpy(str,"global");
        cout<<"enter_symbol8"<<endl;
        enter_symbol(current,($2)->token,str,yylineno);
    }
    ;
assert_stmt: ASSERT test COMMA test
    | ASSERT test
    ;
compound_stmt: if_stmt {cout<<"compound_stmt1"<<endl;}
    | while_stmt {cout<<"compound_stmt2"<<endl;}
    | for_stmt {cout<<"compound_stmt3"<<endl;}
    | try_stmt {cout<<"compound_stmt4"<<endl;}
    | funcdef  {cout<<"compound_stmt5"<<endl;}
    | classdef  {cout<<"compound_stmt6"<<endl;}
    | print_stmt    {cout<<"compound_stmt7"<<endl;}
    | assignment_stmt {cout<<"compound_stmt8"<<endl;}
    ;
print_stmt : PRINT LEFT_PAR arglist RIGHT_PAR {cout<<"print_stmt1"<<endl;}
    ;
assignment_stmt : atom_expr EQUAL_TO expr {
        cout<<"assignment_stmt1"<<endl;
        if($1->l_value != false) {
            cout << "function cannot be assigned at line no:"<<yylineno<<endl;
            exit(EXIT_FAILURE);
        }
            cout << $1->token <<": "<< $1->type << endl;
            cout << $3->token <<": "<< $3->type << endl;
            cout<<strcmp($1->type,$3->type)<<endl;
        if (strcmp($1->type,$3->type) != 0) {
            cout << "6) Arguments are not of same type at line no: "<< yylineno << endl;
            exit(EXIT_FAILURE);
        }
    }
    //## doubt ## x: array[int] = [1, 2, 3, 4, 5]
    | NAME COLON NAME EQUAL_TO atom {
        if(entry_lookup(current,$1->token)==NULL){
           cout<<"enter_symbol20"<<endl;
        cout << "current->token .. " << current->token << endl;
        cout<<"$1->token"<<$1->token<<endl;
        char str[1000];
        strcpy(str,"class"); 
        enter_symbol(current,$1->token,str,yylineno);
            if(entry_lookup(current, $1->token) != NULL) {
                symbol_entry*entry=entry_lookup(current, $1->token);
                strcpy(entry->type2,$3->token);
            }
            
            if (strcmp($3->token, $5->type2)) {
                cout << $3->token << " hello " << $5->type2 << endl; 
                cout << "17) Arguments are not of same type at line no: "<< yylineno << endl;
                exit(EXIT_FAILURE);
            } 
        }
        else {cout<<"redeclared"<<endl;exit(EXIT_FAILURE);}
        cout << "new_rule" << endl;}
    | NAME COLON NAME LEFT_SQUARE_BRACE DATA_TYPE RIGHT_SQUARE_BRACE EQUAL_TO atom {
        cout<<"assignment_stmt2"<<endl;
        if(entry_lookup(current, $1->token) == NULL) {
        cout<<"enter_symbol9"<<endl;
        cout << "current->token .. " << current->token << endl;
        cout<<"$1->token"<<$1->token<<endl;
        enter_symbol(current,$1->token,$5->type,yylineno);
            if(entry_lookup(current, $1->token) != NULL) {
                symbol_entry*entry=entry_lookup(current, $1->token);
                strcpy(entry->type2,$3->token);
            }
            if (!allowed_types($5->type, $8->type)) {
                cout<<"hi";
                cout << "7) Arguments are not of same type at line no: "<< yylineno << endl;
                cout<<"hi";
                exit(EXIT_FAILURE);
            }
        }
        else {cout<<"redeclared"<<endl;exit(EXIT_FAILURE);}
        //doubt :current.symbol_table();? or symbol_table(yylineno,$1->token,current);
    }
    | NAME COLON DATA_TYPE EQUAL_TO atom_expr{
        cout<<"assignment_stmt3"<<endl;
        if(entry_lookup(current, $1->token) == NULL) {
        strcpy($1->type,$3->type);
        cout<<"enter_symbol10"<<endl;
        enter_symbol(current,$1->token,$1->type,yylineno);}
        cout<<"$1->type"<<$1->type;
        cout<<"$5->type"<<$5->type;
        if (!allowed_types($3->type,$5->type)) {
            cout << "8) Arguments are not of same type at line no: "<< yylineno << endl;
            exit(EXIT_FAILURE);
        }
    }
    | NAME DOT NAME COLON DATA_TYPE EQUAL_TO atom {
          cout<<"assignment_stmt4"<<endl;
        if(entry_lookup(current, $3->token) == NULL) {
        strcpy($3->type,$5->type);
        cout<<"enter_symbol11"<<endl;
        enter_symbol(current,$3->token,$3->type,yylineno);}
        cout<<"types:"<<$5->type<<"k"<<$7->type<<endl;
        if (!allowed_types($5->type,$7->type)) {
            cout << "9) Arguments are not of same type at line no: "<< yylineno << endl;
            exit(EXIT_FAILURE);
        }
    }
    
    ;
if_stmt: IF test COLON suite a ELSE COLON suite {cout<<"if_stmt1"<<endl;}
    |IF test COLON suite ELSE COLON suite  {cout<<"if_stmt2"<<endl;}
    | IF test COLON suite a {cout<<"if_stmt3"<<endl;}
    | IF test COLON suite {cout<<"if_stmt4"<<endl;}
    ;
a: ELIF test COLON suite {cout<<"a1"<<endl;}
    | ELIF test COLON suite a {cout<<"a2"<<endl;}
    ;
while_stmt: WHILE test COLON suite ELSE COLON suite {cout<<"while_stmt1"<<endl;}
    | WHILE test COLON suite {cout<<"while_stmt2"<<endl;}
    ;
for_stmt: FOR exprlist IN testlist COLON suite ELSE COLON suite {
        cout<<"for_stmt1"<<endl;
        if(strcmp($2->type, $4->type)) {
            cout << "arguments in for loop are different, line no: " << yylineno << endl;
        }
    }
    | FOR exprlist IN testlist COLON suite  {
        if(strcmp($2->type,$4->type)){
             cout << "arguments in for loop are different, line no: " << yylineno << endl; 
        }
        cout<<"for_stmt2"<<endl;}
    | in_range LEFT_PAR testlist RIGHT_PAR COLON suite {
        cout<<"for_stmt3"<<endl;
        if(strcmp($1->type, $3->type)) {
            cout << "arguments in for loop are different, line no: " << yylineno << endl;
        }
    }
    | in_range LEFT_PAR testlist RIGHT_PAR COLON suite ELSE COLON suite  {
        cout<<"for_stmt4"<<endl;
        if(strcmp($1->type, $3->type)) {
            cout << "arguments in for loop are different, line no: " << yylineno << endl;
        }
    }
    ;
in_range: FOR exprlist IN RANGE {
        if(entry_lookup(current, $2->token) == NULL) {
            strcpy($2->type, "int");
        } else if (strcmp($2->type, "int") != 0) {
            cout << $2->token << " is not of int type" << endl;
        }
        strcpy($$->type, $2->type);
        enter_symbol (current, $2->token, $2->type, yylineno);
    }
    ;
try_stmt:TRY COLON suite b c d {cout<<"try_stmt1"<<endl;}
    | TRY COLON suite FINALLY COLON suite {cout<<"try_stmt2"<<endl;}
    ;
c:       {cout<<"c1"<<endl;}
    | ELSE COLON suite {cout<<"c2"<<endl;}
    ;
d:                     {cout<<"d1"<<endl;}
    | FINALLY COLON suite {cout<<"d2"<<endl;}
    ;
b:except_clause COLON suite {cout<<"b1"<<endl;}
    | except_clause COLON suite b {cout<<"b2"<<endl;}
    ;
except_clause: EXCEPT test AS NAME {cout<<"except_clause1"<<endl;}
    | EXCEPT test {cout<<"except_clause2"<<endl;}
    | EXCEPT {cout<<"except_clause3"<<endl;}
    ;
suite:simple_stmt { cout<<"suite1"<<endl; }
    |  newline_plus INDENT statements DEDENT {
        cout<<"suite2"<<endl;
        cout<<"symbol_table5"<<endl;
       // current=new symbol_table(yylineno,"",current);
        //current=current->parent;
    }
    ;
test: or_test IF or_test ELSE test{
    cout<<"test1"<<endl;
    strcpy($$->type,$1->type);}
    | or_test {
        cout<<"test2 "<<$1->type<<endl;
        strcpy($$->type,$1->type);}
    ;
or_test: and_test e {  
    
    if(!($2->if_null) && allowed_types($1->type,$2->type)){
        cout << "or_test1" << endl;
            strcpy($$->type, $2->type);
        }  else if (!(strcmp($2->type,""))) {
            cout << "or_test2" << endl;
            strcpy($$->type, $1->type);
        }
        else {cout << "or_test3" << endl;
            if(!(strcmp($1->type,""))&& !(strcmp($2->type,"")))break;
            cout << "1 data types are not same at line no: " << yylineno << endl;}
        }
    ;
e:            {
    char str[1000];
    strcpy(str,"e");
    $$ = new nonterminal(str); ($$->if_null) = 1;cout << "e1" << endl;}
    | OR and_test e{
        cout << "e2" << endl;
       strcpy($$->type,$1->type);
    }
    ;
and_test: not_test f  { 
    if(!($2->if_null) && allowed_types($1->type,$2->type)){
        cout << "and_test1" << endl;
        strcpy($$->type, $2->type);
    } else if ($2->if_null) {
        cout << "and_test2" << endl;
        strcpy($$->type, $1->type);
    }
    else {
        cout << "and_test3" << endl;
        cout << "2 data types are not same at line no: " << yylineno << endl;}
    }
    ;
f:            {
    cout << "f1" << endl;
    char str[1000];
    strcpy(str,"f");
    $$ = new nonterminal(str); ($$->if_null) = 1;}
    | AND not_test f        {cout << "f2" << endl;strcpy($$->type,$2->type);}
    ;
not_test: NOT not_test    {cout << "not_test1" << endl;strcpy($$->type,$2->type);}
    | comparison          {cout << "not_test2" << endl;strcpy($$->type,$1->type);}
    ; 
comparison: expr g {
    if(!($2->if_null) && allowed_types($1->type,$2->type))  {
        cout << "comparison1" << endl;
      strcpy($$->type, $2->type);
    } else if ($2->if_null) {
        cout << "comparison2" << endl;
        strcpy($$->type, $1->type);
    } else {
        cout << "comparison3" << endl;
        if(!(strcmp($1->type,""))&& !(strcmp($2->type,"")))break;
        cout << "3 data types are not same at line no: " << yylineno << endl;}
    }
    ;
g:             {
    char str[1000];
    strcpy(str,"g");
    $$ = new nonterminal(str); ($$->if_null) = 1; cout << "g1" << endl;}
    | comp_op expr g {cout << "g2" << endl;strcpy($$->type,$2->type);}
    ;
comp_op: LT       {cout << "comp_op1" << endl;}
    |GT           {cout << "comp_op2" << endl;}
    |EQUAL_EQUAL  {cout << "comp_op3" << endl;}
    |GTE          {cout << "comp_op4" << endl;}
    |LTE          {cout << "comp_op5" << endl;}
    |LT GT        {cout << "comp_op6" << endl;}
    |EXEQ         {cout << "comp_op7" << endl;}
    |IN           {cout << "comp_op8" << endl;}
    |NOT IN       {cout << "comp_op9" << endl;}
    |IS           {cout << "comp_op10" << endl;}
    |IS NOT       {cout << "comp_op11" << endl;}
    ;
    
expr: xor_expr         {cout << "expr1" << endl;strcpy($$->type,$1->type);}
  | xor_expr or_xor     {cout << "expr2" << endl;if(allowed_types($1->type,$2->type)){strcpy($$->type,$1->type);} else{cout<<"error"<<endl;}}
  ;

or_xor: BITWISE_OPER_OR xor_expr    {cout << "or_xor1" << endl;strcpy($$->type,$2->type);}
  | BITWISE_OPER_OR xor_expr or_xor       {cout << "or_xor2" << endl;if(allowed_types($2->type,$3->type)){strcpy($$->type,$2->type);} else{cout<<"error"<<endl;}}
  ;

xor_expr: and_expr           {cout << "xor_expr1" << endl;strcpy($$->type,$1->type);}    
  | and_expr xor_and         {cout << "xor_expr2" << endl;if(allowed_types($1->type,$2->type)){strcpy($$->type,$1->type);} else{cout<<"error"<<endl;}}
  ;

xor_and: BITWISE_OPER_XOR and_expr      {cout << "xor_and1" << endl;strcpy($$->type,$2->type);}
  | BITWISE_OPER_XOR and_expr xor_and       {cout << "xor_and2" << endl;if(allowed_types($2->type,$3->type)){strcpy($$->type,$2->type);} else{cout<<"error"<<endl;}}
  ;

and_expr: shift_expr          {cout << "and_expr1" << endl;strcpy($$->type,$1->type);}       
  | shift_expr and_shift        {cout << "and_expr2" << endl;if(allowed_types($1->type,$2->type)){strcpy($$->type,$1->type);} else{cout<<"error"<<endl;}}
  ;

and_shift: BITWISE_OPER_AND shift_expr       {cout << "and_shift1" << endl;strcpy($$->type,$2->type);}
  | BITWISE_OPER_AND shift_expr and_shift    {cout << "and_shift2" << endl;if(allowed_types($2->type,$3->type)){strcpy($$->type,$2->type);} else{cout<<"error"<<endl;}}
  ;

shift_expr: arith_expr      {cout << "shift_arith1" << endl;strcpy($$->type,$1->type);}
  | arith_expr shift_arith  {cout << "shift_arith2" << endl;if(allowed_types($1->type,$2->type)){strcpy($$->type,$1->type);} else{cout<<"error"<<endl;}}
  ;

shift_arith: shift arith_expr       {cout << "shift_arith1" << endl;strcpy($$->type,$2->type);}
  | shift arith_expr shift_arith     {cout << "shift_arith2" << endl;if($2->type == $3->type){strcpy($$->type,$2->type);} else{cout<<"error"<<endl;}}
  ;

shift: GTGT {cout << "shift1" << endl;}
  | LTLT  {cout << "shift2" << endl;}
  ;

arith_expr: term {
        cout << "arith_expr1" << endl;
       strcpy($$->type, $1->type);
    }
    | term op_term {
        cout << "arith_expr2" << endl;
       if(allowed_types($1->type,$2->type)) {
           strcpy($$->type, $1->type);
        }
        else {
            cout << "4 data types are not same at line no: " << yylineno << endl;
        }
    }
  ;

op_term: AddOrSub term {
        cout << "op_term1" << endl;
        strcpy($$->type, $1->type);
    }
    | AddOrSub term op_term {
        cout << "op_term2" << endl;
       if(allowed_types($2->type,$3->type)) {
           strcpy($$->type, $2->type);
        }
        else {
            cout << "5 data types are not same at line no: " << yylineno << endl;
        }
    }
    ;

AddOrSub: ADD {cout << "AddOrSub1" << endl;}
  | SUB {cout << "AddOrSub2" << endl;}
  ;

term: factor {cout << "term1" << endl;strcpy($$->type,$1->type);}
  | factor op_factor_plus {
        cout << "term2" << endl;
        if(allowed_types($1->type,$2->type)) {
           strcpy($$->type, $1->type);
        }
        else {
            cout << "6 data types are not same at line no: " << yylineno << endl;
        }
    }
  ;

op_factor_plus: op_factor {cout << "op_factor_plus1" << endl;strcpy($$->type,$1->type);}
  | op_factor op_factor_plus {
        cout << "op_factor_plus2" << endl;
        if(allowed_types($1->type,$2->type)) {
           strcpy($$->type, $1->type);
        }
        else {
            cout << "7 data types are not same at line no: " << yylineno << endl;
        }
    }
  ;

op_factor: MULTIPLY factor  {cout << "op_factor1" << endl;strcpy($$->type,$2->type);}
  | DIV factor              {cout << "op_factor2" << endl;strcpy($$->type,$2->type);}
  | PERCENT factor          {cout << "op_factor3" << endl;strcpy($$->type,$2->type);}
  | DOUBLE_SLASH factor     {cout << "op_factor4" << endl;strcpy($$->type,$2->type);}
  ;

factor: ADD factor          {cout << "factor1" << endl;strcpy($$->type,$2->type);}  
  | SUB factor              {cout << "factor2" << endl;strcpy($$->type,$2->type);}
  | BITWISE_OPER_NOT factor {cout << "factor3" << endl;strcpy($$->type,$2->type);}
  | power                   {cout << "factor4" << endl;strcpy($$->type,$1->type);}
  ;

power: atom_expr              {cout << "power1 "<<$1->type << endl;strcpy($$->type,$1->type);}       
  | atom_expr DOUBLE_MULTIPLY factor {
    cout << "power2" << endl;
    if(allowed_types($1->type,$3->type)){
       strcpy($1->type, $3->type);
        }
        else {
            cout << "8 data types are not same at line no: " << yylineno << endl;
        }
  } 
  ;
 // check array[i]
atom_expr: atom {strcpy($$->type, $1->type);}
    | atom trailer {
        cout << "atom_expr" << endl;
        if(strcmp($1->type,"")==0){cout<<"$2->type"<<$2->type<<endl;strcpy($$->type,$2->type);}
            strcpy($$->type, $1->type);
            cout<<"token"<<$1->token<<"$1->type"<<$1->type<<endl;
        if((!($2->if_null) && (!strcmp($1->type, $2->type))) || $2->if_null) {
            cout<<"assigning type in atom expression"<<endl;
        } else {
            cout << "arguments are of different type at line no: "<< endl;
        }
    }
    ;

atom: LEFT_PAR RIGHT_PAR  {cout << "atom01" << endl;}
    | LEFT_SQUARE_BRACE RIGHT_SQUARE_BRACE     {cout << "atom02" << endl;}                 
    | LEFT_CURLY RIGHT_CURLY        {cout << "atom03" << endl;}                            
    | LEFT_PAR {testlist_size = 0;} testlist_comp RIGHT_PAR {cout << "atom04" << endl; $$->size = testlist_size; strcpy($$->type, $3->type);}
    | LEFT_SQUARE_BRACE {testlist_size = 0;} testlist_comp RIGHT_SQUARE_BRACE {cout << "atom05" << endl; $$->size = testlist_size; strcpy($$->type, $3->type);}
    | LEFT_CURLY dictorsetmaker RIGHT_CURLY  {cout << "atom06" << endl;strcpy($$->type, $2->type);}
    | INT { 
        cout << "atom1" << endl;
       cout<<"atom"<<$1->type<<endl;
       strcpy($$->type,"int");
       
    }
    | FLOAT {
        cout << "atom2" << endl;
       strcpy(($$)->type,"float");
    }
    | string_plus {
        cout << "atom3" << endl;
       strcpy(($$)->type,"string"); 
    }
    | DDDOT {cout << "atom4" << endl;strcpy(($$)->type,"ellipsis"); }
    | NONE {cout << "atom5" << endl;strcpy(($$)->type,"None Type"); }                                                   
    | NAME {
        cout << "atom6" << endl;
        // strcpy(($1)->type, "Name");
        // if(!strcmp($1->type,"")){
        //     cout<<"variable used without declaration"<<endl;
        // }
        if(entry_lookup(current,$1->token)!=NULL){
            cout<<"entered"<<endl;
            strcpy($1->type,(entry_lookup(current,$1->token))->type);
        }
        strcpy($$->type2, $1->token);
    }
    | NAME v {
        /*
        symbol_table*t=current->children[$1->token];
        if(t)cout<<"error"<<endl;return 0;
       if(func_param!=t->no_args) {
        cout<<"error in function parametersat line no:"<<yylineno<<"func_param"<<func_param<<"t->no_args"<<t->no_args<<endl;
        exit(EXIT_FAILURE);
       }*/
        if (!strcmp($1->token, "len")) {strcpy($$->type, "int");}
        else if(entry_lookup(current,$1->token)!=NULL){
            cout<<"entered"<<endl;
            strcpy($1->type,(entry_lookup(current,$1->token))->type);
        }
        strcpy($$->type2, $1->token);
        cout << "atom7" << endl;
    }
    | TRUE {
        cout << "atom8" << endl;
       strcpy(($$)->type,"bool");
    }
    | FALSE {
        cout << "atom9" << endl;
       strcpy(($$)->type,"bool");
    }
    | DATA_TYPE {
        cout << "atom10" << endl;
       strcpy(($$)->type, $1->type);
    }
    | NAME DOT NAME {
        cout << "atom11" << endl;
        //## doubt ##
    }
    ;

string_plus: STRING         {cout << "string_plus1" << endl;strcpy($$->type,"string");}
    | STRING string_plus    {cout << "string_plus2" << endl;strcpy($$->type,"string");}
    ;
testlist_comp: namedexprtest_or_starexpr comma_namedexprtest_or_starexpr_star comma_brack  {
        testlist_size++; 
        cout << "testlist_comp1" << endl;
        if(!strcmp($1->type,$2->type)){
            strcpy($$->type, $1->type);
        } else {
            cout << "Arguments are of different type at line no: " << yylineno << endl;
        }
    }
    | namedexprtest_or_starexpr comma_brack  {strcpy($$->type, $1->type);cout << "testlist_comp2" << endl;}
    | namedexprtest_or_starexpr sync_comp_for  {strcpy($$->type, $1->type);cout << "testlist_comp3" << endl;}
    ;
namedexprtest_or_starexpr: test {strcpy($$->type, $1->type);cout << "namedexprtest1" << endl;}
    | star_expr {strcpy($$->type, $1->type);cout << "namedexprtest2" << endl;}
    ;
comma_namedexprtest_or_starexpr_star: COMMA namedexprtest_or_starexpr  {
        testlist_size++;
        strcpy($$->type, $2->type);
        cout << "comma_namedexprtest1" << endl;
    }
    | COMMA namedexprtest_or_starexpr comma_namedexprtest_or_starexpr_star  {
        testlist_size++;
        cout << "comma_namedexprtest2" << endl;
        if(!strcmp($2->type,$3->type)){
            strcpy($$->type, $2->type);
        } else {
            cout << "Arguments are of different type at line no: " << yylineno << endl;
        }
    }
    ;
trailer: LEFT_PAR {arglist_size = 0;} arglist RIGHT_PAR {
        $$->size = arglist_size;
        strcpy($$->type,$3->type);
        cout << "trailer1" << endl;}
    | LEFT_SQUARE_BRACE {sublist_size = 0;} subscriptlist RIGHT_SQUARE_BRACE {
        $$->size = sublist_size;
       strcpy($$->type,$3->type);  
        cout << "trailer2"<<$3->type<< endl;}
    | LEFT_PAR RIGHT_PAR {cout << "trailer3" << endl;}

    ;
argu: COMMA argument {
    strcpy($$->type,$2->type);
    cout << "argu1" << endl;}
    | COMMA argument argu {
         if(!strcmp($2->type,$3->type)){
            strcpy($$->type, $2->type);
        } else {
            cout << "Arguments are of different type at line no: " << yylineno << endl;
        }cout << "argu2" << endl;}
    ;
arglist: argument argu comma_brack {
        arglist_size++;
       if(!strcmp($1->type,$2->type)){
            strcpy($$->type, $1->type);
        } else {
            cout << "Arguments are of different type at line no: " << yylineno << endl;
        }
    cout << "arglist2" << endl;}
    | argument comma_brack {
        arglist_size++;
        strcpy($$->type,$1->type);
        cout << "arglist1" << endl;}
    ;
subscriptlist: subscript comma_subscript_star comma_brack {
        sublist_size++;
        if(!strcmp($1->type,$2->type)){
                strcpy($$->type, $1->type);
        } else {
            cout << "Arguments are of different type at line no: " << yylineno << endl;
        }
        cout << "subscriptlist1" << endl;}
    | subscript comma_brack {
        strcpy($$->type,$1->type);
        cout << "subscriptlist2"<<$1->type << endl;}
    ;
comma_subscript_star:COMMA subscript {
    sublist_size++;
    strcpy($$->type,$2->type);cout << "comma_subscript_star1" << endl;}
    | COMMA subscript comma_subscript_star {
        sublist_size++;
        if(!strcmp($2->type,$3->type)){
            strcpy($$->type, $2->type);
        } else {
            cout << "Arguments are of different type at line no: " << yylineno << endl;
        }cout << "comma_subscript_star2" << endl;}
    ;
subscript: test {strcpy($$->type,$1->type);cout << "subscript1"<<$1->type << endl;}
    | test_brack COLON test_brack  {
        if($3->if_null)strcpy($$->type, $1->type);
        else if($1->if_null)strcpy($$->type, $3->type);
        else if(!strcmp($1->type,$3->type)){
            strcpy($$->type,$1->type);    
        } else {
            cout << "Arguments are of different type at line no: " << yylineno << endl;
        }
        cout << "subscript2" << endl;}
    ;
exprlist: exp_or_starexp comma_exp_or_starexp_star comma_brack {
        cout << "exprlist1" << endl;
       strcpy($$->type,$1->type);
    }
    | exp_or_starexp comma_brack {
        cout << "exprlist2" << endl;
       strcpy($$->type,$1->type);
    }
    ;
exp_or_starexp: expr {
        cout << "exp_or_starexp1" << endl;
       strcpy($$->type,$1->type);
    }
    | star_expr {
        cout << "exp_or_starexp2" << endl;
       strcpy($$->type,$1->type);
    }
    ;
comma_exp_or_starexp_star:COMMA exp_or_starexp  {strcpy($$->type,$2->type);cout << "comma_exp_or_starexp_star1" << endl;}
    | COMMA exp_or_starexp comma_exp_or_starexp_star { 
         if(!strcmp($2->type,$3->type)){
            strcpy($$->type, $2->type);
        } else {
            cout << "Arguments are of different type at line no: " << yylineno << endl;
        }cout << "comma_exp_or_starexp_star2" << endl; }
    ;
testlist: test comma_test comma_brack {
       cout<<"testlist1"<<endl;
    }
    | test comma_brack {  
        cout<<"testlist2"<<endl;
        $$=new nonterminal();
        strcpy($$->type,$1->type);
        $$->no_args=1; 
    }
    ;
dictorsetmaker:  tcolt_or_dsexpr sync_comp_for { 
     if(!strcmp($1->type,$2->type)){
            strcpy($$->type, $1->type);
        } else {
            cout << "Arguments are of different type at line no: " << yylineno << endl;
        }
    cout << "dictorsetmaker1" << endl; }
    | tcolt_or_dsexpr com_tcolt_star comma_brack {
         if(!strcmp($1->type,$2->type)){
            strcpy($$->type, $1->type);
        } else {
            cout << "Arguments are of different type at line no: " << yylineno << endl;
        }
         cout << "dictorsetmaker2" << endl; }
    | tcolt_or_dsexpr comma_brack {
        strcpy($$->type,$1->type);
        cout << "dictorsetmaker3" << endl;}
    | test_or_starexp comma_test_or_starexp_star comma_brack { 
         if(!strcmp($1->type,$2->type)){
            strcpy($$->type, $1->type);
        } else {
            cout << "Arguments are of different type at line no: " << yylineno << endl;
        }
        cout << "dictorsetmaker4" << endl; }
    | test_or_starexp comma_brack {
        strcpy($$->type,$1->type);
        cout << "dictorsetmaker5" << endl;}
    | test_or_starexp sync_comp_for {
        if(!strcmp($1->type,$2->type)){
            strcpy($$->type, $2->type);
        } else {
            cout << "Arguments are of different type at line no: " << yylineno << endl;
        }
         cout << "dictorsetmaker6" << endl; }
    ;
com_tcolt_star: COMMA tcolt_or_dsexpr { 
    strcpy($$->type,$2->type);
    cout << "com_tcolt_star1" << endl; }
    | COMMA tcolt_or_dsexpr com_tcolt_star {
        if(!strcmp($1->type,$2->type)){
            strcpy($$->type, $2->type);
        } else {
            cout << "Arguments are of different type at line no: " << yylineno << endl;
        }
         cout << "com_tcolt_star2" << endl; 
         }
    ;
tcolt_or_dsexpr: test COLON test { //## check ##
       if(!strcmp($1->type,$3->type)){
            strcpy($$->type, $1->type);
        } else {
            cout << "Arguments are of different type at line no: " << yylineno << endl;
        }
        cout << "tcolt_or_dsexpr1" << endl;
    }
    | DOUBLE_MULTIPLY expr {
        cout << "tcolt_or_dsexpr2" << endl;
    }
    ;
comma_test_or_starexp_star: COMMA test_or_starexp { 
    strcpy($$->type,$2->type);
    cout << "classdef1" << endl; }
    | COMMA test_or_starexp comma_test_or_starexp_star {
        if(!(strcmp($1->type,$2->type))){
            strcpy($$->type, $2->type);
        } else {
            cout << "Arguments are of different type at line no: " << yylineno << endl;
        }
        cout << "classdef1" << endl; }
    ;
classdef: classdef_def suite  {current=global;}
    | classdef_def newline_plus suite  {current=global;}
    ; 
classdef_def: CLASS NAME COLON { 
    cout << "classdef1" << endl;
        char str[1000];
        strcpy(str,"class");
        cout<<"enter_symbol12"<<endl;
        enter_symbol(current,$2->token,str,yylineno);
        cout<<"symbol_table6"<<endl;
        current=new symbol_table(yylineno,$2->token,current);
    }
    | CLASS NAME LEFT_PAR arglist RIGHT_PAR COLON {
        cout<<"symbol_table6a"<<endl;
        arglist_size++;
        $$->size = arglist_size;
        cout << "classdef2" << endl;
        char str[1000];
        strcpy(str,"class");
        cout<<"enter_symbol13"<<endl;
        enter_symbol(current,$2->token,str,yylineno);
        
        symbol_entry *entry=entry_lookup(current,$2->token);
        strcpy(entry->type2, $4->token);
        
        for(auto i:current->children) {
            if(!strcmp(i.second->token, $4->token)) {
                enter_symbol(i.second,$2->token,str,yylineno);
                symbol_entry *entry=entry_lookup(i.second,$2->token);
                strcpy(entry->type2, $4->token);
                
            }
        }
        current=new symbol_table(yylineno,$2->token,current);
        
    } 
    | CLASS NAME LEFT_PAR RIGHT_PAR COLON {
        cout << "classdef3" << endl;
        char str[1000];
        strcpy(str,"class");
        cout<<"enter_symbol14"<<endl;
        enter_symbol(current,$2->token,str,yylineno);
        cout<<"symbol_table7"<<endl;
        current=new symbol_table(yylineno,$2->token,current);
    }
    ;
comma_brack:  {cout<<"comma_brack1"<<endl;}
    | COMMA     {cout << "comma_brack2" << endl;}
    ;
argument: test sync_comp_for {
       cout << "argument1" << endl;
    }  
    | test EQUAL_TO test  {
       cout << "argument2" << endl;
    }
    | DOUBLE_MULTIPLY test  {
      cout << "argument3" << endl;
    }
    | MULTIPLY test {
      cout << "argument4" << endl;
    }
    | test { cout << "argument5" << endl;}
    ;

comp_iter: sync_comp_for {cout << "comp_iter1" << endl;}
    | comp_if {cout << "comp_iter2" << endl;}
    ;
sync_comp_for: FOR exprlist IN or_test comp_iter {
    cout << "sync_comp_for1" << endl;
        if ($2->type != $4->type) {
            cout << "error at " << yylineno << endl;
            exit(EXIT_FAILURE);
        }
    }
    | FOR exprlist IN or_test {
        cout << "sync_comp_for2" << endl;
        if ($2->type != $4->type) {
            cout << "error at " << yylineno << endl;
            exit(EXIT_FAILURE);
        }
    }
    ;
comp_if: IF or_test comp_iter {cout << "comp_if1" << endl;}
    | IF or_test  {cout << "comp_if2" << endl;}
    ;

comma_test: COMMA test      {cout << "comma_test1" << endl;}
    | COMMA test comma_test {cout << "comma_test2" << endl;}
    ;
test_brack:      {
     char str[1000];
    strcpy(str,"test_brack");
    $$ = new nonterminal(str); ($$->if_null) = 1; cout << "test_brack1" << endl;}
    | test          {cout << "test_brack2" << endl;}
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

    print(global);

    
      return 0;
}