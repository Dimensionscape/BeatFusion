package bf.sound;

import haxe.Timer;
import haxe.ds.IntMap;
import haxe.ds.StringMap;
import openfl.errors.Error;
import openfl.Assets;
import openfl.events.DataEvent;
import openfl.events.Event;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundMixer;
import openfl.media.SoundTransform;
import bf.sound.SoundCollection;
import bf.sound.SoundObject;

/**
 * ...
 * @author Christopher Speciale
 */
/**
	The SoundManager provides a robust API that enables the organization of audio files and
	their subsequent usage through a static Class with features such as fade in and fade out. 
**/
@:access(bf.sound.SoundObject)
class SoundManager {
	private static inline var ADDED:String = "added";
	private static inline var REMOVED:String = "removed";

	/**
		The collection of sound items and asset path information to process.
	**/
	public static var soundCollection(default, set):SoundCollection;

	/**
		Determines whether or not a valid SoundManager has been initialized.
	**/
	public static var isInitialized:Bool = false;

	/**
		Determines whether or not a SFX sounds are muted.
	**/
	public static var sfxMuted(get, set):Bool;

	private static var _sfxMuted:Bool;

	private static var _activeSounds:Array<SoundObject>;

	private static var _soundMap:StringMap<Sound>;
	private static var _channelMap:IntMap<SoundChannel>;
	private static var _transformMap:IntMap<SoundTransform>;
	private static var _muteMap:IntMap<SoundTransform>;

	private static var _masterTransform:SoundTransform;
	private static var _currentMasterVolume:Float;

	private static var _sfxSoundChannels:Array<SoundChannel>;
	private static var _sfxSoundTransform:SoundTransform;
	private static var _sfxMutedVolume:Float;

	private static function get_sfxMuted():Bool {
		return _sfxMuted;
	}

	private static function set_sfxMuted(value:Bool):Bool {
		if (value) {
			_sfxMutedVolume = _sfxSoundTransform.volume;
			_sfxSoundTransform.volume = 0;

			for (soundChannel in _sfxSoundChannels) {
				soundChannel.soundTransform = _sfxSoundTransform;
			}
		} else {
			_sfxSoundTransform.volume = _sfxMutedVolume;

			for (soundChannel in _sfxSoundChannels) {
				soundChannel.soundTransform = _sfxSoundTransform;
			}
		}
		return _sfxMuted = value;
	}

	private static function set_soundCollection(value:SoundCollection):SoundCollection {
		_disposeSoundCollection();

		soundCollection = value;

		soundCollection.addEventListener(ADDED, _onSoundCollectionItemAdded);
		soundCollection.addEventListener(REMOVED, _onSoundCollectionItemRemoved);

		_loadSoundCollection();

		return soundCollection;
	}

	/**
		Initializes the KeyboardManager and binds the stage to it. Once started, it will begin listening to OpenFL for
		keyboard events.

		@param soundCollection The soundCollection used to determine which audio assets to process.
		@throws Error This error occurs when the SoundManager is already initialized. Dispose of it before attempting to
		call Init again.
	**/
	public static function Init(soundCollection:SoundCollection = null):Void {
		if (isInitialized)
			throw new Error("The SoundManager is already intialized and it must be disposed before calling Init again");
		isInitialized = true;
		_activeSounds = [];
		_soundMap = new StringMap();
		_channelMap = new IntMap();
		_transformMap = new IntMap();
		_muteMap = new IntMap();
		_sfxMuted = false;
		_masterTransform = new SoundTransform();
		_currentMasterVolume = 1;
		_sfxSoundChannels = [];
		_sfxSoundTransform = new SoundTransform();

		if (soundCollection == null) {
			soundCollection = new SoundCollection();
		}

		SoundManager.soundCollection = soundCollection;
	}

	/**
		Disposes of the current SoundManager.		
	**/
	public static function dispose():Void {
		if (!isInitialized)
			return;
		_disposeSoundCollection();
		_activeSounds.resize(0);
		_activeSounds = null;
		_masterTransform = null;
		clearAllChannels(true);
		_channelMap.clear();
		_channelMap = null;
		_soundMap = null;
		_muteMap = null;
		_transformMap = null;
		clearSFX();
		_sfxSoundChannels = null;
		_sfxSoundTransform = null;
		_sfxMuted = false;
		isInitialized = false;
	}

