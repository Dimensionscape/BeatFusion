package bf.core;

import starling.display.DisplayObjectContainer;
import starling.events.EnterFrameEvent;
import haxe.io.BufferInput;
import openfl.display.LoaderInfo;
import openfl.events.ProgressEvent;
import bf.input.keyboard.KeyboardManager;
import bf.sound.SoundManager;
import bf._internal.macros.StarlingMacro;
import bf.asset.AssetManager;
import emitter.signals.Emitter;
import haxe.Json;
import haxe.Timer;
import openfl.display.Stage;
import openfl.geom.Rectangle;
import starling.core.Starling;
import openfl.display.Sprite;
import starling.events.Event;
import openfl.Lib;

/**
 * ...
 * @author Christopher Speciale
 */
 @:access(bf.core.Camera2D)
@:keep class Engine extends Emitter {
	public static var engine(default, null):Engine = _start();

	private static inline function _start():Engine {
		Timer.delay(_setEngine, 0);
		return null;
	}

	private static inline function _setEngine():Void {
		if (Starling.current == null) {
			if (Lib.current.stage != null) {
				engine = new Engine(Lib.current.stage);
			} else {
				_start();
			}
		}
	}

	public var starling(get, null):Starling;
	public var nativeStage:Stage;

	public var viewport:Rectangle;
	public var camera(get, null):Camera2D;

	private var _starling:Starling;

	private var _camera:Camera2D;
	public var overlay(get, never):Sprite;

	private function get_camera():Camera2D{
		return _camera;
	}
	private function get_starling():Starling {
		return _starling;
	}

	private function get_overlay():Sprite {
		return _starling.nativeOverlay;
	}

	private function new(stage:Stage) {
		super();

		this.nativeStage = stage;

		var viewportData:Null<String> = StarlingMacro.getDef("starling_viewport");

		if (viewportData != null) {
			var viewportObj = Json.parse(viewportData);
			viewport = new Rectangle(viewportObj.x, viewportObj.y, viewportObj.width, viewportObj.height);
		}

		#if html5
		stage.loaderInfo.addEventListener(ProgressEvent.PROGRESS, _onLoaderProgress);
		stage.loaderInfo.addEventListener(Event.COMPLETE, _onComplete);
		#else
		_init();
		#end
	}

	private function _onLoaderProgress(e:ProgressEvent):Void {}

	private function _onComplete(e:Event):Void {
		var loaderInfo:LoaderInfo = nativeStage.loaderInfo;

		loaderInfo.removeEventListener(ProgressEvent.PROGRESS, _onLoaderProgress);
		loaderInfo.removeEventListener(Event.COMPLETE, _onComplete);

		_init();
	}

	private function _onProgress():Void {}

	private function _init():Void {
		_starling = new Starling(Main, nativeStage, viewport);
		_starling.addEventListener(Event.CONTEXT3D_CREATE, _onContextCreated);
		_starling.addEventListener(Event.ROOT_CREATED, _onRootCreated);
		_starling.start();
		_starling.showStats = true;
		_starling.antiAliasing = 16;

	}

	private function _onContextCreated(e:Event):Void {
		_starling.removeEventListener(Event.CONTEXT3D_CREATE, _onContextCreated);
		AssetManager.init();
		SoundManager.init();
		KeyboardManager.start(_starling.nativeStage);
		_camera = new Camera2D();
		//_starling.addEventListener(EnterFrameEvent.ENTER_FRAME, _onEnterFrameEvent);
	}

	private function _onRootCreated(e:Event):Void{
		var root:DisplayObjectContainer = cast _starling.root;
		_camera.attach(root);
		

	}

	private function _onEnterFrameEvent(e:EnterFrameEvent):Void {
		// _starling.juggler.advanceTime(e.passedTime);
	}
}
