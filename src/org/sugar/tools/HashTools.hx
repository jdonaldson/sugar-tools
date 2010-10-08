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

package org.sugar.tools;
import org.sugar.tools.IterTools;

/**
	The HashTools class adds additional common hash utility functions.  Support 
	for grouping iterables (into hashes of lists), as well as easily mapping hash types
	are provided. Created by Justin Donaldson (jdonaldson at gmail dot com).
**/


class HashTools{
	/**
			Aggregates an Iterable into a Hash based on the elements' string equivalence under transformer().
			If transformer is not given, Std.string(x) will be used instead.
			The Hash id will be the string value from transformer().
**/	
		public static function groupByHash<A,B>(it : Iterable<A>, ?transformer : A -> String) : Hash<ListType<A>> {
			if (transformer == null) {transformer = function(x) {return Std.string(x);}}
			var r = new Hash<ListType<A>>(); 
			for ( i in it){ // go through the Iterable and add elements to Hash entries based on their transform
				var t = transformer(i);

				if (! r.exists(t)){	
					var l = new ListType<A>();
					l.add(i);
					r.set(t,l);
				}
				else { r.get(t).add(i); }
			}

			return r;
		}

/**
		Similar in functionality to groupByHash...
		Aggregates an Iterable into an IntHash based on the elements' Int equivalence under transformer().
		The IntHash id will be the Int value from transformer().    
**/	
	public static function groupByIntHash<A,B>(it : Iterable<A>, transformer : A -> Int) : IntHash<ListType<A>> {
		var r = new IntHash<ListType<A>>(); //  Hash of List<A>'s

		for ( i in it){ // go through the Iterable and add elements to Hash entries based on their transform
			var t = transformer(i);
			if (! r.exists(t)){	
				var l = new ListType<A>();
				l.add(i);
				r.set(t,l);
			}
			else { r.get(t).add(i); }
		}

		return r;
	}
	
/**
		Applies a function over each of the values of a Hash, returning a new Hash.   
**/	
	public static function hashValueMap<A,B>(h:Hash<A>, transformer : A -> B) : Hash<B> {
		var r = new Hash<B>();
		for (i in h.keys()) r.set(i, transformer(h.get(i)));
		return r;
	}
	
/**
		Applies a function over each of the values of an IntHash, returning a new IntHash.   
**/	
	public static function intHashValueMap<A,B>(h:IntHash<A>, transformer : A -> B) : IntHash<B> {
		var r = new IntHash<B>();
		for (i in h.keys()) r.set(i, transformer(h.get(i)));
		return r;
	}

/**
		Applies a function over each of the values of a Hash, including the associated Hash String key. 
		Returns a new Hash.   
**/	
	public static function hashValueMapKey<A,B>(h:Hash<A>, transformer : A ->String -> B) : Hash<B> {
		var r = new Hash<B>();
		for (i in h.keys()) r.set(i, transformer(h.get(i),i));
		return r;
	}

/**
		Applies a function over each of the values of an IntHash, including the associated IntHash Int key.   
		Returns a new IntHash
**/	
	public static function intHashValueMapKey<A,B>(h:IntHash<A>, transformer : A -> Int -> B) : IntHash<B> {
		var r = new IntHash<B>();
		for (i in h.keys()) r.set(i, transformer(h.get(i), i));
		return r;
	}

	public static function hashMap<A,B>(h:Hash<A>, keyTransformer : String -> A -> String, valueTransformer : String -> A -> B) : Hash<B>{
		var r = new Hash<B>();
		for ( i in h.keys()){
			var value = h.get(i);
			r.set( keyTransformer(i,value) , valueTransformer(i,value));
		}
		return r;
	}
	
	public static function intHashMap<A,B>(h:IntHash<A>, keyTransformer : Int -> A -> Int, valueTransformer : Int -> A -> B) : IntHash<B>{
		var r = new IntHash<B>();
		for ( i in h.keys()){
			var value = h.get(i);
			r.set( keyTransformer(i,value) , valueTransformer(i,value));
		}
		return r;	
	}
	

		
		
		
		
		
	}

	
	
	
