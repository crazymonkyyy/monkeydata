struct mypointer(size_t size){
	import typeless;
	ubyte* point=null;
	static if(size==0){
		ubyte subbyte=null;
		
		struct bool_{
			import std.bitmanip;
			mixin(bitfields!(
				bool,"b0",1,
				bool,"b1",1,
				bool,"b2",1,
				bool,"b3",1,
				
				bool,"b4",1,
				bool,"b5",1,
				bool,"b6",1,
				bool,"b7",1,));
		}
	}
	void opUnary(string op:"++")(){
		point+=size;
		static if(size==0){
			if (subbyte == 7) {point++; subbyte=0;}
			else {subbyte++;}
		}
	}
	void opUnary(string op:"--")(){
		point-=size;
		static if(size==0){
			if (subbyte == 0) {point--; subbyte=7;}
			else {subbyte--;}
		}
	}
	void opBinary(string op:"+")(int a){
		point+= size*a;
		static if(size==0){
			static assert(false,"probaly right but not yet tested");
			subbyte+=a;
			point+=subbyte/8;
			subbyte= subbyte%8;
	}}
	void opAssign(T)(T* a){
		static assert(mysizeof!T >= size,"You are attempting to assign a sized pointer to a smaller datatype");
		point=cast(ubyte*) a;
	}
	void opAssign(mypointer!size a){
		point = a.point;
		static if(size==0){
			subbyte = a.subbyte;}
	}
	void set(T)(ref T foo){
		static assert(mysizeof!T <= size,"You are attempting to set data not nessery allocated with void arrays");
		static if(mysizeof!T==0){
			static if(size !=0){enum subbyte=0;}//grabing a bool from a a different data type should do something, even if its a bit wonky
			import std.conv;
			string c(string s,int x){
				return s~"case "~x.to!string~": (cast(bool_*)point).b"~x.to!string~" =foo; break;";}
			switch(subbyte){
				mixin( c(c(c(c( c(c(c(c("",0),1),2),3),4),5),6),7)
					~"default: assert(false);");}
		}
		else{
			//pragma(msg,"set:"~ T.stringof);
			*(cast(T*)point)=foo;
			//import std.stdio;
			//foo.writeln;
			//(cast(T)*point).writeln;
		}
	}
	T get(T)(){
		static assert(mysizeof!T <= size,"You are attempting to get data not nessery allocated with void arrays");
		static if(mysizeof!T==0){
			static if(size!=0){enum subbyte=0;}
			import std.conv;
			string c(string s,int x){
				return s~"case "~x.to!string~": return (cast(bool_*)point).b"~x.to!string~"; break;";}
			switch(subbyte){
				mixin( c(c(c(c( c(c(c(c("",0),1),2),3),4),5),6),7)
					~"default: assert(false);");}
		}
		else{
			return *cast(T*)(point);}
	}
	int opCmp(ref mypointer a){
		import opoverloadulti;
		static if(size==0){
			static assert(false,"not tested");
			if(point.opcmp(a.point)==0){
				return subbyte.opcmp(a.subbype);}
			else{
				return point.opcmp(a.point);}
		} else {
			return point.opcmp(a.point);}
	}
	bool opEquals(ref mypointer a){
		import opoverloadulti;
		return this.opequal(a);
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
		static if(size==0){ return mypointer!(0)(&(array.ptr[i/8]),i%8);}
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


