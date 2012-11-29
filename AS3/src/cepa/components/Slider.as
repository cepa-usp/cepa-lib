package cepa.components
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Slider extends Sprite
	{
		
		//------------------------------------------------------------------
		// Membros privados (interface).
		//------------------------------------------------------------------
		
		public function Slider (min:Number = 0, max:Number = 100, step:Number = 1)
		{
			var bounds:Rectangle = trail.getBounds(this);
			xmin = bounds.left;
			xmax = bounds.right;
			
			// Garante um estado inicial válido do slider
			_min = 0;
			_max = 100;
			_step = 1;
			
			// Assume os valores requisitados pelo usuário, se forem válidos
			this.min = min;
			this.max = max;
			this.step = step;
			
			handle.buttonMode = true;
			trail.visible = false;
			
			enabled = true;
			liveDragging = false;
		}
		
		/**
		 * O valor apontado pelo cursor.
		 */
		public function get value () : Number
		{
			var rawValue:Number = _min + (_max - _min) * (handle.x - xmin) / (xmax - xmin);
			var roundedValue:Number = _min + Math.round((rawValue - _min) / _step) * _step;
			var value:Number;
			
			if (Math.abs(rawValue - _max) < Math.abs(rawValue - roundedValue)) value = _max;
			else value = Math.min(roundedValue, _max);
			
			return value;
		}
		
		/**
		 * @private
		 */
		public function set value (value:Number) : void
		{
			value = _min + Math.round((value - _min) / _step) * _step; // Arredonda para o mais próximo valor múltiplo de _step, acima de _min.
			
			if (value >= _min && value <= _max)
			{
				handle.x = xmin + (value - _min) * (xmax - xmin) / (_max - _min)
			}
		}
		
		/**
		 * O valor mínimo que o botão deslizante atinge.
		 */
		public function get min () : Number
		{
			return _min;
		}
		
		/**
		 * @private
		 */
		public function set min (value:Number) : void
		{
			if (value < _max)
			{
				_min = value;
				_step = Math.min(_step, _max - _min);
			}
			else throw new Error("O valor mínimo deve ser menor que o máximo (=" + _max + ").");
		}
		
		/**
		 * O valor máximo que o botão deslizante atinge.
		 */
		public function get max () : Number
		{
			return _max;
		}
		
		/**
		 * @private
		 */
		public function set max (value:Number) : void
		{
			if (value > _min)
			{
				_max = value;
				_step = Math.min(_step, _max - _min);
			}
			else throw new Error("O valor máximo deve ser maior que o mínimo (=" + _min + ").");
		}
		
		/**
		 * O passo de variação do botão deslizante.
		 */
		public function get step () : Number
		{
			return _step;
		}
		
		/**
		 * @private
		 */
		public function set step (value:Number) : void
		{
			if (value > 0 && value <= _max - _min)
			{
				_step = value;
			}
			else throw new Error("O passo deve ser maior que zero e menor ou igual ao tamanho do intervalo.");
		}
		
		/**
		 * Ativa/desativa o botão deslizante.
		 */
		public function get enabled () : Boolean
		{
			return _enabled;
		}
		
		/**
		 * @private
		 */
		public function set enabled (enable:Boolean) : void
		{
			_enabled = enable;
			
			if (_enabled)
			{
				cover.visible = false;
				filters = [];
				handle.addEventListener(MouseEvent.MOUSE_DOWN, grabHandle);
			}
			else
			{
				cover.visible = true;
				filters = [GRAYSCALE_FILTER];
				handle.removeEventListener(MouseEvent.MOUSE_DOWN, grabHandle);
			}
		}
		
		public function get liveDragging():Boolean 
		{
			return _liveDragging;
		}
		
		public function set liveDragging(value:Boolean):void 
		{
			_liveDragging = value;
		}
		
		//------------------------------------------------------------------
		// Membros privados.
		//------------------------------------------------------------------
		
		/*
		 * Ao pegar o botão deslizante.
		 */
		private function grabHandle (event:MouseEvent) : void
		{
			previousPos = handle.x;
			clickOffset = event.localX;
			changing = true;
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, dragHandle);
			stage.addEventListener(MouseEvent.MOUSE_UP, releaseHandle);
		}
		
		/*
		 * Ao arrastar o botão deslizante.
		 */
		private function dragHandle (event:Event = null) : void
		{
			step_px = (xmax - xmin) * _step / (_max - _min);
			rawPos = Math.max(xmin, Math.min(mouseX - clickOffset, xmax));
			roundedPos= xmin + Math.round((rawPos - xmin) / step_px) * step_px;
			
			if (Math.abs(rawPos - xmax) < Math.abs(rawPos - roundedPos)) pos = xmax;
			else pos = Math.min(roundedPos, xmax);
			
			previousPos = handle.x;
			handle.x = pos;
			
			if (liveDragging && Math.abs(handle.x - previousPos) >= 1 /*pixel*/)
			{
				dispatchEvent(new Event(Event.CHANGE, true));
			}
		}
		
		/*
		 * Ao soltar o botão deslizante.
		 */
		private function releaseHandle (event:Event) : void
		{
			changing = false;
			
			
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, dragHandle);
			stage.removeEventListener(MouseEvent.MOUSE_UP, releaseHandle);
			
			if(!liveDragging) dispatchEvent(new Event(Event.CHANGE, true));
		}

		/*
		 * Filtro de conversão para tons de cinza.
		 */
		private const GRAYSCALE_FILTER:ColorMatrixFilter = new ColorMatrixFilter([
			0.2225, 0.7169, 0.0606, 0, 0,
			0.2225, 0.7169, 0.0606, 0, 0,
			0.2225, 0.7169, 0.0606, 0, 0,
			0.0000, 0.0000, 0.0000, 1, 0
		]);
		
		private var clickOffset:Number;
		private var changing:Boolean;
		private var xmin:Number;
		private var xmax:Number;
		private var previousPos:Number;
		private var step_px:Number;
		private var rawPos:Number;
		private var roundedPos:Number;
		private var pos:Number;
		private var _min:Number;
		private var _max:Number;
		private var _step:Number;
		private var _enabled:Boolean;
		private var _liveDragging:Boolean;
	}
}