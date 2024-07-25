package bf.view;

import starling.events.EnterFrameEvent;
import bf.ui.HitNote;
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
// THIS IS JUST A TEMPORARY IMPLEMENTATION TO TEST NOTE COLORING IN DIFFERENT WAYS
class NoteView extends Sprite {
	public var leftNote:NoteToggle;
	public var downNote:NoteToggle;
	public var upNote:NoteToggle;
	public var rightNote:NoteToggle;
	public var spawner:NoteSpawner;

	public function new() {
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
		addEventListener(EnterFrameEvent.ENTER_FRAME, _onFrameUpdate);
	}

	var activeHitNotes:Array<HitNote> = [];

	private function _onFrameUpdate(e:EnterFrameEvent):Void {
		var n:Int = Std.random(32);
		var note:HitNote = null;

		switch (n) {
			case 0:
				note = spawner.get(LEFT);
				note.x = leftNote.x;

			case 1:
				note = spawner.get(UP);
				note.x = upNote.x;
			case 2:
				note = spawner.get(DOWN);
				note.x = downNote.x;
			case 3:
				note = spawner.get(RIGHT);
				note.x = rightNote.x;
			default:
				// do nothing
		}

		if (note != null) {
			activeHitNotes.push(note);
			note.y = 600;
			addChild(note);
		}

		_processActiveNotes(e.passedTime);
	}

	private function _processActiveNotes(dt:Float):Void {
		var i:Int = activeHitNotes.length;
		while (--i > -1 ) {
			var note:HitNote = activeHitNotes[i];
			note.y -= dt * 500;

			if (note.y < 0) {
				removeChild(note);
				spawner.recycle(note);
				activeHitNotes.remove(note);
			}
		}
	}
}

class NoteSpawner extends Emitter {
	private static var leftNotePool:ObjectPool<HitNote>;
	private static var upNotePool:ObjectPool<HitNote>;
	private static var rightNotePool:ObjectPool<HitNote>;
	private static var downNotePool:ObjectPool<HitNote>;

	private static var _hasPool:Bool = false;

	private static function _leftNoteFactory():HitNote {
		var note:HitNote = new HitNote(LEFT);
		return note;
	}

	private static function _upNoteFactory():HitNote {
		var note:HitNote = new HitNote(UP);
		return note;
	}

	private static function _rightNoteFactory():HitNote {
		var note:HitNote = new HitNote(RIGHT);
		return note;
	}

	private static function _downNoteFactory():HitNote {
		var note:HitNote = new HitNote(DOWN);
		return note;
	}

	public function new() {
		super();
		if (!_hasPool) {
			leftNotePool = new ObjectPool(_leftNoteFactory, null, 25);
			upNotePool = new ObjectPool(_upNoteFactory, null, 25);
			rightNotePool = new ObjectPool(_rightNoteFactory, null, 25);
			downNotePool = new ObjectPool(_downNoteFactory, null, 25);
			_hasPool = true;
		}
	}

	public function recycle(note:HitNote):Void{
		switch (note.state) {
			case LEFT:
				leftNotePool.release(note);
			case UP:
				upNotePool.release(note);
			case RIGHT:
				rightNotePool.release(note);
			case DOWN:
				downNotePool.release(note);
		}
	}

	public function get(state:NoteState):HitNote {
		var note:HitNote = null;

		switch (state) {
			case LEFT:
				note = leftNotePool.acquire();
			case UP:
				note = upNotePool.acquire();
			case RIGHT:
				note = rightNotePool.acquire();
			case DOWN:
				note = downNotePool.acquire();
		}
		return note;
	}
}
