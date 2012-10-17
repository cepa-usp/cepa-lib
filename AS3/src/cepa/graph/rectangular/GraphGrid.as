package cepa.graph.rectangular {
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class GraphGrid extends Sprite {
		
		private var _xaxis:AxisX; // O eixo x
		private var _yaxis:AxisY; // O eixo y
		private var _thickness:Array; // A espessura dos traços e sub-traços
		private var _color:Array; // A cor dos traços e sub-traços
		
		private var redraw:Boolean = true; // Idenfica se é preciso redesenhar o objeto desta classe
		
		/**
		 * Cria uma grade com base nos eixos x e y.
		 * @param	xaxis - O eixo x.
		 * @param	yaxis - O eixo y.
		 */
		public function GraphGrid (xaxis:AxisX, yaxis:AxisY) : void {
			this.xaxis = xaxis;
			this.yaxis = yaxis;
			
			thickness = [1, 0.5];
			color = [0x999999, 0xCCCCCC];
			
			// Desenha o gráfico quando ele for inserido no palco
			addEventListener(Event.ADDED_TO_STAGE, draw);
		}
		
		/**
		 * (Re)desenha a grade. Utilize este método (sem passar um argumento) para atualizar a grade após alguma alteração
		 * em algum dos eixos x e/ou y. O argumento <source>event</source> permite que o método seja chamado através de um
		 * observador de eventos. Este recurso é utilizado pela própria classe para desenhar a si mesma quando inserida no
		 * palco.
		 * @param	event - Evento que gerou a execução do método (utilizado apenas quando chamado a partir de um observador
		 * de eventos).
		 */
		public function draw (event:Event = null) {
			
			if (!redraw) return;
			
			graphics.clear();
			
			// Desenha os sub-traços da grade
			graphics.lineStyle(_thickness[0], _color[1]);
			
			for each (t in _yaxis.subticks) {
				graphics.moveTo(_xaxis.x2pixel(_xaxis.xmin), _yaxis.size + _yaxis.y2pixel(t));
				graphics.lineTo(_xaxis.x2pixel(_xaxis.xmax), _yaxis.size + _yaxis.y2pixel(t));
			}
			
			for each (t in _xaxis.subticks) {
				graphics.moveTo(_xaxis.x2pixel(t), _yaxis.size + _yaxis.y2pixel(_yaxis.ymin));
				graphics.lineTo(_xaxis.x2pixel(t), _yaxis.size + _yaxis.y2pixel(_yaxis.ymax));
			}
			
			// Desenha os traços da grade
			graphics.lineStyle(_thickness[0], _color[0]);
			
			for each (t in _yaxis.ticks) {
				graphics.moveTo(_xaxis.x2pixel(_xaxis.xmin), _yaxis.size + _yaxis.y2pixel(t));
				graphics.lineTo(_xaxis.x2pixel(_xaxis.xmax), _yaxis.size + _yaxis.y2pixel(t));
			}
			
			for each (var t:Number in _xaxis.ticks) {
				graphics.moveTo(_xaxis.x2pixel(t), _yaxis.size + _yaxis.y2pixel(_yaxis.ymin));
				graphics.lineTo(_xaxis.x2pixel(t), _yaxis.size + _yaxis.y2pixel(_yaxis.ymax));
			}
			
			redraw = false;
		}
		
		/**
		 * Define o eixo x da grade.
		 * @param	xaxis - O eixo x da grade.
		 */
		public function set xaxis (xaxis:AxisX) : void {
			if (xaxis != null) {
				_xaxis = xaxis;
				redraw = true;
			}
			else throw new Error ("The x-axis object cannot be null.");
		}
		
		/**
		 * Retorna o eixo x da grade.
		 */
		public function get xaxis () : AxisX {
			return _xaxis;
		}
		
		/**
		 * Define o eixo y da grade.
		 * @param	yaxis - O eixo y da grade.
		 */
		public function set yaxis (yaxis:AxisY) : void {
			if (yaxis != null) {
				_yaxis = yaxis;
				redraw = true;
			}
			else throw new Error ("The y-axis object cannot be null.");
		}
		
		/**
		 * Retorna o eixo y da grade.
		 */
		public function get yaxis () : AxisY {
			return _yaxis;
		}
		
		/**
		 * Define a espessura dos traços e sub-traços da grade.
		 * @param	stroke - Matriz 2 x 1 contendo a espessura do traço (Number) no primeiro elemento, e a espessura do sub-traço no segundo.
		 * 
		 * Exemplo:
		 * <source>
		 * var grid:GraphGrid = new GraphGrid(...);
		 * grid.stroke = [2, 1];
		 * </source>
		 * 
		 * obs.: as espessuras dos traços e sub-traços devem ser positivas.
		 */
		public function set thickness (thickness:Array) : void {
			if (thickness[0] > 0 && (thickness[0] is Number) && thickness[1] > 0 && (thickness[1] is Number)) {
				_thickness = thickness;
				redraw = true;
			}
		}
		
		/**
		 * Retorna a espessura dos traços da grade.
		 */
		public function get thickness () : Array {
			return _thickness;
		}
		
		/**
		 * Define a cor dos traços e sub-traços da grade.
		 * @param	color - Matriz 2 x 1 contendo a cor do traços (int) no primeiro elemento, e a espessura do sub-traço no segundo.
		 * 
		 * Exemplo:
		 * <source>
		 * var grid:GraphGrid = new GraphGrid(...);
		 * grid.color = [0xFF0000, 0x550000];
		 * </source>
		 * 
		 * obs.: as cores dos traços e sub-traços devem ser positivas.
		 */
		public function set color (color:Array) : void {
			if (color[0] > 0 && (color[0] is int) && color[1] > 0 && (color[1] is int)) {
				_color = color;
				redraw = true;
			}
		}
		
		/**
		 * Retorna a cor dos traços da grade.
		 */
		public function get color () : Array {
			return _color;
		}
	}
}