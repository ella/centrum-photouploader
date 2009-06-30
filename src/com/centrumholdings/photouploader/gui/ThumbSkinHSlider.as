package com.centrumholdings.photouploader.gui
{
	import mx.skins.halo.SliderThumbSkin;
	
	public class ThumbSkinHSlider extends SliderThumbSkin
	{
		public function ThumbSkinHSlider(){
			super();
		}
		
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			graphics.clear();
			// create invisible "hit" box
			graphics.beginFill(0,0);
			graphics.drawRect(-2,-2,unscaledWidth+2, unscaledHeight);
			
			unscaledWidth = 10;
			unscaledHeight = 6;
			graphics.beginFill(0xffffff);
			graphics.moveTo(unscaledWidth/2, 0);
			graphics.lineTo(unscaledWidth, unscaledHeight);
			graphics.lineTo(0, unscaledHeight);
			graphics.endFill();
		}
		

	}
}