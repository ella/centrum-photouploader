package com.centrumholdings.photouploader.tools
{
	import com.centrumholdings.graphics.BitmapEditor;
	
	import flash.display.*;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.controls.Image;
	
	
	[Event(name="sizeChangeAddedBitmap",type="com.centrumholdings.photouploader.tools.LayerEvent")]
	[Event(name="sizeChangeZoom",type="com.centrumholdings.photouploader.tools.LayerEvent")]
	[Event(name="rotateLeft",type="com.centrumholdings.photouploader.tools.LayerEvent")]
	[Event(name="rotateRight",type="com.centrumholdings.photouploader.tools.LayerEvent")]
	[Event(name="flipHorizontal",type="com.centrumholdings.photouploader.tools.LayerEvent")]
	[Event(name="flipVertical",type="com.centrumholdings.photouploader.tools.LayerEvent")]
	public class BitmapLayer extends EventDispatcher
	{
		
		//--------------------------------------
		// BITMAP DATA BACKUP - no filter, no crop
		//--------------------------------------
		private var _bitmapDataBackup:BitmapData;
		
		public function restoreFromBackup():void{
			bitmapDataOriginal = _bitmapDataBackup.clone();
			bitmapDataCopy = _bitmapDataBackup.clone();
			updateZoom();
		}
		
		
		
		//--------------------------------------
		// BITMAP DATA - no filter
		//--------------------------------------
		private var _bitmapDataOriginal:BitmapData;
		public function set bitmapDataOriginal(value:BitmapData):void{
			_bitmapDataOriginal = value;
			onBitmapDataOriginalChanged();
		}
		protected function onBitmapDataOriginalChanged():void{
			imageOriginal.source = new Bitmap(_bitmapDataOriginal, PixelSnapping.ALWAYS, true);
		}
		public function get bitmapDataOriginal():BitmapData{
			return _bitmapDataOriginal;
		}
		
		
		//--------------------------------------
		// BITMAP DATA COPY
		//--------------------------------------
		private var _bitmapDataCopy:BitmapData;
		public function set bitmapDataCopy(value:BitmapData):void{
			_bitmapDataCopy = value;
			onBitmapDataCopyChanged();
		}
		protected function onBitmapDataCopyChanged():void{
			_imageCopy.source = new Bitmap(_bitmapDataCopy, PixelSnapping.ALWAYS, true);
			//updateZoom();
		}
		public function get bitmapDataCopy():BitmapData{
			return _bitmapDataCopy;
		}
		
		
		
		//--------------------------------------
		// IMAGE COPY
		//--------------------------------------
		private var _imageCopy:Image;
		public function get imageCopy():Image{return _imageCopy;}
		
		
		
		//--------------------------------------
		// PHOTO & IMAGE COPY
		//--------------------------------------
		private var _imageOriginal:Image;
		public function get imageOriginal():Image{
			return _imageOriginal;
		}
		
		
		
		public function BitmapLayer(){
			super();
		}
		public function init(bitmapData:BitmapData):void{
			_bitmapDataBackup = bitmapData;
			
			_bitmapDataOriginal = new BitmapData(bitmapData.width, bitmapData.height, false);
			_bitmapDataOriginal.copyPixels(bitmapData, new Rectangle(0,0,bitmapData.width, bitmapData.height), new Point());
			
			_bitmapDataCopy = new BitmapData(bitmapData.width, bitmapData.height, false);
			_bitmapDataCopy.copyPixels(bitmapData, new Rectangle(0,0,bitmapData.width, bitmapData.height), new Point());
			
			_imageCopy = new Image();
			_imageCopy.source = new Bitmap(_bitmapDataCopy, PixelSnapping.ALWAYS, true);
			
			_imageOriginal = new Image();
			_imageOriginal.source = new Bitmap(_bitmapDataOriginal, PixelSnapping.ALWAYS, true);
			BitmapEditor.runGarbageCollector();
		}
		public function removeBitmapData():void{
			_bitmapDataBackup = null;
			_bitmapDataOriginal = null;
			_bitmapDataCopy = null
			if (_imageCopy){
				_imageCopy.source = null;
				_imageCopy = null;
			}
			if (_imageOriginal){
				_imageOriginal.source = null;
				_imageOriginal = null;
			}
			BitmapEditor.runGarbageCollector();
		}
		
		
		public function get widthBitmapOriginal():Number{
			if (bitmapDataOriginal){
				return bitmapDataOriginal.width;
			}
			return 0;
		}
		public function get heightBitmapOriginal():Number{
			if (bitmapDataOriginal){
				return bitmapDataOriginal.height;
			}
			return 0;
		}
		
		public function get widthBitmap():Number{
			if (bitmapDataCopy){
				return bitmapDataCopy.width;
			}
			return 0;
		}
		public function get heightBitmap():Number{
			if (bitmapDataCopy){
				return bitmapDataCopy.height;
			}
			return 0;
		}
		
		public function get width():Number{
			// visible width
			if (imageCopy){
				return Bitmap(imageCopy.source).width;
			}
			return 0;
		}
		public function get height():Number{
			// visible height
			if (imageCopy){
				return Bitmap(imageCopy.source).height;
			}
			return 0;
		}
		
		
		
		
		
		
		
		//--------------------------------------
		// BASIC STAGE ADJUSTMENTS
		//--------------------------------------
		public function rotateLeft():void{
			_bitmapDataCopy 	= BitmapEditor.rotateLeft(_bitmapDataCopy);
			_bitmapDataOriginal = BitmapEditor.rotateLeft(_bitmapDataOriginal);
			_bitmapDataBackup 	= BitmapEditor.rotateLeft(_bitmapDataBackup);
			
			onBitmapDataCopyChanged();
			onBitmapDataOriginalChanged();
			
			updateZoom(LayerEvent.SIZE_CHANGE_ROTATE_LEFT);
		}
		public function rotateRight():void{
			_bitmapDataCopy 	= BitmapEditor.rotateRight(_bitmapDataCopy);
			_bitmapDataOriginal = BitmapEditor.rotateRight(_bitmapDataOriginal);
			_bitmapDataBackup 	= BitmapEditor.rotateRight(_bitmapDataBackup);
			
			onBitmapDataCopyChanged();
			onBitmapDataOriginalChanged();
			
			updateZoom(LayerEvent.SIZE_CHANGE_ROTATE_RIGHT);
		}
		public function flipHorizontal():void{
			_bitmapDataCopy 	= BitmapEditor.flipHorizontal(_bitmapDataCopy);
			_bitmapDataOriginal = BitmapEditor.flipHorizontal(_bitmapDataOriginal);
			_bitmapDataBackup 	= BitmapEditor.flipHorizontal(_bitmapDataBackup);
			
			onBitmapDataCopyChanged();
			onBitmapDataOriginalChanged();
			
			updateZoom(LayerEvent.SIZE_CHANGE_FLIP_HORIZONTAL);
		}
		public function flipVertical():void{
			_bitmapDataCopy 	= BitmapEditor.flipVertical(_bitmapDataCopy);
			_bitmapDataOriginal = BitmapEditor.flipVertical(_bitmapDataOriginal);
			_bitmapDataBackup 	= BitmapEditor.flipVertical(_bitmapDataBackup);
			
			onBitmapDataCopyChanged();
			onBitmapDataOriginalChanged();
			
			updateZoom(LayerEvent.SIZE_CHANGE_FLIP_VERTICAL);
		}
		
		
		public function crop(rect:Rectangle):void{
			
			bitmapDataOriginal = BitmapEditor.crop(bitmapDataOriginal, rect);
			bitmapDataCopy = BitmapEditor.crop(bitmapDataCopy, rect);
			updateZoom();
		}
		
		
		
		//--------------------------------------
		// ZOOM
		//--------------------------------------
		public static const ZOOM_FIT_TO_SCREEN:Number = 0;
		private var _zoom:Number;
		public function set zoom(value:Number):void{
			_zoom = Math.min(Math.max(0, value),1000);
			updateZoom();
		}
		protected function updateZoom(reason:String=null):void{
			if (_zoom == ZOOM_FIT_TO_SCREEN){
				imageCopy.maxWidth = widthBitmap;
				imageCopy.maxHeight = heightBitmap;
				imageCopy.percentHeight = 100;
				imageCopy.percentWidth = 100;
				
				imageOriginal.maxWidth = widthBitmap;
				imageOriginal.maxHeight = heightBitmap;
				imageOriginal.percentHeight = 100;
				imageOriginal.percentWidth = 100;
			}else{
				imageCopy.width = widthBitmap * _zoom / 100;
				imageCopy.height = heightBitmap * _zoom / 100;
				
				imageOriginal.width = widthBitmap * _zoom / 100;
				imageOriginal.height = heightBitmap * _zoom / 100;
			}
			// this class hasn't method callLater, so I used method in imageCopy:Image
			imageCopy.callLater(onLayerSizeChange,[reason]);
			//imageCopy.callLater(imageCopy.callLater,[onLayerSizeChange,[reason]]);
		}
		public function get zoom():Number{
			if (_zoom == ZOOM_FIT_TO_SCREEN){
				return (width / widthBitmap + height / heightBitmap) / 2 * 100
			}else{
				return _zoom;
			}
		}
		
		private function onLayerSizeChange(reason:String):void{
			if (reason){
				dispatchEvent(new LayerEvent(reason));
			}else{
				dispatchEvent(new LayerEvent(LayerEvent.SIZE_CHANGE_ZOOM));
			}
		}
		
		
		
	}
}