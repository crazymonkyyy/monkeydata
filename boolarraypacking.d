struct boolpointer{
	ubyte* p;
	ubyte x;
	struct bool_{
		import std.bitmanip;
		mixin(bitfields!(
			bool,"b1",1,
			bool,"b2",1,
			bool,"b3",1,
			bool,"b4",1,
			
			bool,"b5",1,
			bool,"b6",1,
			bool,"b7",1,
			bool,"b8",1));
	}
	bool opUnary(string op:"*")(){
		import std.conv;
		string c(string s,int x){
			return s~"case "~x.to!string~": return (cast(bool_*)p).b"~x.to!string~"; break;";}
		switch(x){
			mixin( c(c(c(c( c(c(c(c("",1),2),3),4),5),6),7),8)
				~"default: assert(false);");}
	}
	void set(bool b_){
		import std.conv;
		string c(string s,int x){
			return s~"case "~x.to!string~": (cast(bool_*)p).b"~x.to!string~" =b_; break;";}
		switch(x){
			mixin( c(c(c(c( c(c(c(c("",1),2),3),4),5),6),7),8)
				~"default: assert(false);");}
	}
}
struct boolarray(int count){
	static if(((count/8)*8)==count){enum count_=count/8;}
		else {enum count_=count/8+1;}
	ubyte[count_] ubytearray;
	bool opIndex(size_t i){
		return *boolpointer(&ubytearray[i/8],i%8+1);}
	void opIndexAssign(bool value,size_t i){
		boolpointer(&ubytearray[i/8],i%8+1).set(value);}
}

unittest{
	boolarray!100 foo;
	foo[1]=true;
	assert(foo[1]==true);
	assert(foo[0]==false);
	assert(foo[2]==false);
}
void main(){}

/* a packed bool array that has "ref bool opIndex" can not exist given
 * the current spec. I feel this a gross over sight and is why everything
 * else will be defining get and set operators seperatly.
 * I believe dlang should update lvalue rules to have a on-ramp; any on-ramp
 * 
 * either a magic std function that takes a "modify" delagate and an rvalue
 * or allowing an @lvalue on a struct if the operators are exhaustively defined 
 * 
 * 08.January.2020 -monkyyy
 */
