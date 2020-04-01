struct foo{
	struct dollar{}
	dollar opDollar(){return dollar();}
	int opIndex(int i){return i;}
	int opIndex(dollar d){return 100;}
	int opSlice(int i, int j){return j-i;}
	int opSlice(dollar i,int j){return j-100;}
	int opSlice(int i,dollar j){return 100-i;}
}
unittest{
	foo bar;
	assert(bar[$]==100);
	assert(bar[1..2]==1);
	assert(bar[50..$]==50);
	assert(bar[$..200]==100);
}
