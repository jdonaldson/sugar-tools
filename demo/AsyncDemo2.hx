using org.sugar.Async;
import  org.sugar.Async;
import flash.events.MouseEvent;
import flash.events.Event;
class AsyncDemo2 {
	static var localX = new Async<Float>();
	static var localY = new Async<Float>();
	static var localFoo = new Async<Float>();
	static var bar = new Async<MouseEvent>();
	public static function main(){
		flash.Lib.current.stage.addEventListener(MouseEvent.CLICK, bar.yield);
		bar1.wait(bar);
		trace("hi'");


	}

	
	
	public static function bar1(x:MouseEvent){
		trace(x);
		bar.removeWait(bar1);
	}
	
	
	public static function doX(x:Float){

		trace("x: " + Std.string(x)); 
		localY.yield(x); 
	}
	
	public static function doY(y:Float){
		trace("y: " + Std.string(y)); 
/*		localX.yield(y);*/
	}
	
	public static function doXY(x:Float, y:Float ){
		trace("x+ ' ' + y: " + Std.string(x+ ' ' + y)); 
	}
	
	
	public static function foo(){
		trace('yielding');
		localX.yield(1);
	}
	
}

