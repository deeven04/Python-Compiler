#include<bits/stdc++.h>
using namespace std;
ifstream f_in;
ofstream f_out;
map<int,string>string_labels;
map<string,string> reg_map; // t map for variables and stored registers
map<string,string> temp_reg; // r whether a register is empty or being used
map<string,string> init_reg; // s reg and initialised value is stored
map<string,int> string_reg;
vector<vector<string> >lines;//tokens for every line
vector<string> curr_func;
int string_count=0;

string getreg(string temp_var) {
    cout << "getreg called: " << reg_map.size() << endl;
    string reg = "%r" + to_string((temp_reg.size()%8) + 8);
    temp_reg.insert({temp_var,reg});
    reg_map.insert({temp_var,reg});
    return reg;  
}

void printfunc(string a, string b, string c){
    try {
        if(b[1]=='\"'){
         b="$str"+ to_string(string_count);   
        }
        int value = std::stoi(b);
        if (value >= 0 && value <= 9) {
            b = "$" + b;
        }
    } catch (const std::invalid_argument& e) {
        std::cerr << "Invalid argument: " << e.what() << std::endl;
    }
    if (b[b.size()-1] == ')' && c[c.size()-1] == ')' && (a == "movq" || a == "cmpq")) {
        string reg = getreg(reg_map[b]);
        // reg_map.insert({reg, })
        printfunc(a,b,reg);
        printfunc(a,reg,c);
    } else if (b == "db") {
        f_out << "\t" << a << " "  << b << " " << c << endl;
    } else if(c != "") {
        f_out << "\t" << a << " "  << b << ", " << c << endl;
    } else f_out << "\t" << a << " "  << b << endl;
}

int get_size(ifstream& file){
    vector<string> type_column;
    string line;
    while (getline(file, line)) {
        stringstream ss(line);
        string cell;
        int column = 0;
        while (getline(ss, cell, ',')) {
            if (column == 1) {
                type_column.push_back(cell);
            }
            column++;
        }
    }
    int lVar_size = 0;
    auto element = type_column.begin();
    ++element;
    for (; element != type_column.end(); ++element) {
        if(*element =="int" || *element =="float") lVar_size += 8;
        else if(*element =="char" ) lVar_size += 8;
        else if(*element =="bool") lVar_size += 8;
        else if(*element =="long" || *element =="double") lVar_size += 8;
        else lVar_size += 8;
    }
    return lVar_size;
}

int var_size(string str, ifstream& file) {
    vector<string> token_row;
    string line;
    string type;
    while (getline(file, line)) {
        stringstream ss(line);
        string cell;
        int column = 0;
        while (getline(ss, cell, ',')) {
            if (column == 0 && cell == str) {
                getline(ss, type, ',');
            }
            column++;
        }
    }

    int lVar_size = 0;
    if(type =="int" || type =="float") lVar_size = 8;
    else if(type =="char" ) lVar_size = 8;
    else if(type =="bool") lVar_size = 8;
    else if(type =="long" || type =="double") lVar_size = 8;
    else lVar_size = 8;
    return lVar_size;
}

