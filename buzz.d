import mixins;

void main(){
	import std.stdio;
	pointyconstuctors!(["x","y","z"]).writeln;
}
/*					q"[this(ref mylitteral construct){]"~endl~
						q"[	grey.x=typeof(grey.x)();grey.x=&construct.x;]"~endl~
						q"[	grey.y=typeof(grey.y)();grey.y=&construct.y;]"~endl~
					q"[}]"~endl~
					q"[this(typeof(mylitteral.x)* x_,typeof(mylitteral.y)* y_){]"~endl~
						q"[	grey.x=typeof(grey.x)();grey.x=x_;]"~endl~
						q"[	grey.y=typeof(grey.y)();grey.y=y_;]"~endl~
					q"[}]"~endl~
					q"[this(typeof(grey.x) x_,typeof(grey.y) y_){]"~endl~
						q"[	grey.x=typeof(grey.x)();grey.x=x_;]"~endl~
						q"[	grey.y=typeof(grey.y)();grey.y=y_;]"~endl~
					q"[}]"~endl~*/
