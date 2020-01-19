import std.stdio;

mixin template monkeydata(mtypes...){
	
	template definition(T){}
	//alias subtypelist =;
	
	struct typelesstype{
		string indentifer;
		int size;
		this(T)(){}
		string arraydef(int arraysize){}
		string pointerdef(){}
		void valid(){}
	}
	
}



















int main(string[] args){
	return 0;
}

