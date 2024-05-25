#include<bits/stdc++.h>
using namespace std;
#define ll long long

class nonterminal{
    public:
    char token[2000];
    char type[2000];
    char type2[2000];
    char return_type[2000];
    bool l_value=false;//objects and function calls not assigned from left side (piazza note)
    bool declared=false;//whether the variable is already declared
    //bool isdecl=true;
    bool isfunc=false;
    bool if_null=false;
    int no_args=0;
    char temp_var[1000];
    int i_number;
    int end_number;
    int dims;
    int size=0;
    char temp_op[1000];
    vector<int>true_list;
    vector<int>false_list;
    vector<int>next_list;
    vector<int>end_list;
    vector<int>dimension;
    nonterminal(){
        this->l_value=false;
        this->declared=false;
        this->isfunc=false;
        this->no_args=0;  
         char str[1000];
        strcpy(str,"");
        strcpy(type2,str);
    }
    nonterminal(char lexeme[1000],char type[1000]){
        strcpy(this->token,lexeme); 
        strcpy(this->type,type);
        this->l_value=false;
        this->declared=false;
        this->isfunc=false;
        this->if_null=false;
        this->no_args=0;
        char str[1000];
        strcpy(str,"");
        strcpy(type2,str);
    }
    nonterminal(char lexeme[1000]){
        strcpy(this->token,lexeme); 
        this->if_null=false;
        this->l_value=false;
        this->declared=false;
        this->isfunc=false;
        this->no_args=0;
         char str[1000];
        strcpy(str,"");
        strcpy(type2,str);
    }
    
    
};
class symbol_entry{
    public:
     char token[2000];
     char type[2000];
     int offset;
    char return_type[2000];
    bool isfunc=false;
    int no_args=0;
    int base_addr;
    int true_list;
    char temp_var[1000];
    char type2[2000];
    int line;
    int size;
    //class nonterminal* n_terminal;
};



class symbol_table{
    public:
    symbol_table* parent;
    unordered_map<string,symbol_entry*>table;
    unordered_map<string,symbol_table*>children;//for functions and classes
    char token[2000];
    char type[2000];
    char return_type[2000];
    int no_args=0;
    int line;
    int offset;
    // symbol_table(){
    //      this->token="";
    //     this->type="";
    //     this->return_type="";
    //     this->no_args=0;
    //     this->line=0;
    //     this->parent=nullptr;

    // }
    symbol_table() : parent(nullptr), table(), children(), token("global"), type(""), return_type(""), no_args(0), line(0) {}
    symbol_table(int line,char token[1000],symbol_table*parent){
        strcpy(this->token,token);
        this->parent=parent;
        this->line=line;
        cout<<"token in symbol table"<<token<<endl;
        if(token=="print" || token=="range"|| token=="len")return;
        
        if(parent->children.find(token)!=parent->children.end()){
            cout<<"error due to redeclaration of function or class at line no:"<<line<<endl;
            exit(0);
        }parent->children.insert({token,this});
    }
};

