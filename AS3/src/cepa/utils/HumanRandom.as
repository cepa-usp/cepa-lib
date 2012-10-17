package cepa.utils
{
	import flash.events.Event;
	/**
	 * ...
	 * @author Luciano
	 */
	public class HumanRandom
	{
		private var lista:Array = new Array();
		private var memoria:uint
		private var memoryArray:Array = new Array();
		
		public function HumanRandom(_lista:Array) 
		{
			for (var i:int = 0; i < _lista.length; i++ ) lista[i] = _lista[i];
			
			memoria = lista.length;
		}
		
		public function set memory(n:uint):void {
			// Limita n
			if (n <= lista.length) memoria = n;
		}
		
		public function get memory():uint {
			return memoria;
		}
		
		public function getItem():* {
			// Se memoryArray.length == memoria então remove a primeira posição de memoryArray e a insere de volta na matriz lista
			if (memoryArray.length == memoria) lista.push(memoryArray.splice(0,1));
			
			// Sorteia uma posição entre 0 e o length da matriz lista
			var randomPos = Math.floor(Math.random() * lista.length);
			
			// Remove da matriz lista a posição randomPos e a insere na matriz memoryArray
			memoryArray.push(lista.splice(randomPos,1)[0]);
			
			//trace("lista[", lista, "]");
			//trace("memoryArray[", memoryArray, "]");
			//trace("randomPos: ", randomPos);
			
			return memoryArray[memoryArray.length - 1];
		}
	}

}