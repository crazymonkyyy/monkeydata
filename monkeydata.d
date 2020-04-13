mixin template monkeydata(mtypes...){
	import monkeytyping;
	import typeless;
	
	mixin template pointy_(string name,typeless_[] elems){
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
						q"[	alias T=vec2;]"~endl~
						q"[	static if(!issubtype!(T,U)){]"~endl~
						q"[		pragma(msg,"warn: "~U.stringof~" is not a subtype of "~T.stringof);}]"~endl~
					q"[}]"
						
	)));}
	
	mixin template pointy(string name,S,int[] subtypes){
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
					q"[vec2pointy tovec2pointy(){]"~endl~
						q"[	return vec2pointy(grey.x,grey.y);}]"~endl~
					q"[vec2 tovec2(){]"~endl~
						q"[	return grey.get!vec2;}]"~endl,
					
					
					q"[this(ref mylitteral construct){]"~endl~
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
					q"[}]"~endl~
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
						"return vec2pointy("~comma_list(
							elems.make_strings!("name"))~");"),
					"size_t opDollar(){ return n-1;}"
	)));}
	
	mixin template soaslice(string name){
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
							q"[		int* x;]"~endl~
							q"[		int* y;]"~endl~
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
	mixin pointy_!(bar.stringof,foo);
	mixin pointy!(bar.stringof,bar,[0]);
	mixin soa_!(bar.stringof,foo);
	mixin soaslice!(bar.stringof);
	mixin aosoaslice!(bar.stringof);
	mixin aosoa!(bar.stringof);
}

unittest{
	struct vec2{int x;int y;}
	mixin monkeydata!vec2;
	}/*
	{
		vec2 foo=vec2(1,2);
		vec2pointy_ bar;
		bar=foo;
		bar.set(vec2(3,4));
		assert(bar.x.get!int==3);
		assert(bar.get!vec2 ==vec2(3,4));
	}
	{
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
	{
		vec2 bar= vec2(1,2);
		vec2pointy foo=bar;
		assert(foo.tovec2==bar);
	}
	{
		vec2 bar= vec2(1,2);
		vec2pointy foo= vec2pointy(&bar.x,&bar.y);
		assert(foo.tovec2==bar);
	}
	{
		vec2 bar= vec2(1,2);
		vec2pointy foo= vec2pointy(&bar.x,&bar.y);
		foo= vec2(3,4);
		//bar.writeln;
		//foo.grey.x.get!int.writeln;
		//foo.grey.y.get!int.writeln;
		assert(bar==vec2(3,4));
	}
}
unittest{
	struct vec2{int x;int y;}
	mixin monkeydata!vec2;
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
		struct vec2{int x;int y;}
	mixin monkeydata!vec2;
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
		struct vec2{int x;int y;}
	mixin monkeydata!vec2;
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
	{
		vec2soa_!(100) foo;
	auto bar=foo[0];
	bar++;
	assert(bar==foo[1]);
	assert(foo[1]>foo[0]);
	assert(foo[0]<foo[1]);
	assert(! (foo[1]<foo[0]));
	assert(! (foo[0]>foo[1]));
	}
}
*/

