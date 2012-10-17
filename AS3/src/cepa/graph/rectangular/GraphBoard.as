/*
 * TODO: separar a parte do gráfico que é atualizada com mais frequência (pontos e curvas) das outras (eixos e grade)
 * TODO: transformar os eixos em bitmap
 * TODO: criar uma lista de elementos recentemetne modificados, de modo que a classe possa decidir atualizar-se automaticamente após um certo threshold
 */
package cepa.graph.rectangular {
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	
	//import cepa.events.GraphPointEvent;
	import cepa.graph.GraphPoint;
	import cepa.graph.DataStyle;
	import cepa.graph.GraphFunction;
	
	public class GraphBoard extends Sprite {
		
		private const EPS:Number = 0.0001;
		
		private var _xmin:Number; // O limite x inferior do gráfico
		private var _xmax:Number; // O limite x superior do gráfico
		private var _ymin:Number; // O limite y inferior do gráfico
		private var _ymax:Number; // O limite y superior do gráfico
		private var _xsize:Number; // O tamanho do gráfico na direção x, em pixels
		private var _ysize:Number; // O tamanho do gráfico na direção y, em pixels
		private var _registration:Point; // O ponto de referência deste DisplayObject
		private var _resolution:Number;
		
		private var redraw:Boolean = true; // Idenfica se é preciso redesenhar o objeto desta classe
		
		private var points:Array;
		private var pointsLayer:DisplayObjectContainer;
		
		private var currentInRange:Boolean;
		private var lastInRange:Boolean;
		
		private var data:Array;
		private var dataLayer:Sprite;
		private var dataLayerMask:Sprite;
		
		//private var style:GraphDataStyle;
		
		private var clickOffset:Point;
		private var target:GraphPoint;
		private var previousPosition:Point;
		
		private var dataStyle:Array;
		
		private var defaultRegistration:Boolean;
		
		private var functionList:Array;
		private var functionStyle:Array;
		
		public function GraphBoard (xmin:Number, xmax:Number, xsize:Number, ymin:Number, ymax:Number, ysize:Number) : void {
			
			setRange(xmin, xmax, ymin, ymax);
			setSize(xsize, ysize);
			
			//functions = new Array();
			dataLayer = new Sprite();
			addChild(dataLayer);
			dataLayer.mask = dataLayerMask;
			dataLayer.addChild(dataLayerMask);
			
			// Por padrão, o ponto-de-referência deste DisplayObject fica no vértice superior esquerdo
			_registration = new Point(_xmin, _ymax);
			defaultRegistration = true;
			
			pointsLayer = new Sprite();
			addChild(pointsLayer);
			
			points = new Array();
			
			previousPosition = new Point();
			
			data = new Array();
			
			dataStyle = new Array();
			
			functionList = new Array();
			functionStyle = new Array();
			_resolution = 10;
			
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
			
			if (xmax > xmin) {
				_xmin = xmin;
				_xmax = xmax;
			}
			else throw new Error ("xmin must be grater than xmax.");
			
			if (ymax > ymin) {
				_ymin = ymin;
				_ymax = ymax;
			}
			else throw new Error ("ymin must be grater than ymax.");
			
			if (defaultRegistration) _registration = new Point(_xmin, _ymax);
			
			redraw = true;
		}
		
		/**
		 * Define o limite x inferior do gráfico.
		 * @param	xmin - O limite x inferior do gráfico.
		 */
		public function set xmin (xmin:Number) : void {
			if (_xmax <= xmin) throw new Error ("xmin must be grater than xmax.");
			else _xmin = xmin;
		}
		
		/**
		 * Retorna o limite x inferior do gráfico.
		 */
		public function get xmin () : Number {
			return _xmin;
		}
		
		/**
		 * Define o limite x superior do gráfico.
		 * @param	xmax - O limite superior do gráfico.
		 */
		public function set xmax (xmax:Number) : void {
			if (xmax <= _xmin) throw new Error ("xmin must be grater than xmax.");
			else _xmax = xmax;
		}
		
		/**
		 * Retorna o limite x superior do gráfico.
		 */
		public function get xmax () : Number {
			return _xmax;
		}
		
		/**
		 * Define o limite y inferior do gráfico.
		 * @param	ymin - O limite y inferior do gráfico.
		 */
		public function set ymin (ymin:Number) : void {
			if (_ymax <= ymin) throw new Error ("ymin must be grater than ymax.");
			else _ymin = ymin;
		}
		
		/**
		 * Retorna o limite y inferior do gráfico.
		 */
		public function get ymin () : Number {
			return _ymin;
		}
		
		/**
		 * Define o limite y superior do gráfico.
		 * @param	ymax - O limite y superior do gráfico.
		 */
		public function set ymax (ymax:Number) : void {
			if (ymax <= _ymin) throw new Error ("xmin must be grater than xmax.");
			else _ymax = ymax;
		}
		
		/**
		 * Retorna o limite y superior do gráfico.
		 */
		public function get ymax () : Number {
			return _ymax;
		}
		
		/**
		 * Define a área do palco ocupada pelo gráfico.
		 * @param	xsize - O tamanho horizontal, em pixels.
		 * @param	ysize - O tamanho vertical, em pixels.
		 */
		public function setSize (xsize:Number, ysize:Number) : void {
			
			if (xsize > 0 && ysize > 0) {
				_xsize = xsize;
				_ysize = ysize;
			}
			else throw new Error ("The x/y size of the graph must be greater than zero.");
			
			// Atualiza a máscara da camada de funções
			dataLayerMask = new Sprite();
			dataLayerMask.graphics.beginFill(0xFF0000);
			dataLayerMask.graphics.drawRect(0, 0, xsize, ysize);
			dataLayerMask.graphics.endFill();
			
			redraw = true;
		}
		
		/**
		 * Retorna o tamanho horizontal do gráfico, em pixels.
		 */
		public function get xsize () : Number {
			return _xsize;
		}
		
		/**
		 * Retorna o tamanho vertical do gráfico, em pixels.
		 */
		public function get ysize () : Number {
			return _ysize;
		}
		
		/**
		 * Define a resolução do gráfico, isto é, a distância em pixels entre dois pontos consecutivos do gráfico de funções contínuas.
		 */
		public function set resolution (r:Number) : void {
			if (r > 0) _resolution = r;
		}
		
		/**
		 * Retorna a resolução do gráfico, isto é, a distância em pixels entre dois pontos consecutivos do gráfico de funções contínuas.
		 */
		public function get resolution () : Number {
			return _resolution;
		}
		
		/**
		 * Adiciona um ponto genérico na posição (x,y) do gráfico. Um ponto genérico é um objeto da classe GraphPoint,
		 * que estende a classe Sprite. Por isso, é possível utilizar qualquer Sprite ou MovieClip do Flash como ponto a ser adicionado no gráfico.
		 * @param	point - O ponto a ser inserido.
		 * @param	draggable - Indica se o ponto pode ser arrastado (true) ou não (false).
		 */
		public function addPoint (point:GraphPoint, draggable:Boolean = false) : void {
			
			if (point != null) {
				// Adiciona o ponto à lista de pontos do gráfico
				points.push(point);
				
				// Posiciona o ponto no gráfico
				point.x = x2pixel(point.xpos);
				point.y = y2pixel(point.ypos);
				
				// Habilita/desabilita o arraste do ponto
				setDraggable(point, draggable);
				
				redraw = true;
			}
		}
		
		/**
		 * Remove um ponto do gráfico.
		 * @param	point - O ponto a ser removido.
		 */
		public function removePoint (point:GraphPoint) : void {
			var i:int = points.indexOf(point);
			if (i >= 0) {
				pointsLayer.removeChild(point);
				points.splice(i, 1)
				redraw = true;
			}
		}
		
		/**
		 * Habilita/desabilita a possibilidade de se arrastar um ponto do gráfico.
		 * @param	point - O ponto de interesse.
		 * @param	draggable - <source>true</source> caso se queira permitir que este ponto seja arrastado; <source>false</source> em caso contrário.
		 */
		/*
		 * Para permitir que um ponto qualquer seja arrastado, basta adicionar-lhe os observadores de eventos do mouse apropriados;
		 * analogamente, para impedir que este ponto seja arrastado, basta remover-lhe esses observadores.
		 */
		public function setDraggable (point:GraphPoint, draggable:Boolean) : void {
			
			if (points.indexOf(point) >= 0) {
				if (draggable) {
					point.addEventListener(MouseEvent.MOUSE_DOWN,  grabPoint);
					point.addEventListener(MouseEvent.MOUSE_MOVE,  movePoint);
					point.addEventListener(MouseEvent.MOUSE_UP, releasePoint);
				}
				else {
					point.removeEventListener(MouseEvent.MOUSE_DOWN,  grabPoint);
					point.removeEventListener(MouseEvent.MOUSE_MOVE,  movePoint);
					point.removeEventListener(MouseEvent.MOUSE_UP, releasePoint);
				}
				
				redraw = true;
			}
		}
		
		/*
		 * Pega um ponto do gráfico (inicia o arraste).
		 */
		private function grabPoint (event:MouseEvent) : void {
			clickOffset = new Point(event.localX, event.localY);
			target = event.target as GraphPoint;
			pointsLayer.setChildIndex(target, pointsLayer.numChildren - 1);
		}
		
		/*
		 * Arrasta o ponto pelo gráfico.
		 */
		private function movePoint (event:MouseEvent) : void {
			if (clickOffset != null) {
				
				previousPosition.x = target.xpos;
				previousPosition.y = target.ypos;
				
				target.xpos = pixel2x(mouseX - clickOffset.x);
				target.ypos = pixel2y(mouseY - clickOffset.y);
				
				if (inRange(target.xpos, target.ypos)) {
					target.x = x2pixel(target.xpos);
					target.y = y2pixel(target.ypos);
				}
				else {
					target.xpos = previousPosition.x;
					target.ypos = previousPosition.y;
				}
				
				redraw = true;
				draw();
				
				//target.dispatchEvent(new GraphPointEvent(GraphPointEvent.MOVE));
				
				event.updateAfterEvent();
			}
		}
		
		/*
		 * Pára de arrastar um ponto do gráfico.
		 */
		private function releasePoint (event:MouseEvent) : void {
			clickOffset = null;
			target = null;
			redraw = true;
		}
		
		public function addData (d:Array, style:DataStyle) : void {
			data.push(d);
			dataStyle.push(style);
			redraw = true;
		}
		
		public function removeData (d:Array) : void {
			var i:int = data.indexOf(d);
			if (i >= 0) {
				data.splice(i, 1);
				dataStyle.splice(i, 1);
				redraw = true;
			}
		}
		
		public function addFunction (f:GraphFunction, style:DataStyle) : void {
			data.push(f);
			dataStyle.push(style);
			redraw = true;
		}
		
		public function removeFunction (f:GraphFunction) : void {
			var i:int = data.indexOf(f);
			if (i >= 0) {
				data.splice(i, 1);
				dataStyle.splice(i, 1);
				redraw = true;
			}
		}
		
		public function hasFunction (f:GraphFunction) : Boolean {
			return data.indexOf(f) >= 0;
		}
		
		/**
		 * Desenha o gráfico. Este método deve ser chamado após efetuadas as alterações desejadas.
		 * TODO: verificar se o data contém dados.
		 */
		public function draw (event:Event = null) : void {
			
			//if (!redraw) return;
			
			// Desenha as funções adicionadas ao gráfico
			//--------------------------------------------------
			dataLayer.graphics.clear();
			
			for each (var d:* in data) {
				
				lastInRange = false;
				
				var style:DataStyle = dataStyle[data.indexOf(d)];
				dataLayer.graphics.lineStyle(style.stroke, style.color, style.alpha, false, LineScaleMode.NONE);
				
				if (d is Array) {
					if (d.lenght == 0) continue;
					dataLayer.graphics.moveTo(x2pixel(d[0][0]), y2pixel(d[0][1]));
					for (var i:int = 0; i < d.length; i++) {
						currentInRange = inRange(d[i][0], d[i][1]);
						currentInRange = lastInRange = true; // TESTE
						// Entrando na área do gráfico
						if (currentInRange == true && lastInRange == false) {
							dataLayer.graphics.moveTo(x2pixel(d[i][0]), y2pixel(d[i][1]));
							//dataLayer.graphics.drawCircle(x2pixel(d[i][0]), y2pixel(d[i][1]), 1);
						}
						// Dentro da área do gráfico
						else if (currentInRange == true && lastInRange == true) {
							dataLayer.graphics.lineTo(x2pixel(d[i][0]), y2pixel(d[i][1]));
							//dataLayer.graphics.drawCircle(x2pixel(d[i][0]), y2pixel(d[i][1]), 1);
						}
						// Saindo da área do gráfico
						else if (currentInRange == false && lastInRange == true) {
							dataLayer.graphics.lineTo(x2pixel(d[i][0]), y2pixel(d[i][1]));
							//dataLayer.graphics.drawCircle(x2pixel(d[i][0]), y2pixel(d[i][1]), 1);
						}
						// Fora da área do gráfico
						else {
							// Nada
							//dataLayer.graphics.drawCircle(pixel, y2pixel(y), 5);
						}
						
						lastInRange = currentInRange;
					}
				}
				else if (d is GraphFunction) {
					
					var xmin:Number = Math.max(_xmin, d.xmin);
					var xmax:Number = Math.min(_xmax, d.xmax);
					
					if (Math.abs(xmax - xmin) < EPS) continue;
					
					var pixel:Number = x2pixel(xmin)
					var endPixel:Number = x2pixel(xmax);
					var y:Number = d.value(pixel2x(pixel));
					var x:Number = xmin;
					var past_x:Number = x;
					
					currentInRange = true;
					lastInRange = false;
					
					x = past_x = pixel2x(pixel);
					
					// Evita a descontinuidade inicial, se existir
					while (!isContinuous(d, past_x, x))
					{
						past_x = x;
						pixel += _resolution;
						x = pixel2x(pixel);
					}
					
					// Posição inicial da "ponta do lápis"
					dataLayer.graphics.moveTo(pixel, y2pixel(y));
					
					while (pixel < endPixel) {
						
						x = pixel2x(pixel);
						y = d.value(x);
						
						if (!isNaN(y) && isFinite(y))
						{	
							if (isContinuous(d, past_x, x))
							{
								// Entrando na área do gráfico
								if (currentInRange == true && lastInRange == false) {
									dataLayer.graphics.lineTo(pixel, y2pixel(y));
									//dataLayer.graphics.drawCircle(pixel, y2pixel(y), 2);
								}
								// Dentro da área do gráfico
								else if (currentInRange == true && lastInRange == true) {
									dataLayer.graphics.lineTo(pixel, y2pixel(y));
									//dataLayer.graphics.drawCircle(pixel, y2pixel(y), 2);
								}
								// Saindo da área do gráfico
								else if (currentInRange == false && lastInRange == true) {
									dataLayer.graphics.lineTo(pixel, y2pixel(y));
									//dataLayer.graphics.drawCircle(pixel, y2pixel(y), 2);
								}
								// Fora da área do gráfico
								else {
									dataLayer.graphics.moveTo(pixel, y2pixel(y));
									//dataLayer.graphics.drawCircle(pixel, y2pixel(y), 2);
								}
							}
							else
							{
								dataLayer.graphics.moveTo(pixel, y2pixel(y));
							}
						}
						
						past_x = x;
						
						pixel += _resolution;
						lastInRange = currentInRange;
						currentInRange = (d.value(pixel2x(pixel)) >= _ymin && d.value(pixel2x(pixel)) <= _ymax);						
					}
					
					// Desenha o último ponto do gráfico, se não for descontínuo.
					x = xmax;
					y = d.value(x);
					
					if (!isNaN(y) && isFinite(y) && isContinuous(d, past_x, x))
					{
						dataLayer.graphics.lineTo(x2pixel(x), y2pixel(y));
						//dataLayer.graphics.drawCircle(pixel, y2pixel(y), 2);
					}
				}
			}
			
			// Desenha os pontos adicionados ao gráfico
			//--------------------------------------------------
			for each (var point:GraphPoint in points) {
				if (inRange(point.xpos, point.ypos)) {
					point.x = x2pixel(point.xpos);
					point.y = y2pixel(point.ypos);
					if (!pointsLayer.contains(point)) pointsLayer.addChild(point); // TODO: adicionar na camada em addPoint() apenas
				}
			}
			
			// Recoloca os pontos arrastáveis acima dos outros.
			// TODO: fazer isso ao adicionar um ponto novo (já inserí-lo abaixo dos pontos arrastáveis)
			for each (point in points)
			{
				if (point.hasEventListener(MouseEvent.MOUSE_MOVE))
				{
					pointsLayer.setChildIndex(point, pointsLayer.numChildren - 1);
				}
			}
			
			
			redraw = false;
		}
		
		
		private function isContinuous (f:GraphFunction, left_x:Number, right_x:Number) : Boolean
		{
			var ans:Boolean = true;
			
			for each (var singularity:Number in f.discontinuities)
			{
				if (singularity >= left_x && singularity <= right_x)
				{
					ans = false;
					break;
				}
			}
			
			return ans;
		}
		
		/**
		 * Converte a coordenada <source>x</source> do gráfico para a correspondente coordenada <source>x</source> deste DisplayObject.
		 * @param	x - Coordenada do gráfico
		 * @return	A coordenada <source>x</source> deste DisplayObject
		 */
		public function x2pixel (x:Number) : Number {
			return _xsize * (x - _registration.x) / (_xmax - _xmin);
		}
		
		/**
		 * Converte a coordenada <source>y</source> do gráfico para a correspondente coordenada <source>y</source> deste DisplayObject.
		 * @param	y - Coordenada do gráfico
		 * @return	A coordenada <source>y</source> deste DisplayObject
		 */
		public function y2pixel (y:Number) : Number {
			return _ysize * (_registration.y - y) / (_ymax - _ymin);
		}
		
		/**
		 * Converte a coordenada <source>x</source> deste DisplayObject para a correspondente coordenada <source>x</source> do gráfico.
		 * @param	px - Coordenada do DisplayObject
		 * @return	A coordenada <source>x</source> do gráfico
		 */
		public function pixel2x (px:Number) : Number {
			return _registration.x + px * (_xmax - _xmin) / _xsize;
		}
		
		/**
		 * Converte a coordenada <source>y</source> deste DisplayObject para a correspondente coordenada <source>y</source> do gráfico.
		 * @param	py - Coordenada do DisplayObject
		 * @return	A coordenada <source>y</source> do gráfico
		 */
		public function pixel2y (py:Number) : Number {
			return _registration.y - py * (_ymax - _ymin) / _ysize;
		}
		
		/**
		 * Informa se o ponto (x,y) pertence à área do gráfioc.
		 * @param	x - A coordenada horizontal do ponto.
		 * @param	y - A coordenada vertical do ponto.
		 * @return	<source>true</source> se o ponto pertence à área do gráfico; <source>false</source> em caso contrário.
		 */
		public function inRange (x:Number, y:Number) : Boolean {
			if (x >= _xmin && x <= _xmax && y >= _ymin && y <= _ymax) return true;
			else return false;
		}
		
		/**
		 * Define o ponto-de-referência deste DisplayObject, também conhecido como "registration".
		 * @param	point - As coordenadas do ponto-de-referência.
		 */
		public function set registration (point:Point) : void {
			if (point == null) {
				_registration = new Point(_xmin, _ymax);
				defaultRegistration = true;
			}
			else {
				_registration = point;
				defaultRegistration = false;
			}
			
			redraw = true;
		}
		
		/**
		 * Retorna o ponto-de-referência deste DisplayObject
		 */
		public function get registration () : Point {
			return _registration;
		}
		
		public function beingDragged (point:GraphPoint) : Boolean {
			if (target != null && target == point) return true;
			else return false;
		}
		
		private function init (event:Event = null) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, movePoint);
			stage.addEventListener(MouseEvent.MOUSE_UP, releasePoint);
		}
	}
}