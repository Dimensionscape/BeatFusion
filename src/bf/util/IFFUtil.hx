package bf.util;

import openfl.utils.ByteArray;
import openfl.utils.Endian;

class IFFUtil {
    
    public static function writeChunk(output:ByteArray, chunkID:String, data:ByteArray, listType:String=null):Void {
        var isList:Bool = (chunkID == "RIFF" || chunkID == "LIST");
        var len:Int = (data != null ? data.length : 0) + (isList ? 4 : 0);

        output.endian = Endian.BIG_ENDIAN;
        output.writeUTFBytes((chunkID + "    ").substr(0, 4));
        output.writeInt(len);
        if (isList) {
            if (listType != null) output.writeUTFBytes((listType + "    ").substr(0, 4));
            else output.writeUTFBytes("    ");
        }
        if (data != null) {
            output.writeBytes(data);
            if (len & 1 == 1) output.writeByte(0); // pad byte if length is odd
        }
    }

    public static function readChunk(input:ByteArray, searchChunkID:String=null):Dynamic {
        input.endian = Endian.BIG_ENDIAN;

        while (input.bytesAvailable > 0) {
            var id:String = input.readUTFBytes(4);
            var len:Int = input.readInt();
            var type:String = null;
            var chunkData:ByteArray = new ByteArray();
            chunkData.endian = Endian.BIG_ENDIAN;

            if (id == "RIFF" || id == "LIST") {
                type = input.readUTFBytes(4);
                input.readBytes(chunkData, 0, len - 4);
            } else {
                input.readBytes(chunkData, 0, len);
            }

            if (len & 1 == 1) input.readByte(); // skip pad byte if length is odd

            if (searchChunkID == null || searchChunkID == id) {
                return {chunkID: id, length: len, listType: type, data: chunkData};
            } else {
                input.position += len + (len & 1);
            }
        }
        return null;
    }

    public static function readAllChunks(input:ByteArray):Map<String, Array<Dynamic>> {
        var ret:Map<String, Array<Dynamic>> = new Map();

        input.endian = Endian.BIG_ENDIAN;
        while (input.bytesAvailable > 0) {
            var chunk = readChunk(input);
            if (chunk != null) {
                if (!ret.exists(chunk.chunkID)) {
                    ret.set(chunk.chunkID, []);
                }
                ret.get(chunk.chunkID).push(chunk);
            }
        }

        return ret;
    }
}