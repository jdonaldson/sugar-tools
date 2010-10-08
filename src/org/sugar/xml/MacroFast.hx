/*
 * Copyright (c) 2009, Justin Donaldson and The haXe Project Contributors
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

package org.sugar.xml;
import haxe.macro.Expr;
import haxe.macro.Context;
import neko.io.File;
import haxe.macro.Expr.Position;
import haxe.macro.Expr.ExprDef;
using org.sugar.tools.HashTools;
using org.sugar.tools.ListTools;
#if macro
using org.sugar.xml.MacroFast.MacroHelper;
#end

/**
 *  A utility class for reading in an xml file as a single object declaration.
 */
class MacroFast {	
	
/**
 * Creates an object declaration from a file reference given as a constant string. 
 */
	@:macro public static function parseFile(expr:Expr) : Expr {
		var file_name:String;
		var error_msg = 'This function requires a constant string giving the xml file name';
		switch(expr.expr){
			default : Context.error(error_msg, Context.currentPos());
			case EConst(c) : 
				switch(c) {
					default : Context.error(error_msg, Context.currentPos());
					case CString(s) : file_name = s;
				}
		}
			var fh = File.getContent(file_name);
			var n = Xml.parse(fh);
			return child2expr(n.firstChild());
	}
/**
 * Creates an object declaration from a constant string.
 */	
	@:macro public static function parseString(expr:Expr) : Expr {
		var xml:String;
		var error_msg = 'This function requires a constant string describing the xml';
		switch(expr.expr){
			default : Context.error(error_msg, Context.currentPos());
			case EConst(c) : 
				switch(c) {
					default : Context.error(error_msg, Context.currentPos());
					case CString(s) : var xml = s;
				}
		}
		return child2expr(Xml.parse(xml).firstChild());
	}
	
	#if macro
	
/**
 *  The helper function that handles the recursive building of the object declaration.
 */
	private static function child2expr(x:Xml) : Expr{
		var pos = Context.currentPos();
		var fields = new Array<ObjField>();
		
		var nodeType = function(x:Xml){return Std.string(x.nodeType);}
		var children = x.groupByHash(nodeType);
		
		for (c in children.keys()){
			switch(c){
				default: continue;
				case 'element': {
					var nodeName = function(x:Xml){ return Std.string(x.nodeName); }
					var els = children.get(c).groupByHash(nodeName);
					var childmap = function(name:String) { 
						return child2expr(els.get(name).first()).toField(name);		
					}
					var node = EObjectDecl(els.keys().mapIter(childmap).array()).toExpr(pos).toField('node');	
					fields.push(node);
					
					var nodesmap = function(name:String){
						return EArrayDecl(els.get(name).map(child2expr).array()).toExpr(pos).toField(name);
					}
					
					var nodes = EObjectDecl(els.keys().mapIter(nodesmap).array()).toExpr(pos).toField('nodes');
					fields.push(nodes);
					
					var child2expr = function(c:Xml){ return child2expr(c); }
					var vals = children.get(c).map(child2expr).array();
					var elements = EArrayDecl(vals).toExpr(pos).toField('elements');
					fields.push(elements);
					
				}
				case 'pcdata':{
					var str = children.get(c).join('');
					fields.push(EConst(CString(str)).toExpr(pos).toField('innerData'));
				}
			}
		}
		var str2Expr = function(name:String) : ObjField{
			return EConst(CString(x.get(name))).toExpr(pos).toField(name);
		}
		if (x.attributes().hasNext()){
			var att = EObjectDecl(x.attributes().mapIter(str2Expr).array()).toExpr(pos).toField('att');
			fields.push(att);
		}
		
		return EObjectDecl(fields).toExpr(pos);
	}
	#end
}


#if macro

typedef ObjField = { field:String, expr:Expr }

/**
 *  simple functions to ease the creation of macro related enums.
 */
class MacroHelper{
	public static function toExpr(exprdef:ExprDef, pos:Position){
		return{
			expr:exprdef,
			pos:pos
		}
	}
	public static function toField(expr:Expr, field:String){
		return{
			field:field,
			expr:expr
		}
	}
	
}
#end
