package;

import bf.asset.Spritesheets;
import bf.input.keyboard.KeyboardManager;
import bf.view.NoteView;
import bf.asset.AssetManager;
import starling.display.Sprite;
import bf.ui.Note;

/**
 * ...
 * @author Christopher Speciale
 */
class Main extends Sprite 
{

	public function new() 
	{
		super();		
		
		var noteView:NoteView = new NoteView();
		noteView.x = 580;
		noteView.y = 16;
		addChild(noteView);

		AssetManager.getSpritesheet(GF);

		KeyboardManager.setKeyDownCallback(LEFT, ()->{
			noteView.leftNote.isActive = true;
		});

		KeyboardManager.setKeyUpCallback(LEFT, ()->{
			noteView.leftNote.isActive = false;
		});

		KeyboardManager.setKeyDownCallback(RIGHT, ()->{
			noteView.rightNote.isActive = true;
		});

		KeyboardManager.setKeyUpCallback(RIGHT, ()->{
			noteView.rightNote.isActive = false;
		});

		KeyboardManager.setKeyDownCallback(UP, ()->{
			noteView.upNote.isActive = true;
		});

		KeyboardManager.setKeyUpCallback(UP, ()->{
			noteView.upNote.isActive = false;
		});

		KeyboardManager.setKeyDownCallback(DOWN, ()->{
			noteView.downNote.isActive = true;
		});

		KeyboardManager.setKeyUpCallback(DOWN, ()->{
			noteView.downNote.isActive = false;
		});

	}

}
