auto mypointer(T)(T a){
	import std.conv;
	return "mypointer!"~a.size.to!string~" "~a.name;}
auto plusplus(T)(T a){
	return "++"~a.name;}
auto minusminus(T)(T a){
	return "--"~a.name;}
