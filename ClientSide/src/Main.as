package {
	import com.dhubdigital.rpc.RemoteAPI;
	import flash.display.Sprite;
	import flash.events.Event;
	import services.TestAPI;
	
	/**
	 * ...
	 * @author Achmad Aulia Noorhakim
	 */
	public class Main extends Sprite {
		
		public function Main():void {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			RemoteAPI.url = 'http://localhost/sandbox/rpc/';
			RemoteAPI.key = 'dhub';
			
			var api:TestAPI = new TestAPI();
			api.getUser(12345, onGetUser);
		}
		
		private function onGetUser(r:*):void {
			trace(r.result);
		}
		
	}
	
}