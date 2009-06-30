package com.centrumholdings.graphics
{
	//import flash.display.BitmapData;
	import flash.display.*;
	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.LocalConnection;
	import flash.net.URLRequest;
	
	import mx.controls.Alert;
	
	public class BitmapEditor
	{
		public function BitmapEditor(){
		}
		
		
		
		public static function resizeBigImage(bmp:BitmapData, maxWidth:Number, maxHeight:Number):BitmapData{
			var newWidth:Number = bmp.width;
			var newHeight:Number = bmp.height;
			if (newWidth > maxWidth){
				newWidth = maxWidth;
				newHeight = newWidth * bmp.height/bmp.width;
			}
			if (newHeight > maxHeight){
				newHeight = maxHeight;
				newWidth = maxHeight * bmp.width/bmp.height;
			}
			newWidth = Math.floor(newWidth);
			newHeight = Math.floor(newHeight);
			
			if (newWidth != bmp.width){
				trace("resize ano");
				var resizedBmp:BitmapData = new BitmapData(newWidth, newHeight, false);
				var matrix:Matrix = new Matrix();
				matrix.scale(newWidth/bmp.width, newHeight/bmp.height);
				resizedBmp.draw(bmp, matrix, null, null, null, true);
				return resizedBmp;
			}else{
				trace("resize ne");
				return bmp;
			}
		}
		
		
		
		public static function crop(bmp:BitmapData, rect:Rectangle):BitmapData{
			if (!rect  ||  rect.isEmpty()){
				rect = new Rectangle(0,0, bmp.width, bmp.height);
			}
			rect.x 		= Math.max(0, Math.round(rect.x));
			rect.y 		= Math.max(0, Math.round(rect.y));
			rect.width 	= Math.round(rect.width);
			rect.height = Math.round(rect.height);
			
			var croppedBmp:BitmapData = new BitmapData(rect.width, rect.height, false);
			croppedBmp.copyPixels(bmp, rect, new Point());
			runGarbageCollector();
			return croppedBmp;
		}
		
		
		public static function rotateRight(bmp:BitmapData):BitmapData{
			var matrix:Matrix = new Matrix();
			matrix.translate(bmp.width/-2, bmp.height/-2);
			//matrix.rotate(90 * Math.PI/180);
			matrix.rotate(Math.PI/2);
			matrix.translate(bmp.height/2, bmp.width/2);
			
			var bd:BitmapData = new BitmapData(bmp.height, bmp.width);
			bd.draw(bmp, matrix);
			return bd;
		}
		public static function rotateLeft(bmp:BitmapData):BitmapData{
			var matrix:Matrix = new Matrix();
			matrix.translate(bmp.width/-2, bmp.height/-2);
			//matrix.rotate(-90 * Math.PI/180);
			matrix.rotate(Math.PI/-2);
			matrix.translate(bmp.height/2, bmp.width/2);
			
			var bd:BitmapData = new BitmapData(bmp.height, bmp.width);
			bd.draw(bmp, matrix);
			return bd;
		}
		
		public static function flipHorizontal(bmp:BitmapData):BitmapData{
			var matrix:Matrix = new Matrix();
			matrix.scale(1,-1);
			matrix.translate(1,bmp.height);
			var bd:BitmapData = new BitmapData(bmp.width, bmp.height);
			bd.draw(bmp, matrix);
			return bd;
		}
		public static function flipVertical(bmp:BitmapData):BitmapData{
			var matrix:Matrix = new Matrix();
			matrix.scale(-1,1);
			matrix.translate(bmp.width,0);
			var bd:BitmapData = new BitmapData(bmp.width, bmp.height);
			//bmp.draw(source, matrix, colorTransform, blendMode, clipRect, smoothing);
			//bd.draw(bmp, matrix, null, null, null, true);
			bd.draw(bmp, matrix);
			return bd;
		}
		
		
		
		
		private static const r_lum:Number = 0.212671;
		private static const g_lum:Number = 0.715160;
		private static const b_lum:Number = 0.072169;
		public static function setSaturation(bmp:BitmapData, saturation:Number):BitmapData{
			if (saturation == 0){
				return bmp.clone();
			}
			saturation /= 100;
			saturation++;

			var s:Number = 1-saturation;
			var irlum:Number = s * r_lum;
			var iglum:Number = s * g_lum;
			var iblum:Number = s * b_lum;
			var mat:Array = [irlum + saturation,iglum,				iblum, 				0, 0,
						  	irlum,				iglum + saturation,	iblum,				0, 0,
						    irlum,				iglum, 				iblum + saturation, 0, 0,
						    0,					0,					0,					1, 0];
			
			var colorMatrixFilter:ColorMatrixFilter = new ColorMatrixFilter(mat);
			var bd:BitmapData = new BitmapData(bmp.width, bmp.height, false);
			bd.applyFilter(bmp, new Rectangle(0, 0, bmp.width, bmp.height), new Point(), colorMatrixFilter);
			runGarbageCollector();
			return bd;
		}
		private static var aa:BitmapData;
		private static var byteArrayReader:Loader;
			
		public static function tryFixCMYK(bmp:BitmapData):BitmapData{
			bmp = bmp.clone();
			if (!aa){
				byteArrayReader = new Loader();
				byteArrayReader.contentLoaderInfo.addEventListener(Event.COMPLETE, onByteArrayReady);
				byteArrayReader.load(new URLRequest("cmyk_colorspace.png"));
				return bmp;
			}else{
				bmp.lock();
				var x:Number;
				var y:Number;
				for (y=0; y < bmp.height; y++){
					for (x=0; x < bmp.width; x++){
						bmp.setPixel(x, y,    rgbFix(bmp.getPixel(x, y))     );
					}
				}
				bmp.unlock();
				Alert.show("cmyk ok");
				return bmp;
			}
		}
		public static function rgbFix(rgb:uint):uint{
			var tmpR:Number = ((rgb >> 16) & 0xff) / 255;  
			var tmpG:Number = ((rgb >> 8) & 0xff) / 255;  
			var tmpB:Number = (rgb & 0xff) / 255;  
			var cyan:Number;  
			var magenta:Number;  
			var yellow:Number;  
			var black:Number;  
			if (tmpR == 0 && tmpG == 0 && tmpR == 0){
				cyan = 0;
				magenta = 0;
				yellow = 0;
				black = 100;
			}else{
				var tmpBk:Number = Math.min(1 - tmpR, 1 - tmpG, 1 - tmpB);  
				cyan = (1 - tmpR - tmpBk) / (1 - tmpBk) * 100;  
				magenta = (1 - tmpG - tmpBk) / (1 - tmpBk) * 100;  
				yellow = (1 - tmpB - tmpBk) / (1 - tmpBk) * 100;  
				black = tmpBk * 100;  
			}
			return cmyk_to_rgb(cyan, magenta, yellow, black);  
			//return cmyk_to_rgb2(cyan, magenta, yellow, black);
		}  
		private static function cmyk_to_rgb(c:Number, m:Number, y:Number, k:Number):uint{
			var x:Number = Math.round(y/5) * 21 + Math.round(c/5);
			var y:Number = Math.round(k/5) * 21 + Math.round(m/5);
			
			var rgb:uint = aa.getPixel(x, y);
			return rgb;
			var r:uint = (rgb >> 16) & 0xFF;
			var g:uint = (rgb >> 8) & 0xFF;
			var b:uint = rgb & 0xFF;	    	
			   	
			return r<<16 + g<<8 + b;     
		}
		private static function cmyk_to_rgb2(c:Number, m:Number, y:Number, k:Number):uint{
			// Convert percentages to 0 – 255 range
			c = (0xFF * c) / 100;
			m = (0xFF * m) / 100;
			y = (0xFF * y) / 100;
			k = (0xFF * k) / 100;
			
			var r:uint = Math.round(((0xff - c) * (0xff - k)) / 0xff);
			var g:uint = Math.round(((0xff - m) * (0xff - k)) / 0xff);
			var b:uint = Math.round(((0xff - y) * (0xff - k)) / 0xff);
			//var r:uint = ((0xFF – c) * (0xFF – k)) / 0xFF ;
			//var g:uint =  (((0xFF – m) * (0xFF – k)) / 0xFF ));
			//var b:uint = ( (((0xFF – y) * (0xFF – k)) / 0xFF )); 
			
			return (r << 16) + (g << 8) + b;
			return r << 16 + g << 8 + b;
			//return r;
		}
		
		
		private static function onByteArrayReady(evt:Event):void{
			var bitmap:Bitmap = byteArrayReader.content as Bitmap;
			aa = bitmap.bitmapData;
			Alert.show("cmyk bmp načteno");
		}
		
		
		
		
		
		
		
		
		
		
		
				
		public static function runGarbageCollector():void{
			try{
				var lc1:LocalConnection = new LocalConnection();
				var lc2:LocalConnection = new LocalConnection();
				
				lc1.connect( "runGarbageCollector" );
				lc2.connect( "runGarbageCollector" );
			}catch (e:Error) {}
		}
        

        
        
        
        
		public static function setContrast(bmp:BitmapData, contrast:Number):BitmapData{
			return getCollorTransformBitmapData(bmp, getContrastColorTransform(contrast));
		}
		
		
		public static function setBrightness(bmp:BitmapData, brightness:Number):BitmapData{
			return getCollorTransformBitmapData(bmp, getBrightnessColorTransform(brightness));
		}
		
		public static function setContrastAndBrightness(bmp:BitmapData, contrast:Number, brightness:Number):BitmapData{
			if (contrast == 0  &&  brightness == 0){
				return bmp.clone();
			}
			var mixedColorTransform:ColorTransform = getContrastColorTransform(contrast);
			mixedColorTransform.concat(getBrightnessColorTransform(brightness));
			
			return getCollorTransformBitmapData(bmp, mixedColorTransform);
		}
		
		
		private static function getCollorTransformBitmapData(bmp:BitmapData, colorTransform:ColorTransform):BitmapData{
			var bd:BitmapData = new BitmapData(bmp.width, bmp.height, false);
			bd.draw(bmp, null, colorTransform);
			return bd;
		}
		
		
		private static function getContrastColorTransform(contrast:Number):ColorTransform{
			contrast = contrast/100;
			contrast++;
			
			var colorTransform:ColorTransform = new ColorTransform();
			colorTransform.redMultiplier 	= colorTransform.greenMultiplier 	= colorTransform.blueMultiplier = contrast; // color percent
			colorTransform.redOffset 		= colorTransform.greenOffset 		= colorTransform.blueOffset 	= 128 - (128 * contrast); // color offset
			
			return colorTransform;
		}
		private static function getBrightnessColorTransform(brightness:Number):ColorTransform{
			brightness /= 100;
			
			var colorTransform:ColorTransform = new ColorTransform();
			colorTransform.redMultiplier 	= colorTransform.greenMultiplier 	= colorTransform.blueMultiplier = 1 - Math.abs(brightness);
			colorTransform.redOffset 		= colorTransform.greenOffset 		= colorTransform.blueOffset 	= (brightness > 0) ? brightness * 256 : 0;
			
			return colorTransform;
		}

		
	}
}