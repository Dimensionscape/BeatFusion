package bf.input.keyboard;

import haxe.ds.IntMap;
import openfl.errors.Error;
import openfl.display.Stage;
import openfl.events.KeyboardEvent;
import bf.util.Set;
import bf.input.keyboard.KeyCode;
import openfl.utils.Function;

/**
 * ...
 * @author Christopher Speciale
 */
/**
	The KeyboardManager delivers lightweight API that enables access to keyboard events
	through simple callbacks, live key stroke information, and Character Code keypress without 
	the burden of heavier event dispatching architectures.
**/
class KeyboardManager {
	private static var _stage:Stage;
	private static var _keysDown:IntMap<Void->Void>;
	private static var _keysUp:IntMap<Void->Void>;
	private static var _keysPressed:Set<Int>;
	private static var _keyPressedCallback:(KeyCode, Int) -> Void;
	private static var _hasKeyPressedCallback:Bool = false;

	/**
		Determines whether or not a valid KeyboardManager has been initialized.
	**/
	public static var isInitialized(default, null):Bool = false;

	/**
		Determines whether or not a valid KeyboardManager is currently running.
	**/
	public static var isRunning(default, null):Bool = false;

	/**
		Initializes the KeyboardManager and binds the stage to it. Once started, it will begin listening to OpenFL for
		keyboard events.

		@param stage The current Stage to begin listening on for keyboard events.
		@throws Error This error occurs when the KeyboardManager is already running. Dispose of it before attempting to
		call start again.
	**/
	public static function start(stage:Stage):Void {
		if (isInitialized)
			throw new Error("The KeyboardManager is already running and it must be disposed before calling start() again.");

		KeyboardManager._stage = stage;

		_keysDown = new IntMap();
		_keysUp = new IntMap();
		_keysPressed = new Set();

		_stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
		_stage.addEventListener(KeyboardEvent.KEY_UP, _onKeyUp);

		isInitialized = isRunning = true;
	}

	/**
		Stops the KeyboardManager from listening to new keyboard events. Once stoped, you can call resume() in order
		to begin listening again if the KeyboardManager has not been disposed, or start() if it has been disposed. 
		A safe practice is to check the isInitialized property to be certain that a KeyboardManager has been properly 
		disposed of before running a new one or resuming one that is temporarily stopped. 

		@param dispose Disposes of the KeyboardManager and any registered callbacks. This method frees up system 
		resources for GC if set to true and completely clears the KeyboardManager. Once you	dispose of the 
		KeyboardManager, you must call the start method to run it again.
	**/
	public static function stop(dispose:Bool = false):Void {
		_stage.removeEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
		_stage.removeEventListener(KeyboardEvent.KEY_UP, _onKeyUp);

		isRunning = false;

		if (dispose) {
			_stage = null;

			_keysDown.clear();
			_keysDown = null;

			_keysUp.clear();
			_keysUp = null;

			_keysPressed.clear();
			_keysPressed = null;

			_keyPressedCallback = null;
			_hasKeyPressedCallback = false;

			isInitialized = false;
		}
	}

	/**
		Resumes the stopped KeyboardManager and begins listening to keyboard events again. You cannot resume a stopped 
		KeyboardManager once it has been disposed. Resuming a disposed KeyboardManager will throw an error. If you 
		have disposed of a KeyboardManager, you must call start() to continue processing keyboard events. If the
		KeyboardManager is already running, this method will simply return and do nothing.

		@throws Error This error occurs when the KeyboardManager has been disposed or has not been started previously.		
	**/
	public static function resume():Void {
		if (!isInitialized)
			throw new Error("You cannot resume a KeyboardManager that has been disposed or not started previously");
		if (isRunning)
			return;
		_stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
		_stage.addEventListener(KeyboardEvent.KEY_UP, _onKeyUp);

		isRunning = true;
	}

