#include <bits/stdc++.h>
using namespace std;

typedef struct quadruple{
    string op;
    string arg1;
    string arg2;#include <bits/stdc++.h>
using namespace std;

typedef struct quadruple{
    string op;
    string arg1;
    string arg2;
    string result;
    int index;// target label for this particular instruction
}quadruple;

int inst_num=0;
int curr_inst_num = 0;
vector <quadruple> code;
vector <quadruple> curr;

int var_num = 0;
void emitt(string op,string arg1, string arg2, string result, int idx,int bt){
    if(bt == 0){
    quadruple entry;
    entry.op = op;
    entry.arg1 = arg1;
    entry.arg2 = arg2;
    entry.result = result;
    entry.index = idx;
    code.push_back(entry);
    inst_num++;
    }else if(bt == 1){
    quadruple entry;
    entry.op = op;
    entry.arg1 = arg1;
    entry.arg2 = arg2;
    entry.result = result;
    entry.index = idx;
    curr.push_back(entry);
    curr_inst_num++;
    }
}


string array_access(string name,vector<int> a,vector<int> b){
    string t = "t_"+to_string(var_num);
    var_num++;
    for(int i = 0; i<a.size();i++){
        if(i==0) emitt("*","t_"+to_string(a[i]),"t"+to_string(b[i]),t,-1,0);
        else{
            string s = "t_"+to_string(var_num);
            var_num++;
            emitt("*","t_"+to_string(a[i]),"t_"+to_string(b[i]),s,-1,0);
            emitt("+",t,s,t,-1,0);
        }
    }
    return "*("+name+" + "+t+")";
}
void print3ac(){
    ofstream tac_file;
    string file_name = "3ac.txt";
    tac_file.open(file_name);
    vector<int>gt;
    vector<pair<int,int>>func;

    for(int i=0;i<code.size();i++){
        if(code[i].result=="goto ")gt.push_back(code[i].index);
        if(code[i].op=="begin") func.push_back({i+1,0});
    }
    sort(gt.begin(),gt.end());
    int t=0;

    for(int i=0;i<code.size();i++){
        
        // if(code[i].op=="loop:"|| code[i].result=="goto loop"){
        //     cout<<"came"<<t<<gt.size()<<gt[t]<<i<<endl;
        //   if(t<gt.size() && gt[t]==i){//instr number==goto
        //     cout<<"came"<<endl;
        //     tac_file<<".L"<<(t+1)<<":"<<endl;t++;
        //   }
        // }
        if(code[i].op == "array"){
            emitt("string","pushparam "+code[i].arg1,"","",-1,0);
            emitt("string","stack_pointer +8","","",-1,0);
            emitt("string","call allocmem 1","","",-1,0);
            emitt("string","stack_pointer -8","","",-1,0);
            emitt("","pop 4","",code[i].result,-1,0);
            emitt("string","popparam 4","","",-1,0);
        }
        if(code[i].op == "param"){
            tac_file<<code[i].arg1<<endl;
        }
        if(code[i].op == "pushparam"){
            tac_file<<code[i].arg1<<endl;
        }
        if(code[i].result == "return" || code[i].result == "returnpop"){
            tac_file << code[i].arg1<<" = "<<code[i].result<<endl;
        }
        else if(code[i].op == "string"){
           tac_file<<code[i].arg1<<endl;
        }
        else if(code[i].op == "begin"){
           tac_file<<"BeginFunc "<<code[i].arg1<<endl;
        }
        else if(code[i].result == "end"){
            tac_file<<"EndFunc"<<endl;
        }
        else if(code[i].op == "if"){
            tac_file<<"if "<<code[i].arg1<<" "<<code[i].result<<" "<<code[i].arg2<<"\n";
        }
        else if(code[i].result=="goto"){
            tac_file<<"goto "<<code[i].arg1<<endl;
        }
        else if(code[i].result=="loop:" || code[i].result == "goto loop"){
           tac_file<<code[i].arg1<<endl;
        }
        else if(code[i].result=="end loop" ){
            tac_file<<code[i].arg1<<endl;
        }
        else if(code[i].op == "call"){
            tac_file<<code[i].op<<code[i].arg1<<endl;
        }
        else if(code[i].result == "break"){
            tac_file<<code[i].result<<endl;
        }
        else if(code[i].result == "print"){
            tac_file<<code[i].result<<" "<<code[i].arg1<<endl;
        }
        else if(code[i].op==""){
            tac_file<<code[i].result<<" = "<<code[i].arg1<<endl;
        }
        
        else {
            tac_file<<code[i].result<<" = "<<code[i].arg1<<" "<<code[i].op<<" "<<code[i].arg2<<"\n";
        }
    }
}


void backpatch(string arg1, string arg2 , string op,int indx,int curr_num,int b_true,int for_if){
   quadruple entry;
    entry.op = curr[curr_num].op;
    entry.arg1 = curr[curr_num].arg1;
    entry.arg2 = curr[curr_num].arg2;
    entry.result = curr[curr_num].result;
    entry.index = curr[curr_num].index;
    if(b_true==0){
    code.push_back(entry);
    inst_num++;
    }
    if(b_true == 1){
        curr_inst_num++;
    string s2 = arg2;
        string s = s2 + "  " + "goto " + "end.L" +  to_string(for_if);
     
     entry.op = "if";
    entry.arg1 = arg1;
    entry.arg2 = s;
    entry.result = ">";
    entry.index = indx;
    curr.insert(curr.begin()+curr_num + 1,entry);
    }
    else{
         string s2 = arg2;
        string s = s2 + "  " + "goto " + "end.L" +  to_string(for_if);
     emitt("if",arg1,s,">",indx,0);
    }
    for(int i = curr_num + 1 ; i<curr_inst_num;i++){
    entry.op = curr[i].op;
    entry.arg1 = curr[i].arg1;
    entry.arg2 = curr[i].arg2;
    entry.result = curr[i].result;
    entry.index = curr[i].index;
    if(b_true == 0){
    code.push_back(entry);
    inst_num++;\
    }
    }
    //cout<<endl;

}
void array_func(string name, string type){
    string size;
    if(type.substr(0,3)=="int" || type.substr(0,5)=="float") size="4";
    else if(type.substr(0,4)=="char" || type.substr(0,4)=="short") size="2";
    else if(type.substr(0,4)=="byte") size = "1";
    else if(type.substr(0,4)=="long" || type.substr(0,6)=="double") size = "8";
    else {
        cout<<"Unexpected Error Occurred. Pls give diff input"<<endl;
        exit(1);
    }
    string t = "t_"+to_string(var_num);
    var_num++;
    emitt("",size,"",t,-1,0);
    emitt("array",t,"",name,-1,0);
}

string new_temporary(){
    string temp_var="t_"+to_string(var_num);
    var_num++;
    return temp_var;
}
    string result;
    int index;// target label for this particular instruction
}quadruple;

