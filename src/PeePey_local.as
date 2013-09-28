package  {
	
	import com.greygreen.net.p2p.events.P2PEvent;
	import com.greygreen.net.p2p.model.P2PConfig;
	import com.greygreen.net.p2p.model.P2PPacket;
	import com.greygreen.net.p2p.P2PClient;
	import entity.Circle;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import utils.GlobalTimer;
	
	public class PeePey_local extends MovieClip {
		
		private var p2pclient:P2PClient;
		
		private var stack : Dictionary = new Dictionary();
		
		private var recieveID			: String;
		private var recieveData			: Object;
		private var globalTimer			: GlobalTimer;
		private var circle				: Circle;
		private var datas				: Object = { x:0, y:0 };
		
		public function PeePey_local() {
			// constructor code
			
			p2pclient = new P2PClient();
			globalTimer = new GlobalTimer(update, 16);
			setupConnection();
		}
		
		private function setupConnection():void {

            p2pclient.addEventListener(P2PEvent.CONNECTED, onConnect);
			p2pclient.addEventListener(P2PEvent.STATE_RESTORED, onStateRestored);
			
			p2pclient.listen(messageReceived, "message");
			p2pclient.listen(userRegister, "user");
			
			p2pclient.connect(new P2PConfig({
				groupName	: "example",      // NetGroup name
				saveState	: "true"          // restore state from previous messages
			}));
        }
		
		function onStateRestored(e:P2PEvent):void {
			// e.info.state contains an Array of messages
        }
		
		//==================================================================================================
		private function handleEnterFrame(e:Event):void {
		//==================================================================================================
			globalTimer.tick();
		}
		
		//==================================================================================================	
		private function update():void {
		//==================================================================================================	
			circle.setPos(mouseX, mouseY);
		}
		
		private function onConnect(e:P2PEvent):void {
			circle = new Circle();
			this.addChild(circle);
			this.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			this.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
        }
		
		//==================================================================================================
		private function handleMouseMove(e:MouseEvent):void {
		//==================================================================================================
			datas.x = mouseX;
			datas.y = mouseY;
			p2pclient.send(datas, "message");
		}
		
		function messageReceived(p:P2PPacket):void {
			recieveID 	= p.recipientId;
			recieveData = p.data;
			(stack[recieveID] as Circle).setPos( recieveData.x , recieveData.y );
		}
		
		 private function userRegister(p:P2PPacket):void {
			addChild(stack[p.recipientId] = new Circle());
        }
	}
	
}
