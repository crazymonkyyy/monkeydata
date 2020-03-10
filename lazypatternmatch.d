import typeless;
void patternmatch(alias actions,alias classify)(T x){
	//["even","odd"]
	enum string[] identifiers= [__traits(allMembers,actions!())];
	//enum classifications {even,odd}
	mixin("enum classifications "~identifiers.comma_list.curly_wrap);
	
	string casestatement(string s){
		return "case classifications."~s~": actions!()."~s~"(x);break exit;"~endl;}
	exit:final switch(classify!(classifications)(x)){
		static foreach(s;identifiers){
			mixin(casestatement(s));}}
		//case classifications.even: actions!().even(x);break;
		//case classifications.odd: actions!().odd(x);break;
		//exit to make mixin happy
}
void patternmatch_(alias actions,alias classify,classifications,T)(T x){
	enum string[] identifiers= [__traits(allMembers,actions!())];
	string casestatement(string s){
		return "case classifications."~s~": actions!()."~s~"(x);break exit;"~endl;}
	exit:final switch(classify(x)){
		static foreach(s;identifiers){
			mixin(casestatement(s));}}
}
unittest{
	import std.conv;
	import std.stdio;
	static void writeeven(int x){assert(x%2==0); (x.to!string~"even").writeln;}
	static void writeodd(int x){assert(x%2==1); (x.to!string~"odd").writeln;}
	template actions(){
		alias even=writeeven;
		alias odd=writeodd;
	}
	//static assert(__traits(allMembers,actions!())==("even","odd"));
	static T classify(alias T)(int x){
		if(x%2==0) {return T.even;}
		else{return T.odd;}
	}
	patternmatch!(actions,classify)(2);
	patternmatch!(actions,classify)(3);
}
void main(){}
