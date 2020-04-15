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
	
auto pointyconstruct(string[] elems...){
	assert(__ctfe);
	import typeless;
	import std.algorithm;
	import std.array;
	static string magicstring(string foo)(string elem){
		return "grey."~elem~"=typeof(grey."~elem~")();grey."~elem~"="~
				mixin("elem."~foo);
	}
	static string construct(string f,string g)(){
		return "this"~paren_wrap(mixin("elems."~f))~curly_wrap(
			elems.map!(magicstring!g).endl_list);}
	static string fun1(string[] foo){return "ref mylitteral construct";}
	static string fun2(string foo){return "&construct."~foo~";"~endl;}
	return construct!("fun1","fun2");
}
unittest{
	import std.stdio;
	"hi".writeln;
	enum foo=["x","y"];
	writeln(pointyconstruct(foo));
}
/*q"[this(ref mylitteral construct){]"~endl~
q"[	grey.x=typeof(grey.x)();grey.x=&construct.x;]"~endl~
q"[	grey.y=typeof(grey.y)();grey.y=&construct.y;]"~endl~
q"[}]"~endl~
q"[this(typeof(mylitteral.x)* x_,typeof(mylitteral.y)* y_){]"~endl~
q"[	grey.x=typeof(grey.x)();grey.x=x_;]"~endl~
q"[	grey.y=typeof(grey.y)();grey.y=y_;]"~endl~
q"[}]"~endl~
q"[this(typeof(grey.x) x_,typeof(grey.y) y_){]"~endl~
q"[	grey.x=typeof(grey.x)();grey.x=x_;]"~endl~
q"[	grey.y=typeof(grey.y)();grey.y=y_;]"~endl~
q"[}]"~endl~*/
