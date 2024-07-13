package bf.graphics;

import starling.animation.Juggler;
import starling.textures.Texture;
import starling.display.MovieClip;

class Animation extends MovieClip {

    public var _juggler:Juggler;
    public var _animateID:UInt;

    public var initialized(get, null):Bool;

    public function get_initialized():Bool {
        return _juggler != null;
    }
    
    public function new(textures:Array<Texture>, fps:Int, ?juggler:Juggler)
        {
            super(textures, fps);

            if(juggler != null){
                this._juggler = juggler;
            }
        }
    
    public function initialize():Void{
        if(_juggler != null){
            _animateID = _juggler.add(this);
        }
        
    }
}