package bf.util;

import openfl.display.DisplayObjectContainer;
import openfl.text.TextField;
import openfl.events.Event;
import openfl.Lib;

/**
 * A static utility class for measuring and displaying frame times.
 */
class TimerUtil {
    
    /** The title to display at the top of the timer text. */
    static public var title:String = "";
    
    /** Internal TextField used to display the timing information. */
    static private var _text:TextField = null;
    
    /** Array to store start times for each slot. */
    static private var _time:Array<Int>;
    
    /** Array to accumulate times for each slot. */
    static private var _sum:Array<Int>;
    
    /** Array of strings representing the format for each slot's display text. */
    static private var _stat:Array<String>;
    
    /** Counter for the number of frames processed. */
    static private var _cnt:Int;
    
    /** The number of frames to average over. */
    static private var _avc:Int;
    
    /**
     * Initializes the TimerUtil.
     * 
     * @param parent The parent DisplayObjectContainer to add the TextField to.
     * @param averagingCount The number of frames to average over.
     * @param stat An array of strings representing the format for each slot's display text. "##" is replaced with the measured time.
     */
    static public function initialize(parent:DisplayObjectContainer, averagingCount:Int, stat:Array<String>):Void {
        if (_text == null) {
            _text = new TextField();
            parent.addChild(_text);
        }
        _avc = averagingCount;
        _stat = stat;
        _time = new Array<Int>();
        _time.resize(stat.length);
        _sum = new Array<Int>();
        _sum.resize(stat.length);
        _cnt = 0;
        _text.background = true;
        _text.backgroundColor = 0x80c0f0;
        _text.autoSize = openfl.text.TextFieldAutoSize.LEFT;
        _text.multiline = true;
        parent.addEventListener(Event.ENTER_FRAME, _onEnterFrame);
    }
    
    /**
     * Starts the timer for a specific slot.
     * 
     * @param slot The slot index to start the timer for (default is 0).
     */
    static public function start(slot:Int = 0):Void {
        _time[slot] = Lib.getTimer();
    }
    
    /**
     * Pauses the timer for a specific slot.
     * 
     * @param slot The slot index to pause the timer for (default is 0).
     */
    static public function pause(slot:Int = 0):Void {
        _sum[slot] += Lib.getTimer() - _time[slot];
    }
    
    /**
     * Event handler for the ENTER_FRAME event. Updates the TextField with the averaged frame times.
     * 
     * @param e The Event object.
     */
    static private function _onEnterFrame(e:Event):Void {
        _cnt++;
        if (_cnt == _avc) {
            _cnt = 0;
            var str:String = "";
            for (i in 0..._sum.length) {
                var line:String = StringTools.replace(Std.string(_stat[i]), "##", Std.string(_sum[i] / _avc).substr(0, 3));
                str += line + "\n";
                _sum[i] = 0;
            }
            _text.text = title + "\n" + str;
        }
    }
}
