package bf.core;

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
@:keep class Engine extends Emitter
{
	public static var engine(default, null):Engine = _start();
	
	private static inline function _start():Engine{
		Timer.delay(_setEngine, 0);		
		return null;
	}
	
	private static inline function _setEngine():Void{
		if (Starling.current == null){
			if (Lib.current.stage != null){
				engine = new Engine(Lib.current.stage);
			} else {
				_start();
			}
		}
	}
	
	public var starling(get, null):Starling;
	
	private var _starling:Starling;
	public var overlay(get, never):Sprite;
	
	
	private function get_starling():Starling{
		return _starling;
	}
	
	private function get_overlay():Sprite{
		return _starling.nativeOverlay;
	}
	
	private function new(stage:Stage) 
	{
		super();
		
		var viewportData:Null<String> = StarlingMacro.getDef("starling_viewport");
		var viewport:Rectangle = null;
		
		if (viewportData != null){
			var viewportObj = Json.parse(viewportData);
			viewport = new Rectangle(viewportObj.x, viewportObj.y, viewportObj.width, viewportObj.height);	
		}
		
		_starling = new Starling(Main, stage, viewport);		
		_starling.addEventListener(Event.CONTEXT3D_CREATE, _onContextCreated);
		_starling.start();
		_starling.showStats = true;
			
	}
	
	private function _onContextCreated(e:Event):Void{
		_starling.removeEventListener(Event.CONTEXT3D_CREATE, _onContextCreated);
		AssetManager.init();
		SoundManager.init();
		KeyboardManager.start(_starling.nativeStage);		
	}
	
	
}

