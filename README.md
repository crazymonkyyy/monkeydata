## Monkeydata

A "aosoa" template to try and make this data-oriented design primitive comfy to work with and not a bunch of manual work like it would be in c or the clusterfuck of boilerplate that is unity ecs. 

### Intended use

```d
import monkeydata;
struct vec2{
	int x;
	int y;
}
struct vec3{
	int x;
	int y;
	int z;
}
monkeydata!(vec2,vec3);//creates 6 structs for each data type passed
aosoavec3 data;
data[$..100];//create 100 vec3's
data[42]=vec2(1,2); // assign 1 and 2 to x,y
data[0..1000].simdmap!(foo,bar) //create 900 new vec3's running foo on the first 512 vec3`s(the full soa), and bar on the 488 seperately
data[500..600].lazymap!bar //run bar on 100 vec3's

struct strangevec2{
	int y; int z;
	opBinary!"+"(){}
}
data[269]+=strangevec2(3,4);//cast/swizzle into a strangevec2 runs + of strangevec2, copy the result back
data[269].tovec2;
```

### notes

* only compiles in ldc
* requires a -J=.
* not feature complete and I'm taking a break from this rabbit hole