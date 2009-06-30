package com.centrumholdings.photouploader.tools
{
	
	///import flash.display.Graphics;
	import flash.display.InteractiveObject;
	import flash.display.PixelSnapping;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.containers.Canvas;
	import mx.managers.CursorManager;
	import mx.managers.CursorManagerPriority;
	
	use namespace tool_internal;
	
	public class CropTool //implements ITool
	{
		private const cursorXOffset:int = -8;
		private const cursorYOffset:int = -8;
		
		[Embed(source="../../../../assets/cursors.swf", symbol="resize0")]
		private const cropCursor:Class;
		
		[Embed(source="../../../../assets/cursors.swf", symbol="resize1")]
		private const resize1Cursor:Class;
		
		[Embed(source="../../../../assets/cursors.swf", symbol="resize2")]
		private const resize2Cursor:Class;
		
		[Embed(source="../../../../assets/cursors.swf", symbol="resize3")]
		private const resize3Cursor:Class;
		
		[Embed(source="../../../../assets/cursors.swf", symbol="resize4")]
		private const resize4Cursor:Class;
		
		[Embed(source="../../../../assets/cursors.swf", symbol="move")]
		private const moveCursor:Class;
		
		
		public function CropTool(toolLayer:Canvas){
			super();
			this.toolLayer = toolLayer;
		}
		
		
		
		
		//--------------------------------------
		// CURSORS
		//--------------------------------------
		private var currentCursorClass:Class;
		private function showMouseCursor(cursor:Class=null):void{
			if (cursor == null){
				cursor = cropCursor;
			}
			if (currentCursorClass != cursor){
				CursorManager.removeAllCursors();
				CursorManager.setCursor(cursor, CursorManagerPriority.HIGH, cursorXOffset, cursorYOffset);
			}
		}
		private function hideMouseCursor():void{
			CursorManager.removeAllCursors();
			currentCursorClass = null;
		}
		
		
		
		
		//--------------------------------------
		// MOUSE EVENTS
		//--------------------------------------
		tool_internal function onMouseOver():void{
			if (!isDraging  &&  !isCropping  &&  !isResizing){
				showMouseCursor();
			}
		}
		tool_internal function onMouseOut():void{
			if (!isDraging  &&  !isCropping  &&  !isResizing){
				hideMouseCursor();
			}
		}
		tool_internal function onMouseDown():void{
			// reset values
			isDraging = isResizing = isCropping = false;
			
			switch (mousePosition){
				case MOUSE_IN_BOX:
					onDragingStart();
					break;
				case MOUSE_OVER_LEFT_TOP:
				case MOUSE_OVER_TOP:
				case MOUSE_OVER_RIGHT_TOP:
				case MOUSE_OVER_RIGHT:
				case MOUSE_OVER_RIGHT_BOTTOM:
				case MOUSE_OVER_BOTTOM:
				case MOUSE_OVER_LEFT_BOTTOM:
				case MOUSE_OVER_LEFT:
					onResizeStart(mousePosition);
					break;
				case MOUSE_OUT_BOX:
					onCroppingStart();
					break;
			}
		}
		tool_internal function onMouseMove():void{
			if (isCropping){
				onCropping();
			}else if (isDraging){
				onDraging();
			}else if (isResizing){
				onResizing();
			}else{
				switch (mousePosition){
					case MOUSE_OVER_LEFT_TOP:
					case MOUSE_OVER_RIGHT_BOTTOM:
						showMouseCursor(resize1Cursor);
						break;
					case MOUSE_OVER_TOP:
					case MOUSE_OVER_BOTTOM:
						showMouseCursor(resize2Cursor);
						break;
					case MOUSE_OVER_RIGHT_TOP:
					case MOUSE_OVER_LEFT_BOTTOM:
						showMouseCursor(resize3Cursor);
						break;
					case MOUSE_OVER_RIGHT:
					case MOUSE_OVER_LEFT:
						showMouseCursor(resize4Cursor);
						break;
					case MOUSE_IN_BOX:
						showMouseCursor(moveCursor);
						break;
					case MOUSE_OUT_BOX:
						showMouseCursor();
						break;
					case MOUSE_OUT_SCENE:
					default:
						hideMouseCursor();
						break;
				}
			}
		}
		tool_internal function onMouseUp():void{
			if (isCropping){
				isCropping = false;
				onCropping();
				onEditCropFinished();
			}else if (isDraging){
				isDraging = false;
				onDraging();
				onEditCropFinished();
			}else if (isResizing){
				isResizing = false;
				onResizing();
				onEditCropFinished();
			}
		}
		
		
		
		
		
		//--------------------------------------
		// AREAS
		//--------------------------------------
		private var toolLayer:Canvas;
		tool_internal function setSceneFullSize(photoWidth:Number, photoHeight:Number):void{
			sceneRect.width = photoWidth;
			sceneRect.height = photoHeight;
		}
		
		
		private var _zoom:Number = 1;
		tool_internal function set zoom(value:Number):void{
			_zoom = value / 100;
			cropToolGraphic.zoom = _zoom;
		}
		
		tool_internal function transform(type:String):void{
			var buffer:Number;
			switch (type){
				case LayerEvent.SIZE_CHANGE_ADDED_BITMAP:
					break;
				case LayerEvent.SIZE_CHANGE_FLIP_HORIZONTAL:
					cropRect.y = sceneRect.height - cropRect.y - cropRect.height;
					break;
				case LayerEvent.SIZE_CHANGE_FLIP_VERTICAL:
					cropRect.x = sceneRect.width - cropRect.x - cropRect.width;
					break;
				case LayerEvent.SIZE_CHANGE_ROTATE_LEFT:
					// rotate sceneRect
					buffer = sceneRect.width;
					sceneRect.width = sceneRect.height;
					sceneRect.height = buffer;
					
					// rotate cropRect
					buffer = cropRect.width;
					cropRect.width = cropRect.height;
					cropRect.height = buffer;
					
					buffer = cropRect.x;
					
					// X ... stará hodnota y
					cropRect.x = cropRect.y;
					cropRect.y = sceneRect.height - cropRect.height - buffer;
					break;
				case LayerEvent.SIZE_CHANGE_ROTATE_RIGHT:
					// rotate sceneRect
					buffer = sceneRect.width;
					sceneRect.width = sceneRect.height;
					sceneRect.height = buffer;
					
					// rotate cropRect
					buffer = cropRect.width;
					cropRect.width = cropRect.height;
					cropRect.height = buffer;
					
					buffer = cropRect.x;
					
					// nyní šířka (dříve výška) obrázku  -   nynější šířka cropu
					cropRect.x = sceneRect.width 		- cropRect.width -  	cropRect.y;
					// Y ... stará hodnota x
					cropRect.y = buffer;
					
					break;
				/* case LayerEvent.SIZE_CHANGE_ZOOM:
					cropToolGraphic.zoom = _zoom;
					break; */
			}
			
			pointA.x = cropRect.x;
			pointA.y = cropRect.y;
			
			pointB.x = cropRect.right;
			pointB.y = cropRect.y;
			 
			pointC.x = cropRect.right;
			pointC.y = cropRect.bottom;
			
			pointD.x = cropRect.x;
			pointD.y = cropRect.bottom;
			
			//method onPointsUpdated will call cropToolGraphic.draw()
			onPointsUpdated(true);
		}
		
		
		private var cropToolGraphic:CropToolGraphic = new CropToolGraphic();
		private var sceneRect:Rectangle = new Rectangle();
		
		private const cropInnerLimit:Number = 20;
		private const cropOuterLimit:Number = 20;
		private var cropLeftTopCornerArea:Rectangle = new Rectangle();
		private var cropRightTopCornerArea:Rectangle = new Rectangle();
		private var cropLeftBottomCornerArea:Rectangle = new Rectangle();
		private var cropRightBottomCornerArea:Rectangle = new Rectangle();
		
		private var cropInnerArea:Rectangle = new Rectangle();
		private var cropTopArea:Rectangle = new Rectangle();
		private var cropLeftArea:Rectangle = new Rectangle();
		private var cropRightArea:Rectangle = new Rectangle();
		private var cropBottomArea:Rectangle = new Rectangle();
		
		// cropRect ... zobrazení 1:1 k fotce
		private var cropRect:Rectangle = new Rectangle();
		// points of cropRect
		private var pointA:Point = new Point(); // a ... left top
		private var pointB:Point = new Point(); // b ... right top
		private var pointC:Point = new Point(); // c ... right bottom
		private var pointD:Point = new Point(); // d ... left bottom
		
		//--------------------------------------
		// CROPPING
		//--------------------------------------
		private var isCropping:Boolean = false;
		private function onCroppingStart():void{
			isCropping = true;
			pointA.x = toolLayer.mouseX/_zoom;
			pointA.y = toolLayer.mouseY/_zoom;
			
			pointB.y = pointA.y;
			pointD.x = pointA.x;
			cropToolGraphic.setSceneRectangle(sceneRect);
			if (cropToolGraphic.parent != toolLayer){
				toolLayer.addChild(cropToolGraphic);
			}
			/* startMouseX = toolLayer.mouseX;
			startMouseY = toolLayer.mouseY; */
		}
		private function onCropping():void{
			pointC.x = toolLayer.mouseX/_zoom;
			pointC.y = toolLayer.mouseY/_zoom;
			
			pointB.x = pointC.x;
			pointD.y = pointC.y;
			
			onPointsUpdated();
		}
		
		
		
		
		//--------------------------------------
		// DRAGING
		//--------------------------------------
		private var mouseXOffset:Number = 0;
		private var mouseYOffset:Number = 0;
		private var isDraging:Boolean = false;
		private function onDragingStart():void{
		 	isDraging = true;
		 	mouseXOffset = (toolLayer.mouseX/_zoom - pointA.x);
		 	mouseYOffset = (toolLayer.mouseY/_zoom - pointA.y);
		}
		private function onDraging():void{
			pointA.x = Math.min(Math.max(0, toolLayer.mouseX/_zoom - mouseXOffset), sceneRect.width - pointC.x + pointA.x);
			pointA.y = Math.min(Math.max(0, toolLayer.mouseY/_zoom - mouseYOffset), sceneRect.height - pointC.y + pointA.y);
			
			pointC.x += pointA.x - pointD.x;
			pointC.y += pointA.y - pointB.y;
			
			pointB.x = pointC.x;
			pointB.y = pointA.y;
			
			pointD.x = pointA.x;
			pointD.y = pointC.y;
			
			onPointsUpdated();
		}
		
		//--------------------------------------
		// RESIZING
		//--------------------------------------
		private var isResizing:Boolean = false;
		private var resizingArea:String;
		private function onResizeStart(resizeType:String):void{
			isResizing = true;
			resizingArea = resizeType;
		}
		private function onResizing():void{
			switch(resizingArea){
				case MOUSE_OVER_LEFT_TOP:
					pointD.x = pointA.x = toolLayer.mouseX/_zoom;
					pointB.y = pointA.y = toolLayer.mouseY/_zoom;
					break;
				case MOUSE_OVER_TOP:
					pointA.y = toolLayer.mouseY/_zoom;
					pointB.y = pointA.y;
					break;
				case MOUSE_OVER_RIGHT_TOP:
					pointC.x = pointB.x = toolLayer.mouseX/_zoom;
					pointA.y = pointB.y = toolLayer.mouseY/_zoom;
					break;
				case MOUSE_OVER_RIGHT:
					pointB.x = toolLayer.mouseX/_zoom;
					pointC.x = toolLayer.mouseX/_zoom;
					break;
				case MOUSE_OVER_RIGHT_BOTTOM:
					pointB.x = pointC.x = toolLayer.mouseX/_zoom;
					pointD.y = pointC.y = toolLayer.mouseY/_zoom;
					break;
				case MOUSE_OVER_BOTTOM:
					pointC.y = toolLayer.mouseY/_zoom;
					pointD.y = toolLayer.mouseY/_zoom;
					break;
				case MOUSE_OVER_LEFT_BOTTOM:
					pointA.x = pointD.x = toolLayer.mouseX/_zoom;
					pointC.y = pointD.y = toolLayer.mouseY/_zoom;
					break;
				case MOUSE_OVER_LEFT:
					pointA.x = toolLayer.mouseX/_zoom;
					pointD.x = toolLayer.mouseX/_zoom;
					break;
			}
			onPointsUpdated();
		}
		
		
		private static const MOUSE_OVER_LEFT_TOP:String 	= "mouse_over_left_top";
		private static const MOUSE_OVER_TOP:String 			= "mouse_over_top";
		private static const MOUSE_OVER_RIGHT_TOP:String 	= "mouse_over_right_top";
		private static const MOUSE_OVER_RIGHT:String 		= "mouse_over_right";
		private static const MOUSE_OVER_RIGHT_BOTTOM:String = "mouse_over_right_bottom";
		private static const MOUSE_OVER_BOTTOM:String 		= "mouse_over_bottom";
		private static const MOUSE_OVER_LEFT_BOTTOM:String 	= "mouse_over_left_bottom";
		private static const MOUSE_OVER_LEFT:String 		= "mouse_over_left";
		private static const MOUSE_IN_BOX:String 			= "mouse_in_box";
		private static const MOUSE_OUT_BOX:String 			= "mouse_out_box";
		private static const MOUSE_OUT_SCENE:String 		= "mouse_out_scene";		
		private function get mousePosition():String{
			if (isMouseOver(toolLayer, cropInnerArea)){
				return MOUSE_IN_BOX;
			}else if (isMouseOver(toolLayer, cropLeftTopCornerArea)){
				return MOUSE_OVER_LEFT_TOP;
			}else if (isMouseOver(toolLayer, cropRightBottomCornerArea)){
				return MOUSE_OVER_RIGHT_BOTTOM;
			}else if (isMouseOver(toolLayer, cropTopArea)){
				return MOUSE_OVER_TOP;
			}else if (isMouseOver(toolLayer, cropBottomArea)){
				return MOUSE_OVER_BOTTOM;
			}else if (isMouseOver(toolLayer, cropRightTopCornerArea)){
				return MOUSE_OVER_RIGHT_TOP;
			}else if (isMouseOver(toolLayer, cropLeftBottomCornerArea)){
				return MOUSE_OVER_LEFT_BOTTOM;
			}else if (isMouseOver(toolLayer, cropRightArea)){
				return MOUSE_OVER_RIGHT;
			}else if (isMouseOver(toolLayer, cropLeftArea)){
				return MOUSE_OVER_LEFT;
			}else if (isMouseOver(toolLayer, sceneRect)){
				return MOUSE_OUT_BOX;
			}else{
				return MOUSE_OUT_SCENE;
			}
		}
		
		
		
		
		
		private function onPointsUpdated(fixPoints:Boolean=false):void{
			function getFixedPoint(p:Point):Point{
				return new Point(	Math.min(Math.max(0, p.x), sceneRect.width), 	// x
									Math.min(Math.max(0, p.y), sceneRect.height)); // y
			}
			var internalPointA:Point = getFixedPoint(pointA);
			var internalPointB:Point = getFixedPoint(pointB);
			var internalPointC:Point = getFixedPoint(pointC);
			var internalPointD:Point = getFixedPoint(pointD);
			
			var switchPointBuffer:Point;
			if (internalPointA.x > internalPointB.x){
				// switch A <-> B
				switchPointBuffer = internalPointA;
				internalPointA = internalPointB;
				internalPointB = switchPointBuffer;
				// switch C <-> D
				switchPointBuffer = internalPointC;
				internalPointC = internalPointD;
				internalPointD = switchPointBuffer;
			}
			if (internalPointA.y > internalPointD.y){
				// switch A <-> D
				switchPointBuffer = internalPointA;
				internalPointA = internalPointD;
				internalPointD = switchPointBuffer;
				// switch B <-> C
				switchPointBuffer = internalPointB;
				internalPointB = internalPointC;
				internalPointC = switchPointBuffer;
			}
			
			cropRect.x = internalPointA.x;
			cropRect.y = internalPointA.y;
			cropRect.width = internalPointC.x - internalPointA.x;
			cropRect.height = internalPointC.y - internalPointA.y;
			
			
			if (fixPoints  &&  (cropRect.width < 10  ||  cropRect.height < 10)){
				cropCancel();
			}else{
				cropToolGraphic.draw(cropRect);
			}
			if (fixPoints){
				pointA = internalPointA;
				pointB = internalPointB;
				pointC = internalPointC;
				pointD = internalPointD;
			}
		}
		
		// fixing size and position of crop
		private function onEditCropFinished():void{
			onPointsUpdated(true);
			updateMouseAreas();
		}
		
		private function updateMouseAreas():void{
			const xPosition:Number = cropRect.x;
			const yPosition:Number = cropRect.y;
			const w:Number = cropRect.width;
			const h:Number = cropRect.height;
			
			cropInnerArea.x = xPosition + cropInnerLimit;
			cropInnerArea.y = yPosition + cropInnerLimit;
			cropInnerArea.width = w - 2*cropInnerLimit;
			cropInnerArea.height = h - 2*cropInnerLimit;
			
			cropLeftTopCornerArea.x = xPosition-cropOuterLimit;
			cropLeftTopCornerArea.y = yPosition-cropOuterLimit;
			cropLeftTopCornerArea.width = cropInnerLimit+cropOuterLimit;
			cropLeftTopCornerArea.height = cropInnerLimit+cropOuterLimit;
			
			cropRightTopCornerArea.x = xPosition + w - cropInnerLimit;
			cropRightTopCornerArea.y = yPosition - cropOuterLimit;
			cropRightTopCornerArea.width = cropInnerLimit+cropOuterLimit;
			cropRightTopCornerArea.height = cropInnerLimit+cropOuterLimit;
			
			cropLeftBottomCornerArea.x = xPosition - cropOuterLimit;
			cropLeftBottomCornerArea.y = yPosition + h - cropInnerLimit;
			cropLeftBottomCornerArea.width = cropInnerLimit+cropOuterLimit;
			cropLeftBottomCornerArea.height = cropInnerLimit+cropOuterLimit;
			
			cropRightBottomCornerArea.x = xPosition + w - cropInnerLimit;
			cropRightBottomCornerArea.y = yPosition + h - cropInnerLimit
			cropRightBottomCornerArea.width = cropInnerLimit+cropOuterLimit;
			cropRightBottomCornerArea.height = cropInnerLimit+cropOuterLimit;
			
			cropTopArea.x = xPosition + cropInnerLimit;
			cropTopArea.y = yPosition - cropOuterLimit;
			cropTopArea.width = w - 2*cropInnerLimit;
			cropTopArea.height = cropInnerLimit+cropOuterLimit;
			
			cropLeftArea.x = xPosition - cropOuterLimit;
			cropLeftArea.y = yPosition + cropInnerLimit;
			cropLeftArea.width = cropInnerLimit+cropOuterLimit;
			cropLeftArea.height = h - 2*cropInnerLimit;
			
			cropRightArea.x = xPosition + w - cropInnerLimit;
			cropRightArea.y = yPosition + cropInnerLimit;
			cropRightArea.width = cropInnerLimit+cropOuterLimit;
			cropRightArea.height = h - 2*cropInnerLimit;
			
			cropBottomArea.x = xPosition + cropInnerLimit;
			cropBottomArea.y = yPosition + h - cropInnerLimit;
			cropBottomArea.width = w - 2*cropInnerLimit;
			cropBottomArea.height = cropInnerLimit+cropOuterLimit;
		}
		
		public function crop():void{
			updateMouseAreas();
			cropToolGraphic.activate();
		}
		public function setCropRect(value:Rectangle):void{
			cropRect = value.clone();
			pointA = cropRect.topLeft;
			
			pointB.x = cropRect.right;
			pointB.y = cropRect.y;
			
			pointC = cropRect.bottomRight;
			
			pointD.x = cropRect.x;
			pointD.y = cropRect.bottom;
			
			onPointsUpdated(true);
		}
		public function getCropRect():Rectangle{
			return cropRect.clone();
		}
		public function cropConfirm():void{
			cropToolGraphic.deactivate();
			hideMouseCursor();
		}
		public function cropCancel():void{
			cropToolGraphic.erase();
			resetCrop();
			hideMouseCursor();
		}
		private function resetCrop():void{
			cropRect = new Rectangle();
			pointA = new Point();
			pointB = new Point();
			pointC = new Point();
			pointD = new Point();
			
			// reset mouse poitions
			cropLeftTopCornerArea = new Rectangle();
			cropRightTopCornerArea = new Rectangle();
			cropLeftBottomCornerArea = new Rectangle();
			cropRightBottomCornerArea = new Rectangle();
			
			cropInnerArea = new Rectangle();
			cropTopArea = new Rectangle();
			cropLeftArea = new Rectangle();
			cropRightArea = new Rectangle();
			cropBottomArea = new Rectangle();
		}
		
		
		
		private function isMouseOver(interactiveObject:InteractiveObject, rect:Rectangle):Boolean{
			if (!interactiveObject){
				return false;
			}
			rect = rect.clone();
			rect.x *= _zoom;
			rect.y *= _zoom;
			rect.width *= _zoom;
			rect.height *= _zoom;
			 
			if (interactiveObject.mouseX >= rect.x  &&  interactiveObject.mouseX <= rect.x+rect.width  &&
				interactiveObject.mouseY >= rect.y  &&  interactiveObject.mouseY <= rect.y+rect.height){
					return true;
			}else{
				return false;
			}
		}
		
		 
		

	}
}