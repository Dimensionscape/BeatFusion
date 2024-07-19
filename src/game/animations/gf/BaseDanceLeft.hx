package game.animations.gf;

import starling.textures.Texture;
import bf.asset.AssetManager;
import bf.graphics.Animation;

class BaseDanceLeft extends Animation {
	public function new() {
		var textures:Array<Texture> = AssetManager.getSpritesheet(GF).getTextures("GF Dancing Beat");
		var indicies:Array<Int> = [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14];
		var animTextures:Array<Texture> = [];

		for (i in indicies) {
			animTextures.push(textures[i]);
		}

		super(animTextures, 24);
		stop();
	}
}
