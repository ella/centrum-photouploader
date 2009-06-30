package com.centrumholdings.photouploader.tools
{
	
	import flash.geom.Rectangle;
	
	import mx.containers.Canvas;
	
	use namespace tool_internal;
	
	/**
	 * Tool for selecting important area in photo e.g. face.
	 */
	public class FaceSelectTool extends SelectTool
	{
		
		[Embed(source="../../../../assets/cursors.swf", symbol="selectTool")]
		private const selectCursorTemp:Class;
		
		public function FaceSelectTool(toolLayer:Canvas){
			super(toolLayer);
		}
		override protected function init():void{
			selectToolGraphic = new FaceSelectToolGraphic();
			selectCursor = selectCursorTemp;
		}
		
		
		
		
		//--------------------------------------
		// CROP SELECTION
		//--------------------------------------
		public function cropSelection(rect:Rectangle):void{
			if (rect.isEmpty() == false){
				onCropRectChange(rect);
			}
		}
		private function onCropRectChange(cropRect:Rectangle):void{
			var currentSelection:Rectangle = new Rectangle(pointA.x, pointA.y, pointB.x - pointA.x, pointC.y - pointB.y);
			
			if (currentSelection.x < cropRect.x){
				currentSelection.width -= cropRect.x - currentSelection.x;
				currentSelection.x = cropRect.x;
			}
			if (currentSelection.y < cropRect.y){
				currentSelection.height -= cropRect.y - currentSelection.y;
				currentSelection.y = cropRect.y;
			}
			
			if (currentSelection.width > 0  &&  currentSelection.x + currentSelection.width > cropRect.x + cropRect.width){
				currentSelection.width = cropRect.x + cropRect.width - currentSelection.x;
			}
			if (currentSelection.height > 0  &&  currentSelection.y + currentSelection.height > cropRect.y + cropRect.height){
				currentSelection.height = cropRect.y + cropRect.height - currentSelection.y;
			}
			
			currentSelection.x -= cropRect.x;
			currentSelection.y -= cropRect.y;
			
			if (currentSelection.width < 0  ||  currentSelection.height < 0){
				currentSelection = new Rectangle();
			}
			
			pointA.x = currentSelection.x;
			pointA.y = currentSelection.y;
			
			pointB.x = currentSelection.x + currentSelection.width;
			pointB.y = pointA.y;
			
			pointC.x = pointB.x
			pointC.y = currentSelection.y + currentSelection.height;
			
			pointD.x = pointA.x
			pointD.y = pointC.y;
			
			onPointsUpdated(true);
			updateActiveAreas();
		}
		
		
		//--------------------------------------
		// UNCROP SELECTION
		//--------------------------------------
		public function uncropSelection(cropRect:Rectangle):void{
			if (cropRect){
				pointA.x += cropRect.x;
				pointA.y += cropRect.y;
				
				pointB.x += cropRect.x;
				pointB.y += cropRect.y;
				
				pointC.x += cropRect.x;
				pointC.y += cropRect.y;
				
				pointD.x += cropRect.x;
				pointD.y += cropRect.y;
				
				onPointsUpdated(true);
				updateActiveAreas();
			}
		}
		
		
		 

	}
}