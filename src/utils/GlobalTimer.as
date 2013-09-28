package utils
{
	/**
	 * ...
	 * @author Vladimir Minkin (vk.com/dqvsra)
	 */
	import flash.utils.getTimer;
	
	public class GlobalTimer
	{
		public var 			gameStartTime				:Number = 0.0; 		// when the game started
		public var 			lastFrameTime				:Number = 0.0; 		// timestamp: previous frame
		public var 			currentFrameTime			:Number = 0.0; 		// timestamp: right now
		public var 			frameMs						:Number = 0.0; 		// how many ms elapsed last frame
		public var 			frameCount					:uint = 0; 			// number of frames this game
		public var 			nextHeartbeatTime			:uint = 0; 			// when to fire this next
		public var 			gameElapsedTime				:uint = 0; 			// how many ms so far?
		public var 			heartbeatIntervalMs			:uint = 1000; 		// how often in ms does the heartbeat occur?
		public var 			heartbeatFunction			:Function; 			// function to run each heartbeat
		
		public function GlobalTimer(heartbeatFunc:Function=null, heartbeatMs:uint = 1000)
		{
			if (heartbeatFunc != null)
				heartbeatFunction = heartbeatFunc;
			heartbeatIntervalMs = heartbeatMs;
		
		}
		
		public function tick():void
		{
			currentFrameTime = getTimer();
			if (frameCount == 0) // first frame?
			{
				gameStartTime 		= currentFrameTime;
				frameMs 			= 0;
				gameElapsedTime 	= 0;
			}
			else
			{
				// how much time has passed since the last frame?
				frameMs 			= currentFrameTime - lastFrameTime;
				gameElapsedTime 	+= frameMs;
			}
			if (heartbeatFunction != null)
			{
				if (currentFrameTime >= nextHeartbeatTime)
				{
					heartbeatFunction();
					nextHeartbeatTime = currentFrameTime + heartbeatIntervalMs;
				}
			}
			lastFrameTime = currentFrameTime;
			frameCount++;
		}
	}

}
