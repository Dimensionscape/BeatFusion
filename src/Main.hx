package;

import starling.display.Quad;
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
		
		trace("hello starling");
		var quad:Quad = new Quad(32, 32);
		addChild(quad);
	}

}
