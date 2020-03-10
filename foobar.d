struct vec2{
	int x;
	int y;
}
struct vec2slice{
	vec2* start;
	vec2* end;
	vec2* front(){return start;}
	void popFront(){start++;}
	bool empty(){ return start > end;}
}

struct vec2aos{
	import slice;
	vec2[] data;
	auto length(){
		struct len{
			vec2aos* parent;
			size_t getlength(){
				return (*parent).data.length;}
			void opAssign(string op:"+")(size_t a){
				*parent.data.length += a*10;}
			alias getlength this;
		}
		return len(&this);
	}
	vec2* opIndex(size_t x){
		return &data[x];}
	auto opSlice(size_t i,size_t j){
		
}

void main(){}
