package com.centrumholdings.photouploader.tools
{
	
	///import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.containers.Canvas;
	import mx.managers.CursorManager;
	import mx.managers.CursorManagerPriority;
	
	use namespace tool_internal;
	
	/**
	 * Tool for make selection of some area in photo
	 */
	public class SelectTool //implements ITool
	{
		protected var cursorXOffset:int = -8;
		protected var cursorYOffset:int = -8;
		
		[Embed(source="../../../../assets/cursors.swf", symbol="resize0")]
		protected var selectCursor:Class;
		
		[Embed(source="../../../../assets/cursors.swf", symbol="resize1")]
		protected var resize1Cursor:Class;
		
		[Embed(source="../../../../assets/cursors.swf", symbol="resize2")]
		protected var resize2Cursor:Class;
		
		[Embed(source="../../../../assets/cursors.swf", symbol="resize3")]
		protected var resize3Cursor:Class;
		
		[Embed(source="../../../../assets/cursors.swf", symbol="resize4")]
		protected var resize4Cursor:Class;
		
		[Embed(source="../../../../assets/cursors.swf", symbol="move")]
		protected var moveCursor:Class;
		
		protected var toolLayer:Canvas;
		
		
		public function SelectTool(toolLayer:Canvas){
			super();
			this.toolLayer = toolLayer;
			init();
		}
		protected function init():void{
			selectToolGraphic = new SelectToolGraphic();
		}
		
		
		
		
		//--------------------------------------
		// CURSORS
		//--------------------------------------
		private var currentCursorClass:Class;
		private function showMouseCursor(cursor:Class=null):void{
			if (cursor == null){
				cursor = selectCursor;
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
			if (!isDraging  &&  !isSelecting  &&  !isResizing){
				showMouseCursor();
			}
		}
		tool_internal function onMouseOut():void{
			if (!isDraging  &&  !isSelecting  &&  !isResizing){
				hideMouseCursor();
			}
		}
		tool_internal function onMouseDown():void{
			// reset values
			isDraging = isResizing = isSelecting = false;
			
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
					onSelectingStart();
					break;
			}
		}
		tool_internal function onMouseMove():void{
			if (isSelecting){
				onSelecting();
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
			if (isSelecting){
				isSelecting = false;
				onSelecting();
				onEditSelectionFinished();
			}else if (isDraging){
				isDraging = false;
				onDraging();
				onEditSelectionFinished();
			}else if (isResizing){
				isResizing = false;
				onResizing();
				onEditSelectionFinished();
			}
		}
		
		
		
		
		
		//--------------------------------------
		// AREAS
		//--------------------------------------
		tool_internal function setSceneFullSize(photoWidth:Number, photoHeight:Number):void{
			sceneRect.width = photoWidth;
			sceneRect.height = photoHeight;
		}
		
		
		
		private var _zoom:Number = 1;
		tool_internal function set zoom(value:Number):void{
			_zoom = value / 100;
			selectToolGraphic.zoom = _zoom;
		}
		
		tool_internal function transform(type:String):void{
			var buffer:Number;
			switch (type){
				case LayerEvent.SIZE_CHANGE_ADDED_BITMAP:
					break;
				case LayerEvent.SIZE_CHANGE_FLIP_HORIZONTAL:
					selectedRect.y = sceneRect.height - selectedRect.y - selectedRect.height;
					break;
				case LayerEvent.SIZE_CHANGE_FLIP_VERTICAL:
					selectedRect.x = sceneRect.width - selectedRect.x - selectedRect.width;
					break;
				case LayerEvent.SIZE_CHANGE_ROTATE_LEFT:
					// rotate sceneRect
					buffer = sceneRect.width;
					sceneRect.width = sceneRect.height;
					sceneRect.height = buffer;
					
					// rotate selectedRect
					buffer = selectedRect.width;
					selectedRect.width = selectedRect.height;
					selectedRect.height = buffer;
					
					buffer = selectedRect.x;
					
					// X ... stará hodnota y
					selectedRect.x = selectedRect.y;
					selectedRect.y = sceneRect.height - selectedRect.height - buffer;
					break;
				case LayerEvent.SIZE_CHANGE_ROTATE_RIGHT:
					// rotate sceneRect
					buffer = sceneRect.width;
					sceneRect.width = sceneRect.height;
					sceneRect.height = buffer;
					
					// rotate selectedRect
					buffer = selectedRect.width;
					selectedRect.width = selectedRect.height;
					selectedRect.height = buffer;
					
					buffer = selectedRect.x;
					
					// nyní šířka (dříve výška) obrázku  -   nynější šířka selectu
					selectedRect.x = sceneRect.width 		- selectedRect.width -  	selectedRect.y;
					// Y ... stará hodnota x
					selectedRect.y = buffer;
					
					break;
				/* case LayerEvent.SIZE_CHANGE_ZOOM:
					selectToolGraphic.zoom = _zoom;
					break; */
			}
			
			pointA.x = selectedRect.x;
			pointA.y = selectedRect.y;
			
			pointB.x = selectedRect.x + selectedRect.width;
			pointB.y = selectedRect.y;
			 
			pointC.x = selectedRect.x + selectedRect.width;
			pointC.y = selectedRect.y + selectedRect.height;
			
			pointD.x = selectedRect.x;
			pointD.y = selectedRect.y + selectedRect.height;
			
			//method onPointsUpdated will call selectToolGraphic.draw()
			onPointsUpdated(true);
		}
		
		
		protected var selectToolGraphic:SelectToolGraphic;
		
		/**
		 * Size of image with zoom 1:1.
		 */
		protected var sceneRect:Rectangle = new Rectangle();
		
		private static const selectInnerLimit:Number = 20;
		private static const selectOuterLimit:Number = 20;
		private var selectLeftTopCornerArea:Rectangle = new Rectangle();
		private var selectRightTopCornerArea:Rectangle = new Rectangle();
		private var selectLeftBottomCornerArea:Rectangle = new Rectangle();
		private var selectRightBottomCornerArea:Rectangle = new Rectangle();
		
		private var selectInnerArea:Rectangle = new Rectangle();
		private var selectTopArea:Rectangle = new Rectangle();
		private var selectLeftArea:Rectangle = new Rectangle();
		private var selectRightArea:Rectangle = new Rectangle();
		private var selectBottomArea:Rectangle = new Rectangle();
		
		// selectedRect ... zobrazení 1:1 k fotce
		protected var selectedRect:Rectangle = new Rectangle();
		// points of selectedRect
		protected var pointA:Point = new Point(); // a ... left top
		protected var pointB:Point = new Point(); // b ... right top
		protected var pointC:Point = new Point(); // c ... right bottom
		protected var pointD:Point = new Point(); // d ... left bottom
		
		//--------------------------------------
		// SELECTING
		//--------------------------------------
		private var isSelecting:Boolean = false;
		private function onSelectingStart():void{
			isSelecting = true;
			pointA.x = toolLayer.mouseX/_zoom;
			pointA.y = toolLayer.mouseY/_zoom;
			
			pointB.y = pointA.y;
			pointD.x = pointA.x;
			selectToolGraphic.setSceneRectangle(sceneRect);
			if (selectToolGraphic.parent != toolLayer){
				toolLayer.addChild(selectToolGraphic);
			}
		}
		private function onSelecting():void{
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
			const mousePoint:Point = new Point(toolLayer.mouseX / _zoom, toolLayer.mouseY / _zoom);
			
			if (selectInnerArea.containsPoint(mousePoint)){
				return MOUSE_IN_BOX;
			}else if (selectLeftTopCornerArea.containsPoint(mousePoint)){
				return MOUSE_OVER_LEFT_TOP;
			}else if (selectRightBottomCornerArea.containsPoint(mousePoint)){
				return MOUSE_OVER_RIGHT_BOTTOM;
			}else if (selectTopArea.containsPoint(mousePoint)){
				return MOUSE_OVER_TOP;
			}else if (selectBottomArea.containsPoint(mousePoint)){
				return MOUSE_OVER_BOTTOM;
			}else if (selectRightTopCornerArea.containsPoint(mousePoint)){
				return MOUSE_OVER_RIGHT_TOP;
			}else if (selectLeftBottomCornerArea.containsPoint(mousePoint)){
				return MOUSE_OVER_LEFT_BOTTOM;
			}else if (selectRightArea.containsPoint(mousePoint)){
				return MOUSE_OVER_RIGHT;
			}else if (selectLeftArea.containsPoint(mousePoint)){
				return MOUSE_OVER_LEFT;
			}else if (sceneRect.containsPoint(mousePoint)){
				return MOUSE_OUT_BOX;
			}else{
				return MOUSE_OUT_SCENE;
			}
		}
		
		
		
		
		
		protected function onPointsUpdated(fixPoints:Boolean=false):void{
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
			
			selectedRect.x = internalPointA.x;
			selectedRect.y = internalPointA.y;
			selectedRect.width = internalPointC.x - internalPointA.x;
			selectedRect.height = internalPointC.y - internalPointA.y;
			
			
			if (fixPoints  &&  (selectedRect.width < 10  ||  selectedRect.height < 10)){
				selectCancel();
			}else{
				selectToolGraphic.draw(selectedRect);
			}
			if (fixPoints){
				pointA = internalPointA;
				pointB = internalPointB;
				pointC = internalPointC;
				pointD = internalPointD;
			}
		}
		
		// fixing size and position of selection
		private function onEditSelectionFinished():void{
			onPointsUpdated(true);
			updateActiveAreas();
		}
		
		/**
		 * Update active areas for.
		 */
		protected function updateActiveAreas():void{
			const xPosition:Number = selectedRect.x;
			const yPosition:Number = selectedRect.y;
			const w:Number = selectedRect.width;
			const h:Number = selectedRect.height;
			
			selectInnerArea.x = xPosition + selectInnerLimit;
			selectInnerArea.y = yPosition + selectInnerLimit;
			selectInnerArea.width = w - 2*selectInnerLimit;
			selectInnerArea.height = h - 2*selectInnerLimit;
			
			selectLeftTopCornerArea.x = xPosition-selectOuterLimit;
			selectLeftTopCornerArea.y = yPosition-selectOuterLimit;
			selectLeftTopCornerArea.width = selectInnerLimit+selectOuterLimit;
			selectLeftTopCornerArea.height = selectInnerLimit+selectOuterLimit;
			
			selectRightTopCornerArea.x = xPosition + w - selectInnerLimit;
			selectRightTopCornerArea.y = yPosition - selectOuterLimit;
			selectRightTopCornerArea.width = selectInnerLimit+selectOuterLimit;
			selectRightTopCornerArea.height = selectInnerLimit+selectOuterLimit;
			
			selectLeftBottomCornerArea.x = xPosition - selectOuterLimit;
			selectLeftBottomCornerArea.y = yPosition + h - selectInnerLimit;
			selectLeftBottomCornerArea.width = selectInnerLimit+selectOuterLimit;
			selectLeftBottomCornerArea.height = selectInnerLimit+selectOuterLimit;
			
			selectRightBottomCornerArea.x = xPosition + w - selectInnerLimit;
			selectRightBottomCornerArea.y = yPosition + h - selectInnerLimit
			selectRightBottomCornerArea.width = selectInnerLimit+selectOuterLimit;
			selectRightBottomCornerArea.height = selectInnerLimit+selectOuterLimit;
			
			selectTopArea.x = xPosition + selectInnerLimit;
			selectTopArea.y = yPosition - selectOuterLimit;
			selectTopArea.width = w - 2*selectInnerLimit;
			selectTopArea.height = selectInnerLimit+selectOuterLimit;
			
			selectLeftArea.x = xPosition - selectOuterLimit;
			selectLeftArea.y = yPosition + selectInnerLimit;
			selectLeftArea.width = selectInnerLimit+selectOuterLimit;
			selectLeftArea.height = h - 2*selectInnerLimit;
			
			selectRightArea.x = xPosition + w - selectInnerLimit;
			selectRightArea.y = yPosition + selectInnerLimit;
			selectRightArea.width = selectInnerLimit+selectOuterLimit;
			selectRightArea.height = h - 2*selectInnerLimit;
			
			selectBottomArea.x = xPosition + selectInnerLimit;
			selectBottomArea.y = yPosition + h - selectInnerLimit;
			selectBottomArea.width = w - 2*selectInnerLimit;
			selectBottomArea.height = selectInnerLimit+selectOuterLimit;
		}
		
		/**
		 * Start selecting.
		 */
		public function select():void{
			updateActiveAreas();
			selectToolGraphic.setSceneRectangle(sceneRect);
			selectToolGraphic.activate();
		}
		
		/**
		 * Set selection.
		 */
		public function setSelectedRect(value:Rectangle):void{
			selectedRect = value.clone();
			pointA = selectedRect.topLeft;
			
			pointB.x = selectedRect.right;
			pointB.y = selectedRect.y;
			
			pointC = selectedRect.bottomRight;
			
			pointD.x = selectedRect.x;
			pointD.y = selectedRect.bottom;
			
			onPointsUpdated(true);
		}
		/**
		 * Return Rectangle selection.
		 */
		public function getSelectedRect():Rectangle{
			return selectedRect.clone();
		}
		/**
		 * Confirm Selection.
		 */
		public function selectConfirm():void{
			selectToolGraphic.deactivate();
			hideMouseCursor();
		}
		/**
		 * Delete Selection.
		 */
		public function selectCancel():void{
			selectToolGraphic.erase();
			resetSelection();
			hideMouseCursor();
		}
		private function resetSelection():void{
			selectedRect = new Rectangle();
			pointA = new Point();
			pointB = new Point();
			pointC = new Point();
			pointD = new Point();
			
			// reset mouse poitions
			selectLeftTopCornerArea = new Rectangle();
			selectRightTopCornerArea = new Rectangle();
			selectLeftBottomCornerArea = new Rectangle();
			selectRightBottomCornerArea = new Rectangle();
			
			selectInnerArea = new Rectangle();
			selectTopArea = new Rectangle();
			selectLeftArea = new Rectangle();
			selectRightArea = new Rectangle();
			selectBottomArea = new Rectangle();
		}
		
		
		

	}
}