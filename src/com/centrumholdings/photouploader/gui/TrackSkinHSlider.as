package com.centrumholdings.photouploader.gui
{
	import mx.skins.halo.SliderThumbSkin;
	
	public class TrackSkinHSlider extends SliderThumbSkin
	{
		public function TrackSkinHSlider(){
			super();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			graphics.clear();
			graphics.beginFill(0x696969);
			
			for (var currentX:Number=0; (currentX+2)<unscaledWidth;){
				graphics.drawRect(currentX, 0, 2, 3);
				currentX += 4;
			}
		}
		
		
	}
}