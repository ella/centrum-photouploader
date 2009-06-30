package com.centrumholdings.photouploader.tools
{
	///import flash.display.BitmapData;
	import com.centrumholdings.controllers.AnimationController;
	
	import flash.display.*;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import mx.containers.Canvas;
	import mx.events.ChildExistenceChangedEvent;
	
	use namespace tool_internal;

	[Event(name="sizeChange",		type="com.centrumholdings.photouploader.tools.PhotoStageEvent")]
	[Event(name="rotateLeft",		type="com.centrumholdings.photouploader.tools.PhotoStageEvent")]
	[Event(name="rotateRight",		type="com.centrumholdings.photouploader.tools.PhotoStageEvent")]
	[Event(name="flipHorizontal",	type="com.centrumholdings.photouploader.tools.PhotoStageEvent")]
	[Event(name="flipVertical",		type="com.centrumholdings.photouploader.tools.PhotoStageEvent")]
	public class PhotoStage extends Canvas
	{
		
		//--------------------------------------
		// Layer ONLY for tool's objects 
		//--------------------------------------
		tool_internal var bitmapLayer:BitmapLayer = new BitmapLayer();
		tool_internal var cropLayer:Canvas;
		tool_internal var faceLayer:Canvas;
		
		private var _toolController:ToolController;
		[Bindable("toolControllerChanged")]
		public function get toolController():ToolController{
			return _toolController;
		}
		
		
		public function PhotoStage(){
			super();
			_toolController = new ToolController(this);
			dispatchEvent(new Event("toolControllerChanged"));
			
			cropLayer = new Canvas();
			addChild(cropLayer);
			
			faceLayer = new Canvas();
			addChild(faceLayer);
			
			addEventListener(ChildExistenceChangedEvent.CHILD_ADD, onChildAdded);
		}
		private function onChildAdded(evt:ChildExistenceChangedEvent):void{
			setChildIndex(cropLayer, numChildren-1);
			setChildIndex(faceLayer, numChildren-1);
		}
		
		
		
		public function set editable(value:Boolean):void{
			toolController.editable = value;
			if (!value){
				hideCompare();
			}
		}
		public function get editable():Boolean{
			return toolController.editable;
		}
		
		
		
		public function set zoom(value:Number):void{
			bitmapLayer.zoom = value;
		}
		
		
		public function zoomFitToScreen():void{
			bitmapLayer.zoom = BitmapLayer.ZOOM_FIT_TO_SCREEN;
		}
		
		
		
		public function addBitmapData(bitmapData:BitmapData):void{
			removeBitmapData();
			
			bitmapLayer.init(bitmapData);
			addChild(bitmapLayer.imageCopy);
		}
		public function getBitmapData():BitmapData{
			return bitmapLayer.bitmapDataCopy;
		}
		public function getSelectedFaceRect(imageWidth:Number, imageHeight:Number):Rectangle{
			var rect:Rectangle = toolController.getSelectedFaceRect();
			if (rect){
				var wKoef:Number = imageWidth / getBitmapData().width;
				var hKoef:Number = imageHeight / getBitmapData().height;
				
				rect.x = rect.x * wKoef;
				rect.y = rect.y * hKoef;
				rect.width = rect.width * wKoef;
				rect.height = rect.height * hKoef;
			}
			return rect;
		}
		
			
		public function removeBitmapData():void{
			if (bitmapLayer  &&  bitmapLayer.imageCopy  &&  bitmapLayer.imageCopy.parent){
				removeChild(bitmapLayer.imageCopy);
			}
			hideCompare();
			toolController.reset();
			bitmapLayer.removeBitmapData();
		}
		
		
		
		
		
		
		
		
		
		
		//--------------------------------------
		// COMPARE IMAGES
		//--------------------------------------
		private var compareMask:Shape = new Shape();
		private var compareLine:Shape = new Shape();
		private var currentComparePercent:Number = 0;
		private var imageOriginalAddingToScene:Boolean = false;
		public function showCompare(percent:Number):void{
			if (bitmapLayer  &&  bitmapLayer.imageOriginal){
				if (bitmapLayer.imageOriginal.parent == null){
					if (imageOriginalAddingToScene == false){
						imageOriginalAddingToScene = true;
						bitmapLayer.imageOriginal.addEventListener(Event.ADDED, imageOriginalAddedToScene);
						addChild(bitmapLayer.imageOriginal);
						bitmapLayer.imageOriginal.mask = compareMask;
						bitmapLayer.imageOriginal.addChild(compareMask);
						bitmapLayer.imageOriginal.addChild(compareLine);
						
						bitmapLayer_height = bitmapLayer.height;
						// redraw line
						compareLine.graphics.clear();
						compareLine.graphics.lineStyle(1, 0xFFFFFF, 1, true);
						compareLine.graphics.lineTo(0, bitmapLayer_height);
					}
				}else{
					AnimationController.callFunction(
						showCompareNow, currentComparePercent, percent, 500, false, AnimationController.easeOut, onCompareAnimationFinish);
				}
			}
		}
		private function imageOriginalAddedToScene(evet:Event):void{
			imageOriginalAddingToScene = false;
			bitmapLayer.imageOriginal.removeEventListener(Event.ADDED, imageOriginalAddedToScene);
		}
		
		
		
		
		private var bitmapLayer_height:Number = 0;
		private function showCompareNow(value:Number):void{
			// orig photo
			// var maskWidth:Number = Math.round(bitmapLayer.width * value/100);
			const currentMaskWidth:Number = Math.round(bitmapLayer.width * currentComparePercent/100);
			const newMaskWidth:Number = Math.round(bitmapLayer.width * value/100);
			
			if (currentComparePercent > value){
				compareMask.graphics.clear();
				compareMask.graphics.beginFill(0x000000);
				compareMask.graphics.drawRect(0, 0, newMaskWidth, bitmapLayer_height);
			}else{
				//compareMask.graphics.beginFill(0x000000);
				compareMask.graphics.drawRect(currentMaskWidth, 0, newMaskWidth - currentMaskWidth, bitmapLayer_height);
			}
			
			//photoOriginal.smoothing = true;
			//bitmapLayer.imageOriginal.mask = compareMask;
			
			// move line
			compareLine.x = newMaskWidth - 1; 
			
			// save current "compare" value
			currentComparePercent = value;
		}
		public function hideCompare():void{
			showCompare(0);
		}
		private function onCompareAnimationFinish():void{
			if (currentComparePercent == 0  &&  bitmapLayer.imageOriginal  &&  bitmapLayer.imageOriginal.parent){
				removeChild(bitmapLayer.imageOriginal);
			}
		}
		
		
		
		
		
		
		
	}
}
