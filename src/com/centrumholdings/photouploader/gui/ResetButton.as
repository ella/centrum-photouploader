package com.centrumholdings.photouploader.gui
{
	import mx.controls.Button;

	public class ResetButton extends Button
	{
		public function ResetButton()
		{
			super();
			useHandCursor = true;
			styleName = "invisible";
		}
		
		
		override public function set enabled(value:Boolean):void{
			super.enabled = value;
			buttonMode = value;
			showIcon = value;
		}
		
		private var _showIcon:Boolean = true;
		private var _icon:Object;
		private function set showIcon(value:Boolean):void{
			_showIcon = value;
			if (_showIcon){
				if (_icon){
					setStyle("icon", _icon);
				}
			}else{
				var currentIcon:Object = getStyle("icon");
				if (currentIcon){
					_icon = currentIcon;
					setStyle("icon", null);
				}
			}
		}
		private function get showIcon():Boolean{
			return _showIcon;
		}
		
		
	}
}