using org.sugar.Async;
import org.sugar.Async;
class AsyncDemo {
	public static function main(){
		var a = new Async<Int>();
		var b = new Async<Int>();
		var c = new Async<Int>();
		var v1 = foo.wait(a);
		var v2 = foo2.wait2(b,v1);
		var v3 = foo3.wait3(b,v1,c);
	
		a.yield(1);
		b.yield(2);
		c.yield(3);
	}
	public static function foo(x:Int){
		trace(x);
		return x+1;
	}
	
	public static function foo2(x:Int, y:Int){
		trace(x+y);
		return x+y;
	}

	public static function foo3(x:Int, y:Int,z:Int){
		trace(x+y+z);
		return x+y+z;
	}
	
	
}