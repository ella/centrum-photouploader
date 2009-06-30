package com.centrumholdings.photouploader.tools
{
	///import flash.display.BitmapData;
	import com.centrumholdings.graphics.BitmapEditor;
	
	import flash.display.*;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import mx.binding.utils.BindingUtils;
	import mx.core.Application;
	use namespace tool_internal;
	
	public class ToolController extends EventDispatcher
	{
		
		private static const CROP_TOOL:String = "cropTool";
		private static const FACE_TOOL:String = "faceTool";
		
		private var photoStage:PhotoStage;
		
		private var _currentTool:SelectTool;
		private var cropToolInstance:SelectTool;
		private var faceToolInstance:FaceSelectTool;
		
		
		private function set currentTool(toolName:String):void{
			isEditing = true;
			isCropping = false;
			isFaceSelecting = false;
		
			switch(toolName){
				case CROP_TOOL:
					if (!cropToolInstance){
						cropToolInstance = new SelectTool(photoStage.cropLayer);
					}
					cropToolInstance.setSceneFullSize(photoStage.bitmapLayer.widthBitmapOriginal, photoStage.bitmapLayer.heightBitmapOriginal);
					cropToolInstance.zoom = photoStage.bitmapLayer.zoom;
					
					_currentTool = cropToolInstance;
					cropToolInstance.select();
					isCropping = true;
					break;
				case FACE_TOOL:
					if (!faceToolInstance){
						faceToolInstance = new FaceSelectTool(photoStage.faceLayer);
						if (cropToolInstance){
							faceToolInstance.cropSelection(cropToolInstance.getSelectedRect());
						}
					}
					faceToolInstance.setSceneFullSize(photoStage.bitmapLayer.widthBitmap, photoStage.bitmapLayer.heightBitmap);
					faceToolInstance.zoom = photoStage.bitmapLayer.zoom;
					
					_currentTool = faceToolInstance;
					faceToolInstance.select();
					isFaceSelecting = true;
					break;
				//case null:
				default:
					isEditing = false;
					_currentTool = null;
					break;
			}
			if (isEditing){
				addMouseListeners();
			}else{
				removeMouseListeners();
			}
		}
		
		
		private var _editable:Boolean = true;
		tool_internal function set editable(value:Boolean):void{
			_editable = value;
			if (isCropping){
				cropCancel();
			}else
			if (isFaceSelecting){
				faceSelectCancel();
			}
		}
		tool_internal function get editable():Boolean{
			return _editable;
		}
		
		
		tool_internal function reset():void{
			cropCancel();
			faceSelectCancel();
			resetColorSetting();
			clearHistory();
			resetCMYK();
		}
			
		
		
		//--------------------------------------
		// HISTORY OF ACTIONS
		//--------------------------------------
		[Bindable]
		public var isUndoStep:Boolean;
		[Bindable]
		public var isRedoStep:Boolean;
		
		protected var stepsController:StepsController;
		public function undo():void{
			stepsController.undo();
		}
		public function redo():void{
			stepsController.redo();
		}
		
		private function clearHistory():void{
			stepsController.clearHistory();
		}
		
		
		
		
		
		[Bindable]
		public var isEditing:Boolean = false;
		
		//--------------------------------------
		// CROP
		//--------------------------------------
		[Bindable]
		public var isCropping:Boolean = false;
		public function crop():void{
			if (cropToolInstance){
				photoStage.bitmapLayer.restoreFromBackup();
				// apply color setting
				refreshColorSetting();
				
				if (faceToolInstance){
					faceToolInstance.zoom = photoStage.bitmapLayer.zoom;
					faceToolInstance.setSceneFullSize(photoStage.bitmapLayer.widthBitmap, photoStage.bitmapLayer.heightBitmap);
					faceToolInstance.uncropSelection(cropToolInstance.getSelectedRect());
				}
			}
			currentTool = CROP_TOOL;
		}
		public function cropConfirm():void{
			stepsController.addFunction(cropConfirmNoHistoryStep, [cropToolInstance.getSelectedRect()],
										cropConfirmNoHistoryStep, [currentCropRect.clone()]);
			
			cropConfirmNoHistoryStep(cropToolInstance.getSelectedRect());
		}
		protected var currentCropRect:Rectangle = new Rectangle();
		protected function cropConfirmNoHistoryStep(cropRect:Rectangle):void{
			cropToolInstance.setSelectedRect(cropRect);
			/* 
			// dočasné
			photoStage.bitmapLayer.restoreFromBackup();
			// apply color setting
			refreshColorSetting();
			
			if (faceToolInstance){
				faceToolInstance.zoom = photoStage.bitmapLayer.zoom;
				faceToolInstance.setSceneFullSize(photoStage.bitmapLayer.widthBitmap, photoStage.bitmapLayer.heightBitmap);
				faceToolInstance.uncropSelection(cropToolInstance.getSelectedRect());
			}
			
			// dočasné end
			 */
			currentCropRect = cropRect;
			photoStage.bitmapLayer.crop(cropRect);
			cropToolInstance.selectConfirm();
			currentTool = null;
			
			if (faceToolInstance){
				faceToolInstance.setSceneFullSize(photoStage.bitmapLayer.widthBitmap, photoStage.bitmapLayer.heightBitmap);
				faceToolInstance.cropSelection(cropRect);
			}
		}
		
		public function cropCancel():void{
			if (cropToolInstance){
				cropToolInstance.selectCancel();
				currentTool = null;
				if (faceToolInstance){
					faceToolInstance.zoom = photoStage.bitmapLayer.zoom;
					faceToolInstance.setSceneFullSize(photoStage.bitmapLayer.widthBitmap, photoStage.bitmapLayer.heightBitmap);
					faceToolInstance.uncropSelection(cropToolInstance.getSelectedRect());
				}
			}
		}
		
		
		
		//--------------------------------------
		// SELECTING FACE
		//--------------------------------------
		[Bindable]
		public var isFaceSelecting:Boolean = false;
		public function faceSelect():void{
			currentTool = FACE_TOOL;
		}
		public function faceSelectConfirm():void{
			//photoStage.bitmapLayer.crop(cropToolInstance.getSelectedRect());
			faceToolInstance.selectConfirm();
			currentTool = null;
		}
		
		public function faceSelectCancel():void{
			if (faceToolInstance){
				faceToolInstance.selectCancel();
				currentTool = null;
			}
		}
		public function getSelectedFaceRect():Rectangle{
			if (faceToolInstance){
				return faceToolInstance.getSelectedRect();
			}else{
				return null;
			}
		}
		
		
		
		
		
		
		
		//--------------------------------------
		// BASIC STAGE ADJUSTMENTS
		//--------------------------------------
		public function rotateLeft():void{
			photoStage.bitmapLayer.rotateLeft();
			stepsController.addFunction(photoStage.bitmapLayer.rotateLeft, null, photoStage.bitmapLayer.rotateRight, null);
		}
		public function rotateRight():void{
			photoStage.bitmapLayer.rotateRight();
			stepsController.addFunction(photoStage.bitmapLayer.rotateRight, null, photoStage.bitmapLayer.rotateLeft, null);
		}
		public function flipHorizontal():void{
			photoStage.bitmapLayer.flipHorizontal();
			stepsController.addFunction(photoStage.bitmapLayer.flipHorizontal, null, photoStage.bitmapLayer.flipVertical, null);
		}
		public function flipVertical():void{
			photoStage.bitmapLayer.flipVertical();
			stepsController.addFunction(photoStage.bitmapLayer.flipVertical, null, photoStage.bitmapLayer.flipHorizontal, null);
		}
		//--------------------------------------
		// IMAGE ADJUSTMENTS
		//--------------------------------------
		[Bindable]
		public var brightness:Number = 0;
		[Bindable]
		public var contrast:Number = 0;
		[Bindable]
		public var color:Number = 0;
		public function setColorSetting(brightness:Number, contrast:Number, color:Number):void{
			if (this.brightness != brightness  ||  this.contrast != contrast  ||  this.color != color){
				stepsController.addFunction(setColorSettingNoHistoryStep, [brightness, contrast, color], 
											setColorSettingNoHistoryStep, [this.brightness, this.contrast, this.color]);
				setColorSettingNoHistoryStep(brightness, contrast, color);
			}
		}
		protected function setColorSettingNoHistoryStep(brightness:Number, contrast:Number, color:Number):void{
			// backup adjustements for stepsController:
			this.brightness = brightness;
			this.contrast = contrast;
			this.color = color;
			var bitmapLayer:BitmapLayer = photoStage.bitmapLayer;
			
			var newBitmapData:BitmapData = BitmapEditor.setSaturation(bitmapLayer.bitmapDataOriginal, color);
			bitmapLayer.bitmapDataCopy = BitmapEditor.setContrastAndBrightness(newBitmapData, contrast, brightness);
		}
		protected function refreshColorSetting():void{
			var bitmapLayer:BitmapLayer = photoStage.bitmapLayer;
			
			var newBitmapData:BitmapData = BitmapEditor.setSaturation(bitmapLayer.bitmapDataOriginal, color);
			bitmapLayer.bitmapDataCopy = BitmapEditor.setContrastAndBrightness(newBitmapData, contrast, brightness);
		}
		protected function resetColorSetting():void{
			brightness = 0;
			contrast = 0;
			color = 0;
		}
		
		
		private var cmykProcessApplied:Boolean = false;  
		public function repairCMYK():void{
			cmykProcessApplied = true;
			photoStage.bitmapLayer.bitmapDataCopy = BitmapEditor.tryFixCMYK(photoStage.bitmapLayer.bitmapDataCopy);
		}
		private function resetCMYK():void{
			cmykProcessApplied = false;
		}
		
		
		
		
		public function ToolController(photoStage:PhotoStage){
			stepsController = new StepsController();
			BindingUtils.bindProperty(this, "isUndoStep", stepsController, "isUndoStep");
			BindingUtils.bindProperty(this, "isRedoStep", stepsController, "isRedoStep");
			
			this.photoStage = photoStage;
			
			this.photoStage.bitmapLayer.addEventListener(LayerEvent.SIZE_CHANGE_ADDED_BITMAP, 		onPhotoStageSizeChange);
			this.photoStage.bitmapLayer.addEventListener(LayerEvent.SIZE_CHANGE_FLIP_HORIZONTAL, 	onPhotoStageSizeChange);
			this.photoStage.bitmapLayer.addEventListener(LayerEvent.SIZE_CHANGE_FLIP_VERTICAL, 		onPhotoStageSizeChange);
			this.photoStage.bitmapLayer.addEventListener(LayerEvent.SIZE_CHANGE_ROTATE_LEFT, 		onPhotoStageSizeChange);
			this.photoStage.bitmapLayer.addEventListener(LayerEvent.SIZE_CHANGE_ROTATE_RIGHT, 		onPhotoStageSizeChange);
			this.photoStage.bitmapLayer.addEventListener(LayerEvent.SIZE_CHANGE_ZOOM, 				onPhotoStageSizeChange);
		}
		
		
		
		//--------------------------------------
		// PHOTO STAGE EVENTS
		//--------------------------------------
		private function onPhotoStageSizeChange(evt:LayerEvent):void{
			switch(evt.type){
				case LayerEvent.SIZE_CHANGE_ZOOM:
					if (cropToolInstance)
						cropToolInstance.zoom = photoStage.bitmapLayer.zoom;
					if (faceToolInstance)
						faceToolInstance.zoom = photoStage.bitmapLayer.zoom;
					break;
				default:
					//cropToolInstance.initSceneSize(photoStage.bitmapLayer.widthBitmap, photoStage.bitmapLayer.heightBitmap);
					if (cropToolInstance){
						cropToolInstance.zoom = photoStage.bitmapLayer.zoom;
						cropToolInstance.transform(evt.type);
					}
					if (faceToolInstance){
						faceToolInstance.zoom = photoStage.bitmapLayer.zoom;
						faceToolInstance.transform(evt.type);
					}
					break;
			}
		}
		
		
		
		
		//--------------------------------------
		// MOUSE EVENTS
		//--------------------------------------
		private var isAddedMouseListeners:Boolean = false;
		private function addMouseListeners():void{
			if (isAddedMouseListeners == false){
				isAddedMouseListeners = true;
				photoStage.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
				photoStage.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
				//photoStage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				Application.application.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				
				photoStage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				//photoStage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				Application.application.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				
				Application.application.stage.addEventListener(Event.DEACTIVATE, onMouseUp);
				Application.application.stage.addEventListener(Event.MOUSE_LEAVE, onMouseUp);
			}
		}
		private function removeMouseListeners():void{
			if (isAddedMouseListeners){
				photoStage.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
				photoStage.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
				//photoStage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				Application.application.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				
				photoStage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				//photoStage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				Application.application.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				
				Application.application.stage.removeEventListener(Event.DEACTIVATE, onMouseUp);
				Application.application.stage.removeEventListener(Event.MOUSE_LEAVE, onMouseUp);
				isAddedMouseListeners = false;
			}
		}
		private function onMouseOver(evt:MouseEvent):void{
			if (_currentTool)
				_currentTool.onMouseOver();
		}
		private function onMouseOut(evt:MouseEvent):void{
			if (_currentTool)
				_currentTool.onMouseOut();
		}
		private function onMouseMove(evt:MouseEvent):void{
			if (_currentTool){
				_currentTool.onMouseMove();
			}
		}
		private function onMouseDown(evt:MouseEvent):void{
			if (_currentTool)
				_currentTool.onMouseDown();
		}
		private function onMouseUp(evt:Event):void{
			if (_currentTool)
				_currentTool.onMouseUp();
		}
		
		
		
		

	}
}