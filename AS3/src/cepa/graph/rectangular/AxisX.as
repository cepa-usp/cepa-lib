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
	
	public class AxisX extends Sprite {
		
		public static const LABEL_BELOW  :String = "LABEL_BELOW";
		public static const LABEL_ABOVE  :String = "LABEL_ABOVE";
		public static const TICKS_ABOVE  :String = "TICKS_ABOVE";
		public static const TICKS_CENTER :String = "TICKS_CENTER";
		public static const TICKS_BELOW  :String = "TICKS_BELOW";
		
		private static const STD_TICK_SIZE:Number = 10;
		private static const STD_TICK_ALIGNMENT:String = TICKS_ABOVE;
		private static const STD_LABEL_ALIGNMENT:String = LABEL_BELOW;
		private static const STD_LABEL_FORMAT:TextFormat = new TextFormat("Arial", 1.2 * STD_TICK_SIZE);
		private static const STD_COLOR:int = 0x000000;
		private static const STD_THICKNESS:Number = 1;
		private static const STD_GAP:Number = 0.2 * STD_TICK_SIZE;
		
		private var _xmin:Number; // Limite inferior do eixo
		private var _xmax:Number; // Limite superior do eixo
		private var _size:Number; // O tamanho do eixo, em pixels
		private var _registration:Number; // A coordenada associada ao ponto x = 0 deste DisplayObject		
		private var _thickness:Number; // A espessura do eixo, em pixel
		private var _color:Number; // A cor do eixo
		private var _ticksize:Number; // O tamanho dos tra�os
		private var _dticks:Number; // A dist�ncia entre dois tra�os consecutivos, em unidades do eixo
		private var _dsubticks:Number; // A dist�ncia entre dois sub-tra�os consecutivos, em unidades do eixo
		private var _labelFormat:TextFormat; // O formato dos r�tulos dos tra�os
		private var _gap:Number; // A dist�ncia entre o tra�o e seu respectivo r�tulo
		private var _tickalignment:String; // O alinhamento dos tra�os: acima do eixo, centralizado ou abaixo dele
		private var _arrow:Sprite; // A flecha que indica a orienta��o do eixo
		private var _ticks:Array; // As coordenadas dos tra�os do eixo
		private var _subticks:Array; // As coordenadas dos sub-tra�os do eixo
		private var _userticks:Array; // As coordenadas e r�tulos personalizados pelo usu�rio
		private var _noticks:Boolean; // Identifica se os tiques do eixo devem ser desenhados ou n�o
		
		private var tickposition:int; // A posi��o dos tra�os: acima, centralizado ou abaixo do eixo
		private var labelBelow:Boolean; // Indica se os r�tulos ficam abaixo ou acima do eixo
		private var userDefinedLabelFormat:Boolean = false; // Indica se o usu�rio alterou o formato de texto dos r�tulos
		private var userDefinedTicks:Boolean = false; // Indica se o usu�rio alterou a dist�ncia entre tra�os/sub-tra�os
		private var userDefinedArrow:Boolean = false; // Indica se o usu�rio alterou a flecha do eixo
		private var hiddenLabels:Array; // Conjunto de r�tulos escondidos
		private var eps:Number; // Quaisquer duas coordenadas cuja diferen�a � menor que eps s�o consideradas como equivalentes
		private var redraw:Boolean = true; // Idenfica se � preciso redesenhar o objeto desta classe
		
		/**
		 * Cria um eixo horizontal
		 * @param	xmin - O limite inferior do intervalo que o eixo representa (deve ser menor que <source>xmax</source>)
		 * @param	xmax - O limite superior do intervalo que o eixo representa (deve ser maior que <source>xmin</source>)
		 * @param	size - O tamanho do eixo, em pixels.
		 */
		public function AxisX (xmin:Number, xmax:Number, size:Number) {
			setRange(xmin, xmax);
			this.size = size;
			
			_thickness = STD_THICKNESS;
			_color = STD_COLOR;
			_ticksize = STD_TICK_SIZE;
			_labelFormat = STD_LABEL_FORMAT;
			labelAlignment = STD_LABEL_ALIGNMENT;
			tickAlignment = STD_TICK_ALIGNMENT;
			
			_arrow = new SimpleArrow(_ticksize, _ticksize / 2, SimpleArrow.STYLE_1);
			_noticks = false;
			
			gap = STD_GAP;
			
			hiddenLabels = new Array();
			
			calculateTicksAndSubTicks();
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		/**
		 * Define o intervalo de valores do eixo.
		 * @param	xmin - O limite inferior do intervalo que o eixo representa (deve ser menor que <source>xmax</source>)
		 * @param	xmax - O limite superior do intervalo que o eixo representa (deve ser maior que <source>xmin</source>)
		 */
		public function setRange (xmin:Number, xmax:Number) : void {
			if (xmax <= xmin) throw new Error("xmin must be greater than xmax.");
			
			_xmin = xmin;
			_xmax = xmax;
			
			// Calcula a dist�ncia entre tra�os e sub-tra�os
			if (!userDefinedTicks) {
				_dticks = Math.pow(10, Math.floor(Math.log(_xmax - _xmin) / Math.LN10));
				_dsubticks = _dticks / 2;
			}
			
			// Por padr�o, o ponto-de-refer�ncia deste DisplayObject fica sobre o limite inferior do eixo
			registration = _xmin; // TODO: n�o fazer isso se o usu�rio alterou o atributo registration
			
			// Duas coordenadas cuja separa��o � menor que eps s�o consideradas como iguais
			eps = (_xmax - _xmin) / 1000;
			
			// Define as coordenadas dos tra�os e sub-tra�os do eixo
			calculateTicksAndSubTicks();
			
			redraw = true;
		}
		
		/**
		 * Define o limite inferior do eixo.
		 * @param	xmin - O limite inferior do eixo.
		 */
		public function set xmin (xmin:Number) : void {
			if (_xmax <= xmin) throw new Error ("xmin must be grater than xmax.");
			
			_xmin = xmin;
			redraw = true;
		}
		
		/**
		 * Retorna o limite inferior do eixo.
		 */
		public function get xmin () : Number {
			return _xmin;
		}
		
		/**
		 * Define o limite superior do eixo.
		 * @param	xmax - O limite superior do eixo.
		 */
		public function set xmax (xmax:Number) : void {
			if (xmax <= _xmin) throw new Error ("xmin must be grater than xmax.");
			
			_xmax = xmax;
			redraw = true;
		}
		
		/**
		 * Retorna o limite superior do eixo.
		 */
		public function get xmax () : Number {
			return _xmax;
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
		 * Define a espessura dos tra�os do eixo.
		 * @param	thickness - A espessura dos tra�os do eixo, em pixels.
		 */
		public function set thickness (thickness:Number) : void {
			if (thickness > 0) {
				_thickness = thickness;
				redraw = true;
			}
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
		 * Define o tamanho dos tra�os do eixo. Os sub-tra�os t�m metade do tamanho do tra�o.
		 * @param	size - O tamanho, em pixels.
		 */
		public function set ticksize (size:Number) : void {
			if (size > 0) {
				_ticksize = size;
				redraw = true;
			}
		}
		
		/**
		 * Retorna o tamanho dos tra�os do eixo.
		 */
		public function get ticksize () : Number {
			return _ticksize;
		}
		
		/**
		 * Define a dist�ncia entre dois tra�os consecutivos, em unidades do eixo
		 * @param	dticks - A dist�ncia entre dois tra�os consecutivos.
		 */
		public function set dticks (dticks:Number) : void {
			
			if (dticks > 0 && dticks <= _xmax - _xmin) {
				_dticks = dticks;
				userDefinedTicks = true;
				calculateTicksAndSubTicks();
				redraw = true;
			}
			else trace("'dticks' = " + dticks + " cannot be used.");
		}
		
		/**
		 * Retorna a dist�ncia entre dois tra�os consecutivos, em unidades do eixo.
		 */
		public function get dticks () : Number {
			return _dticks;
		}
		
		/**
		 * Retorna o conjunto de coordenadas dos tra�os do eixo. Por exemplo, num eixo [0,3] com sub-tra�os distantes de 1 unidade um do outro,
		 * este m�todo retornaria o vetor [0, 0.5, 1, 1.5, 2].
		 */
		// TODO: criar o m�todo set ticks
		public function get ticks () : Array {
			return _ticks;
		}
		
		/**
		 * Define a dist�ncia entre dois sub-tra�os consecutivos, em unidades do eixo.
		 * @param	dsubticks - A dist�ncia entre dois sub-tra�os consecutivos, em unidades do eixo (deve ser maior que zero e menor que a dist�ncia entre tra�os).
		 */
		public function set dsubticks (dsubticks:Number) : void {
			if (dsubticks > 0 && dsubticks < _dticks) {
				_dsubticks = dsubticks;
				userDefinedTicks = true;
				calculateTicksAndSubTicks();
				redraw = true;
			}
		}
		
		/**
		 * Retorna a dist�ncia entre dois sub-tra�os consecutivos.
		 */
		public function get dsubticks () : Number {
			return _dsubticks;
		}
		
		/**
		 * Retorna o conjunto de coordenadas dos sub-tra�os do eixo. Por exemplo, num eixo [0,3] com sub-tra�os distantes de 0,5 um do outro,
		 * este m�todo retornaria o vetor [0, 0.5, 1, 1.5, 2].
		 */
		// TODO: criar o m�todo set subticks
		public function get subticks () : Array {
			return _subticks;
		}
		
		/**
		 * Define tra�os personalizados no gr�fico.
		 * @param	ticks - Matriz n x 2 contendo n coordenadas (primeira coluna) e seus respectivos r�tulos (segunda coluna).
		 * Exemplo:
		 *   var axis:AxisX = new AxisX(...);
		 *   axis.userTicks = [[1, "x = 1"], [3, "x = 2"], [3, "x = 3 (raiz)"]];
		 */
		// TODO: estender os tipos aceit�veis na segunda coluna da matriz: al�m de String, pode ser Number, int, DisplayObject etc
		// TODO: remover pontos fora do intervalo do eixo
		// TODO: escrever o m�todo get associado
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
		 * Define a posi��o dos tra�os do eixo:
		 * @param	alignment - TICKS_ABOVE (acima do eixo), TICKS_CENTER (centralizado) ou TICKS_BELOW (abaixo).
		 */
		public function set tickAlignment (alignment:String) : void {
			if (alignment == TICKS_ABOVE ) {
				_tickalignment = TICKS_ABOVE;
				tickposition = 0;
				redraw = true;
			}
			else if (alignment == TICKS_CENTER) {
				_tickalignment = TICKS_CENTER;
				tickposition = 1;
				redraw = true;
			}
			else if (alignment == TICKS_BELOW) {
				_tickalignment = TICKS_BELOW;
				tickposition = 2;
				redraw = true;
			}
			//else throw new Error("Unknown tick position. Use AxisX.TICKS_ABOVE, AxisX.TICKS_CENTER or AxisX.TICKS_BELOW.");
		}
		
		/**
		 * Retorna a posi��o dos tra�os do eixo:
		 * @return TICKS_ABOVE (acima do eixo), TICKS_CENTER (centralizado) ou TICK_BELOW (abaixo)
		 */
		public function get tickAlignment () : String {
			return _tickalignment;
		}
		
		/**
		 * Define o formato de texto dos r�tulos.
		 * @param	format - O formato de texto dos r�tulos.
		 */
		public function set labelFormat (format:TextFormat) : void {
			_labelFormat = format;
			userDefinedLabelFormat = true;
			redraw = true;
		}
		
		/**
		 * Retorna o formato de texto dos r�tulos.
		 */
		public function get labelFormat () : TextFormat {
			return _labelFormat;
		}
		
		/**
		 * Esconde o r�tulo associado ao tra�o na coordenada x.
		 * @param	x - A coordenada do tra�o cujo r�tulo se quer ocultar. Caso esta coordenada n�o corresponda a nenhum tra�o, o pedido � ignorado.
		 */
		public function hideLabelAt (x:Number) : void {
			hiddenLabels.push(x);
			redraw = true;
		}
		
		/**
		 * Reapresenta todos os r�tulos ocultos.
		 */
		public function resetHiddenLabels () : void {
			hiddenLabels = new Array();
			redraw = true;
		}
		
		/**
		 * Define a posi��o dos r�tulos.
		 * @param	position - LABEL_BELOW (abaixo do eixo) ou LABEL_ABOVE (acima).
		 */
		public function set labelAlignment (position:String) : void {
			if (position == LABEL_BELOW) {
				labelBelow = true;
				redraw = true;
			}
			else if (position == LABEL_ABOVE) {
				labelBelow = false;
				redraw = true;
			}
			//else throw new Error("Unknown label position. Use AxisX.LABEL_BELOW or AxisX.LABEL_ABOVE.");
		}
		
		/**
		 * Retorna a posi��o dos r�tulos do eixo:
		 * @return LABEL_ABOVE (acima do eixo) ou LABEL_BELOW (abaixo).
		 */
		public function get labelAlignment () : String {
			if (labelBelow) return LABEL_BELOW;
			else return LABEL_ABOVE;
		}
		
		/**
		 * Define a dist�ncia entre o tra�o e seu r�tulo
		 * @param	distance - A dist�ncia entre o tra�o e seu r�tulo, em pixels.
		 */
		public function set gap (distance:Number) : void {
			if (distance > 0) {
				_gap = distance;
				redraw = true;
			}
			//else throw new Error ("The distance between a tick and its label must be greater than zero.");
		}
		
		/**
		 * Retorna a dist�ncia entre o tra�o e seu r�tulo, em pixels.
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
		 * Retorna a flecha utilizada para indicar a orienta��o do eixo.
		 */
		public function get arrow () : Sprite {
			return _arrow;
		}
		
		/**
		 * Define o ponto do eixo associado � coordenada (0,0) do DisplayObject (em pixels). Por exemplo,
		 * <source>
		 *	 var axis:AxisX = new AxisX(0,1,100);
		 *	 axis.registration = 0.5;
		 *	 axis.x = 80;
		 * </source>
		 * Neste exemplo o ponto x = 0.5 DO EIXO ficar� na posi��o x = 80 pixels DO PALCO.
		 * 
		 * @param	registration - O ponto que ficar� sobre a coordenada (0,0) do DisplayObject.
		 */
		public function set registration (registration:Number) : void {
			_registration = registration;
			redraw = true;
		}
		
		/**
		 * Retorna o ponto do eixo associado � coordenada (0,0) do DisplayObject (em pixels).
		 */
		public function get registration () : Number {
			return _registration;
		}
		
		/**
		 * Retorna a coordenada <source>px</source> do DisplayObject (em pixel) associada � coordenada <source>x</source> do gr�fico.
		 * @param	x - A coordenada do gr�fico
		 * @return	px - A coordenada do DisplayObject
		 */
		public function x2pixel (x:Number) : Number {
			return _size * (x - _registration) / (_xmax - _xmin);
		}
		
		/**
		 * Retorna a coordenada <source>x</source> do gr�fico associado � coordenada <source>px</source> do DisplayObject (em pixel).
		 * @param	px - A coordenada do DisplayObject
		 * @return	x - A coordenada do gr�fico
		 */
		public function pixel2x (px:Number) : Number {
			return _registration + px * (_xmax - _xmin) / _size;
		}
		
		/*
		 * Desenha o eixo e seus elementos 
		 */
		public function draw (event:Event = null) : void {
			
			if (!redraw) return;
			
			// Pr�-configura��o
			//-----------------------------------------
			while (numChildren > 0) removeChildAt(0);
			
			var y1:Number = _ticksize * (tickposition / 2 - 1); // TODO: colocar isso apenas onde altera _ticksize e _tickposition
			var ncasas:Number = Math.floor(Math.log(_dticks) / Math.LN10);
			ncasas = ncasas >= 0 ? 0 : -ncasas;
			
			var xlimit:Number = _xmax - (_arrow == null ? 0 : pixel2x(_arrow.width) - pixel2x(0));
			
			graphics.clear();
			graphics.lineStyle(_thickness, _color, 1, false, LineScaleMode.NONE);
			
			// Desenha o eixo
			//-----------------------------------------
			graphics.moveTo(x2pixel(_xmin), 0);
			graphics.lineTo(x2pixel(_xmax), 0);
			
			if (!noticks) {
				
				// Desenha os tra�os e seus r�tulos
				//-----------------------------------------
				for each (var t:Number in _ticks) {
					if (t < xlimit) {
						// Desenha o tra�o do eixo
						graphics.moveTo(x2pixel(t), y1);
						graphics.lineTo(x2pixel(t), y1 + _ticksize);
						
						// Se este tra�o estiver assocido a um r�tulo oculto, n�o adiciona o r�tulo ao eixo
						if (isHiddenLabel(t)) continue;
						
						// Adiciona o r�tulo do tra�o
						var label:TextField = new TextField();
						label.defaultTextFormat = _labelFormat;
						label.text = (ncasas > 0 ? t.toFixed(ncasas) : t.toString()).replace(".", ",");
						label.selectable = false;
						label.autoSize = TextFieldAutoSize.CENTER;
						label.background = false;
						label.x = x2pixel(t) - label.width / 2;
						label.y = y1 + (labelBelow ? +1 : -1) * (_gap + (labelBelow ? _ticksize : label.height));
						if (label.x >= x2pixel(_xmin) && label.x + label.width <= x2pixel(_xmax)) addChild(label);
					}
				}
				
				// Desenha os sub-tra�os
				//-----------------------------------------
				for each (t in _subticks) {
					if (t < xlimit) {
						graphics.moveTo(x2pixel(t), y1 / 2);
						graphics.lineTo(x2pixel(t), y1 / 2 + _ticksize / 2);
					}
				}
				
				// Desenha os tra�os/r�tulos personalizados
				//-----------------------------------------
				for each (var tick:Array in _userticks) {
					
					t = tick[0];
					
					if (inRange(t)) {
						// Desenha o tra�o do eixo
						graphics.moveTo(x2pixel(t), y1);
						graphics.lineTo(x2pixel(t), y1 + _ticksize);
						
						// Adiciona o r�tulo do tra�o
						label = new TextField();
						label.defaultTextFormat = _labelFormat;
						label.text = tick[1];
						label.selectable = false;
						label.autoSize = TextFieldAutoSize.CENTER;
						label.background = true;
						label.x = x2pixel(t) - label.width / 2;
						label.y = y1 + (labelBelow ? +1 : -1) * (_gap + (labelBelow ? _ticksize : label.height));
						if (label.x >= x2pixel(_xmin) && label.x + label.width <= x2pixel(_xmax)) addChild(label);
					}
				}
			}
			
			// Desenha a seta
			//-----------------------------------------
			if (_arrow != null) {
				_arrow.x = x2pixel(_xmax);
				_arrow.y = 0;
				
				if (_arrow is SimpleArrow && !userDefinedArrow) {
					(_arrow as SimpleArrow).color = _color;
					(_arrow as SimpleArrow).thickness = _thickness;
				}
				
				addChild(_arrow);
			}
			
			redraw = false;
		}
		
		/**
		 * Informa se a coordenada x est� dentro do intervalo representado pelo eixo.
		 * @param	x - A coordenada.
		 * @return	<source>true</source> se x pertence ao intervalo do eixo; <source>false</source> em caso contr�rio.
		 */
		public function inRange (x:Number) : Boolean {
			return x >= _xmin && x <= _xmax;
		}
		
		/*
		 * Configura��es iniciais que dependem de esta classe j� ter sido adicionada � lista de exibi��o.
		 */
		private function init (event:Event = null) : void {
			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// Desenha o eixo
			draw();
		}
		
		/*
		 * Informa se a coordenada x faz parte da lista de r�tulos que n�o devem ser apresentados.
		 * Retorna true em caso positivo ou false em caso contr�rio.
		 */
		private function isHiddenLabel (x:Number) : Boolean {
			
			for each (var tmp:Number in hiddenLabels) {
				if (Math.abs(x - tmp) < eps) return true;
			}
			
			return false;
		}
		
		/*
		 * Define a posi��o de cada tra�o e sub-tra�o do gr�fico.
		 */
		private function calculateTicksAndSubTicks () : void {
			
			_ticks = new Array();
			_subticks = new Array();
			
			var aux:Number = Math.floor(Math.log(_dticks) / Math.LN10);
			aux = new Number(_xmin.toFixed(aux >= 0 ? 0 : -aux));
			
			// Calcula a posi��o de cada tra�o			
			var t:Number;
			if (_xmin * _xmax > 0) t = aux + _dticks * Math.ceil((_xmin - aux) / _dticks);
			else t = - _dticks * Math.floor(Math.abs(_xmin) / _dticks);
			
			do {
				_ticks.push(t);
				t += dticks;
			} while (t < _xmax + eps);
		
			// Calcula a posi��o de cada sub-tra�o
			t = _ticks[0] - _dsubticks * Math.floor((_ticks[0] - _xmin) / _dsubticks);
			
			do {
				_subticks.push(t);
				t += dsubticks;
			} while (t < _xmax + eps);
		}
	}
}