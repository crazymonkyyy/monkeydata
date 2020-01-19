struct mypointer(size_t size){ 
	ubyte* point;
	static if(size==0){
		ubyte subbyte;
		
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
		
	}
	void opUnary(string op:"++")(){
		point+=size;
		static if(size==0){
			if (subbyte == 8) {point++; subbyte=1;}
			else {subbyte++;}
		}
	}
	void opUnary(string op:"--")(){
		point-=size;
		static if(size==0){
			if (subbyte == 1) {point--; subbyte=8;}
			else {subbyte--;}
		}
	}
	void set(T)(T foo){
		
		static if(size==0){
			import std.conv;
			string c(string s,int x){
				return s~"case "~x.to!string~": (cast(bool_*)point).b"~x.to!string~" =foo; break;";}
			switch(subbyte){
				mixin( c(c(c(c( c(c(c(c("",1),2),3),4),5),6),7),8)
					~"default: assert(false);");}
		}
		else{
			static assert(T.sizeof == size);
			*cast(T*)point=foo;
		}
	}
	T get(T)(){
		static if(size==0){
			import std.conv;
			string c(string s,int x){
				return s~"case "~x.to!string~": return (cast(bool_*)point).b"~x.to!string~"; break;";}
			switch(subbyte){
				mixin( c(c(c(c( c(c(c(c("",1),2),3),4),5),6),7),8)
					~"default: assert(false);");}
		}
		else{
			return *cast(T*)(cast(void*)point);}
	}
}

struct voidarray(size_t size, size_t count){ 
	static if(size==0){
		static if(((count/8)*8)==count){enum count_=count/8;}
		else {enum count_=count/8+1;}
		ubyte[count_] array;
	}
	else {ubyte[count*size] array;}
	mypointer!size opIndex(size_t i){
		static if(size==0){ return mypointer!(0)(&(array.ptr[i/8]),i%8+1);}
		else {return mypointer!(size)(&(array.ptr[i*size]));}
	}
}

//------------

mixin template toy(T, string foo_, string bar_){
	unittest{
		import std.stdio;
		import std.random;
		import std.conv;
		enum N= 1000;//uniform(100,1000);
		bool[N] bools;
		mixin("T foo=T("~foo_~");");
		mixin("T bar=T("~bar_~");");
		static if(is(T==bool)){enum size_=0;}
		else {enum size_ = T.sizeof;}
		voidarray!(size_,N) array;
		for(int i=0; i<N/2; i++){
			bools[uniform(0,N)]=true;}
		writeln("starting unittest for ",T.stringof," with values: ",foo.to!string
				,", ",bar.to!string,". An array count of ", N.to!string,", T size of ",
				T.sizeof.to!string," lazy math says: ",(N*T.sizeof).to!string,
				" actaul is: ", typeof(array).sizeof.to!string
		);
		int errors;
		void assert_(T a, T b){
			if(a!=b){errors+=1;writeln("        ",a.to!string,"!=",b.to!string);}}
		
		for(int i=0; i<N; i++){
			if (bools[i]){array[i].set(foo);}
			else{array[i].set(bar);}
		}
		for({mypointer!(size_) i= array[0]; int j=0;} i!=array[N]; i++, j++) { 
			if(bools[j]){assert_(i.get!T, foo);}
			else{ assert_(i.get!T,bar);}
		}
		writeln("    test one, write by array, read by pointers loop: ", errors.to!string," errors");
		for({mypointer!(size_) i = array[0]; bool j;} i!=array[N]; i++, j=!j) {
			if(j){i.set(foo);}
			else{i.set(bar);}
		}
		for({int i=0; bool j;} i<N; i++,j=!j){
			if(j){assert_(array[i].get!T,foo);}
			else{assert_(array[i].get!T,bar);}
		}
		writeln("    test two, write by pointer, read by array loop: ", errors.to!string, " errors");
		
		mypointer!size_ even(){
			int i= uniform(20,N-4);
			auto p=array[i];
			if(i%2==1){p++;}
			return p;
		}
		mypointer!size_ odd(){
			auto p=even;
			++p;
			return p;
		}
		mypointer!size_ small(){
			return array[uniform(0,10)];}
		
		static if(__traits(compiles,array[0].set(even.get!T+even.get!T))){
			{
				T foobar=cast(T)(foo+foo);
				for(int i=0; i<2000;i++){
					auto x=small;
					x.set(cast(T)(odd.get!T+odd.get!T));
					assert_(x.get!T,foobar);
				}
				writeln("    test:",foo_,"+",foo_,"=",foobar," : ", errors.to!string, " errors");
			}
			{
				T foobar= cast(T)(foo+bar);
				for(int i=0; i<2000;i++){
					auto x=small;
					x.set(cast(T)(odd.get!T+even.get!T));
					assert_(x.get!T,foobar);
				}
				writeln("    test:",foo_,"+",bar_,"=",foobar," : ", errors.to!string, " errors");
			}
			{
				T foobar= cast(T)(bar+foo);
				for(int i=0; i<2000;i++){
					auto x=small;
					x.set(cast(T)(even.get!T+odd.get!T));
					assert_(x.get!T,foobar);
				}
				writeln("    test:",bar_,"+",foo_,"=",foobar," : ", errors.to!string, " errors");
			}
			{
				T foobar= cast(T)(bar+bar);
				for(int i=0; i<2000;i++){
					auto x=small;
					x.set(cast(T)(even.get!T+even.get!T));
					assert_(x.get!T,foobar);
				}
				writeln("    test:",bar_,"+",bar_,"=",foobar," : ", errors.to!string, " errors");
			}
		}
		else{ writeln("    ADDITION TESTS DIDNT RUN: ",T.stringof);}
}}

mixin toy!(int,"1","2");
mixin toy!(bool,"true","false");
mixin toy!(float,"1.23","4.20");

mixin toy!(double,"1.234567","4.206969");

union intfloat{
	int i;
	float f;
}
mixin toy!(intfloat,"1","2");
struct myint{
	int i;
}
mixin toy!(myint,"1","2");
struct myints{
	int[20] i;
	this(int foo){i[0]=foo;}
}
mixin toy!(myints,"1","2");

struct mybrokenint{
	int i;
	mybrokenint opBinary(string op:"+")(mybrokenint foo){
		return mybrokenint(i-foo.i);}
}
mixin toy!(mybrokenint,"1","2");

union fint{
	float f;
	int i;
	this(int foo){i=foo*100;}
	this(float foo){f=foo;}
	fint opBinary(string op:"+")(fint foo){
		return fint(i+foo.f);}
	string toString(){
		import std.conv;
		return "("~i.to!string~","~f.to!string~") ";
}}
mixin toy!(fint,"1","4.20");

struct strangeint{
	union foo{
		int i;
		mybrokenint b;
	}
	foo int_;
	bool flag;
	this(bool f_,int i_){
		flag =f_; int_ =foo(i_);
	}
	strangeint opBinary(string op:"+")(strangeint bar){
		int acc;
		if(flag){acc = int(int_.i+bar.int_.i);}
			else{acc= (int_.b + bar.int_.b).i;}
		return strangeint(flag == bar.flag,acc);
	}
	string toString(){
		import std.conv;
		return int_.i.to!string;
	}
}
mixin toy!(strangeint,"true,4","false,7");
//mixin toy!(short,"100","200");// -__-" all setters will need a cast to T
void main(){}


