package ender.threads
{

	import ender.managers.ThreadManager;

	/**
	 * The Thread class is the primary thread in the system.  It allows you to create threads,
	 * start and stop them, set priority, and handles all interaction with the ThreadManager
	 * singleton.
	 * 
	 * All threads can be created by extending the Thread class directly and overriding run(). 
	 */
	public class Thread implements IThread, IRunnable
	{
		/** Process the thread with urgent priority. */
		public static const URGENT_PRIORITY : int = 150;
		/** Process the thread with high priority. */
		public static const HIGH_PRIORITY : int = 300;
		/** Process the thread with normal priority (default). */
		public static const NORMAL_PRIORITY : int = 600;
		/** Process the thread with low priority. */
		public static const LOW_PRIORITY : int = 1200;
		/** Never process the thread. */
		public static const NO_PRIORITY : int = 10000;
		/** The IRunnable object that the thread is set to process. */
		protected var _runnable : IRunnable;
		/**
		 * The priority the thread should be run at.  The lower the value,
		 * the higher the priority. See Thread constants for declared values.
		 */
		protected var _priority : int = Thread.NORMAL_PRIORITY;

		/** 
		 * Constructor.
		 * 
		 * @param runnable The IRunnable object to process.  If null, defaults to the Thread itself.
		 */
		public function Thread(runnable : IRunnable = null, priority : int = NORMAL_PRIORITY)
		{
			// init
			this._runnable = runnable || this;
			this.priority = priority;
		}

		/**
		 * The IRunnable object that the thread is set to process.
		 */
		public function get runnable() : IRunnable
		{
			return _runnable;
		}

		/**
		 * Starts the thread.
		 */
		public function start() : void
		{
			// add this thread to the manager
			ThreadManager.getInstance().addThread(this);
		}

		/**
		 * Stops the thread.
		 */
		public function stop() : void
		{
			// remove this thread from the manager
			ThreadManager.getInstance().removeThread(this);
		}

		/** 
		 * The priority the thread should be run at.  The lower the value,
		 * the higher the priority. See Thread constants for declared values.
		 */
		public function get priority() : int
		{
			return _priority;
		}

		public function set priority(value : int) : void
		{
			_priority = value;
		}

		/**
		 * Yields execution. This stops thread processing and lets the ThreadManager
		 * process the next thread in the queue.  This should be called by implemented threads
		 * since the Flash Player can't do this itself.
		 * 
		 * Your run() implementation can also simply call return, but yield() is more explicit and
		 * can be called from any method within your thread.
		 * 
		 * Use discretion in your threads.  You should call yield() based on time or iteration
		 * count, or if you've done a segment of processing that satisfies the code enough.
		 * There is no limit to how long your thread can occupy the Player, but keep in mind
		 * that the application will be locked up AT LEAST until you yield execution.
		 */
		public static function yield() : void
		{
			throw new Error(ThreadManager.YIELD_SIG);
		}

		/**
		 * If this is the thread's first time being execute, returns true.  Else, false.
		 * Useful for initializing loop constructs and other items.
		 */
		public static function isFirstRun(thread : IRunnable) : Boolean
		{
			return (ThreadSchedule.allThreads[thread] as ThreadSchedule).isFirstFiring();
		}

		/**
		 * Abstract IRunnable implemention of run().  This *must* be overridden, or an
		 * exception will be thrown.
		 */
		public function run() : void
		{
			throw new Error(ThreadManager.NO_RUN_IMPLEMENTATION_SIG);
		}
	}
}