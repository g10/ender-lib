package
{

	import ender.threads.Thread;

	public class MyThread extends Thread
	{
		/** Loop variable. (Note we make this a field and not local for continuous execution!) */
		protected var iLoop : int;
		/** Status text. */
		public var status : String = "";

		/**
		 * Constructor.
		 */
		public function MyThread(priority : int)
		{
			super(null, priority);
		}

		/**
		 * Our run() method.
		 */
		override public function run() : void
		{
			// initialize the loop construct
			iLoop = isFirstRun(this) ? 0 : iLoop;

			// loop
			while(iLoop <= 1000)
			{
				// update our status
				status = "Iteration #" + iLoop;

				// bump
				iLoop++;

				// yield on each iteration (we could iterate more but we want smooth animation.)
				yield();
			}
		}
	}
}