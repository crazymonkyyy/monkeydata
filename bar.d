import std.traits;
import typeless;
import std.conv;

struct hour{
	size_t h;}
struct min{
	size_t m;
	void opUnary(string op:"++")(){
		m++;}
	int opCmp(min a){return cast(int)m-cast(int)a.m;}
}
struct time{
	hour h;
	min m;
	void opUnary(string op:"++")(){
		m.m++;
		if(m.m>59){m.m-=60;h.h++;}
	}
	int opCmp(time a){
		return cast(int)(h.h*60+m.m)-cast(int)(a.h.h*60+a.m.m);}
}
struct timerange_{
	time start;
	time end;
	bool opEquals(time a){
		return (start <= a) && (end >= a);}
}
timerange_ t(size_t a,size_t b,size_t c,size_t d){
	return timerange_(time(hour(a),min(b)),time(hour(c),min(d)));}

string magicconcat(string s){return "timerange_ " ~ s;}
string blackmagicconcat(string s){ return "case enumlist."~s~": return "~s~"; break";}
string litteralnercomancy(string s){
	return "if (foo == (*sch)[T.enumlist."~s~"])"~
		"{return T.enumlist."~s~";}";}
string whitemagic(string s){
	return "functions."~s~"(a);";}

struct timerange(T){
	import std.typecons;
	time start;
	time end;
	T* sch;
	Nullable!minrange lasthead;
	this(time start_,time end_,T* sch_){
		start=start_;
		end=end_;
		sch=sch_;
		lasthead.nullify;
	}
	struct minrange{
		immutable hour h;
		min start;
		min end;
		immutable T.enumlist classifiedas;
		//ulong length(){return end.m - start.m;}
		time front(){return time(h,start);}
		void popFront(){start++;}
		bool empty(){return start > end;}
		//string toString(){return "hi";}
		string toString(){
			return classifiedas.to!string~"    "~h.to!string~": "
					~start.to!string~","~end.to!string;}
	}
	static T.enumlist classify(time foo){
		alias strings=TemplateArgsOf!T;
		static foreach(hello; 
				strings.make_strings!("litteralnercomancy","import bar;")){
					mixin(hello);}
		assert(false);
	}
	timerange_ declassify(T.enumlist foo){
		return (*sch)[foo];}
	min segment(){
		time natspilt =time(start.h,
				start.h.h<end.h.h ? min(59) : end.m);
		if(classify(start) == classify(natspilt)){
			return natspilt.m;}
		else{ return declassify(classify(start)).end.m;}
	}
	minrange front(){
		if(lasthead.isNull){
			lasthead = minrange(start.h,start.m,segment(),classify(start));}
		return lasthead.get;
	}
	//minrange forcefront(){return minrange(start.h,start.m,segment());}
	void popFront(){
		start.m.m=lasthead.get.end.m;
		start++;
		lasthead.nullify;
	}
	bool empty(){return start > end;}
	
	
	static void iterate(alias functions)(){
		//enum string[] enums=TemplateArgsOf!U;//TemplateArgsOf!(TemplateArgsOf!(typeof(a)));
		//static assert(enums[0]=="work");
		/*void patternmatch(typeof(a).minrange b){
			final switch(b.classifiedas){
				mixin(enums.case_list!("whitemagic.endl_cat.curly_wrap","import bar;"));}}
		*/
		alias enumlist_= T.enumlist;
		void patternmatch(minrange b){
			final switch(b.classifiedas){
				case enumlist_.work: functions.work(b);break;
				case enumlist_.freetime: functions.freetime(b);break;
				case enumlist_.sleep: functions.sleep(b);break;
			}
		}
		
		this.each!patternmatch;
	}
}

struct schedule(string[] periods){
	mixin("enum enumlist "~periods.comma_list.curly_wrap);
	mixin(periods.make_strings!("magicconcat", "import bar;").endl_list);
	timerange_ opIndex(enumlist foo){
		mixin("final switch (foo)"~
				periods.make_strings!("blackmagicconcat", "import bar;")
						.endl_list.curly_wrap);}
	timerange!(typeof(this)) opSlice(time a,time b){
		return timerange!(typeof(this))(a,b,&this);}
	alias innerrange= timerange!(typeof(this)).minrange;
}



import std.algorithm;
import std.stdio;
unittest{
	alias sch = schedule!(["work","freetime","sleep"]);
	sch foo=sch(t(0,0,8,0),t(8,0,16,0),t(16,0,24,00));
	foo[time(hour(0),min(1))..time(hour(0),min(15))].each!(each!writeln);
}
unittest{
	alias sch = schedule!(["work","freetime","sleep"]);
	sch foo=sch(t(0,0,8,0),t(8,0,16,0),t(16,0,24,00));
	auto bar =foo[time(hour(0),min(0))..time(hour(24),min(0))];
	bar.each!writeln;
	"-----".writeln;
	foo.work=t(0,0,12,0);
	auto foobar =foo[time(hour(0),min(0))..time(hour(24),min(0))];
	foobar.each!writeln;
}
void each_(alias f,T)(T a){
	start:if (a.empty){}
	else{f(a.front);goto start;}
}

unittest{
	"----".writeln;
	alias sch = schedule!(["work","freetime","sleep"]);
	sch foo=sch(t(0,0,8,0),t(8,0,16,0),t(16,0,24,00));

	void volitaryovertime(time a){
		if(a==time(hour(7),min(44))){"hi boss".writeln;}
		if(a==time(hour(7),min(45)))
			{foo.work=t(0,0,12,0); "boss: hey work more".writeln;}
		if(a==time(hour(11),min(45))){
			"zzzzz".writeln;}
	}
	void work_(sch.innerrange a){
		a.each!volitaryovertime;}

	template actions(){
		alias work=work_;
		alias freetime=writeln;
		alias sleep=writeln;
	}
	//alias work_=actions!().work;
	//work_(foo[time(hour(0),min(0))..time(hour(24),min(0))].front);
	foo[time(hour(0),min(0))..time(hour(24),min(0))].iterate!(actions!());
	//iterate(foo[time(hour(0),min(0))..time(hour(24),min(0))]);
	//foo[time(hour(0),min(0))..time(hour(24),min(0))].each!(each!volitaryovertime);
}
void main(){}
