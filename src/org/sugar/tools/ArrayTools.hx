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
	The utility Sugar classes provide additional Iterable manipulation routines.

**/


/**
	The ArrayTools class adds additional common array utility functions.  Support 
	for Fisher-Yates shuffling (in place) as well as combinators, permutators, 
	combinations, and permutations are provided. Created by Justin Donaldson 
	(jdonaldson at gmail dot com) with help/contributed methods from Nicholas Canasse 
	and Franco Ponticelli.
**/

package org.sugar.tools;
import org.sugar.tools.IterTools; // for range()
import haxe.PosInfos;

class ArrayTools {

/**
		Returns the kth permutation index of length "n" as an Array (uses factoradics).
		Null if error.	
		WARNING: This routine will only work reliably for [n] values of 12 or less.
**/	

	public static function permutationIndex(n:Int, k:Int):Null<Array<Int>>{
		trace(n + ' ' + k);
		var fac = factoradic(n,k);
		if (fac == null) return null;
		var perm = new Array<Int>();
		for (i in 0...n){ fac[i]+=1; }
		for (j in 1...n+1){
			var i = n-j;
			perm[i] =  fac[i];	
			for (k in (i+1)...n){
				if (perm[k] >= perm[i]) ++perm[k];
			}
		}
		for (k in 0...n) {--perm[k];}
		return perm;
	}
	
	
/**
	Permutes the [arr] Array (in place) according to the [k]th permutation.
	If the [i] index is null, the array is permuted randomly (shuffled).
	The permutation index can be set explicitly with [idx];
	WARNING: If [i] is specified, this routine will only work reliably for small arrays of size 12 or less.
	
**/

	public static function permute<T>(arr:Array<T>,?i:Int, ?idx:Array<Int>){
		if (arr == null) return;
		var length = arr.length; 
		
		if (idx == null) {
			if (i == null) {
				shuffle(arr);
				return;
			} else{
				idx = permutationIndex(length, i);
			}
		} 	
		
		for (j in 0...length){
			if (idx[j] <= j) continue;
			var tmp = arr[j];
			arr[j] = arr[idx[j]];
			arr[idx[j]] = tmp;
		}
	}
	

	
	
/** 
	This function quickly creates an Array from any Iterable.  Using the length field (detected through the 
	IterableWithLength typedef) cuts down Array creation time over Lambda.array() in some instances.
**/
	public static function fastCreateArray<A>(?itl:IterableWithLength<A>, ?it:Iterable<A>) :Array<A> {
		if (itl != null) {
			var r = new Array<A>();
			var last_index = itl.length;
			var itr = itl.iterator();
			for (i in 0...last_index){
				r[i] = itr.next();
			}
			return r;
		}
		else return Lambda.array(it);
	}
		

/**
	Shuffles the "arr" Array (in place) according to a randomly chosen permutation
	This is the classic Fisher-Yates style shuffle.
**/
	public static function shuffle<T>(arr:Array<T>){
		var n = arr.length;
		while (n > 1){
			var k = Std.random(n);
			n--;
			var temp = arr[n];
			arr[n] = arr[k];
			arr[k]= temp;
		}
	}
	

/**
	Concats the Array arr2 to arr1 (in place).
**/	
	public static function concat<T>(arr1:Array<T>, arr2:Array<T>){
		arr1 = arr1.concat(arr2);
	}
	

	




/**
	Returns the [i]th permuted Iterator of an Array, or the Iterator specified by [idx].
	Null if error.
	WARNING: If [i] is specified, this routine will only work reliably for small arrays of size 12 or less .
**/
	
	public static function permutator<T>(arr:Array<T>, ?i:Int, ?idx:Array<Int> ):Null<Iterator<T>>{
		
		if (arr == null) return null;
		
		if (idx == null) {
			if (i == null) {
				idx = indexArray(arr.length);
				shuffle(idx);
				return permutator(arr,idx);
			} else{
				idx = permutationIndex(arr.length, i);
			}
		}
		
		
		var current = 0;
		
		return {
					next:function() {return arr[idx[current++]];},
					hasNext:function() return current < arr.length
		}
	}

/**
	Simple array utility function to create indices
**/
	public static function indexArray(n:Int) :Array<Int>{
		var idx = new Array<Int>();
		for (i in 0...n) idx[i] = i;
		return idx;
	}

/**
	Returns all permutations of an Array "arr" as an Iterator of Iterators
**/

