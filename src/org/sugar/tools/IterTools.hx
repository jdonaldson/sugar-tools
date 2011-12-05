/*
 * Copyright (c) 2009, The haXe Project Contributors
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE HAXE PROJECT CONTRIBUTORS "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE HAXE PROJECT CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 */

/**
	The utility Sugar classes provide additional Iterable manipulation routines
**/


/**
	The IterTools class adds additional common Iterator utility functions. Created 
	by Justin Donaldson (jdonaldson at gmail dot com).
**/
package org.sugar.tools;
import org.sugar.tools.ArrayTools; // for combinationIndex() function and IterableWithLength typedef
import haxe.PosInfos;


/**
The default behavior for the "Tools" classes is to typedef [ListType] as [List] by default. 
Here is the documentation for the <a href='alt/SugarList.html'>[SugarList]</a> class.
**/
#if sugarlist
import org.sugar.collections.SugarList;
typedef ListType<T> = SugarList<T> // we need this in IterTools so that it will be applied in HashTools and ListTools upon import
#else
typedef ListType<T> = List<T>
#end



class IterTools{

/**
	Takes an Iterator of Dynamics.  It is assumed the Dynamics are Iterables.  If they are not, they 
	are either excluded or coerced into an Iteratator by "nonIterableTransform", which defaults to repeat the 
	noniterable element once using repeat(element,1).
	The method iterates throught the first Iterator of the first Iterable until it is exhausted, and then 
	moves on to the next, etc. until all Iterators are exhausted. 
**/

	public static function chain(itr:Iterator<Dynamic>,?nonIterableTransform:Dynamic->Iterator<Dynamic>) : Iterator<Dynamic>{
		if (nonIterableTransform == null) nonIterableTransform = function(x) return repeat(x,1);
		var cur_itr = null;
		var setCurItr = function(){
			var cur_val =  itr.next();
			if (isIterable(cur_val)){
				cur_itr = cur_val.iterator();
			} 
			else { 
				cur_itr = nonIterableTransform(cur_val);
			}
		}

		while(cur_itr == null && itr.hasNext())  setCurItr();
		return{
					next:function() return cur_itr.next(),
					hasNext:function() {					
						if (cur_itr.hasNext()) return true;
						else if (itr.hasNext()) { 		
							while ((cur_itr == null && itr.hasNext()) || (cur_itr != null && !cur_itr.hasNext())) {
								setCurItr();
							}
							return cur_itr.hasNext();
						}
						else return false;
					} 
				}
	}

/**
	Takes an Iterator of Dynamics.  It is assumed the Dynamics are Iterables.  If they are not, nonIterable 
	elements are ignored.  The method determines all of the lengths of the Iterables, and returns the longest one. 
**/
	public static function longestLength(itr:Iterator<Dynamic>):Int{
		var max_length = 0;
		for (i in itr){
			if (isIterable(i)){
				var count = Lambda.count(i);
				if (count > max_length) max_length = count;
			}
		}
		return max_length;
	}
	
/**
	Takes an Iterable of Dynamics.  It is assumed the Dynamics are Iterables.  If they are not, nonIterable 
	elements are ignored.  The method determines all of the lengths of the Iterables, and returns the shortest one. 
**/
	public static function shortestLength(it:Iterable<Dynamic>):Int{
		var max_length:Null<Int> = null;
		for (i in it){
			if (isIterable(i)){
				var count = Lambda.count(i);
				if (max_length == null) max_length = count;
				else if (count < max_length) max_length = count;
			}
		}
		return max_length;
	}
	
	
/**
	  	Similar to Reflect.callMethod, but accepts an Iterable of Array arguments for "func".
		At each iteration, the func method is called with arguments from each Iterable from "args", and the output is
		returned as next().  It is assumed args contains an Iterable of Iterables. 
		If it contains an Iterable of elements, each  element is placed in a single cell Array.  
		The Iteration stops when "args" is exhausted.  
		Warning: starmap only works with a function parameter of 6 arguments or less.
		
**/	
	public static function starmap<A>(	o:Dynamic, 
													?func1:Dynamic->A,
													?func2:Dynamic->Dynamic->A,
													?func3:Dynamic->Dynamic->Dynamic->A,
													?func4:Dynamic->Dynamic->Dynamic->Dynamic->A,
													?func5:Dynamic->Dynamic->Dynamic->Dynamic->Dynamic->A,
													?func6:Dynamic->Dynamic->Dynamic->Dynamic->Dynamic->Dynamic->A,
													 args:Iterable<Dynamic>) : Iterator<A>{
		var func:Dynamic = null;
		for (i in [func1,func2,func3,func4,func5,func6]) {
			if (i != null) func = i;
		}
		if (func== null){
			throw('Function was not specified correctly in starmap.  Make sure that the number of parameters for the function is less than six.');
		}
		
		var itr = args.iterator();
		return {		
			next:function(){
				var cur_args = itr.next();
				var set_args:Array<Dynamic>;
				if (isIterable(cur_args)){
					set_args = ArrayTools.fastCreateArray(cur_args);
				} else {
					set_args = new Array<Dynamic>();
					set_args.push(cur_args);
				}	
				return Reflect.callMethod(o,func, set_args);
			},
			hasNext:function() return itr.hasNext()
		}
		
	
	}
	
	
/**
      Takes an Iterator of Dynamics.  It is assumed the Dynamic elements are Iterables themselves.  
		However, if they are not Iterable, they are either ignored or coerced into an Iterator form 
		according to the behavior indicated by the NonIterableBehavior transform.  The transform defaults
		to throwing errors if a Non-Iterable element is found.  
		The function creates a list of Iterators for each Iterable in "it". The first Iterator steps 
		through and returns the results of next() on each iterator. The second Iterator checks to see 
		if there are more elements to be retrieved from "it"'s Iterators (and according to the "longest" 
		parameter).
**/	
	
