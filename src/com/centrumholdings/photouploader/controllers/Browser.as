package com.centrumholdings.photouploader.controllers
{
	import flash.external.ExternalInterface;
	
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.utils.ObjectUtil;
	
	public class Browser
	{
		public function Browser(){
			ExternalInterface.addCallback("saveData", saveData);
		}
		
		
		private function saveData(...params):Boolean{
			Alert.show("params:" + ObjectUtil.toString(params) );
			
			return true;
		}
		
		
		
		
		
		

	}
}