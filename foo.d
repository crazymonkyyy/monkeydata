import std.stdio;
struct bar{
	int i;
	struct dollar{
		int j;
		this(int i){j=i;}
		int opCall(){return j;}
	}
	int opSlice(){return i;}
	int opSlice(size_t i,size_t j){return cast(int)(i-j);}
	int opSlice(dollar i,size_t j){return i()-cast(int)j;}
	int opSlice(size_t i,dollar j){return cast(int)i-j();}
	dollar opDollar(){return dollar(1);}
}
unittest{
	bar hi;
	assert(hi[$..0]==1);
	assert(hi[1..$]==0);
}
unittest{
	struct i{
		int i_;
		int opBinary(string op:"+")(i b){
			return i_+ b.i_;}
		void opAssign(int a){
			i_=a;}
	}
	i foo;
	i bar;
	auto foobar= bar +foo;
	bar+=foo;
}
void main(string[] args){}

