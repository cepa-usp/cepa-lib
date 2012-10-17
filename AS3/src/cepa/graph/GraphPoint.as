package cepa.graph {
	import flash.display.MovieClip;
	
	import cepa.graph.rectangular.GraphGrid;
	
	public class GraphPoint extends MovieClip {
		
		private var _xpos:Number;
		private var _ypos:Number;
		private var _xconstrain:Function;
		private var _yconstrain:Function;
		private var _grid:GraphGrid;
		
		// Vari�veis auxiliares. Definidas aqui apenas para melhorar o desempenho.
		private var d:Number;
		private var dmin:Number;
		private var pos:Number;
		
		/**
		 * Cria um ponto do gr�fico
		 * @param	xpos - A coordenada <source>x</source> do ponto no gr�fico.
		 * @param	ypos - A coordenada <source>y</source> do ponto no gr�fico.
		 */
		public function GraphPoint (xpos:Number = 0, ypos:Number = 0) : void {
			this.xpos = xpos;
			this.ypos = ypos;
		}
		
		/**
		 * Define a coordenada x do ponto no gr�fico, caso ela N�O esteja sob restri��o
		 * (ie, se x n�o for definido a partir de y dado: veja o m�todo <source>xconstrain</source>).
		 * @param	xpos - A coordenada x do ponto no gr�fico.
		 */
		public function set xpos (xpos:Number) : void {
			if (_xconstrain == null) { // N�o h� restri��o em x
				if (_yconstrain == null) { // N�o h� restri��o em y
					
					if (_grid == null) { // N�o segue a grade (movimenta��o livre)
						_xpos = xpos;
					}
					else {
						
						dmin = _grid.xaxis.xmax - _grid.xaxis.xmin;
						
						for (var i:uint = 0; i < _grid.xaxis.ticks.length; i++ ) {
							d = Math.abs(xpos - _grid.xaxis.ticks[i]);
							if (d < dmin) {
								dmin = d;
								pos = _grid.xaxis.ticks[i];
							}
						}
						
						for (i = 0; i < _grid.xaxis.subticks.length; i++ ) {
							
							d = Math.abs(xpos - _grid.xaxis.subticks[i]);
							if (d < dmin) {
								dmin = d;
								pos = _grid.xaxis.subticks[i];
							}
						}
						
						_xpos = pos;
					}
				}
				// Se houver restri��o sobre y, define-o a partir do x.
				else {
					var ypos:Number = _yconstrain(xpos);
					if (!isNaN(ypos) && isFinite(ypos)) {
						_xpos = xpos;
						_ypos = ypos;
					}
				}
			}
		}
		
		/**
		 * Retorna a coordenada <source>x</source> do ponto no gr�fico.
		 */
		public function get xpos () : Number {
			return _xpos;
		}
		
		/**
		 * Define a coordenada y do ponto no gr�fico, caso ela N�O esteja sob restri��o
		 * (ie, se y n�o for definido a partir de x dado: veja o m�todo <source>yconstrain</source>).
		 * @param	ypos - A coordenada y do ponto no gr�fico.
		 */
		public function set ypos (ypos:Number) : void {
			if (_yconstrain == null) { // N�o h� restri��o em y
				if (_xconstrain == null) { // N�o h� restri��o em x
					
					if (_grid == null) { // N�o segue a grade (movimenta��o livre)
						_ypos = ypos;
					}
					else {
						
						dmin = _grid.yaxis.ymax - _grid.yaxis.ymin;
						
						for (var i:uint = 0; i < _grid.yaxis.ticks.length; i++ ) {
							d = Math.abs(ypos - _grid.yaxis.ticks[i]);
							if (d < dmin) {
								dmin = d;
								pos = _grid.yaxis.ticks[i];
							}
						}
						
						for (i = 0; i < _grid.yaxis.subticks.length; i++ ) {
							d = Math.abs(ypos - _grid.yaxis.subticks[i]);
							if (d < dmin) {
								dmin = d;
								pos = _grid.yaxis.subticks[i];
							}
						}
						
						_ypos = pos;
					}
				}
				else {
					var xpos:Number = _xconstrain(ypos);
					if (!isNaN(xpos) && isFinite(xpos)) {
						_xpos = xpos;
						_ypos = ypos;
					}
				}
			}
		}
		
		/**
		 * Retorna a coordenada <source>y</source> do ponto no gr�fico.
		 */
		public function get ypos () : Number {
			return _ypos;
		}
		
		/**
		 * Define uma restri��o imposta sobre a coordenada y, representada pela fun��o y = f(x). No exemplo abaixo,
		 * y = f(x) = x + 1. Assim, quando definimos x = 3, y � automaticamente feito igual a 4 (= f(3) = 3 + 1).
		 * <source>
		 * var p:GraphPoint = new GraphPoint();
		 * p.yconstrain = function (x:Number) {return x + 1;}
		 * p.xpos = 3; // A coordenada y � automaticamente definida como 3 + 1 = 4.
		 * </source>
		 */
		public function set yconstrain (constrain:Function) : void {
			if (_grid != null) {
				trace("WARNING: this point snaps to a grid. Remove it before imposing a constrain.");
			}
			else if (_xconstrain == null) {
				_yconstrain = constrain;
				this.xpos = _xpos;
			}
			else if (constrain != null) {
				trace("WARNING: there already exists a constrain over x. Remove it before imposing a constrain to y.");
			}
		}
		
		/**
		 * Retorna a fun��o f que representa a restri��o y = f(x).
		 */
		public function get yconstrain () : Function {
			return _yconstrain;
		}
		
		/**
		 * Define uma restri��o imposta sobre a coordenada x, representada pela fun��o x = g(y). No exemplo abaixo,
		 * x = g(y) = y - 1. Assim, quando definimos y = 4, x � automaticamente feito igual a 3 (= g(4) = 3 - 1).
		 * <source>
		 * var p:GraphPoint = new GraphPoint();
		 * p.xconstrain = function (y:Number) {return y - 1;}
		 * p.ypos = 4; // A coordenada x � automaticamente definida como 4 - 1 = 3.
		 * </source>
		 */
		public function set xconstrain (constrain:Function) : void {
			if (_grid != null) {
				trace("WARNING: this point snaps to a grid. Remove it before imposing a constrain.");
			}
			else if (_yconstrain == null) {
				_xconstrain = constrain;
				this.ypos = _ypos;
			}
			else if (constrain != null) {
				trace("WARNING: there already exists a constrain over y. Remove it before imposing a constrain to x.");
			}
		}
		
		/**
		 * Retorna a fun��o g que representa a restri��o x = g(y).
		 */
		public function get xconstrain () : Function {
			return _xconstrain;
		}
		
		/**
		 * Registra uma grade sobre a qual este GraphPoint deve se limitar.
		 * @param	grid - A grade.
		 */
		public function snap2Grid (grid:GraphGrid):void {
			if (_xconstrain == null && _yconstrain == null) {
				if (grid != null) {
					_grid = grid;
					xpos = _xpos;
					ypos = _ypos;
				}
			}
			else trace("WARNING: this point has a constrain. Remove it before request grid-snapping.");
		}
	}
}