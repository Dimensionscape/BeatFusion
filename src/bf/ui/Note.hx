package bf.ui;
import starling.textures.TextureAtlas;
import starling.display.Quad;
import starling.textures.Texture;
import starling.display.MeshBatch;
import bf.asset.AssetManager;

/**
 * ...
 * @author Christopher Speciale
 */
class Note extends MeshBatch
{

	private var _borderTexture:Texture;
	private var _baseTexture:Texture;
	private var _highlightTexture:Texture;

	private var _borderQuad:Quad;
	private var _baseQuad:Quad;
	private var _highlightQuad:Quad;

	public var outerColor(get, set):UInt;
	public var innerColor(get, set):UInt;
	public var highlightColor(get, set):UInt;

	private function get_outerColor():UInt{
		return _borderQuad.color;
	}

	private function set_outerColor(value:UInt):UInt{
		_borderQuad.color = value;
		validate();
		return value;
	}

	private function get_innerColor():UInt{
		return _baseQuad.color;
	}

	private function set_innerColor(value:UInt):UInt{
		_baseQuad.color = value;
		validate();
		return value;
	}

	private function get_highlightColor():UInt{
		return _highlightQuad.color;
	}

	private function set_highlightColor(value:UInt):UInt{
		_highlightQuad.color = value;
		validate();
		return value;
	}
	
	//TURNS OUT THE CHEAPEST METHOD OF COLORING OUR NOTES WAS TO JUST SPLIT THEM UP INTO PARTS
	public function new() 
	{
		super();
		batchable = true;

		var spritesheet:TextureAtlas = AssetManager.getSpritesheet(UI);

		_baseTexture = spritesheet.getTexture("note_base");
		_borderTexture = spritesheet.getTexture("note_border");
		_highlightTexture = spritesheet.getTexture("note_highlight");

		_baseQuad = Quad.fromTexture(_baseTexture);

		_borderQuad = Quad.fromTexture(_borderTexture);
		_borderQuad.textureSmoothing="none";

		_highlightQuad = Quad.fromTexture(_highlightTexture);

		validate();

		this.textureSmoothing = "none";
	}

	public function validate():Void{
		addMesh(_baseQuad);
		addMesh(_borderQuad);
		addMesh(_highlightQuad);
	}
	
}