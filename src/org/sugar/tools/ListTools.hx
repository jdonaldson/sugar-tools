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
	The utility Sugar classes provide additional utilities for haXe
**/




package org.sugar.tools;
import haxe.FastList;
import org.sugar.tools.IterTools;
import org.sugar.tools.ArrayTools;



/**
	The ListTools class includes useful functions that (typically) take Iterables and 
	produce ListTypes (SugarList/List classes). 	SugarLists are pointer based versions of List that extend Lists.  
	They are significantly faster on the Flash platforms.
	Please note that ListTool functions produce Lists by default.  
	To use the alternate SugarList class rather than the default List, use the compiler flag -sugarlist.
	Created by Justin Donaldson (jdonaldson at gmail dot com) with 
	help/contributed methods from Ian Martins.
**/
class ListTools {
	
/**
	      Functions like Lambda.fold, except saves and returns intermediate values as a ListType.
**/
	public static function scan<A,B>( it : Iterable<A>, f : A -> B -> B, accum : B ) : ListType<B>{
		  var l = new ListType<B>();
		  for (x in it){
				accum = f(x,accum);
				l.add(accum);
			}
		
		  return l;
		
	}

/**
      Saves the result of IterTools.zip() to a List of Lists.  See IterTools.zip() for more information.
**/
	public static function zip(it:Iterable<Dynamic>, longest:Null<Bool> = false, ?nonIterableBehavior:Dynamic->Iterator<Dynamic>, ?fill:Dynamic ) : ListType<ListType<Dynamic>>{
		var itr = IterTools.zip(it.iterator(),longest,nonIterableBehavior,fill);
		var l = new ListType<ListType<Dynamic>>();
		for ( i in itr){
			var l2 = new ListType<Dynamic>();
			for (j in i){
				l2.add(j);
			}
			l.add(l2);
		}
		return l;
	}


/**
	  	Transforms the result of IterTools.starmap() into a ListType. See IterTools.starmap() for more information.
**/	
	public static function starmap<A>(	o:Dynamic, 
													?func1:Dynamic->A,
													?func2:Dynamic->Dynamic->A,
													?func3:Dynamic->Dynamic->Dynamic->A,
													?func4:Dynamic->Dynamic->Dynamic->Dynamic->A,
													?func5:Dynamic->Dynamic->Dynamic->Dynamic->Dynamic->A,
													?func6:Dynamic->Dynamic->Dynamic->Dynamic->Dynamic->Dynamic->A,
													 args:Iterable<Dynamic>) : ListType<A>{
		var func:Dynamic = null;
		for (i in [func1,func2,func3,func4,func5,func6]) {
			if (i != null) func = i;
		}
		var itr = IterTools.starmap(o,func,args);
		return ListTools.list(IterTools.itb(itr));	
	}
	

	
/**

      Saves the result of IterTools.chain() to a list. See IterTools.chain() for more information.

**/	

	public static function chain<T>(it:Iterable<Dynamic>,?nonIterableBehavior:Dynamic->Iterator<Dynamic>) : ListType<Dynamic>{
		var itr = IterTools.chain(it.iterator(),nonIterableBehavior);
		var l = new ListType<Dynamic>();
		for ( i in itr) l.add(i);
		return l;
	}


 /**                                                                                                                                                  
      Finds first element in an iterable that satisfies predicate().  
		Returns [null] if it doesn't exist.                                                                              
		Similar to it.filter(predicate).first(), but without the need to 
		process the entire Iterable with filter(). 
		If predicate is not given as an argument, it defaults to IterTools.isNotNull().
		Credit: Ian Martins
**/
 public static function findFirst<A>( it : Iterable<A>, ?predicate : A -> Bool ) : A {

 	if (predicate == null) predicate = IterTools.isNotNull;
	for( ii in it )
    if( predicate(ii) )
      return ii;
  	return null;
 }


/**
		Unfolds "seed", applying transformer() to it, and incrementor() on it
		until predicate() returns false.  Returns a ListType of the results from transformer().
		If predicate is not given as an argument, it defaults to IterTools.isNotNull().
**/

