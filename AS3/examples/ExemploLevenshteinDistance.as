package
{
	import cepa.utils.levenshteinDistance;
	import flash.display.Sprite;
	
	public class ExemploLevenshteinDistance extends Sprite
	{
		public function ExemploLevenshteinDistance ()
		{
			var str1:String = "plutão";
			
			/*
			 * Para levar a string "plutao" até "plutão" é necessário:
			 * 1ª edição: trocar "a" por "ã"
			 * Logo, a distância de Levenshtein é 1 (edição).
			 */
			var str2:String = "plutao";
			trace(levenshteinDistance(str1,str2)); // 1

			/*
			 * Para levar a string "Plutao" até "plutão" é necessário:
			 * 1ª edição: trocar "P" por "p"
			 * 2ª edição: trocar "a" por "ã"
			 * Logo, a distância de Levenshtein é 2 (edições).
			 */
			str2 = "Plutao";
			trace(levenshteinDistance(str1,str2)); // 2

			/*
			 * Para levar a string "Pltao" até "plutão" é necessário:
			 * 1ª edição: trocar "P" por "p"
			 * 2ª edição: adicionar "l"
			 * 3ª edição: trocar "a" por "ã"
			 * Logo, a distância de Levenshtein é 3 (edições).
			 */
			str2 = "Pltao";
			trace(levenshteinDistance(str1,str2)); // 3
		}
	}
}