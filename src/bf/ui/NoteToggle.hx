package bf.ui;

import starling.display.Sprite;

class NoteToggle extends Sprite {

    //TODO: Getters and setters for validation
    public var activeNote:Note;
    public var inactiveNote:Note;

    public var isActive(get, set):Bool;

    private inline function get_isActive():Bool{
        return !inactiveNote.visible;
    }

    private inline function set_isActive(value:Bool):Bool{
        inactiveNote.visible = !value;
        return value;
    }

    public function new(){
        super();
        
        activeNote = new Note();
        addChild(activeNote);

        inactiveNote = new Note();
        inactiveNote.highlightColor = 0xFFFFFF;
        inactiveNote.innerColor = 0x87A3AD;
        inactiveNote.outerColor = 0x000000;
        addChild(inactiveNote);

        isActive = false;
    }



}