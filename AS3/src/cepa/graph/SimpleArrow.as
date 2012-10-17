package cepa.graph {
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class SimpleArrow extends Sprite {
		
		public static const STYLE_1:String = "ARROW_STYLE_1";
		public static const STYLE_2:String = "ARROW_STYLE_2";
		// TODO: desenvolver outros estilos de setas
		
		private const STD_WIDTH:Number = 10;
		private const STD_HEIGHT:Number = 10;
		
		private var _arrowwidth:Number;
		private var _arrowheight:Number;
		private var _thickness:Number = 1;
		private var _color:int = 0x000000;
		private var _style:String;
		
		/**
		 * Cria uma flecha simples.
		 * @param	width - Largura da flecha
		 * @param	height - Altura da flecha
		 * @param	style - Estilo da flecha: SimpleArrow.STYLE_1, SimpleArrow.STYLE_2 etc
		 */
		public function SimpleArrow (width:Number = STD_WIDTH, height:Number = STD_HEIGHT, style:String = STYLE_1) : void {
			_style = style;
			setSize(width, height);
		}
		
		/**
		 * Define a largura/altura da flecha.
		 * @param	width - A largura da flecha.
		 * @param	height - A altura da flecha.
		 */
		/*
		 * TODO: o observador de eventos substitui uma chamada ao método draw. O intuito é não executar draw()
		 * desnecessariamente. Ainda não está claro se este método funciona corretamente sempre; precisa testar.
		 */
		public function setSize (width:Number, height:Number) : void {
			if (width > 0 && height > 0) {
				_arrowwidth = width;
				_arrowheight = height;
				addEventListener(Event.ENTER_FRAME, draw);
				//draw();
			}
			else trace("WARNING: both width and height must be positive. Resizing ignored.");
		}
		
		/**
		 * Define a cor da flecha.
		 * @param	color - A cor da flecha.
		 */
		public function set color (color:int) : void {
			_color = color;
			addEventListener(Event.ENTER_FRAME, draw);
			//draw();
		}
		
		/**
		 * Retorna a cor da flecha.
		 */
		public function get color () : int {
			return _color;
		}
		
		/**
		 * Define a espessura dos traços.
		 * @param	thickness - A espessura dos traços.
		 */
		public function set thickness (thickness:Number) : void {
			if (thickness > 0) {
				_thickness = thickness;
				addEventListener(Event.ENTER_FRAME, draw);
				//draw();
			}
		}
		
		/**
		 * Retorna a espessura dos traços.
		 */
		public function get thickness () : Number {
			return _thickness;
		}
		
		/**
		 * Define o estilo da seta.
		 * @param	style - O estilo da seta: SimpleArrow.STYLE_1, SimpleArrow.STYLE_2 etc.
		 */
		public function set style (style:String) : void {
			if (style == STYLE_1 || style == STYLE_2) _style = style;
		}
		
		/**
		 * Retorna o estilo da seta.
		 */
		public function get style () : String {
			return _style;
		}
		
		/*
		 * Desenha a flecha.
		 */
		private function draw (event:Event = null) : void {
			
			if (hasEventListener(Event.ENTER_FRAME)) removeEventListener(Event.ENTER_FRAME, draw);
			
			graphics.clear();
			
			if (_style == STYLE_1) {
				graphics.lineStyle(_thickness, _color, 1, false, LineScaleMode.NONE);
				graphics.moveTo(- _arrowwidth, - _arrowheight);
				graphics.curveTo(- _arrowwidth / 2, 0, 0, 0);
				graphics.curveTo(- _arrowwidth / 2, 0, - _arrowwidth, + _arrowheight);
			}
			else if (_style == STYLE_2) {
				graphics.beginFill(_color);
				graphics.moveTo(- _arrowwidth, - _arrowheight);
				graphics.curveTo(- _arrowwidth / 2, 0, 0, 0);
				graphics.curveTo(- _arrowwidth / 2, 0, - _arrowwidth, + _arrowheight);
				graphics.lineTo(- _arrowwidth, - _arrowheight);
			}
		}
	}
}