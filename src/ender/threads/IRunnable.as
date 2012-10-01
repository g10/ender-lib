package ender.threads
{
	/**
	 * IRunnable represents the interface to an object runnable by a thread.  By implementing
	 * a class of type IRunnable, you can create a Thread that will run that object in a threaded way
	 * without having to extend Thread.
	 * 
	 * This is similar to the method used in Java.
	 */  
	public interface IRunnable
	{
		/**
		 * This method is run by the Thread when time slices are available.  Implementations should
		 * assume that this method will be called multiple times and not just once like
		 * real threading implementations, so avoid local variables, or use them with caution.
		 * You should rely on class fields to maintain all state.
		 */
		function run():void;
	}
}