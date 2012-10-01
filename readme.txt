Ender Lib - Flex Threading Library


Project Homepage:   http://code.google.com/p/ender-lib/
Author:             John Blanco, Rapture In Venice
Contact:            john.blanco@raptureinvenice.com


INTRODUCTION
------------

Ender Lib creates an abstraction that emulates threads in Flex and Flash. While not physically possible to do in the Flash Player, much to our dismay, we can still roughly approximate them with a framework that provides yielding and scheduling.

In many cases, such as socket processing, events replaces the need for threads in AS3. However, in cases where long-term processing needs to take place, Ender Lib can emulate threading that will avoid apps that appear to "freeze".

There are just a small dash of rules for how to write your threaded routines, but if you follow it then all the special code needed to approximate threading will be done for you in a flexible framework!


HOW IT WORKS
------------

You can create thread in one of two ways:

* Extend Thread and override its empty run() implementation (Thread is abstract).
* Implement IRunnable, create an instance, and pass it to the Thread constructor.

If you're familiar with Java, these two options should look very familiar, because it's exactly the same.  From here, you are now free to implement run().  There are two concepts you should be aware of, though: (1) yielding and (2) continuous execution.


YIELDING
--------

Threading isn't natively possible in the Flash Player, so Ender Lib is only a virtual realization of it.  Ender Lib uses a process called cooperative multitasking, meaning that each thread must willingly cede execution to the next thread or main timeline.  This is different that what modern threading systems look like, but more flexible than what other Flex threading systems provide.

The idea is that when you write your thread code, *you* decide when to cede execution of the thread. You may decide to perform as much functionality in some timeframe, perhaps 100 milliseconds.  You may also cede execution only when a certain amount of processing is complete.  When you are prepared to cede execution, you may call yield() or Thread.yield() (if you are using a custom Thread implementation).

Note that while you may call return to exit out of the method, Ender Lib will interpret this as the final ending of the thread and automatically remove it from the Thread manager for you.  

*Never call return unless you want the thread to stop executing ever again.*


CONTINUOUS EXECUTION
--------------------

Continuous Execution is the concept that, since Flash Player doesn't have native support for threads, your run() implementation will *not* be called just once as in normal thread implementations, but rather continuously until the thread is completed.

You should *not* rely on local variables to maintain processing state. Instead, you should use class properties for everything, perhaps even your loops (if you intend to yield() inside them.)


AN EXAMPLE IMPLEMENTATION
-------------------------

Here's a simple example of using Ender Lib that demonstrates the usage of everything you'll need.  We will create a thread that does the following:

* Loops 1,000 times
* Makes the loop status available for binding.
* Yields execution after each iteration.
* Completes execution and cleans up thread when done.

There are two ways to write this thread, as described earlier.  Both methods are demonstrated here.


AN EXAMPLE IMPLEMENTATION (EXTENDING THREAD)
--------------------------------------------

Your class simply needs to extend the Thread class and override the runnable:

	public class MyThread extends Thread
	{
		/** Loop variable. (Note we make this a property and not local for continuous execution!) */
		protected var iLoop:int;

		/** Status text. */
		[Bindable]
		public var status:String = "";

		/**
		 * Constructor.
		 */		
		public function MyThread(priority:int) {
			super(null, priority);
		}
		
		/**
		 * Our run() method.
		 */
		override public function run():void {
			// initialize the loop construct
			iLoop = Thread.isFirstRun(this) ? 0 : iLoop;
			
			// loop
			while (iLoop <= 1000) {
				// update our status
				status = "Iteration #" + iLoop;

				// bump
				iLoop++;
				
				// yield on each iteration (we could iterate more but we want smooth animation.)
				yield();
			}
		} 
	}

As you can see in this class, we don't rely on local variables for our loop construct because continuon execution would constantly be resetting them!  This is not Java, the method will be called multiple times. 

Also, we yield() on every iteration, though it's not required, of course.  We do it, though, so we have a smooth animation happening in our status.  If you are doing something graphical, you want to yield() more often to keep the animation stable.  if you are doing calculation that results in one final change to the state of the UI, you can hold off on your yield() a lot longer. 

To execute out thread, we simply do this:

	// start!
	(thread = new MyThread(Thread.URGENT_PRIORITY)).start();

In fact, we wouldn't even need to keep a reference to the thread except that we need to bind to its status property.  When the thread ends naturally (via hitting the end of the run() method or an explicit return), the thread is cleaned up automatically. Here's if we didn't need to:

	// start!
	new MyThread(Thread.URGENT_PRIORITY).start();


AN EXAMPLE IMPLEMENTATION (IMPLEMENTING IRUNNABLE)
--------------------------------------------------

Here's the same example, but written as an IRunnable:

	public class MyThread implements IRunnable
	{
		/** Loop variable. (Note we make this a field and not local for continuous execution!) */
		protected var iLoop:int;

		/** Status text. */
		[Bindable]
		public var status:String = "";
		
		/**
		 * Our run() method.
		 */
		public function run():void {
			// initialize the loop construct
			iLoop = Thread.isFirstRun(this) ? 0 : iLoop;

			// loop
			while (iLoop <= 1000) {
				// update our status
				status = "Iteration #" + iLoop;

				// bump
				iLoop++;
				
				// yield on each iteration (we could iterate more but we want smooth animation.)
				Thread.yield();
			}
		} 
	}

Note that Thread must be used explicitly for yield() and isFirstRun() because this is not a Thread.
