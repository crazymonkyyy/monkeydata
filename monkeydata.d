mixin template monkeydata(mtypes...){
	import monkeytyping;
	import typeless;
	
	mixin template pointy(string name,typeless_[] elems){
		mixin(
			struct_construct(name~"pointy_",
				linebreak_list(
					import_list("voiddata","monkeytyping"),
					(make_strings!("mypointer","import mixins;")(elems)).endl_list,
					q{void opUnary(string op:"++")()}~curly_wrap(
						(make_strings!("plusplus","import mixins;")(elems)).endl_list),
					q{void opUnary(string op:"--")()}~curly_wrap(
						(make_strings!("minusminus","import mixins;")(elems)).endl_list),
					"//hello"
		)));}
	
	
	enum typeless_[] foo=[typelessdefinations!(definitions!(mtypes[0]))];
	mixin pointy!(mtypes[0].stringof,foo);
	mixin("//bye");
}

unittest{
	{
	struct vec2{int x;int y;}
	mixin("//bar");
	mixin monkeydata!vec2;
	mixin("//foo");
	vec2pointy_ foo;
	mixin("//foobar");
	{
		mixin("//scope change?");
	}
	}
	mixin("//scope exit?");
	//assert(false);
}