	public static function unfold<A,B>(seed : A, transformer : A -> B, incrementor : A -> A, ?predicate : A->Bool) : ListType<B> {
		if (predicate == null) predicate = IterTools.isNotNull;
		var itr = IterTools.unfold(seed,transformer, incrementor, predicate);
		var l = new ListType<B>();
		for (i in itr) l.add(i);
		return l;
   }



	
/**
	This function behaves like Lambda.map(), except it takes an Iterator.
**/	
	public static function mapIter<A,B>(itr:Iterator<A>, transform:A->B) : ListType<B> {
		var itr2 = IterTools.map(itr,transform);
		var l = new ListType<B>();
		for (i in itr2) l.add(i);
		return l;
	}

/**
		Concatenates two Iterables together and returns the result as a [List].  
		Preferable to chain() in some instances because it preserves Type.
**/

	public static function concat<A> (l1 : Iterable<A>, l2 : Iterable<A>) : ListType<A> {
		var l = new ListType<A>();
		for (i in l1) l.add(i);
		for (i in l2) l.add(i);
		return l;
		
	}
	

	
	
	
/**
			Reverses a copy of a ListType and returns it
**/	
	
	public static function reverse<A>(l : ListType<A>) : ListType<A> {
		var l2 = new ListType<A>();
		
		for (i in l){
			l2.push(i);
		}
		
		return l2;
	}
	

/**
			Converts an [Iterable] into a [FastList]
**/	

	public static function fastList<A>(it: Iterable<A>):FastList<A>{
		var r = new FastList<A>();
		var itr = it.iterator();
		var head = new FastCell<A>(itr.next(),null);
		r.head = head;
		var current = head;
		for (i in itr){
			current.next = new FastCell<A>(i,null);
			current = current.next;
		}
		return r;
	}


/**
		Aggregates an [Iterable] into a [ListType] of [GroupByContainers] (simple key/list-of-values objects) based
		on each element's equivalence under transformer().  If transformer() is not given as an argument 
		it defaults to the IterTools.identity() function.
**/	

	public static function groupBy<A,B>(it : Iterable<A>, ?transformer : A -> B) : ListType<GroupByContainer<B,A>> {
		if (transformer == null) transformer = IterTools.identity;
		var r = new ListType<GroupByContainer<B,A>>();
		var f = function(x:A):GroupByContainer<B,A>{      
			var t = new GroupByContainer<B,A>(transformer(x), new ListType<A>()); 
			t.values.add(x);
			return t;							
		}
		var r2 = ListTools.map(it,f);
		while (! r2.isEmpty()){
			var first = r2.pop();
			var m = bifurcate(r2, function(x){return x.key == first.key;});
			for (i in m.first()){
				first.values.add(i.values.first());
			}
			r.add(first);
			r2 = m.last();
		}
		return r;
	}
	


	
/**
		A very crude sort mechanism for [Iterables] using [Arrays].  Creates a new [ListType] that contains
		a sorted version of the elements in "it".
**/
	public static function sort<A>(it : Iterable<A>, comparator : A -> A -> Int) : ListType<A> {
		var arr = ArrayTools.fastCreateArray(it);
		arr.sort(comparator);
		return ListTools.list(arr);
	}


/**
		Bifurcate is similar to Lambda.filter, except it returns both [ListType] of results.  The first [ListType] includes
		elements that were true under "f", and the second/last [ListType] includes those that were false.
		If transformer is not given as an argument it defaults to IterTools.isNotNull().
**/	
	public static function bifurcate<A>(it : Iterable<A>, ?transformer : A -> Bool) : ListType<ListType<A>> {
		var l = new ListType<A>();
		var l2 = new ListType<A>();
		var r = new ListType<ListType<A>>();
		if (transformer == null) transformer = IterTools.isNotNull;
		
		for (i in it){
			if (transformer(i)) l.add(i);
			else {l2.add(i);}
		}

		r.add(l); 
		r.add(l2);

		return r;
	}


	
	
/**
	Returns the unique items in an [Iterable] as a [ListType]
**/	
	public static function unique<A>(it : Iterable<A>) : ListType<A> {
		var it2 = it;
		var l = new ListType<A>();
		
		while(!ListTools.empty(it2)){
			var a = it2.iterator().next();
			l.add(a);
			it2 = ListTools.filter(it2, function(x) {return x != a;});
		}
		
		return l;
	}
	
	
/***************************************
LAMBDA API
****************************************/
	
