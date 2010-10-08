import org.sugar.xml.MacroFast;
class MacroFastDemo {
	public static function main(){
		var y = MacroFast.parseFile('assets/simple.xml');
		// generate --display completions below...
		trace(y.node.cd.node.artist.innerData);
		trace(y.nodes.cd[4].node.artist.innerData);
		trace(y.node.cd.elements[5].innerData);
	}

}