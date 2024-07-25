package bf.ui;

import starling.display.Sprite;

class HitNote extends Sprite {
	public var state:NoteState;

	private var _note:Note;

	public function new(?state:NoteState) {
		super();

		_note = new Note();
		addChild(_note);
		_note.alignPivot();

		if (state != null) {
			changeState(state);
		}
	}

	public function changeState(state:NoteState):Void {
		switch (state) {
			case LEFT:
				_note.innerColor = 0xC24B99;
				_note.outerColor = 0x3C1F56;
			case DOWN:
				_note.innerColor = 0x00FFFF;
				_note.outerColor = 0x1542B7;
				_note.rotation = -1.570795;
			case UP:
				_note.innerColor = 0x12FA05;
				_note.outerColor = 0x0A4447;
				_note.rotation = 1.570795;
			case RIGHT:
				_note.innerColor = 0xF9393F;
				_note.outerColor = 0x651038;
				_note.rotation = 3.14159;
		}
		this.state = state;
	}
}

enum NoteState {
	LEFT;
	DOWN;
	UP;
	RIGHT;
}
