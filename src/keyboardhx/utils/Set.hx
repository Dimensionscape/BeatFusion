package keyboardhx.utils;
import openfl.utils.Object;
import haxe.ds.Map;

/**
 * ...
 * @author Christopher Speciale
 */
@:generic
abstract Set<T>(Map<Dynamic, Bool>) from Object to Object
{
	public inline function new():Void{
		this = new Map<Dynamic, Bool>();
	}
	
	public inline function iterator():Iterator<T>{
		return this.keys();
	}
	
	public inline function add(element:T):Bool{
		if (this.exists(element)){
			return false;
		}
		
		this.set(element, true);
		return true;
	}
	
	public inline function clear():Void{
		this.clear();
	}
	
	public inline function contains(element:T):Bool{
		return this.exists(element);
	}
	
	public inline function isEmpty():Bool{
		return !this.iterator().hasNext();
	}
	
	public inline function remove(element:T):Bool{
		return this.remove(element);
	}
	
	public inline function size():Int{
		var size:Int = 0;
		var iterator:Iterator<T> = this.keys();
		
		for (element in iterator){
			size++;
		}
		
		return size;
	}
	
	@:to
	public inline function toArray():Array<T>{
		var arr:Array<T> = [];
		var iterator:Iterator<T> = this.keys();
		
		for (element in iterator){
			arr.push(element);
		}
		
		return arr;
	}

	@:to
	public inline function toString():String{
		return toArray().toString(); 
	}
	
	@:from
	public static inline function fromArray<T>(array:Array<T>):Set<T>{
		var set:Set<T> = new Set();
		for (item in array){
			set.add(item);
		}
		
		return set;
	}

}