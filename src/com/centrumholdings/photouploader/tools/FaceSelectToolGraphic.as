package com.centrumholdings.photouploader.tools
{
	import flash.display.*;
	use namespace tool_internal;
	
	public class FaceSelectToolGraphic extends SelectToolGraphic
	{
		
		public function FaceSelectToolGraphic(){
			super();
			drawBackground = false;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			super.$updateDisplayList(unscaledWidth, unscaledHeight);
		
			if (!drawRect){
				graphics.clear();				
			}else{
				// update drawRectZoomed from drawRect
				drawRectZoomed.x = drawRect.x * _zoom;
				drawRectZoomed.y = drawRect.y * _zoom;
				drawRectZoomed.width = drawRect.width * _zoom;
				drawRectZoomed.height = drawRect.height * _zoom;
				
				graphics.clear();
				
				// dasched lines
				const colors:Array = [0xFF0000,0x000000];
				const alphas:Array = [1.0,0.0];
				const thickness:Array = [2,2];
				drawHorizontalDashedLine(graphics, drawRectZoomed.x, drawRectZoomed.y, drawRectZoomed.width, colors, alphas, null, thickness);
				drawHorizontalDashedLine(graphics, drawRectZoomed.x, drawRectZoomed.y+ drawRectZoomed.height, drawRectZoomed.width, colors, alphas, null, thickness);
				drawVerticalDashedLine(graphics, drawRectZoomed.x, drawRectZoomed.y, drawRectZoomed.height, colors, alphas, null, thickness);
				drawVerticalDashedLine(graphics, drawRectZoomed.x+drawRectZoomed.width, drawRectZoomed.y, drawRectZoomed.height, colors, alphas, null, thickness);
			}
		}

	}
}