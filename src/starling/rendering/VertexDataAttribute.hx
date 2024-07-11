// =================================================================================================
//
//	Starling Framework
//	Copyright Gamua GmbH. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.rendering;

import openfl.errors.ArgumentError;
import openfl.utils.Dictionary;

/** Holds the properties of a single attribute in a VertexDataFormat instance.
 *  The member variables must never be changed; they are only <code>public</code>
 *  for performance reasons. */
class VertexDataAttribute
{
    private static var FORMAT_SIZES:Map<String, Int>;

    public var name:String;
    public var format:String;
    public var isColor:Bool;
    public var offset:Int; // in bytes
    public var size:Int;   // in bytes

    /** Creates a new instance with the given properties. */
    public function new(name:String, format:String, offset:Int)
    {
        if (FORMAT_SIZES == null)
        {
            FORMAT_SIZES = [
                "bytes4" => 4,
                "float1" => 4,
                "float2" => 8,
                "float3" => 12,
                "float4" => 16
            ];
        }
        if (!FORMAT_SIZES.exists(format))
            throw new ArgumentError(
                "Invalid attribute format: " + format + ". " +
                "Use one of the following: 'float1'-'float4', 'bytes4'");

        this.name = name;
        this.format = format;
        this.offset = offset;
        this.size = FORMAT_SIZES[format];
        this.isColor = name.indexOf("color") != -1 || name.indexOf("Color") != -1;
    }
}