	public static function permutators<T>(arr:Array<T>):Iterator<Iterator<T>>{				
		var idx = indexArray(arr.length);
		var cur_idx = idx.copy();
		var first = true;
		return{ 
				 next:function(){ return(permutator(arr,cur_idx)); },
				 hasNext:function(){ 
					if (first) {
						first = false;
						return true;
					} else if (equivalent(idx,cur_idx)) { 
						return false;
					} else {
						nextPermutationIndex(cur_idx);
						return true;
					}
					
				 }
		}
	}


/**
	Returns all possible combinations of an Array "arr" as an Iterator (iterating groups of combinators of different lengths) 
	of Iterators (iterating combinators of the same length) of Iterators (iterating elements of a given combinator)...
**/

	public static function allCombinators<T>(arr:Array<T>):Iterator<Iterator<Iterator<T>>>{
		var max_index = arr.length;
		var choose_index = 1; // the "choose" parameter
		return{
			next:function(){return(combinators(arr,choose_index++));},
			hasNext:function(){return choose_index <= max_index;}
		}
	}


/**
	Returns all "select k" combinations of an Array "arr" as an Iterator of Iterators.  Null if error.
**/

	public static function combinators<T>(arr:Array<T>, k:Int):Null<Iterator<Iterator<T>>>{	
	   var idx = indexArray(k);
		var cur_idx = idx.copy();
		var cur_index = 0;
		var first = true;
		return{
			next:function(){ return(combinator(arr,k,cur_idx)); },
			hasNext:function(){ 
					if (first) return true;
					else if (equivalent(idx, cur_idx)) return false;
					else {
						nextCombinationIndex(cur_idx, arr.length);
						return true;
					}
				}
		}

	}


/** 
	Creates a "combinator" Iterator that will iterate through the "k" selected values of [arr].
	A specific combination can be chosen by setting [i], or by setting the permutation index [idx].
	If neither [i] nor [idx] is not given, a random permutation is given. Null if error.
	WARNING: This routine will only work reliably for small arrays of size 12 or less if [i] is given.

**/

	public static function combinator<T>(arr:Array<T>, k:Int, ?i:Int, ?idx:Array<Int>, ?pos:PosInfos):Null<Iterator<T>>{
		if (arr == null) return null;
		var length = arr.length;
		
		if (idx == null) {
			if (i == null) {
				idx = randomCombinationIndex(arr.length,k);
				return combinator(arr, k, idx);
			} else{
				idx = combinationIndex(arr.length, k, i);
			}
		}
		
		if (idx == null){
			throw('initialization error for ' + pos.methodName);
			return null;
		}
		
		var current:Int = 0;
		return {
					next:function(){ return arr[idx[current++]]; },
					hasNext:function(){ return current < k; }
					}
		
	}



/** 
	Creates a random combination index array for an array of length [n] for a combination of length [k].
**/
	
	public static function randomCombinationIndex<T>(n:Int, k:Int) : Array<Int> {
		if (k < 1) { 
			throw "invalid k value";
			return null;
		}
		var idx_arr = new Array<Int>();  // a temporary index array
		for (i in 0...n)	idx_arr[i] = i;
		
		var k_arr = new Array<Int>(); // a temporary array to hold the k index values
		for (i in 0...k){
			var idx = Std.random(idx_arr.length);
			var tmp = idx_arr[idx];
			idx_arr[idx] = idx_arr[idx_arr.length-1];
			idx_arr[idx_arr.length-1] = tmp;
			k_arr.push(idx_arr.pop());
		}
		k_arr.sort(function(x,y) {return x-y;});
		
		return k_arr;
		
	}




	
/** 
	Selects the combination index "i" from "n choose k" as an Array of Ints. Null if error.
	WARNING: This routine will only work reliably for n values of 12 or less.
**/

