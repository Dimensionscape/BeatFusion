// =================================================================================================
//
//	Starling Framework
//	Copyright Gamua GmbH. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.textures;

/** A class that provides constant values for the possible smoothing algorithms of a texture. */ 
enum abstract TextureSmoothing(String) from String to String
{
    /** No smoothing, also called "Nearest Neighbor". Pixels will scale up as big rectangles. */
    public var NONE:String      = "none";
    
    /** Bilinear filtering. Creates smooth transitions between pixels. */
    public var BILINEAR:String  = "bilinear";
    
    /** Trilinear filtering. Highest quality by taking the next mip map level into account. */
    public var TRILINEAR:String = "trilinear";
    
}