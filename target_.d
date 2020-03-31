struct vec2{
	int x;
	int y;
}
struct vec3{
	int x;
	int y;
	int z;
}
import std.stdio;
//------------

//mixin monkeydata!(monkeytypes: vec3,vec2)

struct vec2pointy_{
	import voiddata;
	import monkeytyping;
	mypointer!4 x;
	mypointer!4 y;
	void opUnary(string op:"++")(){
		++x;
		++y;
	}
	void opUnary(string op:"--")(){
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
	
	auto ref opBinary(string op,T)(auto ref T a) if (hasMember!(T,"ispointy")){
		return operation!op(tolitteral,a.tolitteral);
	}
	auto ref opBinary(string op,T)(auto ref T a) if (!hasMember!(T,"ispointy")){
		return operation!op(tolitteral, a);
	}
	ref typeof(this) opAssign(T)(T a) if (hasMember!(T,"ispointy")){
		this = a.tolitteral;
	}
	ref typeof(this) opAssign(T)(T a) if (!hasMember!(T,"ispointy")){
		static if(issubtype!(mylitteral,T)){
			static foreach(foo;definitions!T){
				mixin("grey."~foo.name,".set(a.",foo.name,");//hello");}
		} else { 
			static assert(issubtype!(T,mylitteral),"These types airnt compadible");
			static foreach(foo;definitions!mylitteral){
				mixin("grey."~foo.name,".set(a.",foo.name,");");}}
		return this;
	}
	ref typeof(this) opOpAssign(string op,T)(auto ref T a){
		mixin("this = this ",op," a;");
		return this;
	}
	ref typeof(this) opUnary(string op:"++")(){
		grey++;return this;}
	ref typeof(this) opUnary(string op:"--")(){
		grey--;return this;}
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
		grey.x=typeof(grey.x)();grey.x=x_;
		grey.y=typeof(grey.y)();grey.y=y_;
	}
	void setpointers(T)(ref T litteral){
		static assert(issubtype!(mylitteral,T));
		static foreach(def; definitions!T){
			mixin("grey."~def.name~" =&litteral."~def.name~";");
	}}
}

unittest{
	vec2 bar= vec2(1,2);
	vec2pointy foo=bar;
	assert(foo.tovec2==bar);
}
unittest{
	vec2 bar= vec2(1,2);
	vec2pointy foo= vec2pointy(&bar.x,&bar.y);
	assert(foo.tovec2==bar);
}
unittest{
	vec2 bar= vec2(1,2);
	vec2pointy foo= vec2pointy(&bar.x,&bar.y);
	foo= vec2(3,4);
	//bar.writeln;
	//foo.grey.x.get!int.writeln;
	//foo.grey.y.get!int.writeln;
	assert(bar==vec2(3,4));
}
unittest{
	//"------".writeln;
	struct x_{int x;}
	struct y_{int y;}
	x_[10] xs;
	y_[10] ys;
	vec2pointy foo;
	vec2pointy bar;
	foo.setpointers(xs[3]);
	assert(cast(int*)foo.grey.x.point==&xs[3].x);
	foo.setpointers(ys[4]);
	//foo.tovec2.writeln;
	foo=x_(1);
	xs[3].x=1;
	//"firstwrite".writeln;
	//foo.grey.x.get!int.writeln;
	//foo.grey.y.get!int.writeln;
	foo=y_(2);
	ys[4].y=2;
	assert(xs[3].x==1);
	assert(ys[4].y==2);
	//foo.grey.x.get!int.writeln;
	//foo.grey.y.get!int.writeln;
	//foo.tovec2.writeln;
	assert(foo.tovec2==vec2(1,2));
}

unittest{
	//"------".writeln;
	struct x_{int x;}
	struct y_{int y;}
	x_[10] xs;
	y_[10] ys;
	vec2pointy foo;
	vec2pointy bar;
	foo.setpointers(xs[3]);
	foo.setpointers(ys[4]);
	foo = vec2(1,2);
	//foo.tovec2.writeln;
	//xs[3].x.writeln;
	assert(xs[3].x==1);
	//foo.tovec2.writeln;
	assert(foo.tovec2==vec2(1,2));
	bar.setpointers(xs[2]);
	bar.setpointers(ys[5]);
	bar = vec2(3,4);
	
	++foo;
	assert(foo.tovec2==vec2(0,4));
	--bar;
	assert(bar.tovec2==vec2(0,2));
}

unittest{
	//"------".writeln;
	struct x_{int x;}
	struct y_{int y;}
	x_[10] xs;
	y_[10] ys;
	vec2pointy foo;
	vec2pointy bar;
	foo.setpointers(xs[3]);
	foo.setpointers(ys[4]);
	foo = vec2(1,2);
	
	struct evilvec2{
		int x;
		int y;
		auto opBinary(string op:"*")(evilvec2 a){
			return evilvec2(x*a.y,y*a.x);}
	}
	foo *= evilvec2(3,4);
	assert(foo.tovec2 == vec2(4,6));
	foo *= evilvec2(100,10);
	assert(foo.tovec2 == vec2(40,600));
}

struct vec2soa_(size_t n=512){
	import voiddata;
	voidarray!(4,n) x;
	voidarray!(4,n) y;
	vec2pointy opIndex(size_t i){
		return vec2pointy(x[i],y[i]);
	}
	size_t opDollar(){ return n-1;}
}
unittest{
	vec2soa_!(100) foo;
	auto bar=foo[0];
	bar++;
	assert(bar==foo[1]);
	assert(foo[1]>foo[0]);
}


