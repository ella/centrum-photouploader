package com.centrumholdings.controllers
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.core.Application;
	
	public class AnimationController{
		
		private var isDisplayObject:Boolean = true;
		
		private var displayObjectKey:DisplayObject; // first DisplayObject of displayObjectGroup
		private var displayObjectGroup:Array; // all DisplayObjects (first too)
		private var property:String;
		private var visibleValue:Boolean;
		private var startValue:Number;
		private var endValue:Number;
		private var duration:Number;
		private var currentTime:Number;
		private var roundValue:Boolean;
		private var easingFunction:Function;
		private var callBack:Function;
		
		private var functionReference:Function;
		
		
		private static var animationControllerCReferences:Array = [];
		private static var functionControllers:Array = [];
				
		public function AnimationController(){
		}
		
		
		private static function removeAnimationController(displayObject:DisplayObject, property:String):void{
			var newAnimationControllerCReferences:Array = new Array();
			for (var i:uint=0; i<animationControllerCReferences.length; i++){
				if (AnimationController(animationControllerCReferences[i]).displayObjectKey == displayObject  &&  animationControllerCReferences[i].property == property){
					AnimationController(animationControllerCReferences[i]).stop();
				}else{
					newAnimationControllerCReferences.push(animationControllerCReferences[i]);
				}
			}
			animationControllerCReferences = newAnimationControllerCReferences;
		}
		private static function removeFunctionController(fce:Function):void{
			var newFunctionControllers:Array = new Array();
			for (var i:uint=0; i<functionControllers.length; i++){
				if (AnimationController(functionControllers[i]).functionReference == fce){
					AnimationController(functionControllers[i]).stop();
				}else{
					newFunctionControllers.push(functionControllers[i]);
				}
			}
			functionControllers = newFunctionControllers;
		}
		
		
		
		public static function setVisible(displayObject:DisplayObject, value:Boolean, duration:uint=500):void{
			removeAnimationController(displayObject, "visible");
			
			var newAnimationController:AnimationController = new AnimationController();
			newAnimationController.displayObjectKey= displayObject;
			newAnimationController.displayObjectGroup= [displayObject];
			newAnimationController.property 	= "visible";
			newAnimationController.visibleValue	= value;
			newAnimationController.duration 	= duration;
			newAnimationController.currentTime 	= 0;
			newAnimationController.play();
			
			animationControllerCReferences.push(newAnimationController);
		}
		
		public static function animatingIsRunning(displayObject:DisplayObject, property:String):Boolean{
			for (var i:uint=0; i<animationControllerCReferences.length; i++){
				if (AnimationController(animationControllerCReferences[i]).displayObjectKey == displayObject  &&  animationControllerCReferences[i].property == property){
					return true;
				}
			}
			return false;
		}
		public static function animateNow(displayObject:DisplayObject, property:String, startValue:Number, endValue:Number, duration:uint=500, pixelHinting:Boolean=false, easingFunction:Function=null, callBack:Function=null):void{
			var newAnimationController:AnimationController = animate(displayObject, property, startValue, endValue, duration, pixelHinting, easingFunction, callBack);
			newAnimationController.update();
		}
		public static function animate(displayObjects:*, property:String, startValue:Number, endValue:Number, duration:uint=500, pixelHinting:Boolean=false, easingFunction:Function=null, callBack:Function=null):AnimationController{
			if (!displayObjects){
				return null;
			}
			var newAnimationController:AnimationController = new AnimationController();
			
			// input is Array of DisplayObjects
			if (displayObjects is Array  &&  displayObjects.length>0){
				for (var i:uint=0; i<displayObjects.length; i++){
					// I don't know, which displayObject was chosen as key in last animation
					removeAnimationController(displayObjects[i], property);
				}
				newAnimationController.displayObjectKey = displayObjects[0];
				newAnimationController.displayObjectGroup = displayObjects;
				
			// input is one DisplayObject
			}else if (displayObjects is DisplayObject){
				removeAnimationController(displayObjects, property);
				newAnimationController.displayObjectKey = displayObjects;
				newAnimationController.displayObjectGroup = [displayObjects];
			}else{
				return null;
			}
			
			// set startValue
			if (pixelHinting){
				startValue = Math.round(startValue);
			}
			
			newAnimationController.property 	= property;
			newAnimationController.startValue 	= startValue;
			newAnimationController.endValue 	= endValue;
			newAnimationController.duration 	= duration;
			newAnimationController.roundValue 	= pixelHinting;
			newAnimationController.currentTime 	= 0;
			newAnimationController.callBack 	= callBack;
			
			if (easingFunction == null){
				easingFunction = easeOut;
			}
			newAnimationController.easingFunction = easingFunction;
			newAnimationController.setProperty(startValue);
			newAnimationController.play();
			newAnimationController.update();
			
			animationControllerCReferences.push(newAnimationController);
			return newAnimationController;
		}
		
		
		//--------------------------------------
		// ANIMATION FUNCTION 
		//--------------------------------------
		public static function callFunction(fce:Function, startValue:Number, endValue:Number, duration:uint=500, roundValue:Boolean=false, easingFunction:Function=null, callBack:Function=null):AnimationController{
			if (fce == null){
				return null;
			}
			var newAnimationController:AnimationController = new AnimationController();
			
			removeFunctionController(fce);
			newAnimationController.functionReference = fce;
			newAnimationController.isDisplayObject = false;
			
			newAnimationController.startValue 	= roundValue ? Math.round(startValue) : startValue;
			newAnimationController.endValue 	= endValue;
			newAnimationController.duration 	= duration;
			newAnimationController.roundValue 	= roundValue;
			newAnimationController.currentTime 	= 0;
			newAnimationController.callBack 	= callBack;
			
			if (easingFunction == null){
				easingFunction = easeOut;
			}
			newAnimationController.easingFunction = easingFunction;
			//newAnimationController.setProperty(startValue);
			newAnimationController.play();
			
			functionControllers.push(newAnimationController);
			return newAnimationController;
		}
		
		
		
		private var visibleAnimationTimer:Timer;
		private const animationTimeInterval:uint = 40;
		public function play():void{
			if (visibleAnimationTimer){
				visibleAnimationTimer.removeEventListener(TimerEvent.TIMER, updateVisible);
				visibleAnimationTimer.stop();
			}
			if (startValue == endValue  ||  duration <= 0){
				lastUpdate();
				return;
			}
			
			if (property == "visible"){
				visibleAnimationTimer = new Timer(duration, 1);
				visibleAnimationTimer.addEventListener(TimerEvent.TIMER, updateVisible);
				visibleAnimationTimer.start();
			}else{
				Application.application.addEventListener(Event.ENTER_FRAME, update);
			}
		}
		public function stop():void{
			if (visibleAnimationTimer){
				visibleAnimationTimer.removeEventListener(TimerEvent.TIMER, updateVisible);
				visibleAnimationTimer.stop();
			}else{
				Application.application.removeEventListener(Event.ENTER_FRAME, update);
			}
		}
		
		
		private function updateVisible(evt:TimerEvent):void{
			displayObjectKey.visible = visibleValue;
			stop();
			removeAnimationController(displayObjectKey, property);
		}
		private function update(evt:Event=null):void{
			currentTime += animationTimeInterval;
			var newValue:Number = easingFunction(currentTime, startValue, endValue-startValue, duration);
			
			if (roundValue){
				newValue = Math.round(newValue);
			}
			setProperty(newValue);
			
			if (currentTime >= duration){
				lastUpdate();
			}
		}
		private function lastUpdate():void{
			if (property  &&  property == "visible"){
				displayObjectKey.visible = visibleValue;
			}else{
				setProperty(endValue);
			}
			stop();
			if (callBack != null){
				callBack();
			}
			if (isDisplayObject){
				removeAnimationController(displayObjectKey, property);
			}else{
				removeFunctionController(functionReference);
			}
		}
		
		private function setProperty(value:Number):void{
			if (isDisplayObject){
				for (var i:uint=0; i<displayObjectGroup.length; i++){
					displayObjectGroup[i][property] = value;
				}
			}else{
				functionReference(value);
			}
		}
	
	
		
	/**
     *  The <code>easeOut()</code> method starts motion fast, 
     *  and then decelerates motion to a zero velocity as it executes. 
     *
     *  @param t Specifies time.
	 *
     *  @param b Specifies the initial position of a component.
	 *
     *  @param c Specifies the total change in position of the component.
	 *
     *  @param d Specifies the duration of the effect, in milliseconds.
     *
     *  @return Number corresponding to the position of the component.
     */  
    
    public static function easeOut(t:Number, b:Number, c:Number, d:Number):Number{
		return c * ((t = t / d - 1) * t * t + 1) + b;
	}
	
	public static function easeIn(t:Number, b:Number,
								  c:Number, d:Number):Number{
		return c * (t /= d) * t * t + b;
	}
	
	
	
	public static function LINEAR_easeIn(t:Number, b:Number,
								  c:Number, d:Number):Number{
		return c * t / d + b;
	}
	
	
	//*
	public static function easeInOut(t:Number, b:Number,
									 c:Number, d:Number):Number{
		if ((t /= d / 2) < 1)
			return c / 2 * t * t * t + b;

		return c / 2 * ((t -= 2) * t * t + 2) + b;
	}/**/


}
}