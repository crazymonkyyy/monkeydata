import std.meta;
import std.conv;
import std.stdio;

enum string endl="\n";

static string curly_wrap(string s){
	return "{"~endl~s~"}"~endl;}
static string bracket_wrap(string s){
	return "["~s~"]";}
static string paren_wrap(string s){
	return "("~s~")";}
static string quote_wrap(string s){
	return '\"'~s~'\"';}
static string comma_cat(string s){
	return s~",";}
static string colon_cat(string s){
	return s~":";}
static string endl_cat(string s){
	return s~";"~endl;}
static string cast_wrap(string t,string s){
	return "cast("~t~")("~s~")";}
static string star_cat(string s){
	return s~"*";}
static string cat(string s,string t){
	return s ~ t;}
static string reverse_cat(string s, string t){
	return t ~ s;}
static string struct_construct(string s, string t){
	return "struct "~s~curly_wrap(t.dup);}
static string function_construct(string name,string import_,
		string headergen,string bodygen,
		string[] data)(){
			import typeless;
			mixin(import_);
			mixin("enum head=data."~headergen~";");
			mixin("enum body_=data."~bodygen~";");
			return name~head.comma_list.paren_wrap~body_.endl_list.curly_wrap;
}
static string comma_list(string[] s...){
	if(s.length==1) {return s.dup[0];}
	else {return s.dup[0].comma_cat~comma_list(s.dup[1..$]);}
}
unittest{
	assert(comma_list("1","2","3")=="1,2,3");
	assert(comma_list(["1","2","3"])=="1,2,3");
}
static string endl_list(string[] s...){
	if(s.length==0){return "";}
	else {return s.dup[0].endl_cat~endl_list(s.dup[1..$]);}
}
static string linebreak_list(string[] s...){
	if(s.length==0){return "";}
	else {return s.dup[0]~endl~linebreak_list(s.dup[1..$]);}
}
static string import_list(string[] s...){
	if(s.length==0){return "";}
	else {return ("import "~s.dup[0]).endl_cat~import_list(s.dup[1..$]);}
}
unittest{
	//mixin(["hi","hello","foo"].endl_list);
}

static string[] make_strings(string fun,string import_="",T)(T[] args...){
	import typeless;
	mixin(import_);
	if(args.length==0){ return [];}
	else{
		return mixin("args.dup[0]."~fun) ~
			make_strings!(fun,import_,T)(args.dup[1..$]);}
}
unittest{
	assert(make_strings!("to!string","import std.conv;")([1,2,3])
			== ["1","2","3"]);}
			
T noop(T)(T a){return a;}
static string case_list(string f,string import_="",string g="noop",T)(T[] args...){
	mixin(import_);
	if(args.length==0){return [];}
	else{
		return "case "~mixin("args[0]."~g)~": "~mixin("args[0]."~f)~endl
				~case_list!(f,g,T)(args.dup[1..$]);}
}

//unittest{case_list!("noop")(["1","2","3"]).writeln;}

static string spiltmixin(string f,string g)(string s){
	return mixin("s."~f~"~"~"s."~g);}//awful in practice

unittest{
	assert("hi".spiltmixin!("comma_cat","star_cat")=="hi,hi*");}

struct typeless_{
	int size;
	string name;
}

template mysizeof(T){
	static if (is(T==bool)){enum mysizeof=0;}
	else{enum mysizeof=T.sizeof;}
}

template maketypeless(alias def){
	enum maketypeless=typeless_(mysizeof!(def.T),def.name);}
unittest{
	import monkeytyping;
	struct vec2{int x; int y;}
	alias foo=definitions!vec2;
	typeless_ x_=maketypeless!(foo[0]);
	assert(x_.size==4);
	assert(x_.name=="x");
	enum y_=maketypeless!(foo[1]);
	static assert(y_.name=="y");
}

template typelessdefinations(defs...){
	alias typelessdefinations= staticMap!(maketypeless,defs);
}
unittest{
	import monkeytyping;
	struct vomit{
		int x;
		double y;
		bool flag;
	}
	alias foo=typelessdefinations!(definitions!vomit);
	assert(foo[0].name=="x");
	assert(make_strings!("name")(foo).comma_list.paren_wrap=="(x,y,flag)");
}



void main(){}
