package com.centrumholdings.photouploader.tools
{
	///import flash.display.Graphics;
	import flash.display.*;
	import flash.geom.Rectangle;
	
	import mx.containers.Canvas;
	use namespace tool_internal;
	
	public class CropToolGraphic extends Canvas
	{
		
		public function CropToolGraphic(){
			super();
			photoRectangle = new Rectangle();
		}
		
		private var drawRect:Rectangle;
		private const drawRectZoomed:Rectangle = new Rectangle();
		tool_internal function draw(rect:Rectangle):void{
			// copy rectangle:
			if (rect){
				drawRect = rect.clone();
				invalidateDisplayList();
			}
		}
		tool_internal function erase():void{
			drawRect = null;
			invalidateDisplayList();
		}
		
		
				
		private var photoRectangle:Rectangle;
		tool_internal function setSceneRectangle(rect:Rectangle):void{
			photoRectangle = rect;
			invalidateDisplayList();
		}
		private var _zoom:Number = 1;
		tool_internal function set zoom(value:Number):void{
			_zoom = value;
			invalidateDisplayList();
		}
		
		
		private var isActive:Boolean = true;
		tool_internal function activate():void{
			isActive = true;
			invalidateDisplayList();
		}
		tool_internal function deactivate():void{
			isActive = false;
			invalidateDisplayList();
		}
		
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			if (!drawRect  ||  isActive == false){
				graphics.clear();				
			}else if (isActive){
				// update drawRectZoomed from drawRect
				drawRectZoomed.x = drawRect.x * _zoom;
				drawRectZoomed.y = drawRect.y * _zoom;
				drawRectZoomed.width = drawRect.width * _zoom;
				drawRectZoomed.height = drawRect.height * _zoom;
				
				graphics.clear();
				graphics.beginFill(0, 0.6);
				graphics.drawRect(0, 0, photoRectangle.width*_zoom, photoRectangle.height*_zoom);
				graphics.drawRect(drawRectZoomed.x, drawRectZoomed.y, drawRectZoomed.width, drawRectZoomed.height);
				
				
				// dasched lines
				drawHorizontalDashedLine(graphics, drawRectZoomed.x, drawRectZoomed.y, drawRectZoomed.width);
				drawHorizontalDashedLine(graphics, drawRectZoomed.x, drawRectZoomed.y+ drawRectZoomed.height, drawRectZoomed.width);
				drawVerticalDashedLine(graphics, drawRectZoomed.x, drawRectZoomed.y, drawRectZoomed.height);
				drawVerticalDashedLine(graphics, drawRectZoomed.x+drawRectZoomed.width, drawRectZoomed.y, drawRectZoomed.height);
				 
				const corner:Rectangle = new Rectangle(5,5,7,7);
				graphics.lineStyle(1,0xffffff,1,true);
				graphics.beginFill(0, 1);
				// left top corner
				graphics.drawRect(drawRectZoomed.x-corner.x, drawRectZoomed.y-corner.y, corner.width, corner.height);
				// right top corner
				graphics.drawRect(drawRectZoomed.x+drawRectZoomed.width-2, drawRectZoomed.y-corner.y, corner.width, corner.height);
				// left bottom corner
				graphics.drawRect(drawRectZoomed.x-corner.x, drawRectZoomed.y+drawRectZoomed.height-2, corner.width, corner.height);
				// right bottom corner
				graphics.drawRect(drawRectZoomed.x+drawRectZoomed.width-2, drawRectZoomed.y+drawRectZoomed.height-2, corner.width, corner.height);
				graphics.endFill()
			}/* else{
				graphics.clear();
				graphics.beginFill(0, 1);
				graphics.drawRect(0,0,sceneRectangle.width, sceneRectangle.height);
				graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
			} */
			//controlCropAreas();
		}
		/* private function controlCropAreas():void{
			drawControlRectangle(cropTool.cropLeftTopCornerArea, 0x0099FF);
			drawControlRectangle(cropTool.cropRightTopCornerArea, 0x00CC33);
			drawControlRectangle(cropTool.cropLeftBottomCornerArea, 0xFF9900);
			drawControlRectangle(cropTool.cropRightBottomCornerArea, 0xFF0033); 
			
			drawControlRectangle(cropTool.cropInnerArea, 0xCC00CC);
			drawControlRectangle(cropTool.cropTopArea, 0x99FF00);
			drawControlRectangle(cropTool.cropLeftArea, 0x99CCCC);
			drawControlRectangle(cropTool.cropRightArea, 0xFFFF00);
			drawControlRectangle(cropTool.cropBottomArea, 0xFF99CC);
			drawControlRectangle(cropTool.rect, 0x000099);
		}
		private function drawControlRectangle(rect:Rectangle, color:Number):void{
			graphics.beginFill(color, 0.2);
			graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
		} */
		
		
		
		
		
		
		private static function drawHorizontalDashedLine(g:Graphics, startX:Number, startY:Number, width:Number, colors:Array=null, alphas:Array=null, gaps:Array=null, thickness:Array=null):void{
			if (width<0){
				width *= -1;
				startX -= width;
			}
			
			if (!colors){
				colors = [0xffffff,0x000000];
			}
			if (!alphas){
				alphas = [1,1];
			}
			if (!gaps){
				gaps = [5,5];
			}
			if (!thickness){
				thickness = [1,1];
			}
			
			g.moveTo(startX,startY);
			const endX:Number = startX+width;
			for (var currentX:Number = startX; currentX<endX;){
				currentX = Math.min(currentX+gaps[0],endX);
				g.lineStyle(thickness[0], colors[0], alphas[0], true);
				g.lineTo(currentX, startY);
				
				g.moveTo(currentX, startY);
				currentX = Math.min(currentX+gaps[1],endX);
				g.lineStyle(thickness[1], colors[1], alphas[1], true);
				g.lineTo(currentX, startY);
				g.moveTo(currentX, startY);
			}
		}
		private static function drawVerticalDashedLine(g:Graphics, startX:Number, startY:Number, height:Number, colors:Array=null, alphas:Array=null, gaps:Array=null, thickness:Array=null):void{
			if (height<0){
				height *= -1;
				startY -= height;
			}
			if (!colors){
				colors = [0xffffff,0x000000];
			}
			if (!alphas){
				alphas = [1,1];
			}
			if (!gaps){
				gaps = [5,5];
			}
			if (!thickness){
				thickness = [1,1];
			}
			
			g.moveTo(startX,startY);
			const endY:Number = startY+height;
			
			for (var currentY:Number = startY; currentY<endY;){
				currentY = Math.min(currentY+gaps[0],endY);
				g.lineStyle(thickness[0], colors[0], alphas[0], true);
				g.lineTo(startX, currentY);
				
				g.moveTo(startX, currentY);
				currentY = Math.min(currentY+gaps[1],endY);
				g.lineStyle(thickness[1], colors[1], alphas[1], true);
				g.lineTo(startX, currentY);
				g.moveTo(startX, currentY);
			}
		}
		

	}
}