	public static function zip(itr:Iterator<Dynamic>, ?longest:Null<Bool> = false, 
										?nonIterableTransform:Dynamic->Iterator<Dynamic>, 
										?fill:Dynamic) : Iterator<Iterator<Dynamic>>{
		if (fill != null) longest = true;  // if fill is set, assume user wants to filling in missing values according to the "longest" behavior
		if (nonIterableTransform == null) nonIterableTransform = function(x) {throw('NonIterable element in "it" for zip'); return null;}
		
		var list_itr = new List<Iterator<Dynamic>>(); // check these for hasNext()
		var max_length = 0;
		for (i in itr){  // check each element in "it" for an iterator
			if (isIterable(i)){  
				var itr = i.iterator();
				list_itr.add(itr);
			} else { // it's not iterable
				var itr = nonIterableTransform(i);
				if (itr != null){ // ignore null iterators
					list_itr.add(itr);
				}
			} 	
		}
		
		var zipCheck = zipCheckHelper(longest);
		var itr_list_itr = list_itr.iterator();
		var status = {first:false};
		
		return{
			next:function(){
				return zipNextHelper(itr_list_itr,fill,status);
				},
			hasNext: function(){
				if (!itr_list_itr.hasNext() ) {itr_list_itr = list_itr.iterator();}
				else if (itr_list_itr.hasNext() && status.first) {
					for (i in itr_list_itr){
						i.next();
					}
				}
				return zipCheck(list_itr); 
			}
		}
	}


/**
	Helper function for zip()
**/

private static function zipCheckHelper(longest:Bool):List<Iterator<Dynamic>>->Bool{
	var fold_func:Dynamic->Bool->Bool;
	var start:Bool;
	if (longest){
		fold_func = function(item,accum) return accum || item.hasNext();
		start = false;
	} else{
		fold_func = function(item,accum) return accum && item.hasNext();
		start = true;
	}
	var f = function(x:List<Iterator<Dynamic>>) return Lambda.fold(x, fold_func, start);
	
	return f; 
	
}



/**
	Helper function for zip()
**/
private static function zipNextHelper(itr:Iterator<Iterator<Dynamic>>,fill:Dynamic, status:{first:Bool}):Iterator<Dynamic>{	
	
	return {
		next: function() { 	
			var cur = itr.next();
			var val = Dynamic;
			status.first = false;
			if (cur.hasNext()) val = cur.next();
			else val = fill;
			return val;
			},
		hasNext: function() {
			if (itr.hasNext()){
				return true;
			}else{	
	
				return false;
			}				
			
		}
	}
}

	
	
	
/**
	Returns a fast combinator for the Iterable "it". The [i]th combinator for [it.length()] choose [k] will
	be generated.  The iterator can also be specified explicitly by setting [idx].
	Warning: Successive calls of next() are not uniform 
	in terms of calculation time (the Iterator may need to skip through many intermediate states).
	WARNING: This routine will only work reliably for small arrays of size 11 or less if [i] is given.
**/

