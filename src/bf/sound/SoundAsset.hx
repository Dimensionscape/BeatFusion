package bf.sound;

/**
 * ...
 * @author Christopher Speciale
 */
/**
	The sound asset object that contains information about it's unique id and
	asset path used for a SoundCollection to populate the SoundManager.
**/
class SoundAsset implements ISoundAsset {
	/**
		The unique id referenced in the SoundManager to control playback.
	**/
	public var id:String;

	/**
		The OpenFL asset path in which to retrieve a Sound.
	**/
	public var path:String;

	public function new(id:String, path:String) {
		this.id = id;
		this.path = path;
	}
}
