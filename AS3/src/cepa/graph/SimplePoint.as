package cepa.graph {
	public class SimplePoint extends GraphPoint {
		
		private var _fillColor:uint = 0x000000;
		private var _lineColor:uint = 0x000000;
		private var _alpha:Number = 1;
		private var _thickness:Number = 0;
		private var _radius:Number = 5;
		
		public function SimplePoint (x:Number, y:Number) : void {
			super(x, y);
			draw();
		}
		
		/**
		 * Define a cor de preenchimento do ponto.
		 * @param	value	A cor de preenchimento.
		 */
		public function set fillColor (value:uint) : void
		{
			_fillColor = value;
			draw();
		}
		
		/**
		 * Obtém a cor de preenchimento do ponto.
		 * @return	A cor de preenchimento.
		 */
		public function get fillColor () : uint
		{
			return _fillColor;
		}
		
		/**
		 * @ignore
		 * (Re)desenha o ponto.
		 */
		private function draw () : void
		{
			graphics.clear();
			graphics.lineStyle(_thickness, _lineColor);
			graphics.beginFill(_fillColor, _alpha);
			graphics.drawCircle(0, 0, _radius);
			graphics.endFill();
		}
	}
}