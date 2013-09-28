package
{
	import com.projectcocoon.p2p.LocalNetworkDiscovery;
	import com.projectcocoon.p2p.events.ClientEvent;
	import com.projectcocoon.p2p.events.GroupEvent;
	import com.projectcocoon.p2p.vo.ClientVO;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.NetStatusEvent;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.SoundCodec;
	import flash.media.Video;
	import flash.net.NetStream;
	import flash.text.TextField;
	
	public class AudioVideo extends Sprite
	{

		private var channel:LocalNetworkDiscovery;
		private var info:TextField;
		private var localVideo:Video;
		private var remoteVideo:Video;
		private var publishStream:NetStream;
		private var receivingStream:NetStream;
		
		/**
		 * As of now, Cocoon P2P does not include any audio/video streaming features. But
		 * you can easily workaround this by just creating NetStreams yourself to publish
		 * and receive audio/video from peers.
		 * 
		 * The following demo shows how two peers that both belong to the same NetGroup 
		 * (the one that Cocoon creates by default) can both publish their local audio/video
		 * to the corresponding peer while at the same time receiving the a/v from the peer.
		 * 
		 * This demo is just meant as a demo - do not expect anything too sophisticated :-)
		 * 
		 * We still plan to add built-in a/v-functionality to Cocoon P2P itself btw
		 * 
		 */ 
		public function AudioVideo()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			createUI();
			createConnection();
		}
		
		private function createUI():void
		{
			// just some UI stuff
			info = new TextField();
			info.width = 500;
			info.x = 20;
			info.y = 20;
			info.text = "Simple AV/p2p chat. Only works for 1:1 with 2 peers."
			addChild(info);
			
			graphics.beginFill(0x000000);
			graphics.drawRect(20,50,400,300);
			graphics.endFill();
			
			graphics.beginFill(0xCECECE);
			graphics.drawRect(30,60,133,100);
			graphics.endFill();
			
			// video object for the remote peer
			remoteVideo = new Video(400, 300);
			remoteVideo.x = 20;
			remoteVideo.y = 50;
			addChild(remoteVideo);
			
			// video object for the local video (loopback)
			localVideo = new Video(133, 100);
			localVideo.x = 30;
			localVideo.y = 60;
			addChild(localVideo);
			
			var txt1:TextField = new TextField();
			txt1.textColor = 0xFFFFFF;
			txt1.text = "You";
			txt1.x = 35;
			txt1.y = 65;
			addChild(txt1);
			
			var txt2:TextField = new TextField();
			txt2.textColor = 0xFFFFFF;
			txt2.text = "Peer";
			txt2.x = 380;
			txt2.y = 320;
			addChild(txt2);
		}
		
		private function createConnection():void
		{
			// Connect
			channel = new LocalNetworkDiscovery();
			channel.addEventListener(GroupEvent.GROUP_CONNECTED, onGroupConnected);
			channel.addEventListener(ClientEvent.CLIENT_ADDED, onClientAdded);
			channel.addEventListener(ClientEvent.CLIENT_REMOVED, onClientRemoved);
			channel.connect();
		}
		
		private function startPublishing():void
		{
			// try to get the local Camera
			var cam:Camera = Camera.getCamera();
			if (cam)
			{
				cam.setMode(400, 300, 15);
				// attach to local video
				localVideo.attachCamera(cam);
				// attach to outgoing NetStream
				publishStream.attachCamera(cam);
			}
			
			// try to get the local Microphone
			var mic:Microphone = Microphone.getMicrophone();
			if (mic)
			{
				mic.codec = SoundCodec.SPEEX;
				mic.setSilenceLevel(0);
				// attach to outgoing NetStream
				publishStream.attachAudio(mic);
			}
			
			// publish the stream (name of the stream == local peer ID == farID of this peer for the connecting side)
			publishStream.publish(channel.localClient.peerID);
		}
		
		private function startReceiving():void
		{
			// we have a max of 2 clients, so grab the remote peer from the list of clients
			var peer:ClientVO;
			if (channel.clients[0] == channel.localClient)
				peer = channel.clients[1];
			else
				peer = channel.clients[0];
		
			// attach receiving NetStream to remote video
			remoteVideo.attachNetStream(receivingStream);
			// play the stream (using the peerID == farID of the peer)
			receivingStream.play(peer.peerID);
		}
		
		private function onClientAdded(event:ClientEvent):void
		{
			// this demo only works with a maximum of 2 peers in the NetGroup
			if (channel.clients.length == 2)
			{
				// create receingg stream
				receivingStream = new NetStream(channel.connection, channel.spec);
				receivingStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStreamStatus);
			}
		}
		
		private function onClientRemoved(event:ClientEvent):void
		{
			// if peer left, tear down the receiving stream and clean up things
			if (channel.clients.length == 1)
			{
				receivingStream.removeEventListener(NetStatusEvent.NET_STATUS, onNetStreamStatus);	
				receivingStream.close();
				receivingStream = null;
				remoteVideo.attachNetStream(null);
				remoteVideo.clear();
			}
		}
		
		private function onGroupConnected(event:GroupEvent):void
		{
			channel.connection.addEventListener(NetStatusEvent.NET_STATUS, onNetStreamStatus);	
			
			// setup a new outgoing stream in this NetGroup
			publishStream = new NetStream(channel.connection, channel.spec);
			publishStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStreamStatus);	
			
		}
		
		
		private function onNetStreamStatus(event:NetStatusEvent):void
		{
			trace(event.info.code);
			if (event.info.code == "NetStream.Connect.Success")
			{
				// when the NetStream was successfully connected, start publishing / receiving
				if (event.info.stream == publishStream)
					startPublishing();
				else if (event.info.stream == receivingStream)
					startReceiving();
			}
		}		
		
		
	}
}