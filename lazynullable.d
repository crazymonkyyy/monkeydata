struct nullable(T){
	T payload;
	bool isnull=true;
	void opAssign(T foo){
		payload=foo; isnull=false;}
	alias payload this;
}
unittest{
	import std.stdio;
	nullable!int[20] foo;
	foo[0]=0;
	foo[1]=1;
	foo[2]=2;
	foo[3]=3;
	int count=0;
	for(int i=0;!foo[i].isnull;i++){
		count+=foo[i];
		foo[i].isnull=true;
		i.writeln;
	}
	count.writeln;
	for(int i=0;!foo[i].isnull;i++){
		count+=foo[i];
		foo[i].isnull=true;
		i.writeln;
	}
}
void main(){}

/* std.nullable added an entier second to my compile time and vomited
 * 1000s of lines into my mix file, quite frankly no. The syntax is bad
 * and even this lazy replacement fits my needs better.
 *
 * something proper should overload assign to test for null, and the
 * alias this should be a lamda that asserts null if false then return 
 * payload or something along those lines.
 */
