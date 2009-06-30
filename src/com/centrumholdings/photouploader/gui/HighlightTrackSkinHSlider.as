package com.centrumholdings.photouploader.gui
{
	import mx.skins.halo.SliderHighlightSkin;
	
	public class HighlightTrackSkinHSlider extends SliderHighlightSkin
	{
		public function HighlightTrackSkinHSlider()
		{
			super();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			graphics.clear();
			graphics.beginFill(0xffffff);
			
			for (var currentX:Number=0; currentX+1<unscaledWidth;){
				graphics.drawRect(currentX, -1, 2, 3);
				currentX += 4;
			}
		} 
		
		

	}
}