	/**
		Sets the callback that returns the key code and character code of the arbitrary key actively pressed. If a non-character 
		key is pressed, this this method will return 0.

		@param callback The callback function fired when a key is pressed. A function passed as the callback
		should expect an Int parameter.
	**/
	public static function setKeyPressedCallback(callback:(KeyCode, Int) -> Void):Void {
		_keyPressedCallback = callback;
		if (callback != null)
			_hasKeyPressedCallback = true;
	}

	/**
		Removes the callback that returns the key code and character code of the key actively pressed.
	**/
	public static function removeKeyPressedCallback():Void {
		_keyPressedCallback = null;
		_hasKeyPressedCallback = false;
	}

	/**
		Returns a Boolean that reflects whether or not a callback has been set to catch arbitrary key presses that 
		return a key code and character code.
	**/
	public static function hasKeyPressedCallback():Bool {
		return _hasKeyPressedCallback;
	}

	/**
		Returns a Boolean that reflects whether a specific key designated by it's keycode is pressed at the time the 
		method is called or the last time the KeyboardManager was running.

		@param keyCode The key code enum or integer that designates which key to check.	
		@throws Error This error occurs when the KeyboardManager has been disposed or has not been started previously.
	**/
	public static function isKeyDown(keyCode:KeyCode):Bool {
		if (!isInitialized)
			throw new Error("A KeyboardManager must be initialized in order to access this method");

		return _keysPressed.contains(keyCode);
	}

	/**
		Sets the callback for a specific key press.

		@param keyCode The key code enum or integer that designates which key the callback belongs to.	
		@param callback The callback function fired when a key is pressed. A function passed as the callback
		should not expect any parameters.
		@throws Error This error occurs when the KeyboardManager has been disposed or has not been started previously.
	**/
	public static function setKeyDownCallback(keyCode:KeyCode, callback:Void->Void):Void {
		if (!isInitialized)
			throw new Error("A KeyboardManager must be initialized in order to access this method");
		_keysDown.set(keyCode, callback);
	}

	/**
		Returns a Boolean that reflects whether or not a callback has been set to catch a specific key press designated
		by the key code.
		@param keyCode The key code enum or integer that designates which key the callback belongs to.
	**/
	public static function hasKeyDownCallback(keyCode:KeyCode):Bool {
		if (!isInitialized)
			return false;
		return _keysDown.exists(keyCode);
	}

	/**
		Removes the callback for a designated key code.
		@param keyCode The key code enum or integer that designates which key the callback to remove belongs to.
	**/
	public static function removeKeyDownCallback(keyCode:KeyCode):Void {
		if (_keysDown != null)
			_keysDown.remove(keyCode);
	}

	/**
		Sets the callback for a specific key release.

		@param keyCode The key code enum or integer that designates which key the callback belongs to.
		@param callback The callback function fired when a key is released. A function passed as the callback
		should not expect any parameters.
		@throws Error This error occurs when the KeyboardManager has been disposed or has not been started previously.
	**/
	public static function setKeyUpCallback(keyCode:KeyCode, callback:Void->Void):Void {
		if (!isInitialized)
			throw new Error("A KeyboardManager must be initialized in order to access this method");
		_keysUp.set(keyCode, callback);
	}

	/**
		Returns a Boolean that reflects whether or not a callback has been set to catch a specific key release designated
		by the key code.
	**/
	public static function hasKeyUpCallback(keyCode:KeyCode):Bool {
		if (!isInitialized)
			return false;
		return _keysUp.exists(keyCode);
	}

	/**
		Removes the callback for a designated key code.

		@param keyCode The key code enum or integer that designates which key the callback to remove belongs to.
	**/
	public static function removeKeyUpCallback(keyCode:KeyCode):Void {
		if (_keysUp != null)
			_keysUp.remove(keyCode);
	}

	/**
		Removes all key press callbacks for a designated key code.
	**/
	public static function removeAllKeyDownCallbacks():Void {
		if (_keysDown != null)
			_keysDown.clear();
	}

