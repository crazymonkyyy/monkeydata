import monkeydata;
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
