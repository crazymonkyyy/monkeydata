import std.stdio;
import std.traits;

unittest{
	struct foo1{
		int i;
	}
	struct foo2{
		float f;
	}
	struct bar(T){
		T.one i;
		T.two f;
		T* well_then;
		this(T* wellthen){well_then =wellthen;}
	}
	struct foo3{
		alias one=foo1;
		alias two=foo2;
		bar!foo3 hi;
		this(int i){ hi=bar!foo3(&this);}
	}
	foo3 foobar= foo3(1);
	foobar.hi.i.i=1;
	foobar.hi.f.f=4.20;
	//static assert(is(foo3.hi.i.i == int));
	//static assert(is(foo3.hi.f.f == float));
}
unittest{
	struct foo{
		struct bar{
			int i;}
		bar opIndex(int j){ return bar(j);}
	}
	auto foobar=foo()[1];
	assert(foobar.i==1);
}

unittest{
	struct foo{}
	struct bar{}
	
	int foobar(T)(int a, int b){
		int c=1;
		static if(is(T==bar)){goto hi;}
			if(false){hi:c=10;}
		return a*b*c;
	}
	foobar!foo(1,2);
	assert(foobar!bar(3,4)==120);
}
unittest{
	int delegate(int)[3] foo;
	int add1(int x){return x+1;}
	foo[0]=&add1;
	foo[0](1).writeln;
}
unittest{
	class foo{
		abstract void toslice();
	}
	struct bar(T){
		foo front(){return new T();}
	}
	class foobar : foo{
		override void toslice(){"hi".writeln;}
	}
	auto hi=bar!foobar();
	hi.front.toslice;
}
unittest{
	import std.typecons;
	alias foo=Tuple!(int,int);
	auto bar= foo(1,2);
	foo delegate(foo) foobar= (foo)=> bar;
}


void main(string[] args){}

