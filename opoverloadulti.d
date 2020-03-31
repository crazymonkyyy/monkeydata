int opcmp(T,U)(T a,U b){
	if(a<b){return -1;}
	else if(a>b){return 1;}
	return 0;
}
bool opequal(T,U)(T a,U b){
	return a.opcmp(b)==0;}

string tostring(T)(T a){
	import std.conv;
	return a.to!string;
}
