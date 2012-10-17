package cepa.interfaces
{
	public interface Serializable
	{
		function serialize () : String;
		function deserialize (serialization:String) : void;
	}
}