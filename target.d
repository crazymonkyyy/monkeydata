struct vec2{
	int x;
	int y;
}
struct vec3{
	int x;
	int y;
	int z;
}

//------------

//mixin monkeydata!(monkeytypes: vec3,vec2)

struct vec2pointy_{
	import voidarrays;
	mypointer!4 x;
	mypointer!4 y;
	void opUnaray(string op:"++"){
		++x;
		++y;
	}
	void opUnarry(string op:"--"){
		--x;
		--y;
	}
	void set(T)(ref T setter){
		valid!T;
		x.set!(T.x)(setter.x);//assuming T is vec2, will need to mixin in a meta mixin here
		y.set!(T.y)(setter.y);
	}
	T get(T)(){
		valid!T;
		T foo=void;
		foo.x=x.get!T.x;
		foo.y=x.get!T.y;
		foo.z=z.get!t.z;
		return foo;
	}
	void valid(T)(){
		static assert(T.x.sizeof <= 4);
		static assert(T.y.sizeof <= 4);
	}
}

struct vec3pointy_{
	import voidarrays;
	mypointer!4 x;
	mypointer!4 y;
	mypointer!4 z;
	void opUnaray(string op:"++"){
		++x;
		++y;
		++z;
	}
	void opUnarry(string op:"--"){
		--x;
		--y;
		--z;
	}
	void set(T)(T setter){
		valid!T;
		x.set!(T.x)(setter.x);
		y.set!(T.y)(setter.y);
		z.set!(T.z)(setter.z);
	}
	T get(T)(){
		valid!T;
		return T(x.get!(T.x),y.get!(T.y),z.get!(T.z));
	}
	void valid(T)(){
		static assert(T.x.sizeof <= 4);
		static assert(T.y.sizeof <= 4);
		static assert(T.z.sizeof <= 4);
	}
}

struct vec2pointy{
	@property ispointy=true;
	vec2pointy_ grey;
	
	//mixin op_nonsense!1;
	
	auto opBinary(string op)(T a){
		
	
	vec2pointy tovec2pointy{// my subtype system returns duplicates so I'm rolling with it
		return vec2pointy(grey.x,grey.y);}
	vec2 tovec2{
		return grey!vec2;}
	
	this(ref vec2 construct){
		grey.x=&construct.x;
		grey.y=&construct,y;
	}
	this(vec2.x* x_,vec2.y* y_){
		grey.x=x_;
		grey.y=y_;
	}
	void setpointers(T)(T litteral){
		import monkeytyping;
		static assert(issubtype!(vec2,T));
		static foreach(def, definitions!T){
			//grey.x=&litteral.x;
			//grey.y=&litteral.y;
	}}
}

struct vec3pointy{
	vec3pointy_ grey;
	
	mixin op_nonsense!0;
	
	vec2pointy tovec2pointy(){
		return vec2pointy(grey.x,grey.y);}
	vec2 tovec2(){
		return grey.get!vec2;}
	vec3pointy tovec3pointy(){
		return vec3pointy(grey.x,grey.y,grey.z);}
	vec3 tovec3(){
		return grey.get!vec3;}
	
	this(vec3 construct){
		grey.x=&construct.x;
		grey.y=&construct,y;
		grey.z=&construct.z;
	}
	this(vec3.x* x_,vec3.y* y_,vec3.z z_){
		grey.x=x_;
		grey.y=y_;
		grey.z=z_;
	}
	void setpointers(){}
}

struct vec2slice{
	vec2pointy start;
	vec2pointy end;
	/*delagate defination I don't know how to write*/ end_;
	//start_ @future 
	vec2aosoa* parent;
	bool halt;
	
	vec2 head(){
		return *start;}
	vec2slice tail(){
		if(start==end){return end_();}
		else {vec2slice(++start,end,end_);}
	}
	//map(){};reduce(){};filter(){}etc;
}
struct vec3slice{}

struct vec2soa_(size_t n){
	import voidarray;
	voidarray!(4,n) x;
	voidarray!(4,n) y;
	vec2pointy_ opIndex(size_t i){
		return vec2pointy_(x[i],y[i]);
	}
	size_t opDollar(){ return n;}
}
struct vec3soa_(size_t n){
	import voidarray;
	voidarray!(4,n) x;
	voidarray!(4,n) y;
	voidarray!(4,n) z;
	vec2pointy_ opIndex(size_t i){
		return vec2pointy_(x[i],y[i],z[i]);
	}
	size_t opDollar(){ return n;}
}
struct vec2aosoa(size_t soa=512){
	vec2soa_!soa[] chunks;
	size_t count;
	struct dollar{}
	dollar opDollar(){return dollar;}
	vec2pointy opIndex(size_t i){
		assert(i<count,"accessing random data is frowned on, use [0..i] 
				if you intended to create i`th T, or [$..i] if you intended 
				to make i elements");
		return vec2pointy((chunks[i/soa])[i%soa]);
	}
	auto opIndex(dollar d){
		return [count-1];}
	vec2slice opSlice(){return [0..$];}
	vec2slice opSlice(size_t i, size_t j){
		assert(i<j,"no");
		size_t whichchunk=i/soa;
		size_t max=whichchunk*(soa+1)-1;
		bool isjthere=j<max;
		if (isjthere){
			return vec2slice([i],[j],
					(){assert(false,"your slice didnt halt");},true);}
		else{
			return vec2slice([i],[max],
					(){[max+1,j];},false);}
	}
	vec2slice opSlice(dollar i, size_t j){
		expand(count+soa);
		size_t whichchunk=count/soa;
		size_t max=whichchunk*(soa+1)-1;
		bool isjthere=j<max;
		if(isjthere){
			return vec2slice([count-1],[j],
					(){assert(false,"your slice didnt halt");},true);}
		else{
			return vec2slice([count-1],[max],
					(){expand();return [$..j-soa];},false);}
	}
	vec2slice opSlice(size_t i, dollar j){
		size_t whichchunk=i/soa;
		size_t max=whichchunk*(soa+1)-1;
		bool isjthere=(count-1)<max;
		if(isjthere){
			return vec2slice([i],[count-1],
					(){assert(false,"your slice didn't halt");},true);}
		else{
			return vec2slice([i],[max],
					(){expand(max+soa);return [max+1..$];},false);}
	}
	alias [] this;
}