	public static function combinator<A>(it:Iterable<A>, k:Int, ?i:Int , ?idx:Array<Int>, ?pos:PosInfos) : Iterator<A>{

		var itr = it.iterator();
		var n = getLength(it);

		if (idx == null) {
			if (i == null) {
				idx = ArrayTools.randomCombinationIndex(n,k);
			} else{
				idx = ArrayTools.combinationIndex(n, k, i);
			}
		}

		if (idx == null){
				throw('initialization error for ' + pos.methodName);
				return null;
		}
		var idx_itr = idx.iterator();
		var cur_index:Int = 0;
		var cur_target = idx_itr.next();
		return {
			next:function() {
					cur_target = idx_itr.next(); return itr.next();
				},
			hasNext:function() {
					while(itr.hasNext() && cur_index < cur_target){
						cur_index++;
						itr.next();
					}
					return itr.hasNext();
				}
			}
			
		}
		
	
/**
	Returns a permutator for the given Iterable "it".  If [i] is specified, the [i]the permuted iterator is generated.
	The iterator can also be specified explicitly with [idx].  
	Warnings: The Iterable must reinitialize itself 
	identically with successive calls to iterator().  Also, successive calls of next() are not uniform in 
	terms of calculation time (the Iterator must often step forward through many intermediate states, or 
	reinitialize itself).
	This routine will only work reliably for small Iterables of size 11 or less if [i] is given.
**/
	public static function permutator<A>(it:Iterable<A>, ?i:Int, ?idx:Array<Int>, ?pos:PosInfos) : Iterator<A>{
		var length = getLength(it);
		
		if (idx == null) {
			if (i == null) {
				idx = ArrayTools.indexArray(length);
				ArrayTools.shuffle(idx);
			} else{
				idx = ArrayTools.permutationIndex(length, i);
			}
		}

		if (idx == null){
			throw('initialization error for ' + pos.methodName);
			return null;
		}
		var idx_ptr = idx.iterator();
		var itr = it.iterator();
		var cur_idx = 0;
		return{
			next:function() return itr.next(),
			hasNext:function() {
				var next_idx = idx_ptr.next();
				if (next_idx == null) return false;
				else if (next_idx > cur_idx ){
					cur_idx++;
					itr = skip(itr,next_idx - cur_idx);

				} else if (next_idx <= cur_idx){
					itr = skip(it.iterator(), next_idx);
				}
				return itr.hasNext();
			}
		}
	}
	
/**
	Skips through an Iterator "count" times and returns it.  If the Iterator becomes !hasNext(), it will halt and return 
	the Iterator in its current state.
**/
	public static function skip<A>(itr:Iterator<A>, count:Int, ?pos:PosInfos):Iterator<A>{
		if (count < 0 ){
			throw('initialization error for ' + pos.methodName);
			return null;
		}
		for (i in 0...count){
			if (!itr.hasNext()) return itr;
			itr.next();
		}
		return itr;
	}

/**
	Returns an empty Iterator.  Useful for initializing Iterators in certain cases
**/
	private static function emptyIterator<A>(e:A):Iterator<A>{
		return {
			next:function() return null,
			hasNext:function() return false
		}
	}



/**
	Returns a Range iterator from "from" (inclusive) to "to" (exclusive).
	If "to" is not set, the Iterator will repeat indefinitely. 
**/
	public static function range<A>(from:Int=0, ?to:Null<Int>) : Iterator<Int>{
	
		var by = 1;
		if (from > to) by *= -1;
		var set_from = from;
	
		return{
			next:function() {
				var return_val = from; 
				from += by;
				return return_val;
				},
			hasNext:function() {return (to == null || from - to != 0);} 
		}
	}

/** 
	This function is intended to be called with only one argument. It is intended to be used when 
	a read-only array index of an Iterable is required.  Beware that in the case of non-array Iterables, 
	an Array is created,  whereas with an Array, the original is simply returned. (leaving it out for now)
	Credit: Nicholas Canasse
**/

/*	private static function returnAsArray<A> (?a:Array<A>, ?itl:IterableWithLength<A>, ?it:Iterable<A>) : Array<A>{
		if( a != null ) return a;
		else if (itl != null) return ArrayTools.fastCreateArray(itl);
 		else return Lambda.array(it);
	}*/

	
/**
		Creates an Iterator over a given Iterator element's "get_field" field.
		If "get_field" doesn't exist, it returns null.
**/
	public static function fieldItr<A>(itr:Iterator<A>, get_field:String) : Iterator<Dynamic> {
	  	return {
					next:function() return Reflect.field(itr.next(),get_field), 
					hasNext:function() return itr.hasNext()
				}												
	}
	
/**
		Skips elements while predicate() is true, iterates normally after 
		predicate() turns false. If predicate() is not given as an argument 
		it defaults to ListTools.isNotNull().
		Warning: The Iterator may cause a delay when first initialized.  It must
		iterate through "itr" until predicate returns true.
**/
	public static function dropWhile<A>(itr:Iterator<A>, ?predicate:A->Bool) : Iterator<A> {
		var drop = true;
		var end = false;
		var cur_val = itr.next(); 

		if (predicate == null) predicate = isNotNull;
	  	return {
					next:function() {
						return cur_val;
						},
					hasNext:function(){
						if (drop){
							while (drop){
								if (!itr.hasNext()) return false;
								cur_val = itr.next();
								if (predicate(cur_val)) drop = false;
							}
							return true;
						} else {
							var one_more = itr.hasNext();
							cur_val = itr.next();
							return one_more;
						}
					
					}
				}											
	}
	
/**
		Slice will take the "itr" Iterator, and then iterate it "start" times from the initial state.  
		Then it will skip "step" iterations each time next() is called.  It will end once "end" total 
		steps have occurred.  It will also end if the Iterator is exhausted.
		Warning: The Iterator may cause a delay when first initialized.  It must
		iterate through the Iterator "start" times, which could be arbitrarily long.
**/
	public static function slice<A>(itr:Iterator<A>, ?start:Int=0, ?end:Int, ?step:Int = 1, ?pos:PosInfos) : Iterator<A> {
	
	if (start < 0 || end < 0 || step < 0 || start > end) {
		throw('initialization error for ' + pos.methodName);
		return null;	
	}
	
	var cur_init = 0;
	while (cur_init < start && itr.hasNext()) {cur_init++; itr.next();}
	return{
			next:function() { cur_init++; return itr.next();},
			hasNext:function(){
				if (!itr.hasNext()) return false; 
				else if (end != null && cur_init > end) return false; 
				else {
					var cur_step = step;
					while (cur_step > 1 && itr.hasNext()) {itr.next(); cur_step--;}
				}
				return itr.hasNext();
			}	
		}
	}

/**
		Cycles through the elements in "it", re-initializing the Iterator each time with reInit() 
		until it reaches the end.   It will stop if it repeats "times" times (optional), or if the 
		Iterator itself is empty.
**/
	public static function cycle<A>(itr:Iterator<A>, ?times:Int, ?reInit:Void->Iterator<A>, ?pos:PosInfos) : Iterator<A> {
		var store_arr = new Array<A>();
		var store_complete:Bool = false;
		if (times < 0){
			throw('initialization error for ' + pos.methodName);
			return null;
		}
		var count:Int = 0;
		return{
			next:function() return itr.next(),
			hasNext:function() {
				if (count >= times) return false;
				else if (itr.hasNext()) return true;
				else {
					count++;
					if (count >= times) return false;
					else itr = reInit();
					return itr.hasNext();
				}
			}
		}
	}


/**
		Repeats "obj" "times" times as an Iterator, or an infinite number of times if "times" is not given.
**/

