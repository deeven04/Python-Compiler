#include<bits/stdc++.h>
using namespace std;
#ifndef AST_NODE_H
#define AST_NODE_H

class Astnode {
public:
    string label = "default";
    string lexeme = "default";
    string value = "default";
    virtual void add(Astnode* n) = 0;
    virtual void print() const=0 ;
    virtual ~Astnode() {}
};
class common_node : public Astnode{
    private:
    vector<Astnode*>temp;
    public:
     common_node(const string &name ,const string &name2){
        this->label = name ;
        this->lexeme = name2;
        //  cout<<"hi "<<name<<" lexeme "<<name2<<endl;
     }
     
     void add(Astnode* n)override{
        //  cout<<"pushed "<< n->label <<endl;
      temp.push_back(n);
     }

     void print() const override{
        if(lexeme != "default" && label != "default"){
        cout<<"\t"<<label<<" [label = \"" <<lexeme<< "\"]"<<endl;  
        for(const auto & t:temp){
            if(t->lexeme != "default" && t->label != "default"){
            cout<<"\t"<<label<<" -> "<<t->label<<";"<<endl;
            t->print();
            }
        }
     }
}
     ~common_node(){
    for(const auto & t:temp){
        delete t;
    }
}
};
class IdentifierNode : public Astnode {

public:
    string value = "default";
    IdentifierNode( const string& value) {
        this->value = value; 
    }
    void add(Astnode* node) override {
        cerr << "Cannot add a child to a leaf node." <<node->lexeme <<endl;
    }

    void print() const override  {

    }
};
class NumberNode : public Astnode {

public:
    string value = "default";
    NumberNode(const string& name, const string& label, const string& value) {
        this->label = name;
        this->lexeme = label;
        this->value = value; 
    }
    void add(Astnode* /*node*/) override {
        cerr << "Cannot add a child to a leaf node." << endl;
    }

    void print() const override {

    }
};

class AST {
private:
    Astnode* root = nullptr;
public:
    AST(Astnode* r) : root(r) {}

    ~AST() {
        if (root != nullptr) {
            delete root;
            root = nullptr;
        }
    }
    void Print() {
        cout << "digraph G {" << endl;
        root->print();
        cout << "}" << endl;
    }
};
#endif 