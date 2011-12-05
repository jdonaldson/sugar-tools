import org.sugar.tools.IterTools;
class IteratorDemo {
	public static function main(){
		var sitr = new StoredIterator(timerIterator());
		trace('timerIterator iterates over 10 time samples:');
		for (t in timerIterator()) trace(t);
		trace("it's different each time you run it:");
		for (t in timerIterator()) trace(t);
		trace("StoredIterator can save the values of any iterator on the first pass");
		trace('First iteration shows values directly from iterator:');
		for (s in sitr) trace(s); // values directly from iterator;
		trace('Second iteration shows stored values (which should be identical):');		
		for (s in sitr) trace(s); // stored values;

	}
	public static function timerIterator(): Iterator<Float>{
		var count = 0;
		return {
			next: function() return haxe.Timer.stamp(),
			hasNext: function() return count++ < 10
		}
	}
}