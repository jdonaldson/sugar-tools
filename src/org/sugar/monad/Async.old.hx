package org.sugar;
using org.sugar.Async;
#if (neko||cpp)
import Type;
#end

#if neko
	typedef Thread = neko.vm.Thread;
	typedef Mutex = neko.vm.Mutex;
#elseif cpp
	typedef Thread = cpp.vm.Thread;
	typedef Mutex = cpp.vm.Mutex;
#end

class Async<T> {
	private var _yields_to:List<Array<Dynamic>>;
	private static var async_id = 0;
#if (neko||cpp)
	private static var _thread_id = 0;
	private var _thread_status:IntHash<Bool>;
	private var _yielding:Bool;
	private var _yield_chain:List<T>;
#end

	public var val(default, null):T;
	public var set(default, null):Bool;
	public var id(default,null):Int;
	public function new(?val, set = false){
		this.val = val;
		this.set = set;
		this._yields_to = new List<Array<Dynamic>>();
		
		id = Async.async_id++;
#if (neko||cpp)
		_yielding = false;
		_yield_chain = new List<T>();
		_thread_status = new IntHash<Bool>();
#end
	}
	
	public function yield(val:T){
		set = true;
		for(f_av in _yields_to) {
			var f:T->Async<T> = f_av[0];
			var av:Async<Dynamic> = f_av[1];
			var result = f(val);
			trace("Async "+ id + " yielding to " + av.id);
			av.yield(f(val));
			
		}
	}
	


#if (neko||cpp)
	public function threadedYield(val:T){
		if (_yielding){ // already in the process of _yielding a different value.
			trace('Yielding is already in progress, adding to queue');
			_yield_chain.add(val); // add to the continuation
			return; 
		}
		set = true;
		_yielding = true;
		
		var val_mutex = new Mutex();
		var tval = Type.typeof(val); 
		if (tval == TFloat || tval == TInt || tval == TNull) val_mutex = null;
		for(fv in _yields_to) {
				var f = fv[0];
				var av = fv[1];
				var proxy_f = function(){
					var id = Thread.readMessage(true);
					trace("Thread " + id + " started");
					var val = Thread.readMessage(true);
					var f = Thread.readMessage(true);
					var av = Thread.readMessage(true);
					var main:Thread = Thread.readMessage(true);
					var mutex:Mutex = Thread.readMessage(true);
					if (mutex != null) mutex.acquire();
					av.threadedYield(f(val));
					if (mutex != null) mutex.release();
					main.sendMessage(id);
					trace("Thread " + id + " finished");
				}
				var th = Thread.create(proxy_f);
				var cur_id = Async._thread_id++;
				_thread_status.set(cur_id,false);
				th.sendMessage(cur_id);
				th.sendMessage(val);
				th.sendMessage(f);
				th.sendMessage(av);
				th.sendMessage(Thread.current());
				th.sendMessage(val_mutex);
		}
		_yielding = false;
		while (_yield_chain.length > 0){ // check for other yields that are waiting
			var next_val = _yield_chain.pop();
			trace('I found some extra yields that must be called');
			var ty_proxy = function(){
				var val = Thread.readMessage(true);
				var ty = Thread.readMessage(true);
				ty(val);
			}
			var t1 = Thread.create(ty_proxy);
			t1.sendMessage(next_val);
			t1.sendMessage(this.threadedYield); // continue the yields in a separate thread to prevent blocking.
		}
	

	}




	public function blockForThreads(){
		var finished = false;
		for (k in _thread_status.keys()) {
			var id = Thread.readMessage(true);
			_thread_status.set(id,true);
			trace("Thread " + id + " reported back");
			trace(_thread_status);
		}
	}

	
#end
	
	
	public static function both<A,B>(a:Async<A>, b:Async<B>):Async<Bool>{
		var av = new Async<Bool>();
		var f = function(val:B) return true;
		if (a.set && b.set) av.yield(true);
		else if (a.set)	b._yields_to.add([f,av]);
		else {
			var av2 = new Async<Bool>();
			av2._yields_to.add([f,av]);
			a._yields_to.add([f, av2]);
		}
		return av;
	}
	
	

	
	public static function wait<A,B>(f:A->B, arg:Async<A>):Async<B>{
		var av = new Async<B>();	
		if (arg.set) av.yield(f(arg.val));
		else arg._yields_to.add([f,av]);
		return av;
	}

	
	
	public static function wait2<A,B,C>(f:A->B->C, arg1:Async<A>, arg2:Async<B>):Async<C>{
		var av = new Async<C>();

		if (arg1.set) return wait(callback(f,arg1.val), arg2);
		else{
			var av2 = Async.both(arg1, arg2);
			var f = function(x:Bool){ 
				return f(arg1.val, arg2.val);}
			av2._yields_to.add([f, av]);
		}
							
		return av;
	}

	public static function wait3<A,B,C,D>(f:A->B->C->D, arg1:Async<A>, arg2:Async<B>, arg3:Async<C>):Async<D>{
		var av = new Async<D>();				
		var delay_f = function(val:A) wait2(callback(f,val),arg2,arg3);
		if (arg1.set) delay_f(arg1.val);
		else arg1._yields_to.add([delay_f, av]);
		return av;
	}
	
	public static function wait4<A,B,C,D,E>(f:A->B->C->D->E, arg1:Async<A>, arg2:Async<B>, arg3:Async<C>, arg4:Async<D>):Async<E>{
		var av = new Async<E>();				
		var delay_f = function(val:A) wait3(callback(f,val),arg2,arg3,arg4);
		if (arg1.set) delay_f(arg1.val);
		else arg1._yields_to.add([delay_f,av]);
		return av;
	}
	
	
	public static function asAsync<T>(val:T){
		return new Async(val,true);
	}
	
}




