package;

import bf.util.AssetManager;
import starling.display.Sprite;

/**
 * ...
 * @author Christopher Speciale
 */
class Main extends Sprite 
{

	public function new() 
	{
		super();		
		
		trace(AssetManager.getSpritesheet(UI));
	}

}