	public static function repeat<A>(obj:A, ?times:Int) :Iterator<A>{
		if (times < 0){
			return null;
		}
		var count:Int = 0;
		return{
			next:function() {count++; return obj;},
			hasNext:function() return (times == null || count < times)
			}
		}
	
	

/**
		Takes elements from an Iterator while predicate() is true, halts when predicate 
		becomes false. If predicate() is not given as an argument it defaults to 
		ListTools.isNotNull().
**/
	public static function takeWhile<A>(itr:Iterator<A>, ?predicate:A->Bool) : Iterator<A> {

		var cur_val = itr.next();
		if (predicate == null) predicate = isNotNull;
	  	return {
					next:function() {
						var return_val = cur_val;
						cur_val = itr.next();
						return return_val;
					}, 
					hasNext:function(){
						if (!itr.hasNext()) return false;
						else if (!predicate(cur_val)) return false;
						else return true;
						} 
				};											
	}
	
/**
	Returns an Iterator where each element is true under transformer(). 
	if transformer() is null, it will default to return the element's null equivalence.
**/
	public static function filter<A>(itr:Iterator<A>, ?transformer:A->Bool) : Iterator<A> {
		var cur_val = itr.next();
		if (transformer == null) transformer = isNotNull;		
	  	return {
					next:function() {
						var return_val = cur_val;
						cur_val = itr.next();
						return return_val;
					}, 
					hasNext:function(){
						if (!itr.hasNext()) return false;
						else if (cur_val != null && !transformer(cur_val)) return false;
						else return true;
						} 
				};

	}


/**
		Counts from start until the Integer limit is reached.
**/
	public static function count(?start:Int = 0) : Iterator<Int> {
		return{
					next:function() return start++,
					hasNext:function() return start < 2147483648
		}

	}
	
/**
	Groups consecutive equivalent (under transformer) elements of the "itr" Iterator together into an 
	Iterator of Iterators.  
	The first Iterator seperates the different groups, the second Iterator separates elements in the group.
	The key field in the second Iterator contains the current key value for the matched elements.  
	This function is different than ListTools.groupBy() in that it won't guarantee that groups will have unique keys.
**/
	public static function groupBy<A,B>(itr:Iterator<A>, ?transformer:A->B) : Iterator<{>Iterator<A>, key:B}> {
		if (transformer == null) transformer = identity;

		var cur_value = itr.next();
		var group = {key:null, next:function() return null, hasNext:function() return false}
		return{
					next:function() { 
						var this_key = transformer(cur_value);	
						var this_next = function(){
								var return_value = cur_value;
								cur_value = itr.next();
								return return_value; 
							}
						var this_hasNext = function(){
											if (!itr.hasNext()) return false;
											if (this_key != transformer(cur_value)) return false;
											else return true;
										}
					  	group = { key:this_key, next:this_next, hasNext:this_hasNext };
						return group;
					},
					hasNext:function() { 
						while(group.hasNext()) group.next();
						return itr.hasNext();
						}
		}
	}
	
/**
	This function behaves like Lambda.map(), except it takes and returns an Iterator.
**/	
	public static function map<A,B>(itr:Iterator<A>, transform:A->B) : Iterator<B> {
		return {
			next:function() return transform(itr.next()),
			hasNext:function() return itr.hasNext()
		}
	}
	


	
	
	
/**
	This function behaves like Lambda.mapi(), except it takes and returns an Iterator.
**/	
	public static function mapi<A,B>(itr:Iterator<A>, transform:Int->A->B) : Iterator<B> {
		var cnt = 0;
		return {
			next:function() return transform(cnt++,itr.next()),
			hasNext:function() return itr.hasNext() 
		}
	}
	
	

	
/**
	This function is intended to be called with only one argument.
	Returns the Iterable length as quickly as possible for a given Type.
**/	

