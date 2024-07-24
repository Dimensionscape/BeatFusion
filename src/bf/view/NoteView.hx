package bf.view;
import bf.ui.Note;
import bf.util.ObjectPool;
import emitter.signals.Emitter;
import starling.display.Image;
import bf.ui.NoteToggle;
import starling.display.Sprite;

/**
 * ...
 * @author Christopher Speciale
 */

 //THIS IS JUST A TEMPORARY IMPLEMENTATION TO TEST NOTE COLORING IN DIFFERENT WAYS
class NoteView extends Sprite
{
	
	public var leftNote:NoteToggle;
	public var downNote:NoteToggle;
	public var upNote:NoteToggle;
	public var rightNote:NoteToggle;
	public var spawner:NoteSpawner;	
	
	public function new() 
	{
		super();
		
		leftNote = new NoteToggle();	
		leftNote.alignPivot();
		leftNote.x = 0;
		leftNote.y = leftNote.pivotY;
		leftNote.activeNote.innerColor = 0xC24B99;
		leftNote.activeNote.outerColor = 0x3C1F56;					
		addChild(leftNote);
		
		downNote = new NoteToggle();	
		downNote.alignPivot();
		downNote.x = leftNote.x + leftNote.width + 8;
		downNote.y = downNote.pivotY;
		downNote.activeNote.innerColor = 0x00FFFF;
		downNote.activeNote.outerColor = 0x1542B7;			
		downNote.rotation = -1.570795;
		addChild(downNote);

		upNote = new NoteToggle();
		upNote.alignPivot();		
		upNote.x = downNote.x + downNote.width + 8;
		upNote.y = upNote.pivotY;
		upNote.activeNote.innerColor = 0x12FA05;
		upNote.activeNote.outerColor = 0x0A4447;
		upNote.rotation = 1.570795;			
		addChild(upNote);

		rightNote = new NoteToggle();
		rightNote.alignPivot();		
		rightNote.x = upNote.x + upNote.width + 8;
		rightNote.y = rightNote.pivotY;	
		rightNote.activeNote.innerColor = 0xF9393F;
		rightNote.activeNote.outerColor = 0x651038;
		rightNote.rotation = 3.14159;		
		addChild(rightNote);
		
		spawner = new NoteSpawner();

	}
}

class NoteSpawner extends Emitter {

	private static var notePool:ObjectPool<Note>;

	private static function _noteFactory():Note{
		var note:Note = new Note();
		return note;
	}

	public function new(){
		super();
		if(notePool == null){
			notePool = new ObjectPool(_noteFactory, null, 100);
		}
	}
}