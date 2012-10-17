// TODO: remover os métodos set ymin e ymax (usar setRange)
package cepa.graph.rectangular {
	
	import flash.display.DisplayObject;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	import cepa.graph.SimpleArrow;
	
	public class AxisY extends Sprite {
		
		public static const LABEL_LEFT   :String = "LABEL_LEFT";
		public static const LABEL_RIGHT  :String = "LABEL_RIGHT";
		public static const TICKS_LEFT   :String = "TICKS_LEFT";
		public static const TICKS_CENTER :String = "TICKS_CENTER";
		public static const TICKS_RIGHT  :String = "TICKS_RIGHT";
		
		private static const STD_TICK_SIZE:Number = 10;
		private static const STD_TICK_ALIGNMENT:String = TICKS_RIGHT;
		private static const STD_LABEL_ALIGNMENT:String = LABEL_LEFT;
		private static const STD_LABEL_FORMAT:TextFormat = new TextFormat("Arial", 1.2 * STD_TICK_SIZE);
		private static const STD_COLOR:int = 0x000000;
		private static const STD_THICKNESS:Number = 1;
		private static const STD_GAP:Number = 0.2 * STD_TICK_SIZE;
		
		private var _ymin:Number; // Limite inferior do eixo
		private var _ymax:Number; // Limite superior do eixo
		private var _size:Number; // O tamanho do eixo, em pixels
		private var _registration:Number; // A coordenada associada ao ponto y = 0 deste DisplayObject		
		private var _thickness:Number; // A espessura do eixo, em pixel
		private var _color:Number; // A cor do eixo
		private var _ticksize:Number; // O tamanho dos traços
		private var _dticks:Number; // A distância entre dois traços consecutivos, em unidades do eixo
		private var _dsubticks:Number; // A distância entre dois sub-traços consecutivos, em unidades do eixo
		private var _labelFormat:TextFormat; // O formato dos rótulos dos traços
		private var _gap:Number; // A distância entre o traço e seu respectivo rótulo
		private var _tickalignment:String; // O alinhamento dos traços: acima do eixo, centralizado ou abaixo dele
		private var _arrow:Sprite; // A flecha que indica a orientação do eixo
		private var _ticks:Array; // As coordenadas dos traços do eixo
		private var _subticks:Array; // As coordenadas dos sub-traços do eixo
		private var _userticks:Array; // As coordenadas e rótulos personalizados pelo usuário
		private var _noticks:Boolean; // Identifica se os tiques do eixo devem ser desenhados ou não
		
		private var tickposition:int; // A posição dos traços: acima, centralizado ou abaixo do eixo
		private var labelRight:Boolean; // Indica se os rótulos ficam abaixo ou acima do eixo
		private var userDefinedLabelFormat:Boolean = false; // Indica se o usuário alterou o formato de texto dos rótulos
		private var userDefinedTicks:Boolean = false; // Indica se o usuário alterou a distância entre traços/sub-traços
		private var userDefinedArrow:Boolean = false; // Indica se o usuário alterou a flecha do eixo
		private var hiddenLabels:Array; // Conjunto de rótulos escondidos
		private var eps:Number; // Quaisquer duas coordenadas cuja diferença é menor que eps são consideradas como equivalentes
		private var redraw:Boolean = true; // Idenfica se é preciso redesenhar o objeto desta classe
		
		/**
		 * Cria um eixo horizontal
		 * @param	ymin - O limite inferior do intervalo que o eixo representa (deve ser menor que <source>ymax</source>)
		 * @param	ymax - O limite superior do intervalo que o eixo representa (deve ser maior que <source>ymin</source>)
		 * @param	size - O tamanho do eixo, em pixels.
		 */
		public function AxisY (ymin:Number, ymax:Number, size:Number) {
			setRange(ymin, ymax);
			this.size = size;
			
			_thickness = STD_THICKNESS;
			_color = STD_COLOR;
			_ticksize = STD_TICK_SIZE;
			_labelFormat = STD_LABEL_FORMAT;
			labelAlignment = STD_LABEL_ALIGNMENT;
			tickAlignment = STD_TICK_ALIGNMENT;
			
			_arrow = new SimpleArrow(_ticksize, _ticksize / 2, SimpleArrow.STYLE_1);
			
			gap = STD_GAP;
			
			hiddenLabels = new Array();
			
			calculateTicksAndSubTicks();
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		/**
		 * Define o intervalo de valores do eixo.
		 * @param	ymin - O limite inferior do intervalo que o eixo representa (deve ser menor que <source>ymax</source>)
		 * @param	ymax - O limite superior do intervalo que o eixo representa (deve ser maior que <source>ymin</source>)
		 */
		public function setRange (ymin:Number, ymax:Number) : void {
			
			if (ymax <= ymin) throw new Error("ymin must be greater than ymax.");
			
			_ymin = ymin;
			_ymax = ymax;
			
			// Calcula a distância entre traços e sub-traços
			if (!userDefinedTicks) {
				_dticks = Math.pow(10, Math.floor(Math.log(_ymax - _ymin) / Math.LN10));
				_dsubticks = _dticks / 2;
			}
			
			// Por padrão, o ponto-de-referência deste DisplayObject fica sobre o limite inferior do eixo
			registration = _ymin;
			
			// Duas coordenadas cuja separação é menor que eps são consideradas como iguais
			eps = (_ymax - _ymin) / 1000;
			
			// Define as coordenadas dos traços e sub-traços do eixo
			calculateTicksAndSubTicks();
			
			redraw = true;
		}
		
		/**
		 * Define o limite inferior do eixo.
		 * @param	ymin - O limite inferior do eixo.
		 */
		public function set ymin (ymin:Number) : void {
			setRange(ymin, _ymax);
		}
		
		/**
		 * Retorna o limite inferior do eixo.
		 */
		public function get ymin () : Number {
			return _ymin;
		}
		
		/**
		 * Define o limite superior do eixo.
		 * @param	ymax - O limite superior do eixo.
		 */
		public function set ymax (ymax:Number) : void {
			setRange(_ymin, ymax);
		}
		
		/**
		 * Retorna o limite superior do eixo.
		 */
		public function get ymax () : Number {
			return _ymax;
		}
		
		/**
		 * Define o tamanho do eixo, em pixels.
		 * @param	size - O tamanho do eixo, em pixels.
		 */
		public function set size (size:Number) : void {
			if (size <= 0) throw new Error("The size of the axis must be greater than zero.");
			
			_size = size;
			redraw = true;
		}
		
		/**
		 * Retorna o tamanho do eixo, em pixels.
		 */
		public function get size () : Number {
			return _size;
		}
		
		/**
		 * Define a espessura dos traços do eixo.
		 * @param	thickness - A espessura dos traços do eixo, em pixels.
		 */
		public function set thickness (thickness:Number) : void {
			if (thickness > 0) {
				_thickness = thickness;
				redraw = true;
			}
			//else throw new Error("The thickness must be greater than zero.");
		}
		
		/**
		 * Retorna a espessura do eixo.
		 */
		public function get thickness () : Number {
			return _thickness;
		}
		
		/**
		 * Define a cor do eixo.
		 * @param	color - A cor do eixo.
		 */
		public function set color (color:int) : void {
			_color = color;
			if (!userDefinedLabelFormat) _labelFormat.color = color;
			redraw = true;
		}
		
		/**
		 * Retorna a cor do eixo.
		 */
		public function get color () : int {
			return _color;
		}
		
		/**
		 * Exibe/oculta os tiques do eixo.
		 */
		public function get noticks () : Boolean {
			return _noticks;
		}
		
		/**
		 * @private
		 */
		public function set noticks (noticks:Boolean) : void {
			if (noticks != _noticks) {
				_noticks = noticks;
				redraw = true;
			}
		}
		
		/**
		 * Define o tamanho dos traços do eixo. Os sub-traços têm metade do tamanho do traço.
		 * @param	size - O tamanho, em pixels.
		 */
		public function set ticksize (size:Number) : void {
			if (size > 0) {
				_ticksize = size;
				redraw = true;
			}
			//else throw new Error ("The tick size must be greater than zero.");
		}
		
		/**
		 * Retorna o tamanho dos traços do eixo.
		 */
		public function get ticksize () : Number {
			return _ticksize;
		}
		
		/**
		 * Define a distância entre dois traços consecutivos, em unidades do eixo
		 * @param	dticks - A distância entre dois traços consecutivos.
		 */
		public function set dticks (dticks:Number) : void {
			if (dticks > 0 && dticks <= _ymax - _ymin) {
				_dticks = dticks;
				userDefinedTicks = true;
				calculateTicksAndSubTicks();
				redraw = true;
			}
			//else throw new Error("The distance between ticks must be greater than zero and smaller than or equal to the axis range.");
		}
		
		/**
		 * Retorna a distância entre dois traços consecutivos, em unidades do eixo.
		 */
		public function get dticks () : Number {
			return _dticks;
		}
		
		/**
		 * Retorna o conjunto de coordenadas dos traços do eixo. Por exemplo, num eixo [0,3] com sub-traços distantes de 1 unidade um do outro,
		 * este método retornaria o vetor [0, 0.5, 1, 1.5, 2].
		 */
		public function get ticks () : Array {
			return _ticks;
		}
		
		/**
		 * Define a distância entre dois sub-traços consecutivos, em unidades do eixo.
		 * @param	dsubticks - A distância entre dois sub-traços consecutivos, em unidades do eixo (deve ser maior que zero e menor que a distância entre traços).
		 */
		public function set dsubticks (dsubticks:Number) : void {
			if (dsubticks > 0 && dsubticks < _dticks) {
				_dsubticks = dsubticks;
				userDefinedTicks = true;
				calculateTicksAndSubTicks();
				redraw = true;
			}
			//else throw new Error ("The distance between sub-ticks must be greater than zero and smaller than the distance between ticks.");
		}
		
		/**
		 * Retorna a distância entre dois sub-traços consecutivos.
		 */
		public function get dsubticks () : Number {
			return _dsubticks;
		}
		
		/**
		 * Retorna o conjunto de coordenadas dos sub-traços do eixo. Por exemplo, num eixo [0,3] com sub-traços distantes de 0,5 um do outro,
		 * este método retornaria o vetor [0, 0.5, 1, 1.5, 2].
		 */
		public function get subticks () : Array {
			return _subticks;
		}
		
		/**
		 * Define traços personalizados no gráfico.
		 * @param	ticks - Matriz n x 2 contendo n coordenadas (primeira coluna) e seus respectivos rótulos (segunda coluna).
		 * Exemplo:
		 *   var axis:AxisY = new AxisY(...);
		 *   axis.userTicks = [[1, "y = 1"], [3, "y = 2"], [3, "y = 3"]];
		 */
		// TODO: estender os tipos aceitáveis na segunda coluna da matriz: além de String, pode ser Number, int, DisplayObject etc
		// TODO: remover pontos fora do intervalo do eixo
		public function set userTicks (ticks:Array) : void {
			if (ticks != null) {
				for (var i:uint = 0; i < ticks.length; i++) {
					if (!inRange(ticks[i][0])) continue;
					else if (!(ticks[i][0] is Number && ticks[i][1] is String)) throw new Error ("Incompatible user-ticks array ignored. See documents for details.");
				}
			}
			
			_userticks = ticks;
			redraw = true;
		}
		
		/**
		 * Define a posição dos traços do eixo:
		 * @param	alignment - TICKS_ABOVE (acima do eixo), TICKS_CENTER (centralizado) ou TICKS_BELOW (abaixo).
		 */
		public function set tickAlignment (alignment:String) : void {
			if (alignment == TICKS_LEFT ) {
				_tickalignment = TICKS_LEFT;
				tickposition = 0;
				redraw = true;
			}
			else if (alignment == TICKS_CENTER) {
				_tickalignment = TICKS_CENTER;
				tickposition = 1;
				redraw = true;
			}
			else if (alignment == TICKS_RIGHT) {
				_tickalignment = TICKS_RIGHT;
				tickposition = 2;
				redraw = true;
			}
			//else throw new Error("Unknown tick position. Use AxisY.TICKS_LEFT, AxisY.TICKS_CENTER or AxisY.TICKS_RIGHT.");
		}
		
		/**
		 * Retorna a posição dos traços do eixo:
		 * @return TICKS_LEFT (à esquerda do eixo), TICKS_CENTER (centralizado) ou TICK_RIGHT (à direita)
		 */
		public function get tickAlignment () : String {
			return _tickalignment;
		}
		
		/**
		 * Define o formato de texto dos rótulos.
		 * @param	format - O formato de texto dos rótulos.
		 */
		public function set labelFormat (format:TextFormat) : void {
			_labelFormat = format;
			userDefinedLabelFormat = true;
			redraw = true;
		}
		
		/**
		 * Retorna o formato de texto dos rótulos.
		 */
		public function get labelFormat () : TextFormat {
			return _labelFormat;
		}
		
		/**
		 * Esconde o rótulo associado ao traço na coordenada y.
		 * @param	y - A coordenada do traço cujo rótulo se quer ocultar. Caso esta coordenada não corresponda a nenhum traço, o pedido é ignorado.
		 */
		public function hideLabelAt (y:Number) : void {
			hiddenLabels.push(y);
		}
		
		/**
		 * Reapresenta todos os rótulos ocultos.
		 */
		public function resetHiddenLabels () : void {
			hiddenLabels = new Array();
		}
		
		/**
		 * Define a posição dos rótulos.
		 * @param	position - LABEL_LEFT (à esquerda do eixo) ou LABEL_RIGHT (à direita).
		 */
		public function set labelAlignment (position:String) : void {
			if (position == LABEL_LEFT) {
				labelRight = false;
				redraw = true;
			}
			else if (position == LABEL_RIGHT) {
				labelRight = true;
				redraw = true;
			}
			//else throw new Error("Unknown label position. Use AxisY.LABEL_LEFT or AxisY.LABEL_RIGHT.");
		}
		
		/**
		 * Retorna a posição dos rótulos do eixo:
		 * @return LABEL_LEFT (à esquerda do eixo) ou LABEL_RIGHT (à direita).
		 */
		public function get labelAlignment () : String {
			if (labelRight) return LABEL_RIGHT;
			else return LABEL_LEFT;
		}
		
		/**
		 * Define a distância entre o traço e seu rótulo
		 * @param	distance - A distância entre o traço e seu rótulo, em pixels.
		 */
		public function set gap (distance:Number) : void {
			if (distance > 0) {
				_gap = distance;
				redraw = true;
			}
			//else throw new Error ("The distance between a tick and its label must be greater than zero.");
		}
		
		/**
		 * Retorna a distância entre o traço e seu rótulo, em pixels.
		 */
		public function get gap () : Number {
			return _gap;
		}
		
		/**
		 * Define a flecha a ser colocada na extrema direita do eixo.
		 * @param	arrow - A flecha a ser colocada na extrema direita do eixo.
		 */
		public function set arrow (arrow:Sprite) : void {
			_arrow = arrow;
			userDefinedArrow = true;
			redraw = true;
		}
		
		/**
		 * Retorna a flecha utilizada para indicar a orientação do eixo.
		 */
		public function get arrow () : Sprite {
			return _arrow;
		}
		
		/**
		 * Define o ponto do eixo associado à coordenada (0,0) do DisplayObject (em pixels). Por exemplo,
		 * <source>
		 *	 var axis:AxisY = new AxisY(0,1,100);
		 *	 axis.registration = 0.5;
		 *	 axis.y = 80;
		 * </source>
		 * Neste exemplo o ponto y = 0.5 DO EIXO ficará na posição y = 80 pixels DO PALCO.
		 * 
		 * @param	registration - O ponto que ficará sobre a coordenada (0,0) do DisplayObject.
		 */
		public function set registration (registration:Number) : void {
			_registration = registration;
			redraw = true;
		}
		
		/**
		 * Retorna o ponto do eixo associado à coordenada (0,0) do DisplayObject (em pixels).
		 */
		public function get registration () : Number {
			return _registration;
		}
		
		/**
		 * Retorna a coordenada <source>py</source> do DisplayObject (em pixel) associada à coordenada <source>y</source> do gráfico.
		 * @param	y - A coordenada do gráfico
		 * @return	py - A coordenada do DisplayObject
		 */
		public function y2pixel (y:Number) : Number {
			return _size * (_registration - y) / (_ymax - _ymin);
		}
		
		/**
		 * Retorna a coordenada <source>y</source> do gráfico associado à coordenada <source>py</source> do DisplayObject (em pixel).
		 * @param	py - A coordenada do DisplayObject
		 * @return	y - A coordenada do gráfico
		 */
		public function pixel2y (py:Number) : Number {
			return _registration - py * (_ymax - _ymin) / _size;
		}
		
		/*
		 * Desenha o eixo e seus elementos 
		 */
		public function draw () : void {
			
			if (!redraw) return;
			
			// Pré-configuração
			//-----------------------------------------
			while (numChildren > 0) removeChildAt(0);
			
			var y1:Number = _ticksize * (tickposition / 2 - 1); // TODO: colocar isso apenas onde altera _ticksize e _tickposition
			var ncasas:Number = Math.floor(Math.log(_dticks) / Math.LN10);
			ncasas = ncasas >= 0 ? 0 : -ncasas;
			
			var ylimit:Number = _ymax + (_arrow == null ? 0 : pixel2y(_arrow.height) - pixel2y(0));
			
			graphics.clear();
			graphics.lineStyle(_thickness, _color, 1, false, LineScaleMode.NONE);
			
			// Desenha o eixo
			//-----------------------------------------
			graphics.moveTo(0, y2pixel(_ymin));
			graphics.lineTo(0, y2pixel(_ymax));
			
			if (!noticks) {
				
				// Desenha os traços e seus rótulos
				//-----------------------------------------
				for each (var t:Number in _ticks) {
					if (t < ylimit) {
						// Desenha o traço do eixo
						graphics.moveTo(y1, y2pixel(t));
						graphics.lineTo(y1 + _ticksize, y2pixel(t));
						
						// Se este traço estiver assocido a um rótulo oculto, não adiciona o rótulo ao eixo
						if (isHiddenLabel(t)) continue;
						
						// Adiciona o rótulo do traço
						var label:TextField = new TextField();
						label.defaultTextFormat = _labelFormat;
						label.text = (ncasas > 0 ? t.toFixed(ncasas) : t.toString()).replace(".", ",");
						label.selectable = false;
						label.autoSize = TextFieldAutoSize.CENTER;
						label.background = false;
						label.y = y2pixel(t) - label.height / 2;
						label.x = y1 + (labelRight ? +1 : -1) * (_gap + (labelRight ? _ticksize : label.width));
						if (label.y >= y2pixel(_ymax) && label.y + label.height <= y2pixel(_ymin)) addChild(label);
					}
				}
				
				// Desenha os sub-traços
				//-----------------------------------------
				for each (t in _subticks) {
					if (t < ylimit) {
						graphics.moveTo(y1 / 2, y2pixel(t));
						graphics.lineTo(y1 / 2 + _ticksize / 2, y2pixel(t));
					}
				}
				
				// Desenha os traços/rótulos personalizados
				//-----------------------------------------
				for each (var tick:Array in _userticks) {
					
					t = tick[0];
					
					if (inRange(t)) {
						// Desenha o traço do eixo
						graphics.moveTo(y2pixel(t), y1);
						graphics.lineTo(y2pixel(t), y1 + _ticksize);
						
						// Adiciona o rótulo do traço
						label = new TextField();
						label.defaultTextFormat = _labelFormat;
						label.text = tick[1];
						label.selectable = false;
						label.autoSize = TextFieldAutoSize.CENTER;
						label.background = true;
						label.x = y2pixel(t) - label.width / 2;
						label.y = y1 + (labelRight ? +1 : -1) * (_gap + (labelRight ? _ticksize : label.height));
						if (label.y >= y2pixel(_ymax) && label.y + label.height <= y2pixel(_ymin)) addChild(label);
					}
				}
			}
			
			// Desenha a seta
			//-----------------------------------------
			if (_arrow != null) {
				_arrow.x = 0;
				_arrow.y = y2pixel(_ymax);
				_arrow.rotation = -90;
				
				if (_arrow is SimpleArrow && !userDefinedArrow) {
					(_arrow as SimpleArrow).color = _color;
					(_arrow as SimpleArrow).thickness = _thickness;
				}
				
				addChild(_arrow);
			}
			
			redraw = false;
		}
		
		/**
		 * Informa se a coordenada y está dentro do intervalo representado pelo eixo.
		 * @param	y - A coordenada.
		 * @return	<source>true</source> se y pertence ao intervalo do eixo; <source>false</source> em caso contrário.
		 */
		public function inRange (y:Number) : Boolean {
			return y >= _ymin && y <= _ymax;
		}
		
		/*
		 * Configurações iniciais que dependem de esta classe já ter sido adicionada à lista de exibição.
		 */
		private function init (event:Event = null) : void {
			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// Desenha o eixo
			draw();
		}
		
		/*
		 * Informa se a coordenada y faz parte da lista de rótulos que não devem ser apresentados.
		 * Retorna true em caso positivo ou false em caso contrário.
		 */
		private function isHiddenLabel (y:Number) : Boolean {
			
			for each (var tmp:Number in hiddenLabels) {
				if (Math.abs(y - tmp) < eps) return true;
			}
			
			return false;
		}
		
		/*
		 * Define a posição de cada traço e sub-traço do gráfico.
		 */
		private function calculateTicksAndSubTicks () : void {
			
			_ticks = new Array();
			_subticks = new Array();
			
			var aux:Number = Math.floor(Math.log(_dticks) / Math.LN10);
			aux = new Number(_ymin.toFixed(aux >= 0 ? 0 : -aux));
			
			// Calcula a posição de cada traço
			var t:Number;
			if (_ymin * _ymax > 0) t = aux + _dticks * Math.ceil((_ymin - aux) / _dticks);
			else t = - _dticks * Math.floor(Math.abs(_ymin) / _dticks);
			
			do {
				_ticks.push(t);
				t += dticks;
			} while (t <= ymax + eps);
		
			// Calcula a posição de cada sub-traço
			t = _ticks[0] - _dsubticks * Math.floor((_ticks[0] - _ymin) / _dsubticks);
			
			do {
				_subticks.push(t);
				t += dsubticks;
			} while (t < ymax + eps);
		}
	}
}