	public static function getLength<A>(?itl:IterableWithLength<A>, ?it:Iterable<A>) : Null<Int> {
		if (itl != null)  return itl.length;
		else if (it != null) return Lambda.count(it);
		else return null;
	}
	
	
/**
	Lets an Iterator function as an Iterable for relevant methods (caution, can only be iterated once if store == false)		
**/
	public static function itb<T>(itr : Iterator<T>, ?store:Bool = false) : Iterable<T>{		
		if (store) return new StoredIterator(itr);
		else return {iterator:function() return itr};
	}

									
/**
		Determines if a Dynamic is Iterable (works for Arrays and nulls)
**/

	public static function isIterable(d:Dynamic):Bool{
		return (d != null && (Reflect.hasField(d,'iterator') || Std.is(d, Array)));
	}
	


/**
		Unfolds "seed", applying transformer() to it, and incrementor() on it
		until predicate() returns false.  Returns an Iterator of the results from transformer().
		If predicate is not given as an argument, it defaults to isNotNull().
**/

	public static function unfold<A,B>(seed : A, transformer : A -> B, incrementor : A -> A, ?predicate : A->Bool) : Iterator<B> {
		if (predicate == null) predicate = isNotNull;
		var cur_val:A = seed;
		return{
			hasNext:function() return predicate(cur_val),
			next:function() {
					var ret_val = transformer(seed);
					cur_val = incrementor(cur_val);
					return ret_val;
			}
		}
	}
	
	

