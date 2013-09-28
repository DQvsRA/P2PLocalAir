package  {
	
	import com.laiyonghao.Uuid;
	import com.projectcocoon.p2p.events.ClientEvent;
	import com.projectcocoon.p2p.events.GroupEvent;
	import com.projectcocoon.p2p.events.MessageEvent;
	import com.projectcocoon.p2p.LocalNetworkDiscovery;
	import entity.Circle;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import utils.GlobalTimer;
	
	public class PeePey_cocoon extends MovieClip {
		
		private var stack		: Dictionary = new Dictionary();
		private var channel		: LocalNetworkDiscovery;
		private var circle		: Circle;
		private var globalTimer	: GlobalTimer;
		
		private var recieveID			: String;
		private var recieveData			: Object;
		
		public function PeePey_cocoon() {
			// constructor code
			trace("Hello World!");
			
			globalTimer = new GlobalTimer(update, 16);
			this.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
			
			channel = new LocalNetworkDiscovery();
			//channel.localClient = { id: new Uuid() };
			channel.addEventListener(GroupEvent.GROUP_CONNECTED, onGroupConnected);
			channel.addEventListener(ClientEvent.CLIENT_ADDED, onClientAdded);
			channel.addEventListener(ClientEvent.CLIENT_UPDATE, onClientUpdate);
			channel.addEventListener(ClientEvent.CLIENT_REMOVED, onClientRemoved);
			channel.addEventListener(MessageEvent.DATA_RECEIVED, onDataReceived);
			channel.connect();
			
			
		}
		
		
		//==================================================================================================
		private function handleMouseMove(e:MouseEvent):void {
		//==================================================================================================
			channel.sendMessageToAll( { x:mouseX, y:mouseY } );
		}
		
		//==================================================================================================
		private function onGroupConnected(e:GroupEvent):void {
		//==================================================================================================
		
		}
		
		//==================================================================================================
		private function handleEnterFrame(e:Event):void {
		//==================================================================================================
			globalTimer.tick();
		}
		
		/**
		* @TODO Описать метод
		*
		* Parameters:
		* @TODO Описать аргументы или стереть
		*
		* Return:
		* @TODO Описать что возвращает метод или стереть
		*/
		//==================================================================================================	
		private function update():void {
		//==================================================================================================	
			circle.setPos(mouseX, mouseY);
		}
		
		//==================================================================================================
		private function onDataReceived(e:MessageEvent):void {
		//==================================================================================================
			recieveID 	= e.message.client.peerID;
			recieveData = e.message.data;
			(stack[recieveID] as Circle).setPos( recieveData.x , recieveData.y );
		}
	
		//==================================================================================================
		private function onClientRemoved(e:ClientEvent):void {
		//==================================================================================================
			
		}
	
		//==================================================================================================
		private function onClientUpdate(e:ClientEvent):void {
		//==================================================================================================
			
		}
		
		//==================================================================================================
		private function onClientAdded(e:ClientEvent):void {
		//==================================================================================================
			trace(JSON.stringify(e.client));
			if (!circle) {
				circle = new Circle();
				this.addChild(circle);
				this.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			} else {
				addChild(stack[e.client.peerID] = new Circle());
			}
		}
	}
}
