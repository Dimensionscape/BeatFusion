package bf.asset;

import bf.asset.Spritesheets;
import openfl.display.BitmapData;
import starling.textures.Texture;
import haxe.Json;
import haxe.ds.StringMap;
import openfl.Assets;
import starling.textures.TextureAtlas;

/**
 * ...
 * @author Christopher Speciale
 */
class AssetManager {
	private static var _assetManifest:AssetManifest;
	private static var _spritesheetMap:StringMap<TextureAtlas>;

	public function new() {}

	public static inline function init() {
		var rawAssetManfiest:String = Assets.getText("AssetManifest.json");
		_spritesheetMap = new StringMap();
		_assetManifest = Json.parse(rawAssetManfiest);

		for (sheet in _assetManifest.spritesheets) {
			var dat:String = Assets.getText(sheet.data);
			var bmd:BitmapData = Assets.getBitmapData(sheet.image);
			var tx:Texture = Texture.fromBitmapData(bmd, true);
			var atlas:TextureAtlas = new TextureAtlas(tx, dat);

			_spritesheetMap.set(sheet.id, atlas);
		}
	}

	public static function getSpritesheet(sheet:Spritesheets):TextureAtlas {
		return _spritesheetMap.get(sheet);
	}
}

@:noCompletion private interface AssetManifest {
	public var spritesheets:Array<Spritesheet>;
}

@:noCompletion private interface Spritesheet {
	public var image:String;
	public var data:String;
	public var id:String;
}
