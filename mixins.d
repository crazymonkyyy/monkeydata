auto mypointer(T)(T a){
	import std.conv;
	return "mypointer!"~a.size.to!string~" "~a.name;}
auto myarray(T)(T a){
	import std.conv;
	return "voidarray!("~a.size.to!string~",n) "~a.name;}
auto plusplus(T)(T a){
	return "++"~a.name;}
auto minusminus(T)(T a){
	return "--"~a.name;}

static string header1(T)(T a){
	return "ref mylitteral construct";}
static string body1(string elem){
	return "	grey."~elem~"=typeof(grey."~elem~")();grey."~elem~"=&construct."~elem;}
static string header2(string elem){
	return "typeof(mylitteral."~elem~")* "~elem~"_";}
static string body2(string elem){
	return "	grey."~elem~"=typeof(grey."~elem~")();grey."~elem~"="~elem~"_";}
static string header3(string elem){
	return "typeof(grey."~elem~") "~elem~"_";}

static string pointyconstuctors(string[] elems)(){
	import typeless;
	enum foo=function_construct!("this","import mixins;",
		"header1",
		"make_strings!(q{body1},q{import mixins;})",
		elems)();
	enum bar=function_construct!("this","import mixins;",
		"make_strings!(q{header2},q{import mixins;})",
		"make_strings!(q{body2},q{import mixins;})",
		elems)();
	enum fizz=function_construct!("this","import mixins;",
		"make_strings!(q{header3},q{import mixins;})",
		"make_strings!(q{body2},q{import mixins;})",
		elems)();
	return foo~bar~fizz;
}
