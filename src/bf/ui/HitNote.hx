package bf.ui;
import bf.ui.Note.NoteEnum;

class HitNote extends Note{

    public var tail(get, null):NoteTail;

    private var _tail:NoteTail;

    private function get_tail():NoteTail{
        return _tail;
    }

    public function new (?state:NoteEnum){
        super(state);
    }
}