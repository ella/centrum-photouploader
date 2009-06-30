package com.centrumholdings.photouploader.tools
{
	///import flash.display.Graphics;
	import flash.display.*;
	import flash.geom.Rectangle;
	
	import mx.containers.Canvas;
	use namespace tool_internal;
	
	public class SelectToolGraphic extends Canvas
	{
		
		public function SelectToolGraphic(){
			super();
			sceneRectangle = new Rectangle();
		}
		override protected function createChildren():void{
			super.createChildren();
			if (drawBackground){
				rawChildren.addChild(background);
			}
			rawChildren.addChild(toolShape);
		}
		
		protected var drawRect:Rectangle;
		protected const drawRectZoomed:Rectangle = new Rectangle();
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
		
		
		protected var sceneRectangle:Rectangle;
		tool_internal function setSceneRectangle(rect:Rectangle):void{
			if (!sceneRectangle  ||  sceneRectangle.equals(rect) == false){
				sceneRectangle = rect.clone();
				buildBackground();
				invalidateDisplayList();
			}
		}
		protected var _zoom:Number = 1.0;
		tool_internal function set zoom(value:Number):void{
			_zoom = value;
			invalidateDisplayList();
		}
		
		
		protected var isActive:Boolean = true;
		tool_internal function activate():void{
			isActive = true;
			invalidateDisplayList();
		}
		tool_internal function deactivate():void{
			isActive = false;
			invalidateDisplayList();
		}
		
		
		private var currentVisibleSceneRectangleZoomed:Rectangle;
		private var toolShape:Shape = new Shape();
		private var background:Sprite = new Sprite();
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (!drawRect  ||  isActive == false){
				toolShape.graphics.clear();
				background.visible = false;				
			}else if (isActive){
				background.visible = true;
				// update drawRectZoomed from drawRect
				drawRectZoomed.x = drawRect.x * _zoom;
				drawRectZoomed.y = drawRect.y * _zoom;
				drawRectZoomed.width = drawRect.width * _zoom;
				drawRectZoomed.height = drawRect.height * _zoom;
				
				currentVisibleSceneRectangleZoomed = drawRectZoomed;
				redrawBackground(currentVisibleSceneRectangleZoomed, 0x000000, 0.6);
				
				toolShape.graphics.clear();
				//*
				// dasched lines
				drawHorizontalDashedLine(toolShape.graphics, drawRectZoomed.x, drawRectZoomed.y, drawRectZoomed.width);
				drawHorizontalDashedLine(toolShape.graphics, drawRectZoomed.x, drawRectZoomed.y+ drawRectZoomed.height, drawRectZoomed.width);
				drawVerticalDashedLine(toolShape.graphics, drawRectZoomed.x, drawRectZoomed.y, drawRectZoomed.height);
				drawVerticalDashedLine(toolShape.graphics, drawRectZoomed.x+drawRectZoomed.width, drawRectZoomed.y, drawRectZoomed.height);
				
				const corner:Rectangle = new Rectangle(5, 5, 7, 7);
				toolShape.graphics.lineStyle(1, 0xFFFFFF, 1.0,true);
				toolShape.graphics.beginFill(0x000000, 1.0);
				// left top corner
				toolShape.graphics.drawRect(drawRectZoomed.x-corner.x, drawRectZoomed.y-corner.y, corner.width, corner.height);
				// right top corner
				toolShape.graphics.drawRect(drawRectZoomed.x+drawRectZoomed.width-2, drawRectZoomed.y-corner.y, corner.width, corner.height);
				// left bottom corner
				toolShape.graphics.drawRect(drawRectZoomed.x-corner.x, drawRectZoomed.y+drawRectZoomed.height-2, corner.width, corner.height);
				// right bottom corner
				toolShape.graphics.drawRect(drawRectZoomed.x+drawRectZoomed.width-2, drawRectZoomed.y+drawRectZoomed.height-2, corner.width, corner.height);
				toolShape.graphics.endFill();
				/**/
			}
		}
		
		
		
		private function redrawBackground(rect:Rectangle, color:Number=NaN, alpha:Number=NaN):void{
			if (drawBackground == false){
				return;
			}
			var i:uint;
			var j:uint;
			for (i=0; i<shapes.length; i++){
				for (j=0; j<shapes[i].length; j++){
					shape = shapes[i][j];
					shape.willBeBlack = true;
					/*
					if (shape.isTransparent == true){
						shape.isTransparent = false;
						shape.graphics.clear();
						shape.graphics.beginFill(0x000000, 0.6);
						shape.graphics.drawRect(0, 0, shapeWidth, shapeHeight);
					}
					*/
				}
			}
			
			const firstColumn:Number 	= Math.floor(rect.x / shapeWidth);
			const firstLine:Number 		= Math.floor(rect.y / shapeHeight);
			const lastLine:Number 		= Math.min(Math.ceil(rect.bottom / shapeHeight), shapes.length);
			const lastColumn:Number 	= Math.min(Math.ceil(rect.right / shapeWidth), shapes[0].length);
			
			
			const left:Number 	= rect.x - firstColumn * shapeWidth;
			const top:Number 	= rect.y - firstLine * shapeHeight;
			const right:Number 	= rect.right - (lastColumn-1) * shapeWidth;
			const bottom:Number = rect.bottom - (lastLine-1) * shapeHeight;
			
			
			var shape:SelectToolShape;
			var currentLine:Number;
			var currentColumn:Number;
			// procházím pouze ty čtverce, které budou plně nebo částečně transparentní
			for (currentLine = firstLine; currentLine < lastLine; currentLine++){
				for (currentColumn = firstColumn; currentColumn < lastColumn; currentColumn++){
					shape = shapes[currentLine][currentColumn];
					if (shape.isTransparent == false  ||  shape.isSemiTransparent == true){
						shape.graphics.clear();
						shape.isTransparent = true;
					}
					shape.willBeBlack = false;
					
					if (currentLine == firstLine){
						shape.graphics.beginFill(0x000000, 0.6);
						shape.graphics.drawRect(0, 0, shapeWidth, top);
						shape.isSemiTransparent = true;
						//shape.willBeTransparent = false;
					}
					if (currentLine == lastLine-1){
						shape.graphics.beginFill(0x000000, 0.6);
						shape.graphics.drawRect(0, bottom, shapeWidth, shapeHeight - bottom);
						shape.isSemiTransparent = true;
						//shape.willBeTransparent = false;
					}
					if (currentColumn == firstColumn){
						shape.graphics.beginFill(0x000000, 0.6);
						shape.graphics.drawRect(0, 0, left, shapeHeight);
						shape.isSemiTransparent = true;
						//shape.willBeTransparent = false;
					}
					if (currentColumn == lastColumn-1){
						shape.graphics.beginFill(0x000000, 0.6);
						shape.graphics.drawRect(right, 0, shapeWidth-right, shapeHeight);
						shape.isSemiTransparent = true;
						//shape.willBeTransparent = false;
					}
				}
			}
			
			
			//--------------------------------------
			// CLEAR CORNERS
			//--------------------------------------
			// left top
			shapes[firstLine][firstColumn].graphics.clear();
			// right top
			shape = shapes[firstLine][lastColumn-1].graphics.clear();
			// left bottom
			shape = shapes[lastLine-1][firstColumn].graphics.clear();
			// right bottom
			shape = shapes[lastLine-1][lastColumn-1].graphics.clear();
			
			
			const maxShapeCornerWidth:Number = Math.min(shapeWidth, (lastColumn-firstColumn)*shapeWidth/2);
			const maxShapeCornerHeight:Number = Math.min(shapeHeight, (lastLine-firstLine)*shapeHeight/2);
			//--------------------------------------
			// DRAWING CORNERS
			//--------------------------------------
			// left top
			shape = shapes[firstLine][firstColumn];
			//shape.graphics.clear();
			shape.graphics.beginFill(0x000000, 0.6);
			shape.graphics.drawRect(0, 0, maxShapeCornerWidth, top);
			shape.graphics.drawRect(0, top, left, maxShapeCornerHeight-top);
			
			// right top
			shape = shapes[firstLine][lastColumn-1];
			//shape.graphics.clear();
			shape.graphics.beginFill(0x000000, 0.6);
			shape.graphics.drawRect(shapeWidth-maxShapeCornerWidth, 0, maxShapeCornerWidth, top);
			shape.graphics.drawRect(right, top, shapeWidth-right, maxShapeCornerHeight-top);
			
			// left bottom
			shape = shapes[lastLine-1][firstColumn];
			//shape.graphics.clear();
			shape.graphics.beginFill(0x000000, 0.6);
			shape.graphics.drawRect(0, shapeHeight-maxShapeCornerHeight, left, bottom-shapeHeight+maxShapeCornerHeight);
			shape.graphics.drawRect(0, bottom, maxShapeCornerWidth, shapeHeight-bottom);
			
			// right bottom
			shape = shapes[lastLine-1][lastColumn-1];
			//shape.graphics.clear();
			shape.graphics.beginFill(0x000000, 0.6);
			shape.graphics.drawRect(right, shapeHeight-maxShapeCornerHeight, shapeWidth-right, bottom-shapeHeight+maxShapeCornerHeight);
			shape.graphics.drawRect(shapeWidth-maxShapeCornerWidth, bottom, maxShapeCornerWidth, shapeHeight-bottom);
			
			
			for (i=0; i<shapes.length; i++){
				for (j=0; j<shapes[i].length; j++){
					shape = shapes[i][j];
					if (shape.willBeBlack == true  &&  (shape.isTransparent == true  ||  shape.isSemiTransparent == true)){
						shape.isTransparent = false;
						shape.isSemiTransparent = false;
						shape.graphics.clear();
						shape.graphics.beginFill(0x000000, 0.6);
						shape.graphics.drawRect(0, 0, shapeWidth, shapeHeight);
					}
					/*
					if (shape.isTransparent == true){
						shape.isTransparent = false;
						shape.graphics.clear();
						shape.graphics.beginFill(0x000000, 0.6);
						shape.graphics.drawRect(0, 0, shapeWidth, shapeHeight);
					}
					*/
				}
			}
		}
		
		private var sceneRectangleZoomed:Rectangle = new Rectangle();
		private var shapes:Array = [];
		private var shapeWidth:Number = 50;
		private var shapeHeight:Number = 50;
		protected var drawBackground:Boolean = true;
		private function buildBackground():void{
			if (!drawBackground){
				return;
			}
			removeBackground();
			sceneRectangleZoomed.width = sceneRectangle.width * _zoom;
			sceneRectangleZoomed.height = sceneRectangle.height * _zoom;
			
			if (background.mask){
				background.removeChild(background.mask);
			}
			var maskShape:Shape = new Shape();
			maskShape.graphics.clear();
			maskShape.graphics.beginFill(0x000000, 1.0);
			maskShape.graphics.drawRect(0, 0, sceneRectangleZoomed.width, sceneRectangleZoomed.height);
			background.addChild(maskShape);
			background.mask = maskShape;
			
			shapes = [];
			var shape:SelectToolShape;
			var yy:Number;
			var xx:Number;
			var currentColumn:Array;
			
			for (yy = 0; yy < sceneRectangleZoomed.height; ){
				currentColumn = [];
				for (xx = 0; xx < sceneRectangleZoomed.width; ){
					shape = new SelectToolShape();
					shape.graphics.beginFill(0x000000, 0.6);
					//if (xx + shapeWidth <= sceneRectangleZoomed.width){
						shape.graphics.drawRect(0, 0, shapeWidth, shapeHeight);
					/* }else{
						shape.graphics.drawRect(0, 0, sceneRectangleZoomed.width-xx, shapeHeight);
					} */
					shape.x = xx;
					shape.y = yy;
					
					xx += shapeWidth;
					currentColumn.push(shape);
					background.addChild(shape);
				}
				shapes.push(currentColumn);
				yy += shapeHeight;
			}
			trace("Builded " + (shapes.length*currentColumn.length) + " shapes.");
		}
		private function removeBackground():void{
			if (shapes){
				for (var i:uint=0; i<shapes.length; i++){
					for (var j:uint=0; j<shapes[i].length; j++){
						background.removeChild(shapes[i][j]);
					}
				}
			}
			shapes = [];
		}
		
		
		
		
		
		
		
		
		
		
		
		
		/**
		 * Function calls super.updateDisplayList(unscaledWidth, unscaledHeight).
		 */
		protected function $updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
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
		
		
		
		
		protected static function drawHorizontalDashedLine(g:Graphics, startX:Number, startY:Number, width:Number, colors:Array=null, alphas:Array=null, gaps:Array=null, thickness:Array=null):void{
			if (width<0){
				width *= -1;
				startX -= width;
			}
			
			if (!colors)
				colors = [0xFFFFFF,0x000000];
			
			if (!alphas)
				alphas = [1.0,1.0];
			
			if (!gaps)
				gaps = [5,5];
			
			if (!thickness)
				thickness = [1,1];
			
			
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
		protected static function drawVerticalDashedLine(g:Graphics, startX:Number, startY:Number, height:Number, colors:Array=null, alphas:Array=null, gaps:Array=null, thickness:Array=null):void{
			if (height<0){
				height *= -1;
				startY -= height;
			}
			if (!colors)
				colors = [0xFFFFFF,0x000000];
			
			if (!alphas)
				alphas = [1.0,1.0];
			
			if (!gaps)
				gaps = [5,5];
			
			if (!thickness)
				thickness = [1,1];
			
			
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