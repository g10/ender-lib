package
{

	import flash.text.TextField;
	import ender.managers.ThreadManager;
	import ender.threads.Thread;

	import net.hires.debug.Stats;

	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * @author Giovanni Carnel / g10[at]formapparatus.com
	 */
	[SWF(width='600', height='400', frameRate='60', backgroundColor='#FFFFFF')]
	public class Main extends Sprite
	{
		private var thread : MyThread;
		private var anim : Sprite;
		private var tf : TextField;

		public function Main()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		private function onAddedToStage(event : Event) : void
		{
			ThreadManager.stage = stage;

			//

			create_fps_meter();
			create_test_animation();
			create_thread_count();

			//

			create_test_thread();
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function create_fps_meter() : void
		{
			addChild(new Stats());
		}

		private function create_test_animation() : void
		{
			anim = new Sprite();
			anim.graphics.beginFill(0x000000);
			anim.graphics.drawRect(-100, -5, 200, 10);
			anim.graphics.endFill();
			anim.x = 300;
			anim.y = 200;
			addChild(anim);
		}

		private function create_thread_count() : void
		{
			tf = new TextField();
			tf.x = 100;
			tf.y = 20;
			addChild(tf);
		}

		private function create_test_thread() : void
		{
			(thread = new MyThread(Thread.URGENT_PRIORITY)).start();
		}

		private function onEnterFrame(event : Event) : void
		{
			anim.rotation += 1;
			tf.text = thread.status;
		}
	}
}
