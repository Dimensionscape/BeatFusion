package bf.graphics;

import bf.core.Engine;
import starling.animation.Juggler;
import starling.textures.Texture;
import starling.display.MovieClip;

class Animation extends MovieClip {

    public var _juggler:Juggler;
    public var _animateID:Null<Int>;

    public var juggler(get, null):Bool;

    private inline function get_juggler():Bool {
        return this._animateID != null;
    }
    
    public function new(textures:Array<Texture>, fps:Int, ?juggler:Juggler)
        {
            super(textures, fps);

            if(juggler != null){
                attach(juggler);
            }
        }

    public function attach(?juggler:Juggler):Void{
        if(this._animateID != null){
            this._juggler.removeByID(this._animateID);
        }

        if(juggler != null){
            this._juggler = juggler;
        } else {
           this._juggler = Engine.engine.starling.juggler;
        }        
        
        this._animateID = this._juggler.add(this);
    }
}