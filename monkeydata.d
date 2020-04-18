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
			static foreach(i; subtypes){
				import std.conv;
				enum elems=make_strings!("name")(typelessdefinations!(definitions!(mtypes[i])));
				output~=convertor!(mtypes[i].stringof,to!string(i),elems);
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
	
	alias bar=mtypes[0];
	enum typeless_[] foo=[typelessdefinations!(definitions!(bar))];
	enum string[] fizz=make_strings!"name"(foo);
	mixin pointy_!(bar.stringof,foo,bar);
	mixin pointy!(bar.stringof,bar,fizz,[0]);
	mixin soa_!(bar.stringof,foo);
	mixin soaslice!(bar.stringof,definitions!bar);
	mixin aosoaslice!(bar.stringof);
	mixin aosoa!(bar.stringof);
}
