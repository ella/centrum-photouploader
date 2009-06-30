package com.centrumholdings.photouploader.tools
{
	import flash.events.Event;

	public class LayerEvent extends Event
	{
		
		public static const SIZE_CHANGE_ADDED_BITMAP:String 	= "sizeChangeAddedBitmap";
		public static const SIZE_CHANGE_ZOOM:String 			= "sizeChangeZoom";
		
		public static const SIZE_CHANGE_ROTATE_LEFT:String 		= "rotateLeft";
		public static const SIZE_CHANGE_ROTATE_RIGHT:String 	= "rotateRight";
		public static const SIZE_CHANGE_FLIP_HORIZONTAL:String 	= "flipHorizontal";
		public static const SIZE_CHANGE_FLIP_VERTICAL:String 	= "flipVertical";
		
		
		public function LayerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false){
			super(type, bubbles, cancelable);
		}
		
		
		override public function clone():Event{
			var cEvent:LayerEvent = new LayerEvent(type, bubbles, cancelable);
			return cEvent;
		}
		
		
		
	}
}