	public static function combinationIndex<T>(n:Int, k:Int, i:Int, ?pos:PosInfos):Array<Int>{
		var dual = (choose(n,k)-1) -i;
		if (dual < 0){
			throw('initialization error for ' + pos.methodName);
			return null;
		}
		var comb_arr = combinadic(n, k, dual);
		var comb_len = comb_arr.length;
		for (i in 0...comb_len){ comb_arr[i] = n - comb_arr[i] - 1;}
		return comb_arr;
	
	}
	
	
/**
	Returns a given "select k" combination of an Array "arr" as a new array.  If "i" is null, 
	a random "k" length selection is returned.  Null if error.   
	The combination index can be set explicitly with [idx].
	WARNING: If [i] is specified, 
	this routine will only work reliably for small arrays of size 12 or less.
	
**/

	public static function combination<T>(arr:Array<T>, k:Int, ?i:Int, ?idx:Array<Int>, ?pos:PosInfos):Null<Array<T>>{	
		if (arr == null) return null;
		var length = arr.length; 
		
		var idx:Array<Int> = new Array<Int>();
		
		if (idx == null) {
			if (i == null) {
				idx = randomCombinationIndex(arr.length,k);
			} else{
				idx = combinationIndex(arr.length, k, i);
			}
		}
		
				
		if (idx == null){
			throw('initialization error for ' + pos.methodName);
			return null;
		}
		
		var r:Array<T> = new Array<T>();
 		var idx_length = idx.length;
		for (j in 0...idx_length){
			r[j] = arr[idx[j]];
		}
		return r;
	}

/**
	Returns all given "select k" combination of an Array "arr" as a new array of arrays.
	Null if error. 
**/
	public static function combinations<T>(arr:Array<T>, k:Int):Null<Array<Array<T>>>{	
		var length = arr.length; 
		var idx = indexArray(k);
		var cur_idx = idx.copy();
		var done:Bool = false;

		
		var r = new Array<Array<T>>();
		
		while(!done){
			r.push(combination(arr,k,cur_idx));
			nextCombinationIndex(cur_idx,k);
			if (ArrayTools.equivalent(idx,cur_idx)) done = true;
		}
		return r;
	}

/**
	Computes the next combination index of [idx] for a given number [n] in place
**/
	public static function nextCombinationIndex<T>(idx:Array<Int>, n:Int) {	
		var cur_last_idx = idx.length -1;
		var done:Bool = false;
		
		while(!done){
			var ceiling = n;
			if (cur_last_idx != idx.length -1) ceiling = idx[cur_last_idx+1];
			
			if (idx[cur_last_idx] < ceiling -1) { 
				idx[cur_last_idx]+=1;
				for (i in cur_last_idx+1...idx.length) idx[i] = idx[i-1] +1;
 				done = true;
			}
			else if (cur_last_idx != 0) cur_last_idx--;
			else { 
				idx = indexArray(idx.length);
				done = true;
			}
		}
	}

/**
	Computes the next permutationIndex of the array [idx] in place.
**/
	public static function nextPermutationIndex<T>(idx:Array<Int>) {
		var cur_last_idx = idx.length -1;
		var done:Bool = false;
		var itr = IterTools.range(idx.length-2, -1);
		for (i in itr){
			if (idx[i] < idx[i+1]){
				var smallest = i+1;
				for (j in (i+1)...idx.length)	if (idx[smallest] > idx[j]  && idx[j] > idx[i]) smallest = j;
				var tmp = idx[i];
				idx[i]= idx[smallest];
				idx[smallest] = tmp;
				var sort_these = idx.splice(i+1,idx.length-i);
				sort_these.sort(function(x,y) {return x-y;});
				for (i in sort_these) idx.push(i);

				break;
			} else if (i == 0){
				idx.sort(function(x,y){return x-y;});
			}
			
		}
		
		
}





/**
	Returns true if the arrays have the same values and sequence.
**/

	public static function equivalent<T>(arr1:Array<T>, arr2:Array<T>) :Bool{
		if (arr1.length != arr2.length) return false;
		for (i in 0...arr1.length) if (arr1[i] != arr2[i]) return false;
		return true;
	}


/**
	Returns the "i"-th combinadic of "n choose k" as an Array.  Null if error.
**/

