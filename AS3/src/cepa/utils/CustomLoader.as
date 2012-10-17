package cepa.utils
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.net.URLRequest;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;

	public class CustomLoader extends MovieClip
	{
		private var _loader:Loader;
		private var _percent:Number;
		private var _view:ProgressView;
		private var _w:Number;
		private var _h:Number;
		
		public function CustomLoader (file:String, w:Number, h:Number, view:ProgressView = null)
		{
			_loader = new Loader();
			_loader.load(new URLRequest(file));
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, addFile);
			_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, fileProgress);
			
			_w = w;
			_h = h;
			
			//stage.stageWidth = w;
			//stage.width = w;
			//stage.height = h;
			
			if (view)
			{
				_view = view;
				_view.x = _w / 2;
				_view.y = _h / 2;
				addChild(_view);
			}
		}
		
		public function autoResize() : void
		{
			if (_view)
			{
				var largura = _view.width;
				var altura = _view.height;
				var diff;
				var pt;
				var new_altura;
				var new_largura;
				
				if (largura > _w) {
					diff = largura - _w;
					pt = (1 - diff / largura);
					new_altura = altura*pt;
					new_largura = _w;
				}else {
					new_largura = largura;
					new_altura = altura;
				}
				
				if (new_altura > _h) {
					diff = new_altura - _h;
					pt = (1 - diff/new_altura);
					new_largura = largura*pt;
					new_altura = _h;
				}else {
					new_altura = new_altura;
				}
				_view.width = new_largura;
				_view.height = new_altura;
			}else {
				trace("ERRO: Não existe um ProgressView definido. Esta função não pode ser utilizada.");
			}
		}
		
		public function resizeView() : void
		{
			if (_view)
			{
				_view.resizeView(_w, _h);
			}else {
				trace("ERRO: Não existe um ProgressView definido. Esta função não pode ser utilizada.");
			}
		}
			
		private function addFile (evt:Event) : void
		{
			var arquivoSWF = evt.target.content;
			arquivoSWF.x = 0;
			arquivoSWF.y = 0;
			addChild(arquivoSWF);
			
			if (_view)
			{
				removeChild(_view);
			}
		}
			
		private function fileProgress (evt:ProgressEvent) : void
		{
			_percent = Math.round((evt.bytesLoaded / evt.bytesTotal )*100 );
			if (_view)
			{
				_view.percent = _percent;
			}
		}
	}
}