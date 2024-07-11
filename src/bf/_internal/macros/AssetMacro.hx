package bf._internal.macros;
#if macro
import haxe.Json;
import haxe.macro.Context;
import haxe.macro.Expr;

class AssetMacro {
	macro static public function build(type:String):Array<Field> {
		var json = sys.io.File.getContent("assets/AssetManifest.json");
		var data = Json.parse(json);
		var spritesheets:Array<Dynamic> = (data : Dynamic).spritesheets;

		var enumFields = [];
		switch (type) {
			case "Spritesheets":
				buildSpritesheetsEnum(enumFields);
		}

		return enumFields;
	}

	static function makeEnumField(name:String, kind:FieldType) {
		return {
			name: name,
			doc: null,
			meta: [],
			access: [],
			kind: kind,
			pos: Context.currentPos()
		}
	}

	static function buildSpritesheetsEnum(fields:Array<Field>) {
		var json = sys.io.File.getContent("assets/AssetManifest.json");
		var data = Json.parse(json);
		var spritesheets:Array<Dynamic> = (data : Dynamic).spritesheets;

		for (sheet in spritesheets) {
			var id = sheet.id;
			var fieldName = id.toUpperCase();
			fields.push(makeEnumField(fieldName, FVar(macro :String, macro $v{id})));
		}
	}
}
#end
