import std.stdio;
import std.traits;
	struct foo{
		int x;
		enum y=true;
	}
	struct bar{
		int x;
	}
	void poke(T)(T a) if (T.y==true){}
	void poke(T)(T a) if (!hasMember!(T,"y")){}
	

unittest{
	foo foo_;
	bar bar_;
	poke(foo_);
	poke(bar_);
}
void main(string[] args){}

