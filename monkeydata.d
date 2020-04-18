mixin template monkeydata(mtypes...){
	import monkeytyping;
	import typeless;
	
	mixin template pointy_(string name,typeless_[] elems,S){
		mixin(
			struct_construct(name~"pointy_",
				linebreak_list(
					import_list("voiddata","monkeytyping"),
					elems.make_strings!("mypointer","import mixins;").endl_list,
					q{void opUnary(string op:"++")()}~curly_wrap(
						elems.make_strings!("plusplus","import mixins;").endl_list),
					q{void opUnary(string op:"--")()}~curly_wrap(
						elems.make_strings!("minusminus","import mixins;").endl_list),
					q{void opBinary(string op:"+")(int a)}~curly_wrap(
						elems.make_strings!("name.cat(q{+a})").endl_list),
					q"[void opAssign(T)(ref T a){]"~endl~
						q"[	static foreach(t; definitions!T){]"~endl~
						q"[		mixin(t.name~" = &a."~t.name~";");}}]",
					q{int opCmp(ref typeof(this) a)}~curly_wrap(
						"return "~elems[0].name~".opCmp(a."~elems[0].name~");"),
						/* I'm choosing to make opcmp work on a single pointer
						 * this _shouldnt_ matter, but something I should keep
						 * in mind*/
					q"[bool opEquals(ref typeof(this) a){]"~endl~
						q"[	import opoverloadulti;]"~endl~
						q"[	return this.opequal(a);}]",
					q"[void set(T)(T setter){]"~endl~
						q"[	warn!T;]"~endl~
						q"[	static foreach(t; definitions!T){]"~endl~
						q"[		mixin(t.name~".set!(t.T)(setter."~t.name~");");}]"~
					q"[}]",
					q"[T get(T)(){]"~endl~
						q"[	warn!T;]"~endl~
						q"[	T foo=void;]"~endl~
						q"[	static foreach(t; definitions!T){]"~endl~
						q"[		mixin("foo."~t.name~" = "~t.name~".get!(t.T);");}]"~endl~
						q"[	return foo;]"~endl~
					q"[}]",
					q"[void warn(U)(){]"~endl~
						q"[	alias T=S;]"~endl~
						q"[	static if(!issubtype!(T,U)){]"~endl~
						q"[		pragma(msg,"warn: "~U.stringof~" is not a subtype of "~T.stringof);}]"~endl~
					q"[}]"
						
	)));}
	
	mixin template pointy(string name,S,string[] elems,int[] subtypes){
		import mixins;
		import typeless;
		import monkeytyping;
		static string convertor(string name,string i,string[] elems)(){
			enum foo="	"~name~"pointy to"~name~"pointy()"~curly_wrap(
				"		return "~name~"pointy"~paren_wrap(
							elems.make_strings!("reverse_cat(q{grey.})").comma_list).endl_cat);
			enum bar="mtypes["~i~"] to"~name~"()"~curly_wrap("	return grey.get!(mtypes["~i~"]);"~endl);
			return foo~bar;
		}
		static string convertors(int[] subtypes)(){
			string output="";
			static foreach(i; subtypes){
				import std.conv;
				enum elems=make_strings!("name")(typelessdefinations!(definitions!(mtypes[i])));
				output~=convertor!(mtypes[i].stringof,to!string(i),elems);
			}
			return output;
		}
		mixin(
			struct_construct(name~"pointy",
				linebreak_list(
					import_list("std.traits","monkeytyping"),
					"enum ispointy=true;",
					"alias tolitteral=to"~name~";",
					"alias mylitteral=S;",
					name~"pointy_ grey;",
					q"[auto ref opBinary(string op,T)(auto ref T a) if (hasMember!(T,"ispointy")){]"~endl~
						q"[	return operation!op(tolitteral,a.tolitteral);]"~endl~
					q"[}]"~endl~
					q"[auto ref opBinary(string op,T)(auto ref T a) if (!hasMember!(T,"ispointy")){]"~endl~
						q"[	return operation!op(tolitteral, a);]"~endl~
					q"[}]"~endl~
					q"[ref typeof(this) opAssign(T)(T a) if (hasMember!(T,"ispointy")){]"~endl~
						q"[	this = a.tolitteral;]"~endl~
						q"[	return this;]"~endl~
					q"[}]"~endl~
					q"[ref typeof(this) opAssign(T)(T a) if (!hasMember!(T,"ispointy")){]"~endl~
						q"[	static if(issubtype!(mylitteral,T)){]"~endl~
						q"[	static foreach(foo;definitions!T){]"~endl~
							q"[		mixin("grey."~foo.name,".set(a.",foo.name,");");}]"~endl~
						q"[	} else {]"~endl~
						q"[	static assert(issubtype!(T,mylitteral),"These types airnt compadible");]"~endl~
						q"[	static foreach(foo;definitions!mylitteral){]"~endl~
							q"[		mixin("grey."~foo.name,".set(a.",foo.name,");");}}]"~endl~
						q"[	return this;]"~endl~
					q"[}]"~endl~
					q"[ref typeof(this) opOpAssign(string op,T)(auto ref T a){]"~endl~
						q"[	mixin("this = this ",op," a;");]"~endl~
						q"[	return this;]"~endl~
					q"[}]"~endl~
					q"[ref typeof(this) opUnary(string op:"++")(){]"~endl~
						q"[	grey++;return this;}]"~endl~
					q"[ref typeof(this) opUnary(string op:"--")(){]"~endl~
						q"[	grey--;return this;}]"~endl~
					q"[void movepointer(int x){]"~endl~
						q"[	grey + x;}]"~endl~
					q"[int opCmp(typeof(this) a){]"~endl~
						q"[	return grey.opCmp(a.grey);}]"~endl~
					q"[bool opEquals(typeof(this) a){]"~endl~
						q"[	import opoverloadulti;]"~endl~
						q"[	return this.opequal(a);]"~endl~
					q"[}]"~endl,
					//todo convertions
					convertors!subtypes(),
					pointyconstuctors!elems,
					q"[void setpointers(T)(ref T litteral){]"~endl~
						q"[	static assert(issubtype!(mylitteral,T));]"~endl~
						q"[	static foreach(def; definitions!T){]"~endl~
							q"[		mixin("grey."~def.name~" =&litteral."~def.name~";");]"~endl~
					q"[}}]"~endl~
					q"[void copypointers(T)(ref T pointy){]"~endl~
						q"[	static assert(is(typeof(T.ispointy)));]"~endl~
						q"[	static assert(issubtype!(mylitteral,T.mylitteral));]"~endl~
						q"[	static foreach(def;definitions!(T.mylitteral)){]"~endl~
							q"[		mixin("grey."~def.name~" = pointy.grey."~def.name~";");]"~endl~
					q"[}}]"~endl

	)));}
	
	mixin template soa_(string name,typeless_[] elems){
		mixin(
			struct_construct(name~"soa_(size_t n=512)",
				linebreak_list(
					"import voiddata;",
					elems.make_strings!("myarray","import mixins;").endl_list,
					name~"pointy opIndex(size_t i)"~curly_wrap(
						"return "~name~"pointy("~comma_list(
							elems.make_strings!("name.cat(q{[i]})"))~");"),
					"size_t opDollar(){ return n-1;}"
	)));}
	
	mixin template soaslice(string name,defs...){
		mixin(
			struct_construct(name~"soaslice(size_t soa=512)",
				linebreak_list(
					"alias mypointy="~name~"pointy;",
					"alias mysoa="~name~"soa_!soa;",
					q"[size_t start__;]"~endl~
					q"[mypointy start;]"~endl~
					q"[size_t end__;]"~endl~
					q"[mypointy end;]"~endl~
					q"[mysoa* mychunk;]"~endl~
					q"[mypointy front(){return start;}]"~endl~
					q"[void popFront(){start++;}]"~endl~
					q"[bool empty(){return start > end;}]"~endl~
					q"[void opAssign(typeof(this) a){]"~endl~
						q"[	start__=a.start__;]"~endl~
						q"[	end__=a.end__;]"~endl~
						q"[	start.copypointers(a.start);]"~endl~
						q"[	end.copypointers(a.end);]"~endl~
						q"[	mychunk=a.mychunk;]"~endl~
					q"[}]"~endl~
					q"[bool isfull(){return (end__-start__==soa-1);}]"~endl~
					q"[auto simdcast(){]"~endl~
						q"[	assert(isfull);]"~endl~
						q"[	struct simdfriendly{]"~endl~
							q"[		static foreach(d;defs){]"~endl~
								q"[			mixin( "d.T* "~d.name~";");}]"~endl~
						q"[	}]"~endl~
						q"[	static assert(simdfriendly.sizeof==typeof(start.grey).sizeof);]"~endl~
						q"[	return cast(simdfriendly)(start.grey);]"~endl~
					q"[}]"~endl
	)));}

	mixin template aosoaslice(string name){
		mixin(
			struct_construct(name~"aosoaslice(bool expanding,size_t soa=512)",
				linebreak_list(
					"alias myaosoa="~name~"aosoa!soa;",
					"alias mysoaslice="~name~"soaslice!soa;",
					q"[myaosoa* parent;]"~endl~
					q"[size_t start;]"~endl~
					q"[static if(expanding){]"~endl~
						q"[	size_t end(){return(*parent).count-1;}}]"~endl~
					q"[else{]"~endl~
						q"[	size_t end;}]"~endl~
					q"[import lazynullable;]"~endl~
					q"[nullable!(mysoaslice) lasthead;]"~endl~
					q"[size_t segment(){]"~endl~
						q"[	size_t natspilt= (start/soa+1)*soa-1;]"~endl~
						q"[	import std.algorithm;]"~endl~
						q"[	return min(natspilt,end);]"~endl~
					q"[}]"~endl~
					q"[mysoaslice front(){]"~endl~
						q"[	if(lasthead.isnull){]"~endl~
							q"[		auto seg=segment;]"~endl~
							q"[		auto chunk= &(*parent).chunks[(start+1)/soa];]"~endl~
							q"[		lasthead=mysoaslice(]"~endl~
								q"[			start,(*parent)[start],]"~endl~
								q"[			seg,(*parent)[seg],]"~endl~
								q"[			chunk);]"~endl~
						q"[	}]"~endl~
						q"[	return lasthead;]"~endl~
					q"[}]"~endl~
					q"[void popFront(){]"~endl~
						q"[	start=lasthead.end__;]"~endl~
						q"[	start++;]"~endl~
						q"[	lasthead.isnull=true;]"~endl~
					q"[}]"~endl~
					q"[bool empty(){ return start>end || (*parent).count ==0;}]"~endl
	)));}
	mixin template aosoa(string name){
		mixin(
			struct_construct(name~"aosoa(size_t soa=512)",
				linebreak_list(
					"alias mypointy="~name~"pointy;",
					"alias myslice="~name~"aosoaslice;",
					"alias mychunk="~name~"soa_!soa;",
					q"[mychunk[] chunks;]"~endl~
					q"[size_t count;]"~endl~
					q"[struct dollar{}]"~endl~
					q"[dollar opDollar(){return dollar();}]"~endl~
					q"[mypointy opIndex(size_t i){]"~endl~
						q"[	assert(i<count,"accessing random data is frowned on, use [0..i] ]"~endl~
						q"[	if you intended to create i`th T, or [$..i] if you intended]"~endl~
						q"[	to make i elements");]"~endl~
						q"[	return (chunks[i/soa])[i%soa];]"~endl~
					q"[}]"~endl~
					q"[mypointy opIndex(dollar i){return this[count-1];}]"~endl~
					q"[myslice!(true,soa) opSlice(){return this[0..$];}]"~endl~
					q"[myslice!(false,soa) opSlice(size_t i,size_t j){]"~endl~
						q"[	return myslice!(false,soa)(&this,i,j);]"~endl~
					q"[}]"~endl~
					q"[myslice!(true,soa) opSlice(size_t i,dollar j){]"~endl~
						q"[	return myslice!(true,soa)(&this,i);]"~endl~
					q"[}]"~endl~
					q"[myslice!(false,soa) opSlice(dollar i,size_t j){]"~endl~
						q"[	auto c=count;]"~endl~
						q"[	expand(count+j);]"~endl~
						q"[	return this[c..count-1];]"~endl~
					q"[}]"~endl~
					q"[void expand(size_t i){]"~endl~
						q"[	if(i>count){]"~endl~
							q"[		if(i > chunks.length*soa){ chunks.length= (i/soa)+1;}]"~endl~
							q"[		count=i;]"~endl~
						q"[	}]"~endl~
					q"[}]"~endl~
					q"[void remove(size_t i){]"~endl~
						q"[	this[i]=this[$];]"~endl~
						q"[	count--;]"~endl~
					q"[}]"~endl~
					q"[alias opSlice this;]" //`
	)));}
	
	alias bar=mtypes[0];
	enum typeless_[] foo=[typelessdefinations!(definitions!(bar))];
	enum string[] fizz=make_strings!"name"(foo);
	mixin pointy_!(bar.stringof,foo,bar);
	mixin pointy!(bar.stringof,bar,fizz,[0]);
	mixin soa_!(bar.stringof,foo);
	mixin soaslice!(bar.stringof,definitions!bar);
	mixin aosoaslice!(bar.stringof);
	mixin aosoa!(bar.stringof);
}


