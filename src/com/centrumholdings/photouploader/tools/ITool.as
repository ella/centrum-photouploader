package com.centrumholdings.photouploader.tools
{
	import flash.display.Bitmap;
	
	public interface ITool{
		
		
		function get cursorClass():Class; 
		function get cursorXOffset():int;
		function get cursorYOffset():int;
		
	}
}