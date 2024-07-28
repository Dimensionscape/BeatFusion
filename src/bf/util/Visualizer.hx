package bf.util;

import lime.utils.UInt8Array;
import starling.events.EnterFrameEvent;
import starling.textures.Texture;
import starling.display.Quad;
import starling.display.Sprite;
import lime.media.AudioSource;
import lime.media.AudioBuffer;
import lime.utils.Assets;

class Visualizer extends Sprite {
    var colorTexture:Texture;
    var bars:Array<Quad>;
    var fft:FFT;
    var sound:AudioSource;

    public function new() {
        super();
        loadAudio();
    }

    private function loadAudio():Void {
        Assets.loadAudioBuffer("audio/audio2.ogg").onComplete(function(buffer:AudioBuffer) {
            sound = new AudioSource(buffer);
            fft = new FFT(1024); // FFT size of 1024
            createUI();
            sound.play();
            addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrame);
        });
    }

    private function onEnterFrame(event:EnterFrameEvent):Void {
        if (sound != null) {
            var samples:Array<Float> = getSamples();
            fft.setData(samples);
            fft.calcFFT(); // Perform FFT
            var magnitude:Array<Float> = fft.getMagnitude();

            for (i in 0...256) {
                var value = magnitude[i] * 2; // Adjust the scale factor as needed
                value = Math.min(190, value); // Cap the value to prevent overflow
                bars[i].height = value;
                bars[i].y = 190 - value; // Adjust y-position based on the bar height
            }
        }
    }

    private function createUI():Void {
        colorTexture = Texture.fromColor(1, 1, 0xffffff);
        var bg:Quad = Quad.fromTexture(colorTexture);
        bg.color = 0x000000;
        bg.width = 768;
        bg.height = 200;
        addChild(bg);

        bars = [];
        for (i in 0...256) {
            var bar:Quad = Quad.fromTexture(colorTexture);
            bar.width = 3;
            bar.height = 3;
            bar.x = i * 3;
            bar.y = 190;
            addChild(bar);
            bars.push(bar);
        }
    }

    private function getSamples():Array<Float> {
        var samples:Array<Float> = [];
        var buffer:AudioBuffer = sound.buffer;
        var sampleData:UInt8Array = buffer.data;
        var numChannels:Int = buffer.channels;
        var totalSamples:Int = Std.int(sampleData.length / (numChannels * 2)); // Assuming 16-bit samples

        // Calculate the current playback sample position
        var currentSamplePosition:Int = Std.int((sound.currentTime / sound.length) * totalSamples);

        // Define the number of samples you want to visualize, e.g., 1024
        var sampleWindow:Int = Std.int(Math.min(1024, totalSamples - currentSamplePosition));
        sampleWindow = Std.int(Math.max(0, sampleWindow));

        var startSample:Int = Std.int(Math.max(0, currentSamplePosition - sampleWindow));
        var endSample:Int = Std.int(Math.min(totalSamples, currentSamplePosition + sampleWindow));

        for (i in startSample...endSample) {
            var sample:Float = 0;
            for (c in 0...numChannels) {
                var index:Int = (i * numChannels + c) * 2;
                var byte1:Int = sampleData[index];
                var byte2:Int = sampleData[index + 1];
                var signedSample:Int = byte1 | (byte2 << 8);
                if (signedSample >= 32768) signedSample -= 65536;
                sample += signedSample / 32768;
            }
            samples.push(sample / numChannels);
        }

        return samples;
    }
}