struct vec2{int x;int y;}

struct vec3{int x;int y;int z;}
mixin monkeydata!vec2;

import std.stdio;
unittest{
	vec2 foo=vec2(1,2);
	vec2pointy_ bar;
	bar=foo;
	bar.set(vec2(3,4));
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

unittest{
	vec2soa_!(100) foo;
	auto bar=foo[0];
	bar++;
	assert(bar==foo[1]);
	assert(foo[1]>foo[0]);
	assert(foo[0]<foo[1]);
	assert(! (foo[1]<foo[0]));
	assert(! (foo[0]>foo[1]));
}

unittest{
	vec2soaslice!() foo;
	foo.popFront;
	assert(foo.empty);
}

unittest{
	vec2aosoa!() foo;
	assert(foo.count==0);
	assert(foo[].start==0);
	assert(foo[].empty);
	assert(foo.chunks.length==0);
	foo[$..100];
	assert(foo.count==100);
	assert(foo.chunks.length==1);
	foo[$..500];
	assert(foo.count==600);
	assert(foo.chunks.length==2);
	int bar;
	struct x_{int x;}
	void foobar_(T)(T a){bar++;}
	void foobar(T)(T a){a=x_(bar);bar++;}
	import std.algorithm;
	foreach(f;foo){foobar_(f);}
	assert(bar==2);
	bar=0;
	foreach(f;foo){foreach(b;f){foobar(b);}}
	assert(bar==600);
	assert(foo[366].tovec2==vec2(366,0));
	assert(foo[512].tovec2==vec2(512,0));
	foo[512].tovec2.writeln;
	struct y_{int y;}
	foreach(f;foo[$..1234]){foreach(b;f){b=vec2(0,5);}}
	assert(foo.count==1834);
	assert(foo[599].tovec2==vec2(599,0));
	assert(foo[600].tovec2==vec2(0,5));
	foo[0]=x_(1000);
	
	void simdtest(T)(T soa){
		int[2]* x=cast(int[2]*)(soa.x);
		int[2]* y=cast(int[2]*)(soa.y);
		for(int i=0;i<256;i++){
			int[2] xx=*x;
			int[2] yy=*y;
			asm{
				movq XMM0, yy;
				movq XMM1, xx;
				paddd XMM0,XMM1;
				movq yy, XMM0;
			}
			*x=xx;
			*y=yy;
			x++;
			y++;
		}
	}
	foreach(fizz; foo[]){
		if(fizz.end__-fizz.start__==511){
			simdtest(fizz.simdcast);
		} else {
			foreach(a;fizz){
				a=y_(a.tovec2.x+a.tovec2.y);
	}}}
	
	foreach(f;foo[]){foreach(b;f){
		//b.tovec2.writeln;
		if (b.tovec2.x>0){assert(b.tovec2.x==b.tovec2.y);}
		else{assert(b.tovec2==vec2(0,5));}
	}}
	
	assert(foo.count==1834);
	foo.remove(123);
	assert(foo[123].tovec2==vec2(0,5));
	assert(foo.count==1833);
}