	/**
		Clears all channels of any active Sounds.

		@param stop A boolean value that determines whether or not any sound playing in a cleared channel should stop.		
	**/
	public static function clearAllChannels(stop:Bool = true):Void {
		for (activeSound in _activeSounds) {
			if (stop)
				activeSound._soundChannel.stop();
			_onSoundInactive(activeSound);
		}
	}

	/**
		Clears a specific channel of any active Sounds.

		@param channel The channel designated to be cleared.
		@param stop A boolean value that determines whether or not any sound playing in a cleared channel should stop.		
	**/
	public static function clearChannel(channel:Int, stop:Bool = true):Void {
		var soundObject:SoundObject = getSoundObject(channel);
		if (soundObject != null) {
			if (stop)
				soundObject._soundChannel.stop();
			_onSoundInactive(soundObject);
		}
	}

	/**
		Clears all SFX channels of any active Sounds.

		@param stop A boolean value that determines whether or not any SFX sound playing should stop.		
	**/
	public static function clearSFX(stop:Bool = true):Void {
		for (soundChannel in _sfxSoundChannels) {
			soundChannel.stop();
		}
		_sfxSoundChannels.resize(0);
	}

	/**
		Plays a track commonly refered to as background music, or BGM into a designated channel.

		@param id A string value that designates which sound to play based on its SoundCollection id.		
		@param loops The number of times the BGM should loop. A value of -1 assumes that a sound should loop forever.	
		@param channel The channel designated for playing this BGM sound.		
		@param startTime The position in which to begin playing this BGM. A BGM sound that loops infinitely will only
		start at this point the first time it is played.
	**/
	public static function playBGM(id:String, loops:Int = -1, channel:Int = 0, startTime:Float = 0.0):SoundObject {
		if (_channelMap.exists(channel)) {
			var soundObject:SoundObject = getSoundObject(channel);
			if (soundObject != null)
				_onSoundInactive(soundObject);

			_channelMap.get(channel).stop();
		}

		var sound:Sound = _soundMap.get(id);

		var soundChannel:SoundChannel = sound.play(startTime, loops, _transformMap.exists(channel) ? _transformMap.get(channel) : null);
		_channelMap.set(channel, soundChannel);		

		var soundObject:SoundObject = new SoundObject(sound, id, loops, channel, soundChannel);
		_activeSounds.push(soundObject);
		return soundObject;
	}

	/**
		Resumes playing any active BGM sound in a specified channel that has been stopped.

		@param channel The channel designated for resuming.		
	**/
	public static function resume(channel:Int = 0):Bool {
		var soundObject:SoundObject = getSoundObject(channel);

		if (soundObject != null) {
			if (soundObject.isPlaying)
				return false;
			_channelMap.set(channel, soundObject._resume());

			return true;
		}
		return false;
	}

	/**
		Sets the time position of any active BGM sound in a specified channel.

		@param time The time position in which to set the active BGM sound the channel.
		@param channel The channel designated to set the time.	
		@param resume A boolean value that determines whether or not the channel specified should
		resume playing.	
	**/
	public static function setTime(time:Float, channel:Int = 0, resume:Bool = true):Bool {
		var soundObject:SoundObject = getSoundObject(channel);
		if (soundObject != null) {
			soundObject.ignoreCallbacks = true;
			stop(channel, true);
			soundObject.ignoreCallbacks = false;
			soundObject._lastPosition = Math.min(Math.max(time, 0), soundObject.duration);
			if (resume && soundObject._lastPosition < soundObject.duration)
				_channelMap.set(channel, soundObject._resume());
			return true;
		}
		return false;
	}

	/**
		Stops a playing BGM sound in the designated channel.

		@param channel The channel designated for stopping.	
		@param pause A boolean value that determines whether or not the the active BGM sound
		in the channel should stop at its current time or be reset back to 0.	
	**/
	public static function stop(channel:Int = 0, pause:Bool = false):Void {
		if (_channelMap.exists(channel)) {
			var soundChannel:SoundChannel = _channelMap.get(channel);
			if (!pause)
				soundChannel.dispatchEvent(new Event(Event.COMPLETE));
			soundChannel.dispatchEvent(new Event(Event.CANCEL));

			soundChannel.stop();
		}
	}

