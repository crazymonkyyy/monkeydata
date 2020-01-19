import std.meta;
import std.conv;

static string endl= '
';

unittest{
	ubyte[4] float_;
	*cast(float*)&float_= float(4.20);
	assert(*cast(float*)&float_== float(4.20));
} 

struct typelesstype{
	int size;
	string name;
	static bool isvalid(M)(){return true;}
	static string array_cat(size_t count, string s){
		static if(size==0){return 
			"ubyte["~(count/8).to!string~"] "~name~";"~endl ~ s;}
		else{ return 
			"ubyte["~(count*size).to!string~"] "~name~";"endl ~ s;}
	}
	static string get_cat(string x, string s){
		static if(size==0){return 
			"
}
template typelessdefinition(T){

}

unittest{
	struct vec2{ int x; int y;}
	typelesstype bar_=typelesstype_!vec2;
	alias foo =typelessdefinition!vec2;
	static foreach(bar;foo){
		bar.size.writeln;
	}
}

void main(){}
