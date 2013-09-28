package entity
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Vladimir Minkin (vk.com/dqvsra)
	 */
	public class Circle extends Sprite 
	{
		private var g:Graphics;
		
		public function Circle(radius:uint = 10) 
		{
			g = this.graphics;
			g.beginFill(Math.random() * 0xffffff );
			g.drawCircle( 0, 0, radius );
		}
		
		public function setPos( x:uint, y:uint ) {
			this.x = x;
			this.y = y;
		}
	}
}
