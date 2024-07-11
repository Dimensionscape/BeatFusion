package bf.sound;

import openfl.Lib;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundTransform;

/**
 * ...
 * @author Christopher Speciale
 */
/**
	A sound object, which can only be instantiated by the SoundManager, that contains relevant information
	regarding the active BGM sound in a channel.
**/
class SoundObject {
	/**
		The id which represents the sound in the SoundManager that this SoundObject is linked to.
	**/
	public var id:String;

	/**
		A boolean value that determines whether or not the sound linked to this SoundObject will loop
		continuously.
	**/
	public var loop:Bool;

	/**
		The channel that this SoundObject belongs to.
	**/
	public var channel(default, null):Int;

	/**
		The soundTransform of the channel that this SoundObject belongs to.
	**/
	public var soundTransform(get, set):SoundTransform;

	/**
		The duration of the sound that this SoundObject is linked to.
	**/
	public var duration(get, null):Float;

	/**
		The current time position of the sound that this SoundObject is linked to, in miliseconds.
	**/
	public var currentTime(get, null):Float;

	/**
		A boolean value that determines whether or not the sound linked to this SoundObject is 
		currently playing.
	**/
	public var isPlaying(default, null):Bool = false;

	/**
		A boolean value that determines whether or not callbacks such as onStop or onComplete
		should be ignored.
	**/
	public var ignoreCallbacks:Bool = false;

	private var _onComplete:Dynamic->Void;
	private var _onCompleteArgs:Array<Dynamic>;
	private var _onStop:Dynamic->Void;
	private var _onStopArgs:Array<Dynamic>;
	private var _loops:Int;
	private var _sound:Sound;
	private var _soundChannel:SoundChannel;
	private var _lastPosition:Float;
	private var _resetTime:Bool = false;
	private var _fadeInID:UInt;
	private var _fadeOutID:UInt;
	private var _fadeInTicks:Int;
	private var _fadeOutTicks:Int;
	private var _fadeTransform:SoundTransform;

	private function set_soundTransform(value:SoundTransform):SoundTransform {
		return _soundChannel.soundTransform = value;
	}

	private function get_soundTransform():SoundTransform {
		return _soundChannel.soundTransform;
	}

	private function get_duration():Float {
		return _sound.length;
	}

	private function get_currentTime():Float {
		if (isPlaying)
			return _soundChannel.position;
		else
			return _lastPosition;
	}

	private function new(sound:Sound, id:String, loops:Int, channel:Int, soundChannel:SoundChannel) {
		_sound = sound;
		this.id = id;
		_loops = loops;
		if (loops == -1)
			loop = true;
		this.channel = channel;
		_soundChannel = soundChannel;
		_soundChannel.addEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
		_soundChannel.addEventListener(Event.CANCEL, _onSoundStopped);
		_soundChannel.addEventListener(Event.COMPLETE, _onSoundResetTime);
		isPlaying = true;
	}

	/**
		Sets the callback that occurs when the sound playing completes. This callback will fire after every
		subsequent loop as well.

		@param callback The callback function fired when the sound completes a single loop.
		@param args The arguments specified to pass into the callback.
	**/
	public function onComplete(callback:Dynamic->Void, args:Array<Dynamic> = null):SoundObject {
		_onComplete = callback;
		_onCompleteArgs = args;
		return this;
	}

	/**
		Sets the callback that occurs when the channel this sound object belongs to is stopped. This callback does 
		not fire when a sound completes.

		@param callback The callback function fired when the sound stops.
		@param args The arguments specified to pass into the callback.
	**/
	public function onStop(callback:Dynamic->Void, args:Array<Dynamic> = null):SoundObject {
		_onStop = callback;
		_onStopArgs = args;
		return this;
	}

	/**
		Specifies that the sound played should fade in over time. Mute control will be overriden by the 
		fade in. Ensure that fade in does not occur when your application is supposed to be muted. Once
		the fade in beings, until it ends, it will also override any volume control. Note: This will
		be corrected in the future.

		@param time The callback function fired when the sound stops.
		@param interval The interval, in milliseconds, in which to update the fade increment.
		@throws Error This error occurs when the fade time or interval is longer than the sound duration.
	**/
	public function fadeIn(time:UInt, interval:Int = 50):SoundObject {
		var currentVolume:Float = soundTransform.volume;
		_fadeTransform = new SoundTransform(0, soundTransform.pan);
		_soundChannel.soundTransform = _fadeTransform;
		if (time > duration || interval > duration)
			throw new Error("Fade in time or interval cannot be longer than the audio duration.");

		_fadeInTicks = Math.round(time / interval);
		var advance:Float = currentVolume / _fadeInTicks;
		_fadeInID = Lib.setInterval(_fadeInInterval, interval, [advance]);
		return this;
	}

