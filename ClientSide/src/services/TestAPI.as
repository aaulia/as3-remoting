package services {
	import com.dhubdigital.rpc.RemoteAPI;
	
	/**
	 * ...
	 * @author Achmad Aulia Noorhakim
	 */
	public class TestAPI extends RemoteAPI {
		
		public function TestAPI() {
			super();
		}
		
		public function getUser(uid:int, callback:Function = null):void {
			invoke(_fn(arguments.callee), uid, callback);
		}
		
	}

}