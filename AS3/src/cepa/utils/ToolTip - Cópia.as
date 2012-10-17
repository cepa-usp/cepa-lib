package cepa.utils
{	
	import fl.transitions.easing.Strong;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.accessibility.AccessibilityProperties;
	import flash.accessibility.Accessibility;
	import flash.text.TextFormat;
	
	/**
	 * TOOLTIP CEPA
	 * @author CEPA
	 * @version 1.0
	 */
	public class  ToolTip extends Sprite
	{
		public static const DISTANCE = 15; //	ESPAÇAMENTO DE BORDA PARA LIMITAR O TOOLTIP
		
		private var _text:String;
		private var _textSize:uint;
		private var _color:uint;
		private var _alpha:Number;
		private var _font:String;
		private var _boxSize:uint;
		private var _box:Sprite;
		private var _object:DisplayObject;// = new Object();
		private var _alphaTween:Tween;
		private var _bottom:int; // 	LADO DE BAIXO DO QUADRADO (FORMA DO TOOLTIP)
		private var _right:int; //		LADO DIREITO DO QUADRADO (FORMA DO TOOLTIP)
		private var invert:Boolean = false; //	SE VERDADEIRO O TOOLTIP ESTÁ NA POSIÇÃO SUPERIOR ESQUERDA DO CURSOR. SE FALSO ESTÁ NA POSIÇÃO INFERIOR DIREITA.
		private var _visible:Boolean = false; //	VISIBILIDADE DO TOOLTIP
		private var _timeToShow:Number;
		private var _timeToHide:Number;
		/**
		 * MÉTODO CONSTRUTOR
		 * 
		 * @param	object : OBJETO QUE ATIVA O APARECIMENTO DO TOOLTIP CASO O CURSOR REPOUSE SOBRE ELE
		 * @param	text : TEXTO QUE APARECE DENTRO DO TOOLTIP
		 * @param	textSize : TAMANHO DA FONTE DO 'text'
		 * @param	alpha : ALFA DO TOOLTIP
		 * @param	boxSize : LARGURA MÁXIMA DO TOOLTIP. QUANDO FOR ATINGIDA, O TEXTO TERÁ MULTIPLAS LINHAS
		 * @param	font : FONTE DO TEXTO
		 * @param	color : COR DA CAIXA DO TOOLTIP
		 */

		public function ToolTip (object:DisplayObject , text:String = "tooltip default", textSize:uint = 10, alpha:Number = 0.8, boxSize:uint = 100 , timeToShow:Number = 2, timeToHide:Number = 2, font:String = "Arial", color:uint = 0xF2F200) 
		{
			_text = text;
			_textSize = textSize;
			_boxSize = boxSize;
			_color = color;
			_alpha = alpha;
			_font = font;
			_object = object;
			_timeToShow = timeToShow;
			_timeToHide = timeToHide;
			
			draw();
			this.alpha = 0;
			this.visible = false;
			
			
			_object.addEventListener(MouseEvent.MOUSE_OVER, show);
			_object.addEventListener(MouseEvent.MOUSE_OUT, hide);
			
			//O TOOLTIP NÃO VAI APARECER QUANDO O USUÁRIO CLICAR NO BOTÃO
			_object.addEventListener(MouseEvent.MOUSE_DOWN, click);
			_object.accessibilityProperties =  new AccessibilityProperties();
			_object.accessibilityProperties.description = text;
			
			
		}
		
		/**
		 * ESSA FUNÇÃO APENAS ESCONDE O TOOLTIP QUANDO O USUÁRIO CLICA NO BOTÃO
		 * @param	e : EVENTO DO MOUSE
		 */
		private function click(e:MouseEvent):void {
			hide(null);
		}
		
		/**
		 * MÉTODO QUE DESENHA O TOOLTIP
		 */
		private function draw():void 
		{
			var textField:TextField = new TextField();			
			
			var textFormat:TextFormat = new TextFormat();
			var shadow:DropShadowFilter = new DropShadowFilter(4, 45, 0x000000, 0.3);
			
			textFormat.font = _font;
			textFormat.size = _textSize;
			textFormat.color = 0x000000;
			
			textField.backgroundColor = 0xFF0000;
			textField.selectable = false;
			textField.defaultTextFormat = textFormat;
			textField.autoSize = TextFieldAutoSize.CENTER;
			textField.text = _text;
			
			if (textField.textWidth + 5 < _boxSize) {
				textField.width = textField.textWidth + 5;
			}
			else textField.width = _boxSize;
			
			textField.wordWrap = true;
			
			_box = new Sprite();
			
			_box.graphics.beginFill(_color, 1);
			_box.graphics.drawRoundRect(0, 0, textField.width, textField.height, 10, 10);
			_box.graphics.endFill();
			
			textField.x = 0;
			textField.y = 0;
			
			_box.addChild(textField);
			addChild(_box);

			_box.filters = [shadow];
		}
		
		/**
		 * MÉTODO QUE TORNA O TOOLTIP VISÍVEL
		 * @param	e : EVENTO DO MOUSE
		 */
		private function show (e:MouseEvent) : void
		{
			stage.addChild(this);
			this.visible = true;
			_visible = true;
			moving(null);
			visible = true;
			calcPosition();

			_alphaTween = new Tween(this, "alpha", Strong.easeIn, 0, _alpha, _timeToShow, true);
			_object.addEventListener(MouseEvent.MOUSE_MOVE, moving);
		}
		
		/**
		 * MÉTODO QUE TORNA O TOOLTIP INVISÍVEL
		 * @param	e : EVENTO DO MOUSE
		 */
		private function hide (e:MouseEvent) : void
		{
			_visible = false;
			_alphaTween.stop();
			_alphaTween = new Tween(this, "alpha", Strong.easeOut, this.alpha, 0, _timeToHide, true);
			_alphaTween.addEventListener(TweenEvent.MOTION_FINISH, function (e:TweenEvent) : void {
				visible = _visible;
				this.visible = false;
			});
			_object.removeEventListener(MouseEvent.MOUSE_MOVE, moving);	
		}
		
		/**
		 * MÉTODO QUE MOVE O TOOLTIP DE ACORDO COM O MOVIMENTO DO CURSOR
		 * @param	e : EVENTO DO MOUSE
		 */
		private function moving (e:MouseEvent) : void
		{
			if (!invert) {
				x = stage.mouseX + DISTANCE;
				y = stage.mouseY + DISTANCE;
			}
			else {
				this.x = stage.mouseX - this.width - DISTANCE;
				this.y = stage.mouseY - this.height - DISTANCE;
			}
			
			calcPosition();
		}
		
		/**
		 * MÉTODO QUE CALCULA OS LIMITES DE DESLOCAMENTO DO TOOLTIP, CRIANDO UMA BORDA COM AS DIMENSÕES DO PALCO
		 * MENOS UM ESPAÇAMENTO 'DISTANCE'. O BOOLEANO 'invert' PODE SER ALTERADO CASO O TOOLTIP ESTEJA MUITO 
		 * PRÓXIMO DO CANTO INFERIOR DIREITO DO PALCO.
		 */
		private function calcPosition () : void
		{
			_bottom = this.y + this.height + DISTANCE;
			_right = this.x + this.width + DISTANCE;
			
			if (_right > stage.stageWidth && !invert) {
				this.x = stage.stageWidth - this.width - DISTANCE;
			}
			
			if (_bottom > stage.stageHeight && !invert) {
				this.y = stage.stageHeight - this.height - DISTANCE;
			}
			
			if (_right > stage.stageWidth && _bottom > stage.stageHeight && !invert) invert = true;
			if(invert && _right < (stage.stageWidth - 150) && _bottom < (stage.stageHeight - 150)) invert = false;
		}
		
		public function set text(value:String):void 
		{
			_text = value;
		}
		
	}
	
}