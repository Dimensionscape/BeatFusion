package bf.graphics;

import starling.textures.Texture;
import starling.display.MovieClip;

class Animation extends MovieClip {

    public function new(textures:Array<Texture>, fps:Int)
        {
            super(textures, fps);
        }
}