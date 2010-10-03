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


/**
	The SugarList class provides a List class based on conventional head/tail pointers.  This class is intended
	to be a drop in replacement for the base List class, and all functions are overridden so that they work with pointers.
	Some additional basic functionality for inserting elements is also included.
**/
package org.sugar.collections;
import haxe.FastList;


class SugarList<T> extends List<T> {
	private var head : FastCell<T>;
	private var tail : FastCell<T>;
	// inheriting length(default,null) : Int from List
	
	public function new(){
		super();
	}

	/**
		Add an element at the end of the list.
	**/
	public override function add( item : T ){
		
		var c = new FastCell<T>(item,null);
		
		if (length == 0) { 
			head = c; 
			tail = c;
		} else {
			tail.next = c;
			tail = c;
		}
		length++;
		
	}
  

	/**
		Returns a list filtered with [f]. The returned list
		will contain all elements [x] for which [f(x) = true].
		Note that filter will actually produce a SugarList<T> rather than List<T>.
		The List type is maintained in the header to preserve Type equivalence between
		List and SugarList.
	**/
	public override function filter( f : T -> Bool){
		var l2 = new SugarList<T>();
		var l = iterator();
		for (i in l) if (f(i)) l2.add(i);
		return untyped l2; // a Type dodge is required here
	}
	
	/**
		Returns the first element of the list, or null
		if the list is empty.
	**/
	public override function first() : T{
		return if( head == null ) null else head.elt;
	}
	
	/**
		Join the element of the list by using the separator [sep].
	**/
	public override function join(sep : String){
		var s = new StringBuf();
		var first = true;
		var l = iterator();
		for (i in l){
			if (first) first = false;
			else s.add(sep);
			s.add(i);
		}
		return s.toString();
	}
	
	/**
		Returns the last element of the list, or null
		if the list is empty.
	**/
	public override function last() : T {
		return if (tail == null) null else tail.elt;
	}
	
	/**
		Returns a new list where all elements have been converted
		by the function [f].
		Note that map will actually produce a SugarList<X> rather than List<X>.
		The List type is maintained in the header to preserve Type equivalence between
		List and SugarList.
	**/	
	public override function map<X>(f : T -> X) : List<X>{ 
		var b = new SugarList<X>();
		var l = iterator();
		for (i in l) b.add(f(i));
		return untyped b; // another Type dodge
	}
	
	/**
		Removes the first element of the list and
		returns it or simply returns null if the
		list is empty.
	**/
	public override function pop() : T {
		if (head == null) return null;
		var x = head.elt;
		head = head.next;
		length--;
		return x;
		
	}
	
	/**
		Push an element at the beginning of the list.
	**/
	public override function push( item : T ){
		var c = new FastCell<T>(item, head);
		head = c;
		length++;
	}	
	
	/**
		Remove the first element that is [== v] from the list.
		Returns [true] if an element was removed, [false] otherwise.
	**/
	public override function remove( v : T ) : Bool{
		var prev:FastCell<T> = null;
		var cur = head;
		while (cur != null){
			if (cur.elt == v) {
				length--;
				if (cur == head) {  // if cur == head, reset head, set the 'previous' node to be the next node.
					head = cur.next;
					prev = cur.next;
				} else prev.next = prev.next.next; // set the previous node to be the node after
				
				if (cur == tail) tail = prev; // if cur is the tail, set the tail to be the previous node.
				
				return true;
			}
			
			prev = cur;
			cur = cur.next;
			
		}
		return false;
	}

	/**
		Applies the function [f] over each element in the List.  It will insert
		the element [v2] into the list after [v1], or after the first element that returns a True result from [f].
		Returns True if successful, false if not.
	**/		
	public function insertAfter( ?v1 : T, v2 : T, ?f: T->Bool ) : Bool{
		if (v2 == null && f == null) return false;
		if (f == null) f = function(x:Dynamic) {return x == v1;}
		
		var cur = head;
		while (cur != null){
			if (f(cur.elt)){
				var c = new FastCell<T>(v2,cur.next);
				cur.next = c;
				if (c.next == null) tail = c;
				return true;
			}
			cur = cur.next;
		}
		return false;
	}

	/**
		Applies the function [f] over each element in the List.  It will insert
		the element [v2] into the list before [v1], or before the first element that returns a True result from [f].
		Returns True if successful, false if not.
	**/
	public function insertBefore( ?v1 : T, v2 : T, ?f: T->Bool ) : Bool{
		if (v2 == null && f == null) return false;
		if (f == null) f = function(x:Dynamic) {return x == v1;}
	
		var cur = head;
		var prev:FastCell<T> = null;
		while (cur != null){
		
				if (f(cur.elt)){
					var c = new FastCell<T>(v2, cur);
					if (prev == null) head = c;
					else prev.next = c;
					return true;
				}
				prev = cur;
				cur = cur.next;
		}
			
		return false;

	}
	
	/**
		Returns a displayable representation of the String.
	**/
	public override function toString(){
		var s = new StringBuf();
		var first = true;
		var l = iterator();
		s.add("{");
		for (i in l){
			if (first) first = false;
			else s.add(", ");
			s.add(i);
		}
		s.add("}");
		return s.toString();
	}
	
	/**
		Makes the list empty.
	**/
	public override function clear(){
		head = null; tail = null; length = 0;
	}
	
	/**
		Tells if a list is empty.
	**/
	public override function isEmpty(){
		return head == null;
	}
	
	/**
		Returns an iterator on the elements of the list.
	**/
	public override function iterator() : Iterator<T> {
		var l = head;
		return {
			next: function() {
				var k = l;
				l = k.next;
				return k.elt;
			},
			hasNext: function(){
				return l != null;
			}
		}
	}
	


}
	
