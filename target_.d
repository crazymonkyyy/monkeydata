struct vec2{
	int x;
	int y;
}
//static assert(is(vec2.x==int));
static assert(is(typeof(vec2.x)==int));
struct vec3{
	int x;
	int y;
	int z;
}

//------------

//mixin monkeydata!(monkeytypes: vec3,vec2)

struct vec2pointy_{
	import voidarray;
	import monkeytyping;
	mypointer!4 x;
	mypointer!4 y;
	void opUnaray(string op:"++")(){
		++x;
		++y;
	}
	void opUnarry(string op:"--")(){
		--x;
		--y;
	}
	void opBinary(string op:"+")(int a){
		x+a;
		y+a;
	}
	void opAssign(T)(ref T a){
		static foreach(t; definitions!T){
			mixin(t.name~" = &a."~t.name~";");}}
	
	void set(T)(T setter){
		warn!T;
		//x.set!(T.x)(setter.x);
		static foreach(t; definitions!T){
			mixin(t.name~".set!(t.T)(setter."~t.name~");");}
	}
	T get(T)(){
		warn!T;
		T foo=void;
		//foo.x=x.get!T.x;
		static foreach(t; definitions!T){
			mixin("foo."~t.name~" = "~t.name~".get!(t.T);");}
		return foo;
	}
	void warn(U)(){
		alias T=vec2;
		static if(!issubtype!(T,U)){
			pragma(msg,"warn: "~U.stringof~" is not a subtype of "~T.stringof);}}
}

unittest{
	vec2 foo=vec2(1,2);
	vec2pointy_ bar;
	bar=foo;
	bar.set(vec2(3,4));
	/*import std.stdio;
	writeln(foo.x);
	writeln(foo.y);
	writeln(bar.get!vec2);
	writeln(bar.x.get!int);
	writeln(bar.y.get!int);*/
	assert(bar.x.get!int==3);
	assert(bar.get!vec2 ==vec2(3,4));
}
unittest{
	vec2 foo=vec2(1,2);
	vec2pointy_ bar;
	bar=foo;
	struct x_{int x;}
	bar.set(x_(3));
	assert(bar.get!vec2 == vec2(3,2));
	struct y_{float y;}
	import std.stdio;
	writeln(bar.get!y_);
}

struct vec2pointy{
	import std.traits;
	import monkeytyping;
	enum ispointy=true;
	alias tolitteral=tovec2;
	alias mylitteral=vec2;
	vec2pointy_ grey;
	
	auto ref opBinary(string op,T)(auto ref T a) if (hasMember(T,"ispointy")){
		return operation!op(tolitteral,a.tolitteral);
	}
	auto ref opBinary(string op)(auto ref T a) if (!hasMember(T,"ispointy")){
		return operation!op(tolitteral, a);
	}
	ref typeof(this) opAssign(T)(T a) if (hasMember(T,"ispointy")){
		this = a.tolitteral;
	}
	ref typeof(this) opAssign(T)(T a) if (!hasMember(T,"ispointy")){
		static if(issubtype!(mylitteral,T)){
			static foreach(foo;definitions!T){
				mixin(foo.name,"= a.",foo.name,";");}
		} else { static assert(issubtype!(T,mylitteral),"These types airnt compadible");
			static foreach(foo;definitions!mylitteral){
				mixin(foo.name,"= a.",foo.name,";");
	}}}
	ref typeof(this) opOpAssign(T)(auto ref T a){
		mixin("this = this",op,"a;");
		return this;
	}
	ref typeof(this) opUnarry(string op:"++")(){
		++grey;}
	ref typeof(this) opUnarry(string op:"--")(){
		--grey;}
	void movepointer(int x){
		grey + x;}
	
	vec2pointy tovec2pointy(){// my subtype system returns duplicates so I'm rolling with it
		return vec2pointy(grey.x,grey.y);}
	vec2 tovec2(){
		return grey.get!vec2;}
	
	this(ref vec2 construct){
		grey.x=typeof(grey.x)();grey.x=&construct.x;
		grey.y=typeof(grey.y)();grey.y=&construct.y;
	}
	this(typeof(vec2.x)* x_,typeof(vec2.y)* y_){
		grey.x=typeof(grey.x)();grey.x=x_;
		grey.y=typeof(grey.y)();grey.y=y_;
	}
	this(typeof(grey.x) x_,typeof(grey.y) y_){
		grey.x=x_;
		grey.y=y_;
	}
	void setpointers(T)(T litteral){
		static assert(issubtype!(vec2,T));
		static foreach(def; definitions!T){
			mixin("grey."~def.name~" =&litteral."~def.name~";");
	}}
}

unittest{
	vec2 bar= vec2(1,2);
	vec2pointy foo=bar;
	assert(foo.tovec2==bar);
}
