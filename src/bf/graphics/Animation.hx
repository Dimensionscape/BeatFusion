package bf.graphics;

import bf.core.Engine;
import starling.animation.Juggler;
import starling.textures.Texture;
import starling.display.MovieClip;

class Animation extends MovieClip {
	public var animID(get, null):Int;

	@:noCompletion private var _animID:Int;

	private inline function get_animID():Int {
		return _animID;
	}

	public function new(textures:Array<Texture>, fps:Int) {
		super(textures, fps);
        touchable = false;
        textureSmoothing = "none";
	}
}
