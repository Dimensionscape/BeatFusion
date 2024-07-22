package bf.effects;

enum CameraEffect {
    EaseTo(x:Float, y:Float, duration:Float);
    EaseX(value:Float, duration:Float);
    EaseY(value:Float, duration:Float);
    EaseZ(value:Float, duration:Float);
    Shake(intensity:Float, duration:Float);
    Bounce(intensity:Float, duration:Float);
    // Add some other effects ?
}