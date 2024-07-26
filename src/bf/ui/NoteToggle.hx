package bf.ui;

import bf.ui.Note.NoteEnum;
import starling.display.Sprite;

class NoteToggle extends Note {
	// TODO: Getters and setters for validation
	private var _inactiveMesh:NoteMesh;

	public var isActive(get, set):Bool;

	private inline function get_isActive():Bool {
		return _mesh.visible;
	}

	private inline function set_isActive(value:Bool):Bool {
		_mesh.visible = value;
		return value;
	}

	public function new(?state:NoteEnum) {
		_inactiveMesh = new NoteMesh();
		super(state);

		_inactiveMesh.highlightColor = 0xFFFFFF;
		_inactiveMesh.innerColor = 0x87A3AD;
		_inactiveMesh.outerColor = 0x000000;
		addChildAt(_inactiveMesh, 0);

		isActive = false;
	}

	override public function changeState(state:NoteEnum):Void {
		super.changeState(state);
		_inactiveMesh.setDirection(state);
	}
}
