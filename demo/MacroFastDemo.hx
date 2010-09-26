import org.sugar.macro.MacroFast;
class MacroFastDemo {
	public static function main(){
		var y = MacroFast.construct('assets/simple.xml');
		// generate a --display completion below...
		trace(y.node.CD.node.ARTIST);
		
		//edit things as normal...
		y.node.CD.node.ARTIST = 'Bruce Springsteen';
		trace(y.node.CD.node.ARTIST);
	}
}