int inst_num=0;
vector <quadruple> code;
vector <quadruple> curr;

int var_num = 0;
void emitt(string op,string arg1, string arg2, string result, int idx){
    quadruple entry;
    entry.op = op;
    entry.arg1 = arg1;
    entry.arg2 = arg2;
    entry.result = result;
    entry.index = idx;
    code.push_back(entry);
    inst_num++;
}


string array_access(string name,vector<int> a,vector<int> b){
    string t = "t_"+to_string(var_num);
    var_num++;
    for(int i = 0; i<a.size();i++){
        if(i==0) emitt("*","t_"+to_string(a[i]),"t"+to_string(b[i]),t,-1);
        else{
            string s = "t_"+to_string(var_num);
            var_num++;
            emitt("*","t_"+to_string(a[i]),"t_"+to_string(b[i]),s,-1);
            emitt("+",t,s,t,-1);
        }
    }
    return "*("+name+" + "+t+")";
}
void print3ac(){
    ofstream tac_file;
    string file_name = "3ac.txt";
    tac_file.open(file_name);
    for(int i=0;i<code.size();i++){
        if(code[i].op == "array"){
            emitt("string","pushparam "+code[i].arg1,"","",-1);
            emitt("string","stack_pointer +8","","",-1);
            emitt("string","call allocmem 1","","",-1);
            emitt("string","stack_pointer -8","","",-1);
            emitt("","pop 4","",code[i].result,-1);
            emitt("string","popparam 4","","",-1);
        }
        if(code[i].op == "param"){
            tac_file<<i<<":  "<<code[i].arg1<<endl;
        }
        if(code[i].op == "pushparam"){
            tac_file<<i<<":  "<<code[i].arg1<<endl;
        }
        if(code[i].op == "pushparam"){
            tac_file<<i<<":  "<<code[i].arg1<<endl;
        }
        else if(code[i].op == "string"){
            tac_file<<i<<":    "<<code[i].arg1<<endl;
        }
        else if(code[i].op == "cast"){
            tac_file<<i<<":    "<<code[i].result<<" = cast_to_"<<code[i].arg2<<" "<<code[i].arg1<<endl;
        }
        else if(code[i].op == "begin"){
            tac_file<<i<<": BeginFunc "<<code[i].arg1<<endl;
        }
        else if(code[i].op == "end"){
            tac_file<<i<<": EndFunc"<<endl<<endl;
        }
        else if(code[i].op == "if"){
            tac_file<<i<<":    if "<<code[i].arg1<<" "<<code[i].result<<" "<<code[i].arg2<<"\n";
        }
        else if(code[i].result=="goto"){
            tac_file<<i<<":    goto "<<code[i].index<<endl;
        }
        else if(code[i].result=="loop:" || code[i].result == "goto loop"){
            tac_file<<i<<":  "<<code[i].result<<endl;
        }
        else if(code[i].result=="end loop" ){
            tac_file<<i<<":  "<<code[i].result<<endl;
        }
        else if(code[i].op == "call"){
            tac_file<<i<<":   "<<code[i].op<<code[i].arg1<<endl;
        }
        else if(code[i].op==""){
            tac_file<<i<<":    "<<code[i].result<<" = "<<code[i].arg1<<endl;
        }
        else {
            tac_file <<i<<":    "<<code[i].result<<" = "<<code[i].arg1<<" "<<code[i].op<<" "<<code[i].arg2<<"\n";
        }
    }
}
vector<int> merge(vector <int>& list1, vector <int>& list2){
    for(int i=0;i<list2.size();i++){
        list1.push_back(list2[i]);
    }
    return list1;
}

void backpatch(vector <int>&instructions, int target){
    for (int i=0;i<instructions.size();i++){
        code[instructions[i]].index=target;
        //cout<<instructions[i]<<" ";
    }
    //cout<<endl;

}
void array_func(string name, string type){
    string size;
    if(type.substr(0,3)=="int" || type.substr(0,5)=="float") size="4";
    else if(type.substr(0,4)=="char" || type.substr(0,4)=="short") size="2";
    else if(type.substr(0,4)=="byte") size = "1";
    else if(type.substr(0,4)=="long" || type.substr(0,6)=="double") size = "8";
    else {
        cout<<"Unexpected Error Occurred. Pls give diff input"<<endl;
        exit(1);
    }
    string t = "t_"+to_string(var_num);
    var_num++;
    emitt("",size,"",t,-1);
    emitt("array",t,"",name,-1);
}

string new_temporary(){
    string temp_var="t_"+to_string(var_num);
    var_num++;
    return temp_var;
}