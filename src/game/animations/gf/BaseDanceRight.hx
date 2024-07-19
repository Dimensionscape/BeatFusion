package game.animations.gf;

import starling.textures.Texture;
import bf.asset.AssetManager;
import bf.graphics.Animation;

class BaseDanceRight extends Animation {
	public function new() {
		var textures:Array<Texture> = AssetManager.getSpritesheet(GF).getTextures("GF Dancing Beat");
        var indicies:Array<Int> = [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29];
        var animTextures:Array<Texture> = [];

        for(i in indicies){
            animTextures.push(textures[i]);
        }
        
		super( animTextures, 24);
        stop();
	}
}
