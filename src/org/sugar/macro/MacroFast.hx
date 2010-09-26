package org.sugar.macro;
import haxe.macro.Expr;
import haxe.macro.Context;
import neko.io.File;
import haxe.macro.Expr.Position;
import haxe.macro.Expr.ExprDef;

class MacroFast {	
	public static function main(){
		var y = construct('assets/simple.xml');
		// generate a --display completion below...
		trace(y.node.body);
	}
	
	@:macro public static function construct(expr:Expr) : Expr {
		var file_name:String;
		var error_msg = 'This function requires a bare string giving the xml file name';
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
			var o:ExprDef = child2exprdef(n.firstChild());
			var result = {
				expr:o,
				pos:Context.currentPos()
			}
			return result;
	}
	#if macro
	private static function att2fieldexpr(name:String, val:String) :{field:String, expr:Expr}{
		var pos = haxe.macro.Context.currentPos();
		var expr:Expr = {
			expr:EConst(CString(val)),
			pos:pos
		}
		var result:{field:String, expr:Expr} = {
			field:name,
			expr:expr
		}	
		return result;
	}
	
	private static function str2expr(s:String,pos:Position) : Expr {
		var exprdef = EConst(CString(s));
		return{ expr:exprdef, pos:pos}
	}
	
	
	
	private static function atts2EObjectDecl(xml:Xml) : {field:String, expr:Expr} {
		var pos = haxe.macro.Context.currentPos();
		var fields = new Array<{field:String, expr:Expr}>();
		var att_fields = new Array<{field:String, expr:Expr}>();
		for (a in xml.attributes()){
			trace(a);
			var result = {
				field:a,
				expr:str2expr(xml.get(a), pos)
			}
			att_fields.push(result);
		}
		
		var eobj = {
			expr:EObjectDecl(att_fields),
			pos:pos
		}
		
		return { field:'att', expr: eobj};
	}
	
	private static function children2EObjectDecl(xml:Xml) : {field:String, expr:Expr} {
		var pos = haxe.macro.Context.currentPos();
		var fields = new Array<{field:String, expr:Expr}>();
		var c_fields = new Array<{field:String, expr:Expr}>();
		for (e in xml.elements()){
			var expr = {
				expr:child2exprdef(e),
				pos:pos
			}
			
			
			var result = {
				field:e.nodeName,
				expr:expr
			}
			c_fields.push(result);
		}
		
		var eobj = {
			expr:EObjectDecl(c_fields),
			pos:pos
		}
		
		return { field:'node', expr: eobj};
	}
	
	
	private static function child2exprdef(x:Xml) : ExprDef{
		var fields = new Array<{field:String, expr:Expr}>();
		var pos = haxe.macro.Context.currentPos();
		var content_node = false;
		if (x.attributes().hasNext()) { 
			fields.push(atts2EObjectDecl(x));
			content_node = true;
		}
		if (x.elements().hasNext()) {
			fields.push(children2EObjectDecl(x));
			content_node = true;
		}
		var result:ExprDef;
		
		if (! content_node){
			var node_val = x.firstChild().nodeValue;
			result = EConst(CString(node_val));
		} else {
			result = EObjectDecl(fields);
		}

		return result;
	}
	#end
}



//simple.xml, taken from some xml tutorial site because I am lazy
/*<note>
<to>Tove</to>
<from>Jani</from>
<heading>Reminder</heading>
<body>Don't forget me this weekend!</body>
</note>*/

