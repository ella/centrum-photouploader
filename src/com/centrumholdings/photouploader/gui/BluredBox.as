package com.centrumholdings.photouploader.gui
{
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	
	import mx.containers.Canvas;

	public class BluredBox extends Canvas
	{
		protected var disableFilters:Array;
		
		public function BluredBox(){
			super();
			disableFilters = [new BlurFilter(4, 4, BitmapFilterQuality.MEDIUM)];
			setStyle("disabledOverlayAlpha", 0);
		}
		
		
		override public function set enabled(value:Boolean):void{
			super.enabled = value;
			if (value){
				filters = [];
			}else{
				filters = disableFilters;
			}
		}
		
		
		
		
		
		
	}
}