	/**
		Creates an [Array] from an [Iterable]
	**/
	public static function array<A>( it : Iterable<A> ) : Array<A> {
		var a = new Array<A>();
		for(i in it)
			a.push(i);
		return a;
	}

	/**
		Creates a [ListType] from an [Iterable]
	**/
	public static function list<A>( it : Iterable<A> ) : ListType<A> {
		var l = new ListType<A>();
		for(i in it)
			l.add(i);
		return l;
	}

	/**
		Creates a new [Iterable] by appling the function 'f' to all
		elements of the iterator 'it'.
	**/
	public static function map<A,B>( it : Iterable<A>, f : A -> B ) : ListType<B> {
		var l = new ListType<B>();
		for( x in it )
			l.add(f(x));
		return l;
	}

	/**
		Similar to [map], but also pass an index for each item iterated.
	**/
	public static function mapi<A,B>( it : Iterable<A>, f : Int -> A -> B ) : ListType<B> {
		var l = new ListType<B>();
		var i = 0;
		for( x in it )
			l.add(f(i++,x));
		return l;
	}

	/**
		Tells if the element is part of an iterable. The comparison
		is made using the [==] operator. Optionally you can pass as
		a third parameter a function that performs the comparison.
		That function must take as arguments the two items to
		compare and returns a boolean value.
	**/
	public static function has<A>( it : Iterable<A>, elt : A, ?cmp : A -> A -> Bool ) : Bool {
		if( cmp == null ) {
			for( x in it )
				if( x == elt )
					return true;
		} else {
			for( x in it )
				if( cmp(x,elt) )
					return true;
		}
		return false;
	}

	/**
		Tells if at least one element of the [Iterable] is found by using the specific function.
	**/
	public static function exists<A>( it : Iterable<A>, f : A -> Bool ) {
		for( x in it )
			if( f(x) )
				return true;
		return false;
	}

	/**
		Tells if all elements of the [Iterable] have the specified property defined by [f].
	**/
	public static function foreach<A>( it : Iterable<A>, f : A -> Bool ) {
		for( x in it )
			if( !f(x) )
				return false;
		return true;
	}

	/**
		Call the function [f] on all elements of the [Iterable] 'it'.
	**/
	public static function iter<A>( it : Iterable<A>, f : A -> Void ) {
		for( x in it )
			f(x);
	}

	/**
		Return the list of elements matching the function [f].
	**/
	public static function filter<A>( it : Iterable<A>, f : A -> Bool ) {
		var l = new ListType<A>();
		for( x in it )
			if( f(x) )
				l.add(x);
		return l;
	}

	/**
		Functional 'fold' using an [Iterable]
	**/
	public static function fold<A,B>( it : Iterable<A>, f : A -> B -> B, first : B ) : B {
		for( x in it )
			first = f(x,first);
		return first;
	}

	/**
		Count the number of elements in an [Iterable]
	**/
	public static function count<A>( it : Iterable<A> ) {
		var n = 0;
		for( _ in it )
			++n;
		return n;
	}

	/**
		Tells if an [Iterable] does not contain any element.
	**/
	public static function empty( it : Iterable<Dynamic> ) : Bool {
		return !it.iterator().hasNext();
	}
	
	
	
	
	
	
}


/**
	A small class used by the groupBy routine.  
**/

class GroupByContainer<A,B>{
	public var key (default, null) : A;
	public var values (default, null) : ListType<B>;
	public function new(key:A, values:ListType<B>){
		this.key = key;
		this.values = values;
	}
	public function toString(){
		return ('key: ' + Std.string(key) + ' values: ' + values);
	}
		
}






	
