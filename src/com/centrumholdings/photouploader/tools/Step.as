package com.centrumholdings.photouploader.tools
{
	
	
	public class Step
	{
		
		protected var _redoFunction:Function;
		public function get redoFunction():Function
		{
			return _redoFunction;
		}
		
		protected var _redoParams:Array;
		public function get redoParams():Array
		{
			return _redoParams;
		}
		
		protected var _undoFunction:Function;
		public function get undoFunction():Function
		{
			return _undoFunction;
		}
		
		
		protected var _undoParams:Array;
		public function get undoParams():Array
		{
			return _undoParams;
		}
		
		
		public function Step(redoFunction:Function, redoParams:Array, undoFunction:Function, undoParams:Array){
			this._redoFunction 	= redoFunction;
			this._redoParams 	= redoParams;
			this._undoFunction 	= undoFunction;
			this._undoParams 	= undoParams;
		}
		
		
		
		
		
		
		

	}
}