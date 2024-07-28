package bf.ui;
import bf.core.Settings;
import starling.display.Sprite;
import openfl.geom.Rectangle;
import starling.textures.TextureAtlas;
import starling.display.Image;
import starling.textures.Texture;
import starling.display.MeshBatch;
import bf.asset.AssetManager;

/**
 * ...
 * @author Christopher Speciale
 */
 @:access(starling.display.Image)
class NoteTailMesh extends Sprite
{

	private var _outerTexture:Texture;
	private var _baseTexture:Texture;
	private var _highlightTexture:Texture;

	private var _outerImage:Image;
	private var _baseImage:Image;
	private var _highlightImage:Image;

	public var outerColor(get, set):UInt;
	public var innerColor(get, set):UInt;
	public var highlightColor(get, set):UInt;

	private function get_outerColor():UInt{
		return _outerImage.color;
	}

	private function set_outerColor(value:UInt):UInt{
		_outerImage.color = value;
		validate();
		return value;
	}

	private function get_innerColor():UInt{
		return _baseImage.color;
	}

	private function set_innerColor(value:UInt):UInt{
		_baseImage.color = value;
		validate();
		return value;
	}

	private function get_highlightColor():UInt{
		return _highlightImage.color;
	}

	private function set_highlightColor(value:UInt):UInt{
		_highlightImage.color = value;
		validate();
		return value;
	}
	
	//TURNS OUT THE CHEAPEST METHOD OF COLORING OUR NOTES WAS TO JUST SPLIT THEM UP INTO PARTS
	public function new() 
	{
		super();
		//batchable = true;
		

		var spritesheet:TextureAtlas = AssetManager.getSpritesheet(UI);

		_baseTexture = spritesheet.getTexture("note_tail_base");
		_outerTexture = spritesheet.getTexture("note_tail_outline");
		_highlightTexture = spritesheet.getTexture("note_tail_highlight");

		_baseImage = new Image(_baseTexture);
		_baseImage.textureSmoothing = Settings.textureSmoothing;

		_outerImage = new Image(_outerTexture);
		_outerImage.textureSmoothing = Settings.textureSmoothing;

		_highlightImage = new Image(_highlightTexture);
		_highlightImage.textureSmoothing = Settings.textureSmoothing;

		set3Slice(2,2);
		validate();

		//this.textureSmoothing = "none";

	}

	public function set3Slice(y:Float, height:Float):Void{
	
		//_baseImage.__set3Slice(y, height);
		//_outerImage.__set3Slice(y, height);
		//_highlightImage.__set3Slice(y, height);

	}

	override function set_height(value:Float):Float {
		_baseImage.height = value;
		_outerImage.height = value;
		_highlightImage.height = value;

		return value;
	}

	public function validate():Void{
		addChild(_baseImage);
		addChild(_outerImage);
		addChild(_highlightImage);
	}
	
}