package bf.view;

import haxe.ds.IntMap;
import starling.events.EnterFrameEvent;
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

		touchable = false;

		leftNote = new NoteToggle(LEFT);
		leftNote.x = 0;
		leftNote.y = 0;

		addChild(leftNote);

		downNote = new NoteToggle(DOWN);
		downNote.x = leftNote.x + leftNote.width + 8;
		downNote.y = 0;
		addChild(downNote);

		upNote = new NoteToggle(UP);
		upNote.x = downNote.x + downNote.width + 8;
		upNote.y = 0;
		addChild(upNote);

		rightNote = new NoteToggle(RIGHT);
		rightNote.x = upNote.x + upNote.width + 8;
		rightNote.y = 0;
		addChild(rightNote);

		spawner = new NoteSpawner();
		addEventListener(EnterFrameEvent.ENTER_FRAME, _onFrameUpdate);
	}

	var activeNotes:IntMap<Note> = new IntMap();
//Were only testing here. This is a Note Simlation!
	private function _onFrameUpdate(e:EnterFrameEvent):Void {
		var n:Int = Std.random(7);
		var note:Note = null;

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
			activeNotes.set(note.id, note);
			note.y = 600;
			addChild(note);
		}

		_processActiveNotes(e.passedTime);
	}

	private function _processActiveNotes(dt:Float):Void {
		for (note in activeNotes){
			note.y -= dt * 500;

			if (note.y < 0) {
				removeChild(note);
				spawner.recycle(note);
				activeNotes.remove(note.id);
			}
		}
	}
}

@:access(bf.ui.Note)
class NoteSpawner extends Emitter {
	private static var leftNotePool:ObjectPool<Note>;
	private static var upNotePool:ObjectPool<Note>;
	private static var rightNotePool:ObjectPool<Note>;
	private static var downNotePool:ObjectPool<Note>;

	private static var _hasPool:Bool = false;

	private static var _idSpace:Int = 0;

	private static function _leftNoteFactory():Note {
		var note:Note = new Note(LEFT);
		note._id = _idSpace++;

		return note;
	}

	private static function _upNoteFactory():Note {
		var note:Note = new Note(UP);
		note._id = _idSpace++;

		return note;
	}

	private static function _rightNoteFactory():Note {
		var note:Note = new Note(RIGHT);
		note._id = _idSpace++;

		return note;
	}

	private static function _downNoteFactory():Note {
		var note:Note = new Note(DOWN);
		note._id = _idSpace++;

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

	public function recycle(note:Note):Void{
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

	public function get(state:NoteEnum):Note {
		var note:Note = null;

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
