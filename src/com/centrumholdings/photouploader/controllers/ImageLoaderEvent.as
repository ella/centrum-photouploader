package com.centrumholdings.photouploader.controllers
{

	//import flash.display.BitmapData;
	import flash.display.BitmapData;
	import flash.events.Event;
	
	public class ImageLoaderEvent extends Event
	{
		
		public static const IMAGE_READY:String = "imageReady";
		public static const IMAGE_SELECTED:String = "imageSelected";
		
		public var bitmapData:BitmapData;
		
		
		public function ImageLoaderEvent(type:String, bitmapData:BitmapData=null, bubbles:Boolean=false, cancelable:Boolean=false){
			super(type, bubbles, cancelable);
			this.bitmapData = bitmapData;
		}
		
		override public function clone():Event{
			var cEvent:ImageLoaderEvent = new ImageLoaderEvent(type, bitmapData, bubbles, cancelable);
			return cEvent;
		}
		
		

	}
}