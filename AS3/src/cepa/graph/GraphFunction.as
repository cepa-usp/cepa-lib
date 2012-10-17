package cepa.graph {
	public class GraphFunction {
		
		private var _xmin:Number;
		private var _xmax:Number;
		private var _f:Function;
		
		private var _stroke:Number = 3;
		private var _color:int = 0x000000;
		private var _alpha:Number = 0.5;
		private var _discontinuities:Vector.<Number>;
		
		public function GraphFunction (xmin:Number, xmax:Number, f:Function) : void {
			this.xmin = xmin;
			this.xmax = xmax;
			this.f    = f;
			_discontinuities = new Vector.<Number>();
		}
		
		public function setRange (xmin:Number, xmax:Number) : void {
			this.xmin = xmin;
			this.xmax = xmax;
		}
		
		public function set xmin (xmin:Number) : void {
			_xmin = xmin;
		}
		
		public function get xmin () : Number {
			return _xmin;
		}
		
		public function set xmax (xmax:Number) : void {
			_xmax = xmax;
		}
		
		public function get xmax () : Number {
			return _xmax;
		}
		
		public function set f (f:Function) : void {
			_f = f;
		}
		
		public function get f () : Function {
			return _f;
		}
		
		public function set stroke (stroke:Number) : void {
			if (stroke > 0) _stroke = stroke;
			else throw new Error ("The stroke must be breater than zero.");
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
			if (alpha >= 0 && alpha <= 1) _alpha = alpha;
		}
		
		public function get alpha () : Number {
			return _alpha;
		}
		
		public function value (x:Number) : Number {
			return _f(x);
		}
		
		public function set discontinuities (discontinuities:Vector.<Number>) : void {
			for each (var coordinate:* in discontinuities) {
				if (!(coordinate is Number)) return;
			}
			
			_discontinuities = discontinuities;
		}
		
		public function get discontinuities () : Vector.<Number> {
			return _discontinuities;
		}
		
		/**
		 * Retorna uma representação escrita da função
		 */
		public function toString () : String
		{
			return "Object GraphFunction";
		}
	}
}