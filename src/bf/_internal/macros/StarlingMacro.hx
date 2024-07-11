package bf._internal.macros;

#if macro
	import haxe.macro.Context;
#end

/**
 * ...
 * @author Christopher Speciale
 */
class StarlingMacro
{

	macro public static function getDef(key:String)
	{
		return try
		{
			var s = Context.definedValue(key);
			s = parseStringToJson(s);
			macro $v {s};
		}
		catch (e)
		{
			haxe.macro.Context.error('Failed to load def: $e', haxe.macro.Context.currentPos());
		}
	}
	
	private static function parseStringToJson(input:String):String {
        // Create a regular expression to match both keys and values
        var regex = new EReg("\\b([a-zA-Z0-9_]+)\\b\\s*:\\s*([a-zA-Z0-9_]+)", "g");

        // Replace keys and values with double quotes
        var modifiedString = regex.replace(input, "\"$1\":\"$2\"");
       
		return modifiedString;
    }

}