	/**
		Removes all key release callbacks for a designated key code.
	**/
	public static function removeAllKeyUpCallbacks():Void {
		if (_keysUp != null)
			_keysUp.clear();
	}

	private static function _onKeyDown(e:KeyboardEvent) {
		var keyCode:Int = e.keyCode;
		_keysPressed.add(e.keyCode);

		var callback:Function = _keysDown.get(keyCode);
		if (callback != null) {
			callback();
		}

		if (_hasKeyPressedCallback)
			_keyPressedCallback(keyCode, e.charCode);
	}

	private static function _onKeyUp(e:KeyboardEvent) {
		var keyCode:Int = e.keyCode;
		_keysPressed.remove(keyCode);

		var callback:Function = _keysUp.get(keyCode);
		if (callback != null) {
			callback();
		}
	}

	/**
		Returns an integer that represents the character code of a key code and the pressed status of the shift key.

		@param shift A boolean value that determines whether the shift key should be considered when converting the
		key code.
		@param keyCode The key code enum or integer that designates which keycode to convert.
	**/
	public static function getCharCode(keyCode:KeyCode, shift:Bool = false):Int {
		var key:Int = cast keyCode;
		if (!shift) {
			switch (key) {
				case BACKSPACE:
					return 8;
				case TAB:
					return 9;
				case ENTER:
					return 13;
				case ESCAPE:
					return 27;
				case SPACEBAR:
					return 32;
				case SEMICOLON:
					return 59;
				case EQUAL:
					return 61;
				case COMMA:
					return 44;
				case MINUS:
					return 45;
				case PERIOD:
					return 46;
				case SLASH:
					return 47;
				case BACKQUOTE:
					return 96;
				case LEFTBRACKET:
					return 91;
				case BACKSLASH:
					return 92;
				case RIGHTBRACKET:
					return 93;
				case QUOTE:
					return 39;
				default:
			}

			if (key >= (NUMBER_0 : Int) && key <= (NUMBER_9 : Int)) {
				return key - NUMBER_0 + 48;
			}

			if (key >= (A : Int) && key <= (Z : Int)) {
				return key - A + 97;
			}
		} else {
			switch (key) {
				case NUMBER_0:
					return 41;
				case NUMBER_1:
					return 33;
				case NUMBER_2:
					return 64;
				case NUMBER_3:
					return 35;
				case NUMBER_4:
					return 36;
				case NUMBER_5:
					return 37;
				case NUMBER_6:
					return 94;
				case NUMBER_7:
					return 38;
				case NUMBER_8:
					return 42;
				case NUMBER_9:
					return 40;
				case SEMICOLON:
					return 58;
				case EQUAL:
					return 43;
				case COMMA:
					return 60;
				case MINUS:
					return 95;
				case PERIOD:
					return 62;
				case SLASH:
					return 63;
				case BACKQUOTE:
					return 126;
				case LEFTBRACKET:
					return 123;
				case BACKSLASH:
					return 124;
				case RIGHTBRACKET:
					return 125;
				case QUOTE:
					return 34;
				default:
			}

			if (key >= (A : Int) && key <= (Z : Int)) {
				return key - A + 65;
			}
		}

		if (key >= (NUMPAD_0 : Int) && key <= (NUMPAD_9 : Int)) {
			return key - NUMPAD_0 + 48;
		}

		switch (key) {
			case NUMPAD_MULTIPLY:
				return 42;
			case NUMPAD_ADD:
				return 43;
			case NUMPAD_ENTER:
				return 44;
			case NUMPAD_DECIMAL:
				return 45;
			case NUMPAD_DIVIDE:
				return 46;
			case DELETE:
				return 127;
			case ENTER:
				return 13;
			case BACKSPACE:
				return 8;
			default:
				return 0;
		}

		return 0;
	}
}
