import std.algorithm;
struct hour{
	size_t h;}
struct minute{
	size_t m;
	void opUnary(string op:"++")(){m++;}
	int opCmp(minute a){
		return cast(int)m-cast(int)a.m;}
}
struct time{
	hour h;
	minute m;
	void opUnary(string op:"++")(){
		m.m++;
		if(m.m>59){m.m-=60;h.h++;}
	}
	int opCmp(time a){
		return cast(int)(h.h*60+m.m)-cast(int)(a.h.h*60+a.m.m);}
	time end(){return time(h,minute(59));}
}
struct timerange(T){
	import lazynullable;
	import std.typecons : isTuple;
	struct minrange{
		/*immutable*/ T.classification classification;
		/*immutable*/ hour h;
		minute start;
		minute end;
		time front(){return time(h,start);}
		void popFront(){start++;}
		bool empty(){return start > end;}
		
		string toString(){
			import std.conv;
			return classification.to!string~"    "~h.to!string~":"~
					start.to!string~"-"~end.to!string;
		}
	}
	time start;
	time end;
	T* sch;
	nullable!minrange lasthead;
	auto segmentandclassify(time a){
		struct result{
			T.classification classification;
			minute segment;
		}
		auto foo=(*sch)[a];
		return result(foo.enum_,min(foo.end,a.end).m);
	}
	minrange front(){
		if(lasthead.isnull){
			auto foo=segmentandclassify(start);
			lasthead=minrange(
					foo.classification,start.h,start.m,foo.segment);
		}
		return lasthead;
	}
	void popFront(){
		start.m=lasthead.end;
		start++;
		lasthead.isnull=true;
	}
	bool empty(){return start>end;}
	void iterate(U)(U actions) if (isTuple!U){
		void patternmatch(minrange a){
			exit:final switch(a.classification){
				static foreach(s;T.periods__){
					mixin("case T.classification."~s~":"~
						"actions."~s~"(a); break exit;");}}}
		this.each!patternmatch;
	}
}

struct namedtime{
	string name;
	time time_;
}

struct schedule(string[] periods){
	import typeless;
	enum string[] periods__=periods;
	mixin("enum classification "~periods.comma_list.curly_wrap);
	alias minrange=timerange!(typeof(this)).minrange;
	struct classifiedtime{
		classification enum_;
		time end;
		alias end this;
	}
	classifiedtime[] times;
	ref classifiedtime opIndex(time a){
		assert(times[0..$].isSorted);
		return times[0..$].filter!(b=> b>a).front;
	}
	classification opIndex(string a){
		final switch(a){
			static foreach(s;periods){
				case s: return mixin("classification."~s);}}}
	void add(namedtime a){
		times~=classifiedtime(opIndex(a.name),a.time_);
		times[0..$].sort;
	}
	this(namedtime[] a...){
		foreach(b;a){ add(b);}
	}
	timerange!(typeof(this)) opSlice(time a,time b){
		return timerange!(typeof(this))(a,b,&this);}
	auto opSlice(){
		return opSlice(time(hour(0)),time(hour(23),minute(59)));}
}

import std.stdio;
unittest{
	auto foo=schedule!(["work","free","sleep"])(
			namedtime("work",time(hour(8))),
			namedtime("free",time(hour(16))),
			namedtime("sleep",time(hour(24))));
	foo.each!writeln;
}
unittest{
	"----".writeln;
	auto foo=schedule!(["work","free","sleep"])(
		namedtime("work",time(hour(8))),
		namedtime("free",time(hour(16))),
		namedtime("sleep",time(hour(24))));
	void volitaryovertime(time a){
		if(a==time(hour(7),minute(44))){"hi boss".writeln;}
		if(a==time(hour(7),minute(45)))
			{foo.add(namedtime("work",time(hour(12)))); "boss: hey work more".writeln;}
		if(a==time(hour(11),minute(45))){
			"zzzzz".writeln;}
	}
	foo.each!(each!volitaryovertime);
	foo.each!writeln;
}
unittest{
	"----".writeln;
	"----".writeln;
	"----".writeln;
	auto foo=schedule!(["work","free","sleep"])(
		namedtime("work",time(hour(8))),
		namedtime("free",time(hour(16))),
		namedtime("sleep",time(hour(24))));
	void volitaryovertime(time a){
		if(a==time(hour(7),minute(44))){"hi boss".writeln;}
		if(a==time(hour(7),minute(45)))
			{foo.add(namedtime("work",time(hour(12)))); "boss: hey work more".writeln;}
		if(a==time(hour(11),minute(45))){
			"zzzzz".writeln;}
	}
	alias mr=typeof(foo).minrange;
	import std.typecons;
	auto bar= tuple!("work","free","sleep")(
		(mr a)=>a.each!volitaryovertime,
		(mr a)=>writeln(a),
		(mr a)=>writeln(a) );
	foo[].iterate(bar);
}
void main(){}
