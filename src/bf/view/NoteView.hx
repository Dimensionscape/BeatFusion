package bf.view;
import bf.ui.Note;
import starling.display.Sprite;

/**
 * ...
 * @author Christopher Speciale
 */
class NoteView extends Sprite
{
	
	public var leftNote:Note;
	public var downNote:Note;
	public var upNote:Note;
	public var rightNote:Note;	
	
	public function new() 
	{
		super();
		
		leftNote = new Note();	
		leftNote.alignPivot();
		leftNote.x = 0;
		leftNote.y = leftNote.pivotY;
		leftNote.innerColor = 0xC24B99;
		leftNote.outerColor = 0x3C1F56;			
		addChild(leftNote);

		downNote = new Note();	
		downNote.alignPivot();
		downNote.x = leftNote.x + leftNote.width + 8;
		downNote.y = downNote.pivotY;
		downNote.innerColor = 0x00FFFF;
		downNote.outerColor = 0x1542B7;			
		downNote.rotation = -1.570795;
		addChild(downNote);

		upNote = new Note();
		upNote.alignPivot();		
		upNote.x = downNote.x + downNote.width + 8;
		upNote.y = upNote.pivotY;
		upNote.innerColor = 0x12FA05;
		upNote.outerColor = 0x0A4447;
		upNote.rotation = 1.570795;			
		addChild(upNote);

		rightNote = new Note();
		rightNote.alignPivot();		
		rightNote.x = upNote.x + upNote.width + 8;
		rightNote.y = rightNote.pivotY;	
		rightNote.innerColor = 0xF9393F;
		rightNote.outerColor = 0x651038;
		rightNote.rotation = 3.14159;		
		addChild(rightNote);
		
	}
	
}