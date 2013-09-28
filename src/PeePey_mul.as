package  {
	
	import com.reyco1.multiuser.data.UserObject;
	import com.reyco1.multiuser.debug.Logger;
	import com.reyco1.multiuser.MultiUserSession;
	import entity.Circle;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import utils.GlobalTimer;
	
	public class PeePey_mul extends MovieClip {
		
		private const SERVER:String   = "rtmfp://p2p.rtmfp.net/";
		private const DEVKEY:String   = "223847bf7d40ea71c45ffd71-a4622cbb2928";										// you can get a key from here : http://labs.adobe.com/technologies/cirrus/
		private const SERV_KEY:String = SERVER + DEVKEY;
 
		private var connection:MultiUserSession;
		
		private var stack : Dictionary = new Dictionary();
		private var myName:String;
		
		private var recieveID			: String;
		private var recieveData			: Object;
		private var globalTimer			: GlobalTimer;
		private var circle				: Circle;

		public function PeePey_mul() {
			// constructor code
			globalTimer = new GlobalTimer(update, 16);
			
			Logger.LEVEL = Logger.OWN;											// set Logger to only trace my traces
			initialize();
		}
		
		protected function initialize():void
		{
			connection = new MultiUserSession(SERV_KEY, "multiuser/test"); 		// create a new instance of MultiUserSession
			connection.onConnect 		= handleConnect;						// set the method to be executed when connected
			connection.onUserAdded 		= handleUserAdded;						// set the method to be executed once a user has connected
			connection.onUserRemoved 	= handleUserRemoved;					// set the method to be executed once a user has disconnected
			connection.onObjectRecieve 	= handleGetObject;						// set the method to be executed when we recieve data from a user
			
			myName  = "User_" + Math.round(Math.random()*100);					// my name
			
			connection.connect(myName);						// connect using my name and color variables
			
			
		}
		
		protected function handleConnect(user:UserObject):void					// method should expect a UserObject
		{
			trace("I'm connected: " + user.name + ", total: " + connection.userCount); 
			circle = new Circle();
			addChild(circle);
			stage.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
		}
		
		protected function handleUserAdded(user:UserObject):void				// method should expect a UserObject
		{
			trace("User added: " + user.name + ", total users: " + connection.userCount);
			addChild(stack[user.id] = new Circle());
		}
		
		protected function handleUserRemoved(user:UserObject):void				// method should expect a UserObject
		{
			trace("User disconnected: " + user.name + ", total users: " + connection.userCount); 
			//removeChild( cursors[user.id] );									// remove cursor for disconnected user
			//delete cursors[user.id];
		}
		
		protected function handleGetObject(peerID:String, data:Object):void
		{
			recieveID 	= peerID;
			recieveData = data;
			(stack[recieveID] as Circle).setPos( recieveData.x , recieveData.y );						// update user cursor
		}	
		
		//==================================================================================================
		private function handleMouseMove(e:MouseEvent):void {
		//==================================================================================================
			connection.sendObject( { x:mouseX, y:mouseY } );
		}
		
		//==================================================================================================	
		private function update():void {
		//==================================================================================================	
			circle.setPos(mouseX, mouseY);
		}
		
		//==================================================================================================
		private function handleEnterFrame(e:Event):void {
		//==================================================================================================
			globalTimer.tick();
		}
	}
	
}
