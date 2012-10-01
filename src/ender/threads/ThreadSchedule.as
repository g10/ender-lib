package ender.threads
{
	/**
	 * The ThreadSchedule maintains the schedule of a set of threads for a specified
	 * priority. When enough time has elapsed that these threads should be scheduled to run,
	 * all will be run.
	 */
	public class ThreadSchedule
	{
		/** The number of milliseconds since the last time the threads were executed. */
		protected var _lastFiring:uint = 0;
		
		/** The threads to be executed. */
		public var _threads:Array = [];

		/** The threads scheduled for execution app-wide. */	
		public static var allThreads:Object = {};
		
		/** Priority for this set of threads. */
		protected var _priority:int;
		
		/**
		 * Constructor.
		 * 
		 * @param priority Priority to run these threads at.
		 */
		public function ThreadSchedule(priority:int) {
			_priority = priority;
		}

		/**
		 * Add the time elapsed since the last schedule check.
		 * 
		 * @param timeInMillis The time, in milliseconds, that has elapsed since last check.
		 */		
		public function addTime(timeInMillis:uint):void {
			_lastFiring += timeInMillis;
		}
		
		/**
		 * Returns true if the elapsed time exceeds the schedule time for these threads.
		 * 
		 * @return Returns true if the threads should be executed, false otherwise.
		 */
		public function isReadyToFire():Boolean {
			return ((_priority == Thread.URGENT_PRIORITY) || _lastFiring >= _priority);
		}

		/**
		 * Returns true if this is the first firing of the schedule, false otherwise.
		 */
		public function isFirstFiring():Boolean {
			return (_lastFiring == 0);
		}

		/**
		 * Reset the elapsed time check, signally that execution has occurred.
		 */
		public function resetLastFiring():void {
			_lastFiring = 0;
		}
		
		/**
		 * Adds a thread to this schedule.
		 */
		public function addThread(thread:IThread):void {
			// remove existing references
			removeThread(thread);
			
			// add thread
			_threads.push(thread);
			
			// add thread to global cache
			allThreads[thread.runnable] = this;
		}
		
		/**
		 * Removes a thread from this schedule.
		 */
		public function removeThread(thread:IThread):void {
			var index:int = _threads.indexOf(thread);

			// remove thread if it exists in the list			 
			if (index != -1) {
				_threads.splice(index, 1);	
			}
			
			// remove thread from global cache
			if (allThreads[thread.runnable]) {
				delete allThreads[thread.runnable];
			} 
		}

		/**
		 * Checks if thread is in the cache.
		 * 
		 * @param thread Thread to check for.
		 * @return Returns true if the thread exists in the system, false otherwise.
		 */
		public static function isThreadKnown(thread:IThread):Boolean {
			return allThreads[thread.runnable];
		}

		/**
		 * Returns the number of threads in the system.
		 * 
		 * @return Count of threads.
		 */
		public static function get threadCount():int {
			var count:int = 0;
			
			for each (var i:* in allThreads) {
				count++;
			}
			
			return count;
		}
		
		/**
		 * Priority for this set of threads.
		 */
		public function get priority():int {
			return _priority;
		}
		
		/**
		 * Returns the existing threads in the schedule.
		 * 
		 * @return Threads in the schedule.
		 */
		public function get threads():Array {
			return _threads;
		}
	}
}