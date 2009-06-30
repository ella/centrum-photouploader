package com.centrumholdings.photouploader.controllers
{
	import com.centrumholdings.graphics.BitmapEditor;
	
	import flash.display.*;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import mx.controls.Alert;
	import mx.managers.PopUpManager;
	
	
	
	[Event(name="imageReady",type="com.centrumholdings.photouploader.controllers.ImageLoaderEvent")]
	[Event(name="imageSelected",type="com.centrumholdings.photouploader.controllers.ImageLoaderEvent")]
	public class ImageLoader extends EventDispatcher
	{
		
		
		
		// statistika
		private var loadingFileStartDate:Date
		private var loadingFileStopDate:Date
		private var loadingFileTime:Number;
		
		private var openCStartDate:Date;
		private var openCStopDate:Date;
		private var openCTime:Number;
		
		private var alphaStartDate:Date;
		private var alphaStopDate:Date;
		private var alphaTime:Number;
		
		
		public function ImageLoader(){
		}
		
		
		private var file:FileReference;
		public function get currentFilename():String{
			if (file){
				return file.name;
			}
			return "";
		}
		public function get currentFiletype():String{
			if (file  &&  file.type  &&  file.type.length>1){
				return file.type.substr(1);
			}
			return "";
		}
		
		
		public function selectAndLocalImage():void{
			var fileFilter:FileFilter = new FileFilter("fotografie (*.jpg,*.tif,*.png;*.gif)", "*.jpg;*.png;*.gif;*.tif;*.jpeg");
			file = new FileReference();
			file.addEventListener(Event.SELECT, onFileSelected);
			file.addEventListener(Event.COMPLETE, onFileLoaded);
			
			var browseSucces:Boolean = file.browse([fileFilter]);
			if (browseSucces == false){
				Alert.show("Nastala chyba. Dialog nemohl být otevřen.");
			}
		}
		
		
		private function onFileSelected(evt:Event):void{
			// load file to Flex
			loadingFileStartDate = new Date();
			dispatchEvent(new ImageLoaderEvent(ImageLoaderEvent.IMAGE_SELECTED));
			//file.addEventListener(ProgressEvent.PROGRESS, onProgress);
			file.load();
		}
		/* private function onProgress(event:ProgressEvent):void{
			trace("nacteno:" + Math.round(event.bytesLoaded / event.bytesTotal * 100));
		} */
		
		
		
		private var byteArrayReader:Loader;
		private function onFileLoaded(evt:Event):void{
			loadingFileStopDate = new Date();
			openCStartDate = new Date();
			if (file.type == ".tiff"  ||  file.type == ".tif"){
				sendByteArrayToC(file.data);
			}else{
				showByteArray(file.data);
			}
		}
		
		
		import cmodule.stringecho.CLibInit;
		private var cecko:CLibInit;
		private var ceckoveFunkce:Object;
		
		  
		private var byteArraySendedToC_A:ByteArray;
		private var byteArraySendedToC_B:ByteArray;
		/**
		 * result
		 * {
		 * 	result:Number
		 * 	width:Number
		 *  height:Number
		 * }
		 */
		private var result:Object;
		private function sendByteArrayToC(byteArray:ByteArray):void{
			byteArraySendedToC_A = byteArray;
			byteArraySendedToC_B = new ByteArray();
			
			if (!cecko){
				cecko = new CLibInit;
				ceckoveFunkce = cecko.init();
			}
			var start:Number = getTimer();
			result = ceckoveFunkce.decodeTIFF(byteArraySendedToC_A, byteArraySendedToC_B);
			openCStopDate = new Date();
			
			if (result.result == 1){
				showByteArrayB(byteArraySendedToC_B);
			}else{
				Alert.show("Chyba při čtení tiffu:"  + result.result);
				showByteArrayB(byteArraySendedToC_B);
			}
		}
		
			
		/**/
		private function showByteArray(byteArray:ByteArray):void{
			// read bytes
			byteArrayReader = new Loader();
			byteArrayReader.contentLoaderInfo.addEventListener(Event.COMPLETE, onByteArrayReady);
			byteArrayReader.loadBytes(byteArray);
		}
		
		private function showByteArrayB(byteArray:ByteArray):void{
			alphaStartDate = new Date();
			byteArray.position = 0; 
			
			if (result.width * result.height < byteArray.length){
				var bitmapData:BitmapData = new BitmapData(result.width, result.height, false);
				bitmapData.lock();
				bitmapData.setPixels(new Rectangle(0, 0, result.width, result.height), byteArray);
				bitmapData.unlock();
				dispatchEvent(new ImageLoaderEvent(ImageLoaderEvent.IMAGE_READY, bitmapData));
			}else{
				// chyba
				Alert.show("chyba");
			}
			
			alphaStopDate = new Date();
			loadingFileTime = loadingFileStopDate.valueOf() - loadingFileStartDate.valueOf();
			openCTime = openCStopDate.valueOf() - openCStartDate.valueOf();
			alphaTime = alphaStopDate.valueOf() - alphaStartDate.valueOf();
			
			/*timeInfoAlert = Alert.show("loading: " + loadingFileTime + "\nopen c: " + openCTime + "\nalpha: " + alphaTime);
			var timer:Timer = new Timer(2000, 1);
			timer.addEventListener(TimerEvent.TIMER, closeTimeInfo);
			timer.start();
			*/
			unload();
		}
		private var timeInfoAlert:Alert;
		private function closeTimeInfo(evt:TimerEvent):void{
			PopUpManager.removePopUp(timeInfoAlert);
		}
		
		
		private function unload():void{
			// rest of C code
			if (byteArraySendedToC_A){
				byteArraySendedToC_A.clear()
				byteArraySendedToC_A = null;
			}
			if (byteArraySendedToC_B){
				byteArraySendedToC_B.clear();
				byteArraySendedToC_B = null;
			}
			//cecko = null;
			//ceckoveFunkce = null;
			
			
			// rest of AS code:
			if (byteArrayReader){
				byteArrayReader.unload();
				byteArrayReader = null;
			}
			if (file){
				file.removeEventListener(Event.SELECT, onFileSelected);
				file.removeEventListener(Event.COMPLETE, onFileLoaded);
				file = null;
			}
			BitmapEditor.runGarbageCollector();
		}
		
		
		private function onByteArrayReady(evt:Event):void{
			byteArrayReader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onByteArrayReady);
			var bitmap:Bitmap = byteArrayReader.content as Bitmap;
			dispatchEvent(new ImageLoaderEvent(ImageLoaderEvent.IMAGE_READY, bitmap.bitmapData));
			unload();
		}
		

	}
}