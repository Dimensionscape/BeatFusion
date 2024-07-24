package bf.core;

import openfl.geom.Point;
import starling.display.Sprite;
import starling.animation.Tween;
import starling.animation.Juggler;
import starling.display.DisplayObjectContainer;
import starling.events.EventDispatcher;
import starling.events.Event;
import bf.effects.CameraEffect;

class Camera2D extends EventDispatcher {
	public var overlay(get, null):Sprite;

	public var x(get, set):Float;
	public var y(get, set):Float;
	public var zoom(get, set):Float;
	public var rotation(get, set):Float;
	// Getter returns a copy! editing this value doesnt do anything, you must set it.
	public var focalPoint(get, set):Point;

	private var _overlay:Sprite;
	private var _x:Float;
	private var _y:Float;
	private var _zoom:Float;
	private var _rotation:Float;

	private var _target:DisplayObjectContainer;
	private var _minX:Float;
	private var _maxX:Float;
	private var _minY:Float;
	private var _maxY:Float;

	private var _focalPoint:Point;
	private var _juggler:Juggler;

	private inline function get_focalPoint():Point {
		return _focalPoint.clone();
	}

	private inline function set_focalPoint(value:Point):Point {
		_focalPoint = value;
		if (_target != null) {
			_updateFocalPoint();
		}
		return value;
	}

	private function _updateFocalPoint():Void {
		_target.pivotX = _focalPoint.x;
		_target.pivotY = _focalPoint.y;
	}

	private function new() {
		super();
		this._x = 0;
		this._y = 0;
		this._zoom = 1;
		this._rotation = 0;
		this._minX = Math.NEGATIVE_INFINITY;
		this._maxX = Math.POSITIVE_INFINITY;
		this._minY = Math.NEGATIVE_INFINITY;
		this._maxY = Math.POSITIVE_INFINITY;
		this._focalPoint = new Point(0, 0);

		trace(this._maxY);

		_juggler = Engine.engine.starling.juggler;
		_overlay = new Sprite();
		Engine.engine.starling.stage.addChildAt(_overlay, 0);
	}

	public function attach(target:DisplayObjectContainer):Void {
		if (target != null) {
			this._target = target;
			applyTransformations();
			_updateFocalPoint();
		} else {
			throw "Target DisplayObjectContainer cannot be null.";
		}
	}

	public function detach():Void {
		this._target = null;
	}

	private inline function get_overlay():Sprite {
		return _overlay;
	}

	private inline function get_x():Float {
		return _x;
	}

	private inline function set_x(value:Float):Float {
		_x = Math.max(_minX, Math.min(_maxX, value));
        if(_target != null){
            applyTranslationX();
        }		
		_dispatchChangeEvent();
		return _x;
	}

	private inline function get_y():Float {
		return _y;
	}

	private inline function set_y(value:Float):Float {
		_y = Math.max(_minY, Math.min(_maxY, value));
        if(_target != null){
		    applyTranslationY();
        }
		_dispatchChangeEvent();
		return _y;
	}

	private inline function get_zoom():Float {
		return _zoom;
	}

	private inline function set_zoom(value:Float):Float {
		_zoom = value;
		applyTransformations();
		return _zoom;
	}

	private inline function get_rotation():Float {
		return _rotation;
	}

	private inline function set_rotation(value:Float):Float {
		_rotation = value;
		applyTransformations();
		return _rotation;
	}

	public inline function setPosition(x:Float, y:Float):Void {
		_x = x;
		_y = y;
		applyTranslation();
		_dispatchChangeEvent();
	}

	public function setBoundaries(minX:Float, maxX:Float, minY:Float, maxY:Float):Void {
		this._minX = minX;
		this._maxX = maxX;
		this._minY = minY;
		this._maxY = maxY;
	}

	public function applyEffect(effect:CameraEffect):Void {
		switch (effect) {
			case Bounce(intensity, duration):
				bounce(intensity, duration);
			case EaseTo(x, y, duration):
				easeTo(x, y, duration);
			case EaseX(value, duration):
				easeX(value, duration);
			case EaseY(value, duration):
				easeY(value, duration);
			case EaseZ(value, duration):
				easeZ(value, duration);
			case Shake(intensity, duration):
				shake(intensity, duration);
				// Add other effects here
		}
	}

	private function bounce(intensity:Float, duration:Float):Void {
		if (_target != null) {
			var originalZoom = _zoom;
			var bounceIn = new Tween(this, duration / 2);
			bounceIn.animate("zoom", originalZoom + intensity);
			bounceIn.onComplete = function() {
				var bounceOut = new Tween(this, duration / 2);
				bounceOut.animate("zoom", originalZoom);
				_juggler.add(bounceOut);
			}
			_juggler.add(bounceIn);
		}
	}

	private function easeTo(x:Float, y:Float, duration:Float = 0.5):Void {
		var properties:Dynamic = {
			"x": -(_x + x) * _zoom,
			"y": -(_y + y) * _zoom
		};
		_juggler.tween(_target, duration, properties);
	}

	private function easeX(value:Float, duration:Float = 0.5):Void {
		var properties:Dynamic = {
			"x":x + value
		};
		_juggler.tween(this, duration, properties);
		_juggler.delayCall(_dispatchChangeEvent, duration);
	}

	private function easeY(value:Float, duration:Float = 0.5):Void {
		var properties:Dynamic = {
			"y": y + value
		};
		_juggler.tween(this, duration, properties);
		_juggler.delayCall(_dispatchChangeEvent, duration);
	}

	private function easeZ(value:Float, duration:Float = 0.5):Void {
		var properties:Dynamic = {
			"zoom": zoom + value
		};

		_juggler.tween(this, duration, properties);
		_juggler.delayCall(_dispatchChangeEvent, duration);
	}

	private function shake(intensity:Float, duration:Float):Void {
		if (_target != null) {
			var originalX = _target.x;
			var originalY = _target.y;
			_juggler.repeatCall(function() {
				_target.x = originalX + (Math.random() - 0.5) * intensity;
				_target.y = originalY + (Math.random() - 0.5) * intensity;
			}, 0.05, Math.ceil(duration / 0.05));
			_juggler.delayCall(function() {
				_target.x = originalX;
				_target.y = originalY;
				_dispatchChangeEvent();
			}, duration);
		}
	}

	private function applyTransformations():Void {
		if (_target != null) {
			_target.x = -_x * _zoom;
			_target.y = -_y * _zoom;
			_target.scaleX = _zoom;
			_target.scaleY = _zoom;
			_target.rotation = _rotation;
			_dispatchChangeEvent();
		}
	}

	private inline function applyTranslation():Void {
        if (_target != null) {
	       	applyTranslationX();
		    applyTranslationY();
        }
	}

	private inline function applyTranslationX():Void {		
			_target.x = -_x * _zoom;		
	}

	private inline function applyTranslationY():Void {
			_target.y = -_y * _zoom;
	
	}

	private inline function _dispatchChangeEvent():Void {
		dispatchEventWith(Event.CHANGE);
	}
}
