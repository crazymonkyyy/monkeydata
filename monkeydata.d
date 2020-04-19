mixin template monkeydata(mtypes...){
	import monkeytyping;
	import typeless;
	
	mixin template pointy_(string name,typeless_[] elems,S){
		mixin(struct_construct(name~"pointy_",
			linebreak_list(
				import("pointy_.mix"),
				elems.make_strings!("mypointer","import mixins;").endl_list,
				q{void opUnary(string op:"++")()}~curly_wrap(
					elems.make_strings!("plusplus","import mixins;").endl_list),
				q{void opUnary(string op:"--")()}~curly_wrap(
					elems.make_strings!("minusminus","import mixins;").endl_list),
				q{void opBinary(string op:"+")(int a)}~curly_wrap(
					elems.make_strings!("name.cat(q{+a})").endl_list)
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
			template elems(int i){
				enum elems=make_strings!("name")(typelessdefinations!(definitions!(mtypes[i])));}
			static foreach(i; subtypes){
				import std.conv;
				output~=convertor!(mtypes[i].stringof,to!string(i),elems!i);
			}
			return output;
		}
		mixin(struct_construct(name~"pointy",
			linebreak_list(
				import("pointy.mix"),
				"enum ispointy=true;",
				"alias tolitteral=to"~name~";",
				"alias mylitteral=S;",
				name~"pointy_ grey;",
				convertors!subtypes(),
				pointyconstuctors!elems
	)));}
	
	mixin template soa_(string name,typeless_[] elems){
		mixin(struct_construct(name~"soa_(size_t n=512)",
			linebreak_list(
				"import voiddata;",
				elems.make_strings!("myarray","import mixins;").endl_list,
				name~"pointy opIndex(size_t i)"~curly_wrap(
					"return "~name~"pointy("~comma_list(
						elems.make_strings!("name.cat(q{[i]})"))~");"),
				"size_t opDollar(){ return n-1;}"
	)));}
	
	mixin template soaslice(string name,defs...){
		mixin(struct_construct(name~"soaslice(size_t soa=512)",
			linebreak_list(
				import("soaslice.mix"),
				"alias mypointy="~name~"pointy;",
				"alias mysoa="~name~"soa_!soa;"
	)));}
	mixin template aosoaslice(string name){
		mixin(struct_construct(name~"aosoaslice(bool expanding,size_t soa=512)",
			linebreak_list(
				import("aosoaslice.mix"),
				"alias myaosoa="~name~"aosoa!soa;",
				"alias mysoaslice="~name~"soaslice!soa;"
	)));}
	mixin template aosoa(string name){
		mixin(struct_construct(name~"aosoa(size_t soa=512)",
			linebreak_list(
				import("aosoa.mix"),
				"alias mypointy="~name~"pointy;",
				"alias myslice="~name~"aosoaslice;",
				"alias mychunk="~name~"soa_!soa;"
	)));}
	mixin template everything(int i,T){
		alias formatmembers=definitions!T;// vec2 => [(int,x),(int,y)]
		enum typeless_[] typelessmembers=[typelessdefinations!formatmembers];// vec2 => [(4,"x"),(4,"y")]
		enum string[] membernames=make_strings!("name")(typelessmembers);// vec2 => ["x","y"]
		enum namelitteral=T.stringof; // vec2 => "vec2"
		
		import std.meta;
		template f(alias T){
			enum f=(T._1==i);}
		template g(alias T){
			alias g=T._2;}
		enum mysubtypes=staticMap!(g,Filter!(f,subtypelist!mtypes));
		
		mixin pointy_!(namelitteral,typelessmembers,T);
		mixin pointy!(namelitteral,T,membernames,[mysubtypes]);
		mixin soa_!(namelitteral,typelessmembers);
		mixin soaslice!(namelitteral,formatmembers);
		mixin aosoaslice!(namelitteral);
		mixin aosoa!(namelitteral);
	}
	static foreach(i,T;mtypes){
		mixin everything!(i,T);
	}
}
void simdmap(alias f,alias g,T)(T slice){
	if(slice.end__-slice.start__==511){
		f(slice.simdcast);}
	else{
		foreach(a;slice){
			g(a);}}
	unittest{
		pragma(msg,"note simdmap should run tests that f is"~ 
				"equalilent to g, and f is faster then g; but I'm very"~
				" tired of this project");
}}
void lazymap(alias f,T)(T slice){
	if(slice.end__-slice.start__==511){
		foreach(i;0..511){//maybe it will optimise?
			f(slice.front);
			slice.popFront;
		}
	}
	else{
		foreach(a;slice){
			f(a);}
	}
}
