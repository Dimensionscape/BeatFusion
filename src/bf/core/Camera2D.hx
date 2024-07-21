package bf.core;

import starling.display.DisplayObjectContainer;
import starling.events.EventDispatcher;
import starling.display.Sprite;
import starling.events.Event;

class Camera2D extends EventDispatcher {
    public var x(get, set):Float;
    public var y(get, set):Float;    
	public var zoom(get, set):Float;
    public var rotation(get, set):Float;

	private var _x:Float;
	private var _y:Float;
	private var _zoom:Float;
	private var _rotation:Float;

	private var _target:DisplayObjectContainer;
	private var _minX:Float;
	private var _maxX:Float;
	private var _minY:Float;
	private var _maxY:Float;

	private function new(target:DisplayObjectContainer) {
        super();
        
        trace(target);
		this._target = target;
		this._x = 0;
		this._y = 0;
		this._zoom = 1;
		this._rotation = 0;
		this._minX = Math.NEGATIVE_INFINITY;
		this._maxX = Math.POSITIVE_INFINITY;
		this._minY = Math.NEGATIVE_INFINITY;
		this._maxY = Math.POSITIVE_INFINITY;
	}

	public inline function get_x():Float {
		return _x;
	}

	public inline function set_x(value:Float):Float {
		_x = Math.max(_minX, Math.min(_maxX, value));
		applyTransformations();
		return _x;
	}


	public inline function get_y():Float {
		return _y;
	}

	public inline function set_y(value:Float):Float {
		_y = Math.max(_minY, Math.min(_maxY, value));
		applyTransformations();
		return _y;
	}

	public inline function get_zoom():Float {
		return _zoom;
	}

	public inline function set_zoom(value:Float):Float {
		_zoom = value;
		applyTransformations();
		return _zoom;
	}

	public inline function get_rotation():Float {
		return _rotation;
	}

	public inline function set_rotation(value:Float):Float {
		_rotation = value;
		applyTransformations();
		return _rotation;
	}

	public inline function setPosition(x:Float, y:Float):Void {
		this.x = x;
		this.y = y;
	}

	public function setBoundaries(minX:Float, maxX:Float, minY:Float, maxY:Float):Void {
		this._minX = minX;
		this._maxX = maxX;
		this._minY = minY;
		this._maxY = maxY;
	}

	private function applyTransformations():Void {
		// Apply the camera transformations to the target
		_target.x = -_x * _zoom;
		_target.y = -_y * _zoom;
		_target.scaleX = _zoom;
		_target.scaleY = _zoom;
		_target.rotation = _rotation;

		// Dispatch an event to notify listeners of the transformation change
		dispatchEventWith(Event.CHANGE);
	}
}