	private static function combinadic(n:Int, k:Int, i:Int,?pos:PosInfos):Null<Array<Int>>{
		if (i > choose(n,k)){
			throw('initialization error for ' + pos.methodName +': Index "i" is greater than "n" choose "k"');
			return null;
		}
		else {
			var ans = new Array<Int>();
			var a = n;
			var b = k;
			var x = i;

			for (i in 0...k){
				ans[i]= largestN(n,b,x);
				x = x - choose(ans[i],b);
				a = ans[i];
				b -=1;
			}
			return ans;
		}
	}
	
	
		
/**
	Returns a "Deep Copy" of an Array, recursively copying multidimensional Arrays.
	Credit: Franco Ponticelli.
**/

  public static function deepCopy<A>( arr : Array<A> ) : Array<A> {
    
     if(arr.length > 0 && Std.is(arr[0], Array)){
         var r = new Array<A>();   
         for( i in 0...arr.length ) {
             r.push(cast deepCopy(untyped arr[i]));
         }
         return r;
     } else {
         return arr.copy();
        }
    
	}




/** 
	Returns the largest "n" (less than "max_n") such that "n choose k" will be less than "x".
	(Helper function for combinadics)
**/	

	private static function largestN(max_n:Int, k:Int, x:Int,?pos:PosInfos):Null<Int>{
	
		if (x < 0 || max_n < 0 || k < 0){
			throw('initialization error for ' + pos.methodName);
			return null;
		}
		
		
		else{
			var n = max_n - 1;
			while(choose(n, k) > x){ --n;}
			return n;
		}
	}




/**
		Returns the kth factoradic representation of the number "n" as an Array.
		Null if error.
		
**/

	private static function factoradic(n:Int, k:Int, ?pos:PosInfos):Null<Array<Int>>{

		if (n < 0 || k < 0){
			throw('initialization error for ' + pos.methodName);
			return null;
		}
		var factoradic = new Array<Int>();
		factoradic[n-1]=0;
		for (j in 1...n+1){
			trace(k + ' ' + j);
			factoradic[n-j] = k % j;
			k = Std.int(k/j);
		}
		return factoradic;	
	}







/** 
	Returns "n choose k".  Used for combinadics.
	WARNING: Will not work for [n] larger than 12.
**/

	public static function choose(n:Int, k:Int, ?pos:PosInfos):Null<Int>{
		if (n < 0 || k < 0){
			throw('initialization error for ' + pos.methodName);
			return null;
		}
		else if (n < k) return 0;
		else if (n == k) return 1;
		else{
			var result:Int = 1;
			for (i in k+1...n+1){
				if (i > n-k){

				}
				result *= i; 
				} 
/* 			return result;*/
			return Math.floor(result/factorial(n-k));
		}
	}	


/** 
	Returns the factorial of "n".  Used for factoradic elements.  Null if "n" argument is < 0.
	WARNING: Will not work for [n] larger than 12.
**/
	public static function factorial(n:Int, ?pos:PosInfos):Null<Int>{
		if (n < 0){
			throw('initialization error for ' + pos.methodName);
			return null;
		}
		else {
			var result:Int = 1;
			for (i in 2...n+1){ result*= i; }
			return result;
		}
	}

/** 
	Implements a 'swap and pop' remove for Arrays.  Only use this if you don't care about order in your array.
**/
	public static function swapAndPop<A>(arr:Array<A>, e:A):Bool{
		var tmp:A = null;
		for (i in 0...arr.length){
			if (arr[i] == e){
				var tmp = arr[arr.length-1];
				arr[arr.length-1] = arr[i];
				arr[i] = tmp;
				tmp = arr.pop();
				return true;
				break;
			}
		}	
	return false;
	}
	
}

/**
	A typedef for Iterables with lengths (read-only "length" fields, e.g. List and Array).
	These collection types can often be optimized for different tasks over conventional Iterables.
**/

typedef IterableWithLength<T> = {
	function iterator() : Iterator<T>;
	var length(default, null) : Int;
}





