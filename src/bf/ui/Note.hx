package bf.ui;

import starling.display.Sprite;

class Note extends Sprite {
	public var state:NoteEnum;
	public var id(get, null):UInt;

	private var _id:Int;
	private var _mesh:NoteMesh;

	public function new(?state:NoteEnum) {
		super();

        this.touchable = false;
		_mesh = new NoteMesh();
        _mesh.touchable = false;
        _mesh.textureSmoothing = "none";
		
		addChild(_mesh);

		if (state != null) {
			changeState(state);
		}
	}

	public function changeState(state:NoteEnum):Void {
		switch (state) {
			case LEFT:
				_mesh.innerColor = 0xC24B99;
				_mesh.outerColor = 0x3C1F56;
			case DOWN:
				_mesh.innerColor = 0x00FFFF;
				_mesh.outerColor = 0x1542B7;
			case UP:
				_mesh.innerColor = 0x12FA05;
				_mesh.outerColor = 0x0A4447;
			case RIGHT:
				_mesh.innerColor = 0xF9393F;
				_mesh.outerColor = 0x651038;
		}
        _mesh.setDirection(state);
		this.state = state;
	}

	private inline function get_id():UInt{
		return _id;
	}
}

enum abstract NoteEnum(String) from String to String{
	var LEFT:String = "left";
	var DOWN:String = "down";
	var UP:String = "up";
	var RIGHT:String = "right";
}
