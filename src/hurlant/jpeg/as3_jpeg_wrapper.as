package hurlant.jpeg {
	public class as3_jpeg_wrapper {
		import cmodule.as3_jpeg_wrapper.CLibInit;
		protected static const _lib_init:cmodule.as3_jpeg_wrapper.CLibInit = new cmodule.as3_jpeg_wrapper.CLibInit();
		protected static const _lib:* = _lib_init.init();
		import flash.utils.ByteArray;
		static public function write_jpeg_file(data:ByteArray, width:int, height:int, bytes_per_pixel:int, color_space:int):ByteArray {
			return _lib.write_jpeg_file(data, width, height, bytes_per_pixel, color_space);
		}
	}
}
