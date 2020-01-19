import std.meta;
import std.conv;

string endl='
';

static string curly_wrap(string s){
	return "{"~s~"}";}
static string bracket_wrap(string s){
	return "["~s~"]";}
static string paren_wrap(strind s){
	return "("~s~")";}
static string comma_cat(string s){
	return s~",";}
static string endl_cat(string s){
	return s~";"~endl;}
static string cast_wrap(string t,string s){
	return "cast("~t~")("~s~")";}
static string star_cat(string s){
	return s~"*";}
static string comma_list(string[] s){
	if(s.length==1) {return s[0];}
	else {return s[0].comma_cat~comma_list(s[1..$]);}
}
unittest{
	assert(comman_list(["1","2","3"])=="1,2,3")}



void main(){}
