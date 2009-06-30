package com.centrumholdings.photouploader.tools
{
	
	
	public class StepsController
	{
		[Bindable]
		public var isUndoStep:Boolean = false;
		
		[Bindable]
		public var isRedoStep:Boolean = false;
		
		
		private var historyList:Array = [];
		private var todoList:Array = [];
		
		public function StepsController(){
			super();
		}
		
		
		
		


		/**
		 * Add function to history list, that was called before.
		 */
		public function addFunction(redoFunction:Function, redoParams:Array, undoFunction:Function, undoParams:Array):void{
			var step:Step = new Step(redoFunction, redoParams, undoFunction, undoParams);
			historyList.push(step);
			todoList = [];
			
			updateUndoRedoStepInfo();
		}
		
		/**
		 * Call and add function to history list.
		 */
		public function callFunction(redoFunction:Function, redoParams:Array, undoFunction:Function, undoParams:Array):void{
			arguments.callee
			redoFunction.apply(null, redoParams);
			addFunction(redoFunction, redoParams, undoFunction, undoParams);
		}


		public function undo():void{
			var step:Step = historyList.pop();
			step.undoFunction.apply(this, step.undoParams);
			todoList.unshift(step);
			
			updateUndoRedoStepInfo();
		}
		public function redo():void{
			var step:Step = todoList.shift();
			step.redoFunction.apply(this, step.redoParams);
			historyList.push(step);
			
			updateUndoRedoStepInfo();
		}



		/**
		 * Removes history actions.
		 */
		public function clearHistory():void{
			historyList = [];
			todoList = [];
			updateUndoRedoStepInfo();
		}


		private function updateUndoRedoStepInfo():void{
			isUndoStep = historyList.length > 0;
			isRedoStep = todoList.length > 0;
		}



	}
}