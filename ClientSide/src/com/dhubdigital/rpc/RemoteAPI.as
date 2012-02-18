package com.dhubdigital.rpc {
	import com.adobe.serialization.json.JSON;
	import com.lia.crypto.AES;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.describeType;
	import flash.utils.getTimer;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	/**
	 * ...
	 * @author Achmad Aulia Noorhakim
	 */
	public class RemoteAPI {
		public static var url:String = '';
		public static var key:String = '';
		
		private var className:String     = '';
		private var callbacks:Array      = [];
		private var functions:Dictionary = new Dictionary();
		
		public function RemoteAPI() {
			className = getQualifiedClassName(this);
			className = className.replace('.' , '\\');
			className = className.replace('::', '\\');
			
			var info:XML = describeType(this);
			for each (var method:XML in info.method) {
				functions[this[method.@name]] = method.@name;
			}
		}
		
		protected function _fn(f:Function):String {
			return functions[f];
		}
		
		private function addCallback(callback:Function):int {
			var stamp:int = getTimer();
			callbacks.push({
					s: stamp,
					f: callback
				});
			return stamp;
		}
		
		private function removeCallback(timestamp:int):void {
			var length:int = int(callbacks.length);
			for (var i:int = 0; i < length; ++i) {
				if (callbacks[i].s == timestamp) {
					callbacks.splice(i, 1);
					return;
				}
			}
		}
		
		private function findCallback(timestamp:int):Function {
			var length:int = int(callbacks.length);
			for (var i:int = 0; i < length; ++i) {
				if (callbacks[i].s == timestamp) {
					return callbacks[i].f;
				}
			}
			return null;
		}
		
		protected function invoke(methodName:String, ...params):void {
			var stamp:int = 0;
			if (params[params.length - 1] is Function) {
				stamp = addCallback(params.pop());
			}
			
			var message:* = {
					'class' : className,
					'method': methodName,
					'params': params,
					'stamp' : stamp
				};
			
			send(message);
		}
		
		private function send(message:Object):void {
			var data   :URLVariables = new URLVariables();
			var request:URLRequest   = new URLRequest(url);
			var loader :URLLoader    = new URLLoader(request);
						
			data['request'] = AES.encrypt(JSON.encode(message), key, AES.BIT_KEY_256);
			
			request.method = URLRequestMethod.POST;
			request.data   = data;
			
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, onResponse);
			loader.load(request);
		}
		
		private function onResponse(e:Event):void {
			var loader:URLLoader = URLLoader(e.target);
			if (loader != null) {
				loader.removeEventListener(Event.COMPLETE, onResponse);
			}
			
			if (loader.data == null || loader.data == '') {
				return;
			}
			
			var response:Object   = JSON.decode(AES.decrypt(loader.data, key, AES.BIT_KEY_256));
			var callback:Function = findCallback(response.stamp);
			if (callback != null) {
				removeCallback(response.stamp);
				delete response['stamp'];
				callback(response);
			}
			
			loader.close();
		}
		
	}

}