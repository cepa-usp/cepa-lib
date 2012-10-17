package cepa.graph {
	public class DataStyle {
		
		public static const LINE_STYLE_1:String = "LINE_STYLE_1";
		
		private var _stroke:Number = 2;
		private var _color:int = 0xFF0000;
		private var _alpha:Number = 0.5;
		private var _linestyle:String = LINE_STYLE_1;
		
		
		public function DataStyle () : void { }
		
		// TODO: definir set e gets
		
		public function set stroke (thickness:Number) : void {
			if (thickness > 0) _stroke = thickness;
		}
		
		public function get stroke () : Number {
			return _stroke;
		}
		
		public function set color (color:int) : void {
			_color = color;
		}
		
		public function get color () : int {
			return _color;
		}
		
		public function set alpha (alpha:Number) : void {
			_alpha = Math.max(0, Math.min(1, alpha));
		}
		
		public function get alpha () : Number {
			return _alpha;
		}
		
		public function get linestyle () : String {
			return _linestyle;
		}
	}
}