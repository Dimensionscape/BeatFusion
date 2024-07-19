package bf.graphics;

import starling.core.Starling;
import starling.animation.Juggler;

@:access(bf.graphics.Animation)
@:generic
class AnimatedSprite<T:KeyType> extends BaseSprite {
	private var _animationMap:Map<T, Animation>;
	private var _juggler:Juggler;
	private var _currentKey:T;

	public var juggler(get, set):Juggler;

	private inline function get_juggler():Juggler {
		return _juggler;
	}

	private inline function set_juggler(value:Juggler):Juggler {
		if (_juggler == value) {
			return value;
		}

		if (value == null) {
			_detatchJuggler();
			return value;
		}

		return _attachJuggler(value);
	}

	public var current(get, null):Animation;

	private var _current:Animation;

	private inline function get_current():Animation {
		return _current;
	}

	public function new(?juggler:Juggler) {
		super();
		_animationMap = new Map();

		if (juggler == null) {
			_juggler = Starling.current.juggler;
		}
	}

	public inline function play(?key:T):Animation {
		if (_currentKey != key && key != null) {
			setCurrent(key);
		}

		_current.play();

		return _current;
	}

	public inline function setCurrent(key:T):Void {
		if (_current != null) {
			_current.stop();
			removeChild(_current);
		}

		_current = get(key);
		_currentKey = key;

		addChild(_current);
	}

	public inline function stop():Void {
		if (_current == null) {
			return;
		}

		_current.stop();
	}

	public inline function resume():Void {
		if (_current == null) {
			return;
		}

		_current.play();
	}

	public inline function isPlaying():Bool {
		return _current != null && _current.isPlaying;
	}

	public inline function get(key:T):Animation {
		return _animationMap.get(key);
	}

	public inline function exists(key:T):Bool {
		return _animationMap.exists(key);
	}

	public inline function set(key:T, animation:Animation):Animation {
		_animationMap.set(key, animation);
		animation.animID = juggler.add(animation);

		return animation;
	}

	private function _detatchJuggler():Void {
		for (animation in _animationMap) {
			_juggler.removeByID(animation.animID);
		}

		_juggler = null;
	}

	private function _attachJuggler(juggler:Juggler):Juggler {
		for (animation in _animationMap) {
			if (_juggler != null) {
				_juggler.removeByID(animation.animID);
			}
			juggler.addWithID(animation, animation.animID);
		}

		return _juggler = juggler;
	}
}

@:multiType
abstract KeyType(Dynamic) from String to String from Int to Int {
	// inline function new(v:Dynamic) this = v;
}
