package bf.ui;
import bf.ui.Note.NoteEnum;

class NoteTail extends NoteTailMesh {
	public var state:NoteEnum;
	public var id(get, null):UInt;

	private var _id:Int;


	public function new(?state:NoteEnum) {
		super();

        this.touchable = false;
		
		if (state != null) {
			changeState(state);
		}

        
	}

	public function changeState(state:NoteEnum):Void {
		switch (state) {
			case LEFT:
				innerColor = 0xC24B99;
				outerColor = 0x3C1F56;
			case DOWN:
				innerColor = 0x00FFFF;
				outerColor = 0x1542B7;
			case UP:
				innerColor = 0x12FA05;
				outerColor = 0x0A4447;
			case RIGHT:
				innerColor = 0xF9393F;
				outerColor = 0x651038;
		}
		this.state = state;
	}

	private inline function get_id():UInt{
		return _id;
	}
}