	/**
		Plays a sound commonly refered to as a sound effect, or SFX.

		@param id A string value that designates which sound to play based on its SoundCollection id.	
			
	**/
	public static function playSFX(id:String):Void {
		#if flash
		if (getSFXVolume() == 0.0){
			return;
		}
		#end
		var sound:Sound = _soundMap.get(id);
		var soundChannel:SoundChannel = sound.play(0.0, 0, _sfxSoundTransform);
		_sfxSoundChannels.push(soundChannel);
		soundChannel.addEventListener(Event.SOUND_COMPLETE, _onSFXComplete);
	}

	/**
		Plays a sound from the SoundCollection. This method does not load the sound into a specified channel and
		cannot be controlled by most of the API included in this Class.

		@param id A string value that designates which sound to play based on its SoundCollection id.	
		@param startTime The position in which to begin playing this BGM. A BGM sound that loops infinitely will only
		start at this point the first time it is played.
		@param loops The number of times the BGM should loop. A value of -1 assumes that a sound should loop forever.	
		@param soundTransform The SoundTransform to pass into the sound being played.				
	**/
	public static function play(id:String, startTime:Float = 0.0, loops:Int = 0, soundTransform:SoundTransform = null):SoundChannel {
		var sound:Sound = _soundMap.get(id);
		return sound.play(startTime, loops, soundTransform);
	}

	/**
		Controls the volume and panning of all sounds played in the application. This method is synonmous with using OpenFL's
		SoundMixer Class.

		@param volume The volume designated in a range of 0 to 1.
		@param panning The panning in a range of -1 to 1.
			
	**/
	public static function setMasterVolume(volume:Float, panning:Float = 0):Void {
		_masterTransform.volume = volume;
		_masterTransform.pan = panning;
		SoundMixer.soundTransform = _masterTransform;
	}

	/**
		Returns the master volume of all sounds played in the application.			
	**/
	public static function getMasterVolume():Float {
		return _currentMasterVolume;
	}

	/**
		Controls the volume and optionally, the panning of a specified channel.

		@param volume The volume designated in a range of 0 to 1.
		@param channel The channel designated for controling the volume.	
		@param panning The panning in a range of -1 to 1.
			
	**/
	public static function setVolume(volume:Float, channel:Int = 0, panning:Float = 0):Void {
		if (_muteMap.exists(channel)) {
			var soundTransform:SoundTransform = _muteMap.get(channel);
			soundTransform.volume = volume;
		} else {
			_setVolume(volume, channel, panning);
		}
	}

	/**
		Returns the volume of a specified channel.	

		@param channel The channel designated in which to get the volume of.
	**/
	public static function getVolume(channel:Int):Float {
		if (_muteMap.exists(channel)) {
			return _muteMap.get(channel).volume;
		} else if (_transformMap.exists(channel)) {
			return _transformMap.get(channel).volume;
		}
		return 1;
	}

	/**
		Controls the volume of all SFX sounds played.

		@param volume The volume designated in a range of 0 to 1.
		@param panning The panning in a range of -1 to 1.
			
	**/
	public static function setSFXVolume(volume:Float, panning:Float = 0):Void {
		_sfxSoundTransform.volume = volume;
		_sfxSoundTransform.pan = panning;

		for (soundChannel in _sfxSoundChannels) {
			soundChannel.soundTransform = _sfxSoundTransform;
		}
	}

	/**
		Returns the volume of all SFX sounds played.			
	**/
	public static function getSFXVolume():Float {
		return _sfxSoundTransform.volume;
	}

	/**
		Mutes or unmutes a specified channel.

		@param on A boolean value that determines whether or not the channel is muted.
		@param channel The channel designated for muting or unmuting.	
			
	**/
	public static function mute(on:Bool, channel:Int = 0):Void {
		if (on) {
			if (_muteMap.exists(channel)) {
				var mutedSoundTransform:SoundTransform = _muteMap.get(channel);

				if (!_transformMap.exists(channel))
					setVolume(1, channel);

				var soundTransform:SoundTransform = _transformMap.get(channel);
				mutedSoundTransform.volume = soundTransform.volume;
				_setVolume(0, channel, 0);
			} else {
				if (!_transformMap.exists(channel))
					setVolume(1, channel);
				var soundTransform:SoundTransform = _transformMap.get(channel);

				var mutedSoundTransform:SoundTransform = new SoundTransform(soundTransform.volume);
				_muteMap.set(channel, mutedSoundTransform);

				_setVolume(0, channel, 0);
			}
		} else {
			if (_muteMap.exists(channel)) {
				var mutedSoundTransform:SoundTransform = _muteMap.get(channel);

				_setVolume(mutedSoundTransform.volume, channel, 0);
				_muteMap.remove(channel);
			}
		}
	}

