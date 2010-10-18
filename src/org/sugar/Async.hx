package org.sugar;
using org.sugar.Async;
class Async<T>{
	private var val:T;
	private var set:Bool;
	private var _update:Array<T->Bool->Dynamic>;


	public function new(){
		set = false;
		_update = new Array<T->Bool->Dynamic>();
	}

	public function yield(val:T){
		set = true;
		this.val = val;
		
		for (f in _update)  cast(f)(this.val, null);
		
	}
	
	public function addWait(f:T->Dynamic){
		var f2 = function(x:T, ?ret_func:Bool){
			if (ret_func  == true) return f;
			return f(x);
		}
		_update.push(f2);
	}
	
	private function addUpdate(f:T->Bool->Dynamic){
		_update.push(f);
	}
	
	public function removeWait(f:Dynamic): Bool{
		var new_update = new Array<T->Bool->Dynamic>();
		var found = false;
		for (idx in 0..._update.length){
			var rev_idx =_update.length-idx-1;
			var original_f = cast(_update[rev_idx])(null, true);
			if (!found && Reflect.compareMethods(original_f,f)){
				found = true;
				continue;
			}
			new_update.push(_update[rev_idx]);
		}
		new_update.reverse();
		_update = new_update;
		return found;
	}
	
	public function clearUpdate(){
		_update = new Array<T->Bool->Dynamic>();
	}
	
	
	private static function allSet(as:Array<Async<Dynamic>>): Bool{
		for (a in as) if (!a.set) return false;
		return true; 
	}

	public static function wait<A,B>( f:A->B, arg1:Async<A> ) : Async<B> {
		var ret = new Async<B>();
		var yieldf = function(x:Dynamic,?ret_func:Bool) :Dynamic {
			if(ret_func != null) return f;
			ret.yield(f(x));
			return true;
		}		
		if (arg1.set) yieldf(arg1.val);
		else arg1.addUpdate(yieldf);
		
		return ret;
	}


	public static function wait2<A,B,C>( f:A->B->C, arg1:Async<A>, arg2:Async<B> ) : Async<C> {
		var ret = new Async<C>();
		var yieldf = function(x:Dynamic,?ret_func:Bool) : Dynamic {
			if(ret_func != null) return f;
			if (allSet(cast [arg1,arg2])) {
				ret.yield(f(arg1.val, arg2.val));
				return true;
			} else return false;
			};
		var all_set = yieldf(null);
		if (!all_set) for (x in [arg1, arg2]) x.addUpdate(cast yieldf);
		return ret;
	}

	public static function wait3<A,B,C,D>( f:A->B->C->D, arg1:Async<A>, arg2:Async<B>, arg3:Async<C>) : Async<D> {
		var ret = new Async<D>();
		var yieldf = function(x:Dynamic) {
			if (allSet(cast [arg1,arg2,arg3])) {
				ret.yield(f(arg1.val, arg2.val, arg3.val));
				return true;
			} else return false;
			};
		var all_set = yieldf(null);
		if (!all_set) for (x in [arg1, arg2, arg3]) x.addUpdate(yieldf);
		return ret;		
	}

	public static function wait4<A,B,C,D,E>( f:A->B->C->D->E, arg1:Async<A>, arg2:Async<B>, arg3:Async<C>, arg4:Async<D>) : Async<E> {
		var ret = new Async<E>();
		var yieldf = function(x:Dynamic) {
			if (allSet(cast [arg1,arg2,arg3,arg4])) {
				ret.yield(f(arg1.val, arg2.val, arg3.val, arg4.val));
				return true;
			} else return false;
			};
		var all_set = yieldf(null);
		if (!all_set) for (x in [arg1, arg2, arg3, arg4]) x.addUpdate(yieldf);
		return ret;
	}
	
	public static function wait5<A,B,C,D,E,F>( f:A->B->C->D->E->F, arg1:Async<A>, arg2:Async<B>, arg3:Async<C>, arg4:Async<D>, arg5:Async<E>) : Async<F> {
		var ret = new Async<F>();
		var yieldf = function(x:Dynamic) {
			if (allSet(cast [arg1,arg2,arg3,arg4,arg5])) {
				ret.yield(f(arg1.val, arg2.val, arg3.val, arg4.val, arg5.val));
				return true;
			} else return false;
			};
		var all_set = yieldf(null);
		if (!all_set) for (x in [arg1, arg2, arg3, arg4, arg5]) x.addUpdate(yieldf);
		return ret;
	}
	
	public static function wait6<A,B,C,D,E,F,G>( f:A->B->C->D->E->F->G, arg1:Async<A>, arg2:Async<B>, arg3:Async<C>, arg4:Async<D>, arg5:Async<E>, arg6:Async<F>) : Async<G> {
		var ret = new Async<G>();
		var yieldf = function(x:Dynamic) {
			if (allSet(cast [arg1,arg2,arg3,arg4,arg5, arg6])) {
				ret.yield(f(arg1.val, arg2.val, arg3.val, arg4.val, arg5.val, arg6.val));
				return true;
			} else return false;
			};
		var all_set = yieldf(null);
		if (!all_set) for (x in [arg1, arg2, arg3, arg4, arg5, arg6]) x.addUpdate(yieldf);
		return ret;
	}
	
	public static function toAsync<T>(val:T) : Async<T>{
		var ret = new Async<T>();
		ret.yield(val);
		return ret;
	}
}