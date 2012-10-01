package ender.managers
{
	import ender.threads.IRunnable;
	import ender.threads.Thread;
	import ender.threads.ThreadSchedule;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	
	import mx.core.Application;
	
	/**
	 * The ThreadManager organizes and arranges for threads to process during execution.
	 * The Thread subclasses register and unregister themselves with the ThreadManager in order
	 * to schedule themselves for execution.
	 * 
	 * Only Thread subclasses should use this class, otherwise, it should be considered
	 * off-limits to client code.
	 */
	public class ThreadManager extends EventDispatcher
	{
		/** The exception signal for yielding. */
		public static const YIELD_SIG:String = "YLD";

		/** The exception signal when IRunnable.run() is not implemented. */
		public static const NO_RUN_IMPLEMENTATION_SIG:String = "NO_RUN";
		
		/** The thread schedules ready for execution. */	
		protected var _threadSchedules:Object = {};

		/** When debug mode is true, we count thread executions for testing purposes. */
		protected var _debugMode:Boolean = false;

		/** When debug mode is true, this maintains thread execution counts.  Testing only. */
		protected var _debugCallCount:Object;
		
		/** Last tick time. */
		protected var _lastTime:uint = getTimer();
		
		/** Event ticker running. */
		protected var _isTicking:Boolean = false;
		
		/** Singleton. */
		protected static var _instance:ThreadManager = null;
		
		/**
		 * Singleton.
		 */
		public static function getInstance():ThreadManager {
			if (_instance == null) {
				_instance = new ThreadManager();
			}
			
			return _instance;
		}

		public function set debugMode(value:Boolean):void {
			_debugMode = value;
			
			// clear
			if (value) {
				_debugCallCount = {};
			}
		}
		
		/**
		 * When debug mode is true, we count thread executions for testing purposes.
		 */
		public function get debugMode():Boolean {
			return _debugMode;
		}

		/**
		 * When in debug mode, gets the count of how often a thread has been executed.
		 * Useful for testing purposes only.
		 * 
		 * @param thread The thread to check execution count for.
		 * @return Returns the number of times the thread has been executed.
		 */				
		public function getCallCount(thread:IRunnable):int {
			if (_debugCallCount[thread]) {
				return _debugCallCount[thread];
			}
			
			return 0;
		}

		/**
		 * Adds a thread to the execution schedule.
		 * 
		 * @param thread The thread to add to the execution schedule.
		 */
		public function addThread(thread:Thread):void {
			if (!ThreadSchedule.isThreadKnown(thread)) {
				// add
				if (!_threadSchedules[thread.priority]) {
					var threadSchedule:ThreadSchedule = new ThreadSchedule(thread.priority);

					// add thread to schedule
					threadSchedule.addThread(thread);
				}
					
				// add
				_threadSchedules[thread.priority] = threadSchedule;

				// restart timer (in case we need to execute more often)				
				restartTimer();
			}
		}

		/**
		 * Removes a thread from the execution schedule.
		 * 
		 * @param thread The thread to remove from the execution schedule.
		 */
		public function removeThread(thread:Thread):void {
			if (ThreadSchedule.isThreadKnown(thread)) {
				var threadSchedule:ThreadSchedule = _threadSchedules[thread.priority] as ThreadSchedule;
				 
				// remove existing references
				threadSchedule.removeThread(thread);
	
				// remove thread schedule if that was the last one
				if (threadSchedule.threads.length == 0) {
					delete _threadSchedules[thread.priority];
				}
				
				// stop timer if we have no threads left to execute				
				if (ThreadSchedule.threadCount == 0) {
					stopTimer();
				}
			}
		}
		
		/**
		 * Starts the timer for execution.
		 */
		protected function startTimer():void {
			if (_isTicking) {
				restartTimer();
			} else {
				var maxPriority:int = maximumPriority;

				if (maxPriority != Thread.NO_PRIORITY) {
					Application.application.addEventListener(Event.ENTER_FRAME, onThreadTick);
					_isTicking = true;
				}
			}
		}

		/**
		 * Restarts the timer for execution.
		 */
		protected function restartTimer():void {
			stopTimer();
			startTimer();
		}
		
		/**
		 * Stops the timer for execution.
		 */
		protected function stopTimer():void {
			if (_isTicking) {
				// stop
				Application.application.removeEventListener(Event.ENTER_FRAME, onThreadTick);
				
				_isTicking = false;
			}
		}
		
		/**
		 * Returns the maximum priority so we know how often to fire the timer.
		 * 
		 * @return Maximum priority.
		 */
		protected function get maximumPriority():int {
			var highest:int = Thread.NO_PRIORITY;
			
			for each (var iSchedule:ThreadSchedule in _threadSchedules) {
				if (iSchedule.priority < highest) {
					highest = iSchedule.priority;
				}
			}
			
			return highest;
		}
		
		/**
		 * Event handler for the thread ticker.
		 */ 
		protected function onThreadTick(event:Event):void {
			var timeInMillis:uint = getTimer();
			
			for each (var iThreadSchedule:ThreadSchedule in _threadSchedules) {
				var timeDelta:uint = getTimer() - _lastTime;

				// add time
				iThreadSchedule.addTime(timeDelta);
				
				if (iThreadSchedule.isReadyToFire()) {
					for each (var iThread:Thread in iThreadSchedule.threads) {
						try {
							if (_debugMode) {
								if (_debugCallCount[iThread]) {
									_debugCallCount[iThread]++;
								} else {
									_debugCallCount[iThread] = 1;
								} 
							}

							// run thread
							iThread.runnable.run();

							// if we get here, then we didn't yield, and this we're done
							removeThread(iThread);
						} catch (err:Error) {
							if (err.message == NO_RUN_IMPLEMENTATION_SIG) {
								throw err;
							} else if (err.message == YIELD_SIG) {
								// normal yield
							} else {
								// wasn't normal, throw it
								throw err;
							}
						}
					}

					// fired (we do this after so we can detect first firing easily)
					iThreadSchedule.resetLastFiring();
				}
				
				// get time
				_lastTime = getTimer();
			}
		}
	}
}