	/**
		Specifies that the sound played should fade out over time. Mute control will be overriden by the 
		fade out. Ensure that fade out does not occur when your application is supposed to be muted. Once
		the fade out beings, until it ends, it will also override any volume control. Note: This will
		be corrected in the future.

		@param time The callback function fired when the sound stops.
		@param interval The interval, in milliseconds, in which to update the fade increment.
		@throws Error This error occurs when the fade time or interval is longer than the sound duration.
	**/
	public function fadeOut(time:Int, interval:Int = 50):SoundObject {
		if (time > duration || interval > duration - time)
			throw new Error("Fade out time or interval cannot be longer than the audio duration.");

		var fadeTime:UInt = Std.int(duration - time);
		Lib.setTimeout(_startFadeOut, time, [fadeTime, interval]);
		return this;
	}

	private function _dispose():Void {
		_soundChannel.removeEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
		_soundChannel.removeEventListener(Event.CANCEL, _onSoundStopped);
		_soundChannel.removeEventListener(Event.COMPLETE, _onSoundResetTime);
		_onComplete = null;
		_onCompleteArgs = null;
		_onStop = null;
		_onStopArgs = null;
		soundTransform = null;
		_soundChannel = null;
		_sound = null;
		_fadeTransform = null;
	}

	private function _onSoundResetTime(e:Event):Void {
		_resetTime = true;
	}

	private function _onSoundComplete(e:Event):Void {
		_lastPosition = duration;
		isPlaying = false;
		if (loop){
			SoundManager.resume(channel);
			#if flash
				var volume:Float = SoundManager.getVolume(channel);
				SoundManager.setVolume(volume, channel);
			#end
		}
		if (_onComplete != null && !ignoreCallbacks) {
			Reflect.callMethod(this, _onComplete, _onCompleteArgs);
		}
	}

	private function _onSoundStopped(e:Event):Void {
		isPlaying = false;

		_soundChannel.removeEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
		_soundChannel.removeEventListener(Event.CANCEL, _onSoundStopped);
		_soundChannel.removeEventListener(Event.COMPLETE, _onSoundResetTime);

		_lastPosition = _resetTime ? 0 : (_soundChannel.position == 0) ? _lastPosition : _soundChannel.position;

		_resetTime = false;
		if (_onStop != null && !ignoreCallbacks) {
			Reflect.callMethod(this, _onStop, _onStopArgs);
		}
	}

	private function _startFadeOut(time:Int, interval:Int):Void {
		var currentVolume:Float = soundTransform.volume;
		_fadeTransform = new SoundTransform(currentVolume, soundTransform.pan);
		_fadeOutTicks = Math.round(time / interval);
		var advance:Float = currentVolume / _fadeOutTicks;

		_fadeOutID = Lib.setInterval(_fadeOutInterval, interval, [advance]);
	}

	private function _fadeInInterval(advance:Float):Void {
		_fadeTransform.volume += advance;
		_soundChannel.soundTransform = _fadeTransform;
		_fadeInTicks--;
		if (_fadeInTicks < 0) {
			Lib.clearInterval(_fadeInID);
		}
	}

	private function _fadeOutInterval(advance:Float):Void {
		_fadeTransform.volume -= advance;
		_soundChannel.soundTransform = _fadeTransform;
		_fadeOutTicks--;
		if (_fadeOutTicks < 0) {
			Lib.clearInterval(_fadeOutID);
		}
	}

	private function _resume(addListeners:Bool = true):SoundChannel {
		if (currentTime == duration)
			_lastPosition = 0;
		_soundChannel = _sound.play(currentTime, _loops, soundTransform);
		_soundChannel.addEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
		_soundChannel.addEventListener(Event.CANCEL, _onSoundStopped);
		_soundChannel.addEventListener(Event.COMPLETE, _onSoundResetTime);

		isPlaying = true;
		return _soundChannel;
	}
}