int main(int argc, char**argv){
    string input,output;
    int func_call_over = 0;
    if(argc<2){
        cout<<"No Actions Provided"<<endl;
        exit(1);
    }
    bool k_1;
    for(int i=1;i<argc;i++){
        string k = argv[i];
        if(k.size()<6){
            cout<<k<<" is not a valid option."<<endl;
            exit(1);
        }
        if(k=="--help"){
            cout<<"Available Options:"<<endl<<endl;
            cout<<"--help     :  Opens this menu"<<endl;
            cout<<"--input    :  To enter input file destination from the build folder"<<endl;
            cout<<"--output   :  To enter output file destination from the build folder"<<endl;
            exit(1);
        }
        else if(k.size()<8){
            cout<<k<<" is not a valid option."<<endl;
            exit(1);
        }
        else if(k.substr(0,8)=="--input=") input = k.substr(8,k.size()-8);
        else if(k.size()<9){
            cout<<k<<" is not a valid option."<<endl;
            exit(1);
        }
        else if(k.size()<9){
            cout<<k<<" is not a valid option."<<endl;
            exit(1);
        }
        else if(k.substr(0,9)=="--output=") output = k.substr(9,k.size()-9);
        else{
            cout<<k<<" is not a valid option."<<endl;
            exit(1);
        }
    }
    if(input.size()==0){
        cout<<"No input file provided"<<endl;
        exit(1);
    }
    if(output.size()==0){
        output = input.substr(0,input.size()-3)+"s";
    }
    f_in.open(input);
    f_out.open(output);
    string str;
    string_count=0;
    while(getline(f_in,str)){
        vector<string>tokens;int r=0;
        string token;int p=0;//not in brac
        for(int i=0;i<str.size();i++){
         if(str[i] == '\"'){
             r++;
             if(r%2!=0)string_count++;
             else {
                 string_labels.insert({string_count,token + '\"'});

             }
         }
        if(str[i]=='(')p++;
        else if(str[i]==')')p--;
        if(str[i]==' '&& p==0 && r%2==0){
            if(token.size()!=0)tokens.push_back(token);
            token.clear();
        }else token.push_back(str[i]);
        }
        if(token.size()!=0)tokens.push_back(token);
        if(tokens.size())lines.push_back(tokens);
    }  f_out<<"\t.text"<<endl;
    f_out<<"\t.section .rodata"<<endl<<".LC0:"<<endl<<"\t.string \"\%ld\\n\"\n"<<endl;
    f_out<<".LC1:"<<endl<<"\t.string \"\%s\\n\"\n"<<endl;
    for(auto it:string_labels){
     //   it.second[0]='\'',it.second[it.second.length()-1]='\'';
       if(it.second[0]=='\''){it.second[0]='\"';}
       if(it.second[it.second.size()-1]=='\''){it.second[it.second.size()-1]='\"';}
       f_out<<"str"<<it.first<<":"<<endl<<"\t.string "<<it.second<<endl;
       string_reg.insert({it.second,it.first});
    }
    f_out<<"\t.text"<<endl;
    int k = 0;
    int local_variable = 0;
    int local_var = 0;
    for(int i=0;i<lines.size();i++){
        string reg1,reg2;
        if(lines[i][0] == "BeginFunc"){
            curr_func.push_back(lines[i][1]);
            f_out<<"\t.globl "<<lines[i][1]<<endl;
            f_out<<"\t.type "<<lines[i][1]<<"@function"<<endl;
            f_out << lines[i][1]<<":"<<endl;   
            printfunc("pushq","%rbp","");
            printfunc("movq","%rsp","%rbp");

            string filename = lines[i][1] + ".csv";
            ifstream file(filename);
            if (!file.is_open()) {
                cerr << "Error opening file." << endl;
                return 1;
            }
            
            int local_var_size = get_size(file);
            local_var = local_var_size;
            k = -1*(local_var_size+8);
            file.close();
            f_out <<"\t" <<"subq " << "$" << local_var_size << ", %rbp" << endl;
            temp_reg.clear();
        }   
        else if(lines[i][0] == "EndFunc"){
            cout << "endfunc1" << endl;
            for(auto it = temp_reg.begin(); it != temp_reg.end(); it++){
                cout << it->first << " " << it->second << endl;
                f_out << "\tpop\t" << it->second << endl;
            }
            string s="$"+to_string(local_var);
            printfunc("addq",s,"%rbp");
            printfunc("movq", "%rbp", "%rsp");
            printfunc("popq", "%rbp", "");
            f_out << "\tret" << endl;
            f_out << "\n" << "\n" << endl;
            temp_reg.clear();
            reg_map.clear();
            init_reg.clear();

        }  else if(lines[i].size() == 3 && lines[i][2][0] == '[') {
            cout << "enter array: " << lines[i][2] << endl;
            string s = lines[i+3][0];
            string data = "";
            for(int j = 0; j < lines[i][2].size(); j++) {
                if(lines[i][2][j] == '[' || lines[i][2][j] == ']') continue;
                data = data + lines[i][2][j];
            }
            printfunc(lines[i][0], "db" , data);
            // t_24 = [-2,45,0,11,-945]
            // t_25 = 4
            // list = t_25 array 
            // data = t_24
            i = i+3;
        } 
        else if(lines[i][0] == "goto") {
            f_out <<"\t" <<"jmp " << lines[i][1] << endl;
        }
        else if(lines[i][0].substr(0,2) == ".L" || lines[i][0].substr(0,3)=="end"){
            f_out << "   " << lines[i][0] <<":" << endl;
        }
        else if(lines[i][0] == "print"){
            string temp=lines[i][1];
            cout<<"print"<<endl;
            if(reg_map.find(temp)!=reg_map.end()){
                cout<<"hi"<<endl;
                if(reg_map[temp][0] =='\"'){
             printfunc("movq","$str" + string_reg[reg_map[temp]],"%rsi");
            }else{
            
                printfunc("movq",reg_map[temp],"%rsi");}
                cout<<"bye"<<endl;
            }
            else{
                  if(init_reg[temp][0] =='\"'){
                    string s4 = "$str" + to_string(string_reg[init_reg[temp]]);
             printfunc("movq",s4,"%rsi");
              cout << "regguighgh   " << s4 << endl;
                  
            }else{
                printfunc("movq",init_reg[temp],"%rsi");}
            }
            if(init_reg[lines[i][1]][0] == '\"') {printfunc("leaq",".LC1(%rip)","%rdi");}
            else printfunc("leaq",".LC0(%rip)","%rdi");
            //   printfunc("leaq",".LC0(%rip)","%rdi");
                printfunc("movq","$0","%rax");
                printfunc("call","printf@PLT","");
        }
        else if(lines[i][2] == "return"){
            if(reg_map.find(lines[i][0]) != reg_map.end()){
            printfunc("movq",reg_map[lines[i][0]],"%rax");
            }
            else{
                  if(init_reg[lines[i][0]][0] =='\"'){
                    printfunc("movq","$str" + to_string(string_reg[init_reg[lines[i][0]]]),"%rax");
                }else{
                    printfunc("movq",init_reg[lines[i][0]],"%rax");}
            }
        }
        else if(lines[i][2] == "returnpop"){
            if(reg_map.find(lines[i][0])!=reg_map.end() ){
                printfunc("movq","%rax",reg_map[lines[i][0]]);
            }
            else{
                reg1 = getreg(lines[i][0]);
                reg_map.insert({lines[i][0],reg1});
                printfunc("movq","%rax",reg_map[lines[i][0]]);
            }
        }
        else if(lines[i][2] == "popparam"){
            reg1 = getreg(lines[i][0]);
            reg_map.insert({lines[i][0],reg1});
        }
    
        else if(lines[i][2]=="pushparam"){ if(func_call_over == 0  ){ temp_reg.clear(); func_call_over = 1;   }cout<<"ooo"<<endl;continue;}
        else if(lines[i][0].substr(0,2)!="t_" && lines[i][2].substr(0,2) == "t_" && lines[i].size() == 3 && lines[i-1][2] == "pushparam"){
            cout<<"pushed"<<endl;
            if(reg_map.find(lines[i][0])==reg_map.end()){
                    reg1=getreg(lines[i][0]);
                    string s4 = init_reg[lines[i][2]];
                    printfunc("movq",reg_map[lines[i][2]],reg1);
                    // f_out << "movq: 276" << endl;
                    cout<<"pushed1"<<endl;
            }
            else reg1=reg_map[lines[i][0]];
            printfunc("pushq",reg1,"");
            cout<<"pushed2"<<endl;
        }
    
        else if(lines[i][0].substr(0,2) == "t_" && lines[i].size() == 3 && lines[i][2][0] != 't'){
            // f_out<<"imm1"<<endl;
            init_reg.insert({lines[i][0],lines[i][2]});
            cout<<"lines[0][2]"<<lines[i][2]<<endl;
            // f_out<<"imm2"<<endl;
        }
        else if(lines[i][0].substr(0,2) == "t_" && lines[i].size() == 3 && lines[i][2][0] == 't'){
            // f_out<<"imm1"<<endl;
            if(reg_map.find(lines[i][2]) != reg_map.end()){
            printfunc("movq",reg_map[lines[i][2]],reg_map[lines[i][0]]);
            // f_out << "movq: 293" << endl;
                    }
            else{
                printfunc("movq",init_reg[lines[i][2]],reg_map[lines[i][0]]);
            }
            cout<<"lines[0][2]"<<lines[i][2]<<endl;
            // f_out<<"imm2"<<endl;
        }
        else if(lines[i][2].substr(0,2) == "t_" && lines[i].size() == 3) {
            string filename = curr_func[curr_func.size()-1] + ".csv";
            ifstream file(filename);
            if (!file.is_open()) {
                cerr << "Error opening file." << endl;
                return 1;
            }
            int local_var_size = var_size(lines[i][0], file);
            
            file.close();
            if(local_var_size == 8 && lines[i-1][2] != "popparam"){
            k = k + local_var_size;
            string s1 = to_string(k) + "(%rbp)";
            reg_map.insert({lines[i][2],s1});
            if(init_reg[lines[i][2]][0] =='\"'){
             f_out << "\tmovq " << "$str" <<to_string(string_reg[init_reg[lines[i][2]]])  <<", " << s1 << endl;

            }else{
            f_out << "\tmovq " << "$" << init_reg[lines[i][2]] <<", " << s1 << endl;}
            // curr_func[curr_func.size()-1];
            // lines[i][0] 
            }
        }
        else if(lines[i][0].substr(0, 4) == "call") {
            f_out <<"\t" <<"call " << lines[i][0].substr(4) << endl;
            func_call_over = 0;
        
        } 
        else if(lines[i][0] == "if") {
            string reg_l, reg_r;
            if(lines[i].size() == 6) {
                if(reg_map.find(lines[i][1])!=reg_map.end()){
                    reg_l = reg_map[lines[i][1]];
                   
                }
                else if(init_reg.find(lines[i][1])!=init_reg.end()){
                    if(init_reg[lines[i][1]][0] == '\"'){
                        reg_r = "$str" + to_string(string_reg[init_reg[lines[i][1]]]);
                    }
                    else{
                    reg_r="$" + init_reg[lines[i][1]]; 
                    }
                    reg_l="$" + init_reg[lines[i][1]]; 
                     reg_r = "$str" + to_string(string_reg[init_reg[lines[i][1]]]);
                }
                if(reg_map.find(lines[i][3])!=reg_map.end()){
                    reg_r = reg_map[lines[i][3]];
                    
                }
                else if(init_reg.find(lines[i][3])!=init_reg.end()){
                    if(init_reg[lines[i][3]][0] == '\"'){
                        reg_r = "$str" + to_string(string_reg[init_reg[lines[i][3]]]);
                    }
                    else{
                    reg_r="$" + init_reg[lines[i][3]]; 
                    }
                    cout << "kfephfoeihfoehfoefuoehofbgeigbf    8        " << endl;
                } 
                    printfunc("cmpq", reg_r, reg_l);
                    if(lines[i][2] == "<") printfunc("jl",lines[i][5],"");
                    if(lines[i][2] == ">") printfunc("jg",lines[i][5],"");
                    if(lines[i][2] == ">=") printfunc("jge",lines[i][5],"");
                    if(lines[i][2] == "<=") printfunc("jle",lines[i][5],"");
                    if(lines[i][2] == "==") printfunc("je",lines[i][5],"");
                    if(lines[i][2] == "!=") printfunc("jne",lines[i][5],"");
            } else if(lines[i].size() == 4) {
                if(lines[i][1][0] == '!') {
                    string reg_str = lines[i][1].substr(1,lines[i][1].size());
                    f_out<<"\t"<<reg_str<<endl;
                    reg_l = reg_map[str];
                    printfunc("cmpq", reg_l, "$0");
                    printfunc("jz", lines[i][3], "");
                } else if (lines[i][1][0] != '!') {
                    reg_l = reg_map[lines[i][1]];
                    printfunc("cmpq", reg_l, "$0");
                    printfunc("jnz", lines[i][3], "");
                }
            }
        } else if(lines[i].size() == 5){
            cout<<"entered size 5 "<<endl;
            if(reg_map.find(lines[i][0])==reg_map.end()){
                reg2=getreg(lines[i][0]);
                reg_map.insert({lines[i][0],reg2});
            }
            else {
                reg2 = reg_map[lines[i][0]];
            }
            if(reg_map.find(lines[i][2])!=reg_map.end() && lines[i][0] != lines[i][2]){
                reg1 = reg_map[lines[i][2]];
                //f_out << "movq " << reg1 << ", " << reg2 << endl;
                printfunc("movq",reg1,reg2);
                // f_out << "movq: 369" << endl;
            }else if(init_reg.find(lines[i][2]) != init_reg.end() && lines[i][0] != lines[i][2]){
                reg1 = "$" + init_reg[lines[i][2]];
                  if(reg1[1] =='\"'){
             printfunc("movq","$str" + to_string(string_reg[reg1]),reg2);

            }else{
            
                printfunc("movq",reg1,reg2);}
                // f_out << "movq: 373" << endl;
            }
            if(lines[i][4] == "1"){
                reg1 = "$1";
            }
            else if(reg_map.find(lines[i][4])!=reg_map.end()){
                reg1 = reg_map[lines[i][4]];
                
            }else if(init_reg.find(lines[i][4]) != init_reg.end()){
            reg1 = "$" + init_reg[lines[i][4]];
                if(reg1[1]=='\"'){
                    reg1="$str" + to_string(string_reg[reg1]);
                }
            }else{
                reg1=getreg(lines[i][4]);
            }
                if(lines[i][3]=="+")printfunc("addq",reg1,reg2);
                else if(lines[i][3]=="-")printfunc("subq",reg1,reg2);
                else if(lines[i][3]=="*"){
                 
                    printfunc("imulq",reg1,"%rax");
                    printfunc("movq","%rax",reg2);
                }
                else if(lines[i][3]=="/"|| lines[i][3]=="%"){
                    printfunc("movq",reg1,"%rax");//doubt
                    f_out << "\tcltd" << endl;
                    f_out << "\tidivq  " << reg2 << endl; 
                }else if(lines[i][3]=="&")printfunc("andq",reg1,reg2);
                else if(lines[i][3]=="|")printfunc("orq",reg1,reg2);
                else if(lines[i][3]=="^")printfunc("xorq",reg1,reg2);
                
                cout<<"exit 5"<<endl;
        }
        cout<<"i:"<<i<<endl; 
    }
}
