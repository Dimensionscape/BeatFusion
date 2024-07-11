package bf.util;

import haxe.ds.IntMap;

/**
 * ...
 * @author Christopher Speciale
 */
class IntBoolMap {
	private var _intMap:IntMap<Int>;

	public function new() {
		_intMap = new IntMap();
	}

	public function get(key:Int):Null<Bool> {
		return _intMap.exists(key);
	}

	public function set(key:Int, value:Bool):Void {
		if (value)
			_intMap.set(key, 0);
		else
			_intMap.remove(key);
	}

	public function clear():Void {
		_intMap.clear();
	}
}
