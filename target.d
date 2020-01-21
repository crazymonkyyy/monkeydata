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
	void set(T)(T setter){
		valid!T;
		x.set!(T.x)(setter.x);
		y.set!(T.y)(setter.y);
	}
	T get(T)(){
		valid!T;
		return T(x.get!(T.x),y.get!(T.y));
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
