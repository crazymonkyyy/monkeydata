import std.meta;
import std.traits;
import std.stdio;

template uglyzip(elems...){
	static if (elems.length==0){alias uglyzip = AliasSeq!();}
	static if (elems.length==1){ static assert(false);}
	static if (elems.length>1){ 
		alias uglyzip = AliasSeq!(Alias!(elems[0]),Alias!(elems[$-1]),uglyzip!(elems[1..$-1]));}
}

static assert(uglyzip!(AliasSeq!(1,2,3,4,5,6,7,8,9,10))==AliasSeq!(
		Alias!(1),Alias!(10),Alias!(2),Alias!(9),Alias!(3),
		Alias!(8),Alias!(4),Alias!(7),Alias!(5),Alias!(6)));
		
template definitions(T){
	template foo(T){ alias foo=AliasSeq!(__traits(derivedMembers,T));}
	template bar(T){ alias bar=AliasSeq!(typeof(T.tupleof));}
	unittest{
		struct point{int x; int y;}
		alias foo_ = foo!(point);
		static assert(foo_ == AliasSeq!("x","y"));
		alias bar_ = bar!(point);
		static assert(is(bar_==AliasSeq!(int,int)));
	}
	template zip(T){ alias zip = uglyzip!(bar!(T),Reverse!(foo!(T)));}
	unittest{
		struct vomit{int x; float y; bool z;}
		struct vomit_{bool x; float y; int z;}
		//static assert(zip!(vomit) == uglyzip!(foo!vomit_,bar!vomit_));
	}
	template cleanup(elems...){
		template def(T_,string name_){ 
			alias T= T_; alias name= name_;
		}
		static if(elems.length==0){alias cleanup = AliasSeq!();}
		static if(elems.length==1){static assert(false);}
		static if(elems.length>1){
			alias cleanup= AliasSeq!(def!(elems[0],elems[1]),cleanup!(elems[2..$]));}}
	unittest{
		alias foo=cleanup!(AliasSeq!(int,"x",float,"y",bool,"z"));
		static assert(foo[0].name=="x");
		static assert(foo[1].name=="y");
		static assert(foo[2].name=="z");
		static assert(is(foo[0].T==int));
		static assert(is(foo[1].T==float));
		static assert(is(foo[2].T==bool));
	}
	alias definitions= cleanup!(zip!(T));
}
unittest{
	struct vomit{int x; float y; bool z;}
	alias foo= definitions!(vomit);
	static assert(foo[0].name=="x");
	static assert(foo[1].name=="y");
	static assert(foo[2].name=="z");
	static assert(is(foo[0].T==int));
	static assert(is(foo[1].T==float));
	static assert(is(foo[2].T==bool));
}

template memberequal(alias T_,alias U_){
	enum memberequal = (T_.name==U_.name) && (T_.T.stringof == U_.T.stringof);}

unittest{
	struct foo{int x;}
	alias bar=definitions!foo;
	static assert(bar[0].name=="x");
	static assert(memberequal!(bar[0],bar[0]));
}

unittest{
	struct vomit{int x; int y; bool z;}
	alias foo= definitions!(vomit);
	struct chunks{int x; int y; bool a;}
	alias bar= definitions!(chunks);
	static assert(memberequal!(foo[0],bar[0]));
	static assert(memberequal!(foo[1],bar[1]));
	static assert(memberequal!(foo[0],foo[0]));
	static assert(memberequal!(bar[1],bar[1]));
	
	static assert( ! memberequal!(foo[2],bar[2]));
	static assert( ! memberequal!(foo[0],bar[2]));
	static assert( ! memberequal!(foo[1],bar[2]));
	static assert( ! memberequal!(foo[2],bar[0]));
	static assert( ! memberequal!(foo[2],bar[1]));
	
	static assert( ! memberequal!(foo[0],bar[1]));
	static assert( ! memberequal!(foo[1],bar[0]));
}

template issubtype(T,U){
	alias Tmemb= definitions!T;
	alias Umemb= definitions!U;
	template isTmemb(alias U_) { 
		template foo(alias bar){ alias foo = memberequal!(bar,U_);}
		alias isTmemb = anySatisfy!(foo,Tmemb);
	}
	alias issubtype= allSatisfy!(isTmemb,Umemb);
}

unittest{
	struct vec2{ int x; int y;}
	struct vec2f{ float x; float y;}
	struct vec3{ int x; int y; int z;}
	struct vec2_{int x; int y; bool flag;}
	static assert( issubtype!(vec3,vec2));
	static assert( issubtype!(vec2_,vec2));
	static assert( issubtype!(vec2,vec2));
	
	static assert( ! issubtype!(vec2,vec3));
	static assert( ! issubtype!(vec2,vec2_));
	static assert( ! issubtype!(vec3,vec2_));
	static assert( ! issubtype!(vec2_,vec3));
	
	static assert( ! issubtype!(vec2f,vec2));
	static assert( ! issubtype!(vec2,vec2f));
	static assert( ! issubtype!(vec3,vec2f));
	static assert( ! issubtype!(vec2_,vec2f));
}

template subtypelist(types...){
	template pair(int a, int b){
		alias _1=a; alias _2=b;}
	template pairgen(int n){
		template foo(int a, int n){
			static if(n<0){alias foo = AliasSeq!();}
				else {alias foo= AliasSeq!(pair!(a,n),foo!(a,n-1));}}
		template bar(int b, int n){
			static if(b<0){alias bar = AliasSeq!();}
				else {alias bar= AliasSeq!(foo!(b,n),bar!(b-1,n));}}
		alias pairgen = bar!(n,n);
	}
	template f(alias pair_){
		alias f=issubtype!( types[pair_._1], types[pair_._2] );}
	alias subtypelist = Filter!(f,pairgen!(types.length-1));
}

auto operation(string op,T,U)(auto ref T,auto ref U){
	static if(issubtype!(T,U)){
		
	}
	else{ static if(issubtype!(U,T)){
	
	}}
}

unittest{
	struct x_{int x;}
	struct y_{int y;}
	struct vec2{int x; int y;}
	struct vec3{int x; int y; int z;}
	struct vec2_{int y; int z;}
	alias list = subtypelist!(x_,y_,vec2,vec3,vec2_);
	static foreach(p;list){
		writeln(p._1.stringof~", "~p._2.stringof);}
}
	
void main(){
	writeln("hi");
}
