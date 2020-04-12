auto mypointer(T)(T a){
	return "mypointer!"~a.size~" "~a.name;}
auto plusplus(T)(T a){
	return "++"~a.name;}
auto minusminus(T)(T a){
	return "--"~a.name;}
