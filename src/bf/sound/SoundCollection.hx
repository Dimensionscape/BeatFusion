package bf.sound;

import haxe.Json;
import openfl.errors.Error;
import openfl.events.DataEvent;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.utils.Object;

/**
 * ...
 * @author Christopher Speciale
 */
/**
	A SoundCollection provides a the means in order to designate which audio files to populate
	the SoundManager with.
**/
class SoundCollection extends EventDispatcher {
	public var data(default, null):Array<ISoundAsset>;

	public function new(?list:Array<ISoundAsset>) {
		super();
		if (list == null)
			list = [];

		data = list;
	}

	/**
		Adds a sound asset to the SoundCollection.

		@param soundAsset An anonymous structure or SoundAsset instance that contains the sounds
		asset path and unique id for referencing with the SoundManager.
	**/
	public function add(soundAsset:ISoundAsset):Void {
		if (exists(soundAsset))
			throw new Error("A sound asset with the same id already exists in this collection.");
		data.push(soundAsset);
		dispatchEvent(new DataEvent(Event.ADDED, false, false, '${soundAsset.id}:${soundAsset.path}'));
	}

	/**
		Adds a sound asset to the SoundCollection at a specified index.

		@param soundAsset An anonymous structure or SoundAsset instance that contains the sounds
		asset path and unique id for referencing with the SoundManager.
		@param index The index specified at which to add this sound asset object.
	**/
	public function addAt(soundAsset:ISoundAsset, index:Int):Void {
		data.insert(index, soundAsset);
		dispatchEvent(new DataEvent(Event.ADDED, false, false, '${soundAsset.id}:${soundAsset.path}'));
	}

	/**
		Adds a sound asset to the SoundCollection at a specified index.

		@param soundAsset The sound asset object to remove from the SoundCollection.
	**/
	public function remove(soundAsset:ISoundAsset):Void {
		if (exists(soundAsset)) {
			remove(soundAsset);
			dispatchEvent(new DataEvent(Event.REMOVED, false, false, '${soundAsset.id}'));
		}
	}

	/**
		Adds a sound asset to the SoundCollection at a specified index.

		@param index The index specified at which to remove a sound asset object.
	**/
	public function removeAt(index:Int):Void {
		if (exists(data[index])) {
			var soundAsset:ISoundAsset = data.splice(index, 1)[0];

			dispatchEvent(new DataEvent(Event.REMOVED, false, false, '${soundAsset.id}'));
		}
	}

	/**
		Removes all sound asset objects in the collection.
	**/
	public function removeAll():Void {
		data.resize(0);
		dispatchEvent(new DataEvent(Event.REMOVED, false, false, ''));
	}

	/**
		Returns a boolean value that determines whether or not the specified sound asset
		object exists within the collection.
	**/
	public function exists(soundAsset:ISoundAsset):Bool {
		for (item in data) {
			if (item.id == soundAsset.id) {
				return true;
			}
		}
		return false;
	}

	/**
		Disposes this SoundCollection.
	**/
	public function dispose():Void {
		data = null;
	}

	/**
		Returns a SoundCollection populated by JSON data.

		Example data: '{"sounds":[{"path":"<asset-path-here>, "id":"<sound-id-here>"}, {"path":"<asset-path-here>", "id":"<sound-id-here>"}]}'

		@param data The json string in which to populate the SoundCollection from.

	**/
	public static function fromJSON(data:String):SoundCollection {
		var soundCollection:SoundCollection = new SoundCollection();

		var jsonObject:Object = Json.parse(data);

		var jsonFields:Array<String> = Reflect.fields(jsonObject);

		if (jsonFields.length == 0)
			throw new Error("The data does not contain SoundAssets or can not be read.");

		for (field in jsonFields) {
			try {
				var soundAssets:Array<Dynamic> = Reflect.field(jsonObject, field);
				for (soundAsset in soundAssets) {
					soundCollection.add(cast soundAsset);
				}
			} catch (e:Dynamic) {
				throw new Error("The data can not be read.");
			}
		}
		return soundCollection;
	}

	/**
		Returns a SoundCollection populated by an object.

		Example Object: {"sounds":[{"path":"<asset-path-here>", "id":"<sound-id-here>"}, {"path":"<asset-path-here>", "id":"<sound-id-here>"}]}
		@param object The object in which to populate the SoundCollection from.

	**/
	public static function fromObject(object:Dynamic):SoundCollection {
		var soundCollection:SoundCollection = new SoundCollection();

		var objectFields:Array<String> = Reflect.fields(object);

		if (objectFields.length == 0)
			throw new Error("The object does not contain SoundAssets or can not be processed.");

		for (field in objectFields) {
			try {
				var soundAssets:Array<Dynamic> = Reflect.field(object, field);
				for (soundAsset in soundAssets) {
					soundCollection.add(cast soundAsset);
				}
			} catch (e:Dynamic) {
				throw new Error("The object can not be processed.");
			}
		}
		return soundCollection;
	}
}