	/**
		This simple function handles "smart" Null checking for arbitrary elements
	**/	

	   public inline static function isNotNull<A>(e:A) : Bool {
			return e!= null;	
	    }


	/**
		A very simple inlined identity function.  This was designed to be used as a
		default function for transforms.  The untyped return will dodge the type check,
		and allow the parameter "e" to act as if it has changed Types.
	**/
		public inline static function identity<A,B>(e:A) : B { return untyped e; }

	/**
		A very simple inlined greater than zero function
	**/
		public inline static function greaterThanZero<A>(e:Float) : Bool { return e > 0; }


}

/**
		An Iterable class that is created from the Iterator "itr". 
		The iterator() of this class will return results from "itr.next()" normally, 
		but also save them in an array.  All subsequent calls of iterator() will then retrieve 
		the iterator from the stored array.  
		Warning: If another iterator() of a StoredIterator is retrieved before the original "itr" is stored,
		the iterator() will return null.  To determine if the StoredIterator
		is finished storing the results from "itr", use the "isFinished()" function.
**/

class StoredIterator<A>{  // extends Iterable
   private var itr:Iterator<A>;
	private var stored_arr:Array<A>;
	private var finished:Bool;
	private var started:Bool;
	public function new(itr:Iterator<A>){
		stored_arr = new Array<A>();
		this.itr = itr;
		if (!itr.hasNext()){ started = true; finished = true;} 
		else { started = false; finished = false;}
	}
/**
		Determines if Stored Iterator has finished storing results from "itr"
**/
	public function isFinished():Bool {return started && finished;}
/**
		Determines if Stored Iterator has started storing results from "itr"
**/	
	public function isStarted():Bool {return started;}
	
	public function iterator() :Iterator<A>{
		
		if (started && !finished && !itr.hasNext()) finished = true; // finished storing the Iterator
		
		if (started && !finished && itr.hasNext()) { // incompletely stored Iterator
			throw('Second StoredIterator.iterator() called before Iterator argument was completely stored');
			return null;
		}
		else if (finished ) return stored_arr.iterator(); // completely stored Iterator
		else{ 
				started = true;
				var t = this;
				return cast {
					itr:itr,
					stored_arr:stored_arr,
					hasNext : function() return untyped t.itr.hasNext(),
					next : function() {
						var ret_val = untyped t.itr.next();
						untyped t.stored_arr.push(ret_val);
						return ret_val;
					}
				}
		}
	}
	
/**
		Returns the string representation of the Iterable.  If toString() is called
		before StoredIterator has started storing "itr", it will process "itr" completely and
		return the string value of the stored array.If toString() is called before
		StoredIterator has finished storing "itr", it will throw an error.
**/
	public function toString(){
		if (started && !finished && itr.hasNext()) { // incompletely stored Iterator
			throw('StoredIterator.toString() called before Iterator argument was completely stored');
			return null;
		}
		else for ( i in itr) stored_arr.push(i);
		return stored_arr.toString();
	}
}


	