	/**
		Mutes all sound played in this application.

		@param on A boolean value that determines whether all sounds should be muted.
			
	**/
	public static function masterMute(on:Bool):Void {
		if (on) {
			_currentMasterVolume = SoundMixer.soundTransform.volume;
			setMasterVolume(0);
		} else
			setMasterVolume(_currentMasterVolume);
	}

	/**
		Returns a boolean value that determines whether or not a specified channel is muted.

		@param channel The specified channel in which to check.
			
	**/
	public static function isMuted(channel:Int):Bool {
		return _muteMap.exists(channel);
	}

	/**
		Returns a boolean value that determines whether or not all sounds are muted in this application.
	**/
	public static function isMasterMuted():Bool {
		return _currentMasterVolume == 0;
	}

	/**
		Returns a boolean value that determines whether or not all SFX sounds are muted.
	**/
	public static function isSFXMuted():Bool {
		return _sfxMuted;
	}

	private static function _changeVolume(soundTransform:SoundTransform, channel:Int):Void {
		var soundObject:SoundObject = getSoundObject(channel);
		if (soundObject != null)
			soundObject.soundTransform = soundTransform;
	}

	public static function formatTime(time:Float):String {
		time = Std.int(time / 1000);
		var hours:String = Std.string(Math.floor(time / 3600));
		time %= 3600;
		var minutes:String = Std.string(Math.floor(time / 60));
		var seconds:String = Std.string(time % 60);

		if (hours.length == 1)
			hours = '0$hours';
		if (minutes.length == 1)
			minutes = '0$minutes';
		if (seconds.length == 1)
			seconds = '0$seconds';

		return '$hours:$minutes:$seconds';
	}

	public static function getSoundObject(channel:Int):SoundObject {
		for (activeSound in _activeSounds) {
			if (activeSound.channel == channel)
				return activeSound;
		}
		return null;
	}

	private static function _setVolume(volume:Float, channel:Int, panning:Float) {
		if (_transformMap.exists(channel)) {
			var soundTransform:SoundTransform = _transformMap.get(channel);
			soundTransform.volume = volume;
			soundTransform.pan = panning;
			_changeVolume(soundTransform, channel);
		} else {
			var soundTransform:SoundTransform = new SoundTransform(volume, panning);
			_transformMap.set(channel, soundTransform);
			_changeVolume(soundTransform, channel);
		}
	}

	private static function _onSFXComplete(e:Event):Void {
		var soundChannel:SoundChannel = cast e.currentTarget;
		soundChannel.removeEventListener(Event.SOUND_COMPLETE, _onSFXComplete);
		_sfxSoundChannels.remove(soundChannel);
	}

	private static function _onSoundInactive(soundObject:SoundObject):Void {
		_activeSounds.remove(soundObject);
		soundObject._dispose();
	}

	private static function _loadSoundCollection():Void {
		for (item in soundCollection.data) {
			_soundMap.set(item.id, Assets.getSound(item.path));
		}
	}

	private static function _disposeSoundCollection():Void {
		if (soundCollection != null) {
			soundCollection.removeEventListener(ADDED, _onSoundCollectionItemAdded);
			soundCollection.removeEventListener(REMOVED, _onSoundCollectionItemRemoved);
			soundCollection.dispose();
		}

		_soundMap.clear();
		_muteMap.clear();
		_transformMap.clear();
	}

	private static function _onSoundCollectionItemAdded(e:DataEvent):Void {
		var data:Array<String> = e.data.split(":");
		_soundMap.set(data[0], Assets.getSound(data[1]));
	}

	private static function _onSoundCollectionItemRemoved(e:DataEvent):Void {
		if (e.data.length == 0) {
			_soundMap.clear();
			return;
		}
		_soundMap.remove(e.data);
	}
}
