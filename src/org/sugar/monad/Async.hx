package org.sugar.monad;
using org.sugar.monad.Async;
class Async<T>{
	private var _val:T;
	private var _update:Array<T->Dynamic>;
	private var _set:Bool;
	public function new(){
		_set = false;
		_update = new Array<T->Dynamic>();
	}
	

	
	public function yield(val:T){
		_set = true;

	}

	public static function wait<A,B>( f:A->B, arg1:Async<A> ) : Async<B> {
		var ret = new Async<B>();
		if (arg1._set) ret.yield(f(arg1._val));
		else { 
			var mf = asyncReturn(f);
			arg1.bind(mf,ret);
		} 
		return ret;
	}
	
	private static function asyncReturn<A,B>(f:A->B):A->Async<B>{
		return function(x:A){
			var ret = new Async<B>();
			ret.yield(f(x));
			return ret;
		}
	}
	
	public static function bind<A,B>(a1:Async<A>, f:A->Async<B>, a2:Async<B>) : Async<B>{
 		var chain = function(x:A){ a2.yield(f(x)._val);}

		return a2;
	}
	
	
	public static function toAsync<T>(val:T) : Async<T>{
		var ret = new Async<T>();
		ret.yield(val);
		return ret;
	}
}