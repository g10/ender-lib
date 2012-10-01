package ender.threads
{
	/**
	 * IThread represents a type of thread.  This class is only needed for customized thread
	 * implementations.  For most purposes, your thread classes should either extend Thread,
	 * and override run(), or implement IRunnable.
	 */
	public interface IThread
	{
		/**
		 * Starts the thread.
		 */
		function start() : void;

		/**
		 * Stops the thread.
		 */
		function stop() : void;

		/**
		 * The runnable that defines run().
		 */
		function get runnable() : IRunnable;

		/**
		 * The priority the thread should be run at.  Possible values are left up to 
		 * individual implementations.
		 */
		function get priority() : int;

		function set priority(value : int) : void;
	}
}