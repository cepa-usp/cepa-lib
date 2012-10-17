package cepa.graph.rectangular {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	import cepa.graph.DataStyle;
	import cepa.graph.GraphFunction;
	import cepa.graph.GraphPoint;
	import cepa.graph.rectangular.GraphGrid;
	
	public class Graph extends MovieClip {
		
		public static const AXIS_X:String = "AXIS_X";
		public static const AXIS_Y:String = "AXIS_Y";
		
		private var board:GraphBoard;
		private var xaxis:AxisX;
		private var yaxis:AxisY;
		private var _grid:GraphGrid;
		private var resolution:Number;
		
		private var functionsBundle:Dictionary;
		
		/**
		 * Cria um gráfico retangular bidimensional.
		 * @param	xmin - O limite inferior da variável dependente (x).
		 * @param	xmax - O limite superior da variável dependente (x).
		 * @param	xsize - O tamanho horizontal do gráfico, em pixels.
		 * @param	ymin - O limite inferior da variável dependente (y).
		 * @param	ymax - O limite superior da variável dependente (y).
		 * @param	ysize - O tamanho vertical do gráfico, em pixels.
		 */
		public function Graph (xmin:Number, xmax:Number, xsize:Number, ymin:Number, ymax:Number, ysize:Number) : void {
			
			// Área do gráfico
			board = new GraphBoard(xmin, xmax, xsize, ymin, ymax, ysize);
			
			// Eixo x
			xaxis = new AxisX(xmin, xmax, xsize);
			xaxis.x = board.x2pixel(xmin);
			xaxis.y = board.y2pixel(0);

			// Eixo y
			yaxis = new AxisY(ymin, ymax, ysize);
			yaxis.x = board.x2pixel(0);
			yaxis.y = board.y2pixel(ymin);
			
			// Grade
			_grid = new GraphGrid(xaxis, yaxis);
			
			// A distância, em pixels, entre dois pontos consecutivos do gráfico
			resolution = 0.5;
			
			// As funções - contínuas - adicionadas ao gráfico.
			functionsBundle = new Dictionary();
			
			board.addChildAt(xaxis, 0);
			board.addChildAt(yaxis, 0);
			board.addChildAt(_grid, 0);
			addChild(board);
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		/**
		 * Define o intervalo de valores das variáveis independente (x) e dependente (y).
		 * @param	xmin - O limite inferior da variável independente (x).
		 * @param	xmax - O limite superior da variável independente (x).
		 * @param	ymin - O limite inferior da variável dependente (y).
		 * @param	ymax - O limite superior da variável dependente (y).
		 */
		public function setRange (xmin:Number, xmax:Number, ymin:Number, ymax:Number) : void {
			
			if (xmax <= xmin) throw new Error ("xmin must be grater than xmax.");
			if (ymax <= ymin) throw new Error ("ymin must be grater than ymax.");
			
			board.xmin = xmin;
			board.xmax = xmax;
			board.ymin = ymin;
			board.ymax = ymax;
			
			xaxis.xmin = xmin;
			xaxis.xmax = xmax;
			xaxis.x = board.x2pixel(xmin);
			xaxis.y = board.y2pixel(Math.max(ymin, Math.min(ymax, 0)));
			
			yaxis.ymin = ymin;
			yaxis.ymax = ymax;
			yaxis.x = board.x2pixel(Math.max(xmin, Math.min(xmax, 0)));
			yaxis.y = board.y2pixel(ymin);
			
			// obs.: não é necessário atualizar as referências aos eixos x e y no objeto grid.
		}
		
		/**
		 * Define o limite x inferior do gráfico.
		 * @param	xmin - O limite x inferior do gráfico.
		 */
		public function set xmin (xmin:Number) : void {
			setRange(xmin, xaxis.xmax, yaxis.ymin, yaxis.ymax);
		}
		
		/**
		 * Retorna o limite x inferior do gráfico.
		 */
		public function get xmin () : Number {
			return xaxis.xmin;
		}
		
		/**
		 * Define o limite x superior do gráfico.
		 * @param	xmax - O limite superior do gráfico.
		 */
		public function set xmax (xmax:Number) : void {
			setRange(xaxis.xmin, xmax, yaxis.ymin, yaxis.ymax);
		}
		
		/**
		 * Retorna o limite x superior do gráfico.
		 */
		public function get xmax () : Number {
			return xaxis.xmax;
		}
		
		/**
		 * Define o limite y inferior do gráfico.
		 * @param	ymin - O limite y inferior do gráfico.
		 */
		public function set ymin (ymin:Number) : void {
			setRange(xaxis.xmin, xaxis.xmax, ymin, yaxis.ymax);
		}
		
		/**
		 * Retorna o limite y inferior do gráfico.
		 */
		public function get ymin () : Number {
			return yaxis.ymin;
		}
		
		/**
		 * Define o limite y superior do gráfico.
		 * @param	ymax - O limite y superior do gráfico.
		 */
		public function set ymax (ymax:Number) : void {
			setRange(xaxis.xmin, xaxis.xmax, yaxis.ymin, ymax);
		}
		
		/**
		 * Retorna o limite y superior do gráfico.
		 */
		public function get ymax () : Number {
			return yaxis.ymax;
		}
		
		/**
		 * Define a área do palco ocupada pelo gráfico.
		 * @param	xsize - O tamanho horizontal do gráfico, em pixels.
		 * @param	ysize - O tamanho vertical do gráfico, em pixels.
		 */
		public function setSize (xsize:Number, ysize:Number) : void {
			board.setSize(xsize, ysize);
		}
		
		/**
		 * (Re)desenha o gráfico. Utilize este método (sem passar um argumento) para atualizar o gráfico após alguma alteração
		 * em algum dos parâmetros do gráfico. O argumento <source>event</source> permite que o método seja chamado através de
		 * um observador de eventos.
		 * @param	event - Evento que gerou a execução do método (utilizado apenas quando chamado a partir de um observador
		 * de eventos).
		 */
		public function draw (event:Event = null) : void {
			board.draw();
			xaxis.draw();
			yaxis.draw();
			_grid.draw();
		}
		
		/**
		 * Adiciona uma função contínua ao gráfico.
		 * @param	f - A função a ser inserida.
		 * @param	style - O estilo de exibição dos dados.
		 */
		/*
		 *     O objeto da classe Function, passado como argumento deste método, é de conhecimento apenas desta classe. Para o
		 * objeto da classe Rectangular2DGraphBoard, reponsável por desenhar o gráfico, só recebe uma matriz com inúmeros pares
		 * ordenados (x,y), mais um estilo de exibição (DataStyle), que define como esses pontos serão desenhados.
		 *     A primeira coisa que o método faz é estabelecer o limite real de avaliação da função, que deve levar em conta
		 */
		public function addFunction (f:GraphFunction, style:DataStyle = null) : void {
			
			var xmin:Number = Math.max(board.xmin, f.xmin);
			var xmax:Number = Math.min(board.xmax, f.xmax);
			
			var x, y:Number;
			var data:Array = new Array();
			
			for (var pixel:Number = board.x2pixel(xmin); pixel <= board.x2pixel(xmax); pixel += resolution) {
				x = board.pixel2x(pixel);
				y = f.value(x);
				if (!isNaN(y) && isFinite(y)) data.push([x, y]);
			}
			
			if (style == null) style = new DataStyle();
			
			board.addData(data, style);
			functionsBundle[f] = data;
		}
		
		/**
		 * Remove a função <source>f</source> do gráfico.
		 * @param	f - A função a ser removida do gráfico.
		 */
		/*
		 * A função passada como argumento é a chave do dicionário functionsBundle e define a matriz (Array) que contém os dados
		 * passados para a área do gráfico. Isto é usado na primeira linha para remover do objeto board o conjunto de dados. A
		 * segunda linha apaga o registro da função no dicionário.
		 */
		public function removeFunction (f:GraphFunction) : void {
			board.removeData(functionsBundle[f]);
			delete functionsBundle[f];
		}
		
		/**
		 * Adiciona um ponto genérico na posição (x,y) do gráfico. Um ponto genérico é um objeto da classe GraphPoint,
		 * que estende a classe Sprite. Por isso, é possível utilizar qualquer Sprite ou MovieClip do Flash como ponto a ser adicionado no gráfico.
		 * @param	point - O ponto a ser inserido.
		 * @param	draggable - Indica se o ponto pode ser arrastado (true) ou não (false).
		 */
		public function addPoint (point:GraphPoint, draggable:Boolean = false, snap2grid:Boolean = false) : void {
			
			// Faz o ponto seguir a grade
			if (snap2grid) point.snap2Grid(_grid);
			
			board.addPoint(point, draggable);
		}
		
		/**
		 * Remove um ponto do gráfico.
		 * @param	point - O ponto a ser removido.
		 */
		public function removePoint (point:GraphPoint) : void {
			board.removePoint(point);
		}
		
		/**
		 * Define se a grade deve ou não ser exibida.
		 * @param	show - <source>true</source> exibirá a grade; <source>false</source> não.
		 */
		public function set grid (show:Boolean) : void {
			if (show) {
				if (!board.contains(_grid)) board.addChildAt(_grid, 0);
			}
			else {
				if (board.contains(_grid)) board.removeChild(_grid);
			}
		}
		
		/**
		 * Define a espessura dos traçados dos eixos x e y.
		 * @param	thickness - A espessura dos traçados.
		 */
		public function setAxisThickness (thickness:Number) : void {
			xaxis.thickness = thickness;
			yaxis.thickness = thickness;
		}
		
		/**
		 * Retorna a espessura dos traçados dos eixos x e y.
		 * @return	A espessura dos traçados.
		 */
		public function getAxisThickness () : Number {
			return xaxis.thickness;
		}
		
		/**
		 * Define a cor dos traçados dos eixos x e y.
		 * @param	color - A cor dos traçados.
		 */
		public function setAxisColor (color:int) : void {
			xaxis.color = color;
			yaxis.color = color;
		}
		
		/**
		 * Retorna a cor dos traçados dos eixos x e y.
		 */
		public function getAxisColor () : int {
			return xaxis.color;
		}
		
		/**
		 * Define o tamanho dos traços dos eixos x e y. Os sub-traços têm sempre metade do tamanho dos traços.
		 * @param	size - O tamanho dos traços, em pixel.
		 */
		public function setAxisTicksize (size:Number) : void {
			xaxis.ticksize = size;
			yaxis.ticksize = size;
		}
		
		/**
		 * Retorna o tamanho dos traços dos eixos x e y. Os sub-traços têm sempre metade do tamanho dos traços.
		 */
		public function getAxisTicksize () : Number {
			return xaxis.ticksize;
		}
		
		/**
		 * Define o formato de texto dos rótulos associados aos traços dos eixos x e y.
		 * @param	format - O formato de texto dos rótulos associados aos traços dos eixos x e y.
		 */
		public function setLabelsFormat (format:TextFormat) : void {
			xaxis.labelFormat = format;
			yaxis.labelFormat = format;
		}
		
		/**
		 * Retorna o formato de texto dos rótulos associados aos traços dos eixos x e y.
		 * @return
		 */
		public function getLabelsFormat () : TextFormat {
			return xaxis.labelFormat;
		}
		
		/**
		 * Define a distância entre os traços e seus rótulos, dos eixos x e y
		 * @param	distance - A distância, em pixels, entre os traços e os rótulos.
		 */
		public function setAxisLabelTickGap (distance:Number) : void {
			xaxis.gap = distance;
			yaxis.gap = distance;
		}
		
		/**
		 * Retorna a distância entre os traços e seus rótulos, dos eixos x e y.
		 */
		public function getAxisLabelTickGap () : Number {
			return xaxis.gap;
		}
		
		/**
		 * Define a flecha que indica a orientação dos eixos x e y. Uma flecha genérica, representada por um objeto
		 * da classe flash.display.Sprite, deve ter seu ponto-de-referência (registration) na ponta da flecha.
		 * @param	arrow - A flecha.
		 */
		public function setAxisArrow (arrow:Sprite) : void {
			xaxis.arrow = arrow;
			yaxis.arrow = arrow;
		}
		
		/**
		 * Retorna a flecha que indica a orientação dos eixos x e y.
		 */
		public function getAxisArrow () : Sprite {
			return xaxis.arrow;
		}
		
		/**
		 * Define a distância entre dois traços sucessivos do eixo x ou y.
		 * @param	axis - O eixo de interesse: Graph.AXIS_X ou Graph.AXIS_Y.
		 * @param	distance - A distância entre os traços, em unidades do gráfico.
		 */
		public function setTicksDistance (axis:String, distance:Number) : void {
			if (axis == AXIS_X) xaxis.dticks = distance;
			else if (axis == AXIS_Y) yaxis.dticks = distance;
		}
		
		/**
		 * Retorna a distância entre dois traços sucessivos do eixo x ou y.
		 * @param	axis - O eixo de interesse: Graph.AXIS_X ou Graph.AXIS_Y.
		 * @return	A distância entre os traços, em unidades do gráfico.
		 */
		public function getTicksDistance (axis:String) : Number {
			if (axis == AXIS_X) return xaxis.dticks;
			else if (axis == AXIS_Y) return yaxis.dticks;
			else throw new Error ("Unknow axis " + axis + ". Use Graph.AXIS_X or Graph.AXIS_Y.");
		}
		
		/**
		 * Define a distância entre dois traços sucessivos do eixo x ou y.
		 * @param	axis - O eixo de interesse: Graph.AXIS_X ou Graph.AXIS_Y.
		 * @param	distance - A distância entre os sub-traços, em unidades do gráfico.
		 */
		public function setSubticksDistance (axis:String, distance:Number) : void {
			if (axis == AXIS_X) xaxis.dsubticks = distance;
			else if (axis == AXIS_Y) yaxis.dsubticks = distance;
		}
		
		/**
		 * Retorna a distância entre dois sub-traços sucessivos do eixo x ou y.
		 * @param	axis - O eixo de interesse: Graph.AXIS_X ou Graph.AXIS_Y.
		 * @return	A distância entre os sub-traços, em unidades do gráfico.
		 */
		public function getSubticksDistance (axis:String) : Number {
			if (axis == AXIS_X) return xaxis.dsubticks;
			else if (axis == AXIS_Y) return yaxis.dsubticks;
			else throw new Error ("Unknow axis " + axis + ". Use Graph.AXIS_X or Graph.AXIS_Y.");
		}
		
		/**
		 * Retorna as coordenadas dos traços do eixo x ou y.
		 * @param	axis - O eixo cujos traços se quer: Graph.AXIS_X ou Graph.AXIS_Y.
		 * @return	Uma matriz n x 1 contendo as coordenadas dos n traços do eixo requisitado.
		 */
		public function getAxisTicksCoordinates (axis:String) : Array {
			if (axis == AXIS_X) return xaxis.ticks;
			else if (axis == AXIS_Y) return yaxis.ticks;
			else return null;
		}
		
		/**
		 * Retorna as coordenadas dos sub-traços do eixo x ou y.
		 * @param	axis - O eixo cujos sub-traços se quer: Graph.AXIS_X ou Graph.AXIS_Y.
		 * @return	Uma matriz n x 1 contendo as coordenadas dos n sub-traços do eixo requisitado.
		 */
		public function getAxisSubticksCoordinates (axis:String) : Array {
			if (axis == AXIS_X) return xaxis.subticks;
			else if (axis == AXIS_Y) return yaxis.subticks;
			else return null;
		}
		
		/**
		 * Define um conjunto de traços/rótulos personalizados.
		 * @param	axis - O eixo ao qual se quer inserir os traços/rótulos.
		 * @param	coordinates - Matriz n x 2 contendo n coordenadas (primeira coluna) e seus respectivos rótulos (segunda coluna).
		 * Exemplo:
		 *   var graph:Graph = new Graph(...);
		 *   graph.setUserTicks(Graph.AXIS_X, [[1, "x = 1"], [2, "x = 2"], [3, "x = 3 (raiz)"]]);
		 */
		public function setUserTicks (axis:String, ticks:Array) : void {
			if (axis == AXIS_X) xaxis.userTicks = ticks;
			else if (axis == AXIS_Y) yaxis.userTicks = ticks;
		}
		
		/**
		 * Define o alinhamento dos traços e sub-traços do eixo x ou y.
		 * @param	axis - O eixo cujo alinhamento dos traços se quer modificar.
		 * @param	alignment - Para o eixo x pode ser AxisX.TICKS_BELOW, AxisX.TICKS_CENTER ou AxisX.TICKS_ABOVE;
		 * para o eixo y pode ser AxisY.TICKS_LEFT, AxisY.TICKS_CENTER ou AxisY.TICKS_RIGHT.
		 */
		public function setTickAlignment (axis:String, alignment:String) : void {
			if (axis == AXIS_X) xaxis.tickAlignment = alignment;
			else if (axis == AXIS_Y) yaxis.tickAlignment = alignment;
		}
		
		/**
		 * Define o alinhamento dos rótulos dos traços do eixo x ou y.
		 * @param	axis - O eixo cujo alinhamento dos rótulos se quer modificar.
		 * @param	alignment - Para o eixo x pode ser AxisX.LABEL_BELOW ou AxisX.LABEL_ABOVE;
		 * para o eixo y pode ser AxisY.LABEL_LEFT ou AxisY.LABEL_RIGHT.
		 */
		public function setLabelAlignment (axis:String, alignment:String) : void {
			if (axis == AXIS_X) xaxis.labelAlignment = alignment;
			else if (axis == AXIS_Y) yaxis.labelAlignment = alignment;
		}
		
		/*
		 * Configura os elementos que dependem do palco.
		 */
		private function init (event:Event = null) : void {
			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// O que depende do stage...
			this.x = this.y = 50; // TODO: REMOVER ISSO NO FINAL.
		}
	}
}