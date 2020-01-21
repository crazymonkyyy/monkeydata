import std.meta;
import std.conv;
import std.stdio;

enum string endl="\n";

static string curly_wrap(string s){
	return "{"~endl~s~"}";}
static string bracket_wrap(string s){
	return "["~s~"]";}
static string paren_wrap(string s){
	return "("~s~")";}
static string comma_cat(string s){
	return s~",";}
static string endl_cat(string s){
	return s~";"~endl;}
static string cast_wrap(string t,string s){
	return "cast("~t~")("~s~")";}
static string star_cat(string s){
	return s~"*";}
static string comma_list(string[] s){
	if(s.length==1) {return s[0];}
	else {return s[0].comma_cat~comma_list(s[1..$]);}
}
unittest{
	assert(comma_list(["1","2","3"])=="1,2,3");}
static string endl_list(string[] s){
	if(s.length==0){return "";}
	else {return s[0].endl_cat~endl_list(s[1..$]);}
}
unittest{
	//mixin(["hi","hello","foo"].endl_list);
}

static string[] make_strings(string fun,string import_="",T)(T[] args...){
	mixin(import_);
	if(args.length==0){ return [];}
	else{
		return mixin("args[0]."~fun) ~
			make_strings!(fun,import_,T)(args[1..$]);}
}
unittest{
	assert(make_strings!("to!string","import std.conv;")([1,2,3])
			== ["1","2","3"]);}

struct typeless{
	int size;
	string name;
}
template maketypeless(alias def){
	enum maketypeless=typeless(def.T.sizeof,def.name);}
unittest{
	import monkeytyping;
	struct vec2{int x; int y;}
	alias foo=definitions!vec2;
	typeless x_=maketypeless!(foo[0]);
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
