using org.sugar.Async;
import  org.sugar.Async;
/*import flash.events.MouseEvent;
import flash.events.Event;*/
class AsyncDemo2 {
	static var localX = new Async<Float>();
	static var localY = new Async<Float>();
	static var localFoo = new Async<Float>();
	public static function main(){
/*		flash.Lib.current.stage.addEventListener(MouseEvent.CLICK,clickListener);*/
		doX.wait(localX);
		doY.wait(localY);
		
		var t = new haxe.Timer(5000);
		t.run = foo;
		var k = new flash.utils.SetIntervalTimer();
	
		localX.yield(1);
		
		trace('hi');	
		
	}

	
	public static function doX(x:Float){

		trace("x: " + Std.string(x)); 
		localY.yield(x); 
	}
	
	public static function doY(y:Float){
		trace("y: " + Std.string(y)); 
		localX.yield(y);
	}
	
	public static function doXY(x:Float, y:Float ){
		trace("x+ ' ' + y: " + Std.string(x+ ' ' + y)); 
	}
	
	
	public static function foo(){
		trace('yielding');
		localX.yield(1);
	}
	
}