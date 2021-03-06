package prfm.view{
	import __AS3__.vec.Vector;
	
	import flash.display.BlendMode;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.geom.Utils3D;
	import flash.text.TextField;
	import flash.utils.getTimer;
	
	import prfm.view.motion.MotionMan2;
	import prfm.view.motion.TrailLine;
	

	public class MainContainer extends Sprite {	
		private var motions:Array;
		
		public var scale:Number = 2;
		
		private var frame_count:Number = 0;
		public var speed:Number = 100;
		public var rotaY:Number = 0;
		public var rotaX:Number = 0;
		public var freq_r:Number = 0.001;
		public var freq_g:Number = 0.002;
		public var freq_b:Number = 0.003;
		
		private var proj:PerspectiveProjection;
		
		private var tf:TextField;
		
		public function MainContainer()
		{
			super();
		}
		
		public function init():void
		{
			
			proj = new PerspectiveProjection();
			proj.fieldOfView = 45;
			
			motions = [];
			addMotion("A_test.bvh");
			addMotion("B_test.bvh");
			addMotion("C_test.bvh");
			
			tf = new TextField();
			this.addChild(tf);
			tf.blendMode = BlendMode.INVERT;
			
			
			this.addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
			
			onResizeHandler(null);
			stage.addEventListener(Event.RESIZE, onResizeHandler);
		}
		
		public function destroy():void
		{
			for each (var motion:MotionMan2 in motions){
				motion.destroy();
			}
			motions = null;
			proj = null;
			while ( this.numChildren > 0 ) this.removeChildAt(0);
			stage.removeEventListener(Event.RESIZE, onResizeHandler);
			this.removeEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
			if ( parent ) parent.removeChild(this);
		}
		
		public function onResizeHandler(e:Event):void
		{
			var sw:Number = stage.stageWidth;
			var sh:Number = stage.stageHeight;
			proj.projectionCenter = new Point(sw/2, sh/2);
		}
		
		
		
		public function addMotion(_path:String):void{
			if ( !motions ) motions = [];
			var motion:MotionMan2 = new MotionMan2(_path);
			for ( var i:int = 0; i<100; i++ ) {
				motion.addPoint();
			}
			motions.push(motion);
		}
		
		
		private function onEnterFrameHandler(e:Event):void{
			var time_pos:Number = flash.utils.getTimer();
			
			var i:int = 0;
			var l:int;
			var sw:Number = stage.stageWidth;
			var sh:Number = stage.stageHeight;
			var cx:Number = sw/2;
			var cy:Number = sh/2;
			
			var n_timer:Number = flash.utils.getTimer();
			
			var cnts:Array = [];
			var motion:MotionMan2;
			for each ( motion in motions ) {
				motion.update(frame_count, 400);
			}
			
			var m:Matrix3D = proj.toMatrix3D().clone();
			var verts:Vector.<Number> = new Vector.<Number>();
			var proj:Vector.<Number> = new Vector.<Number>();
			var uvts:Vector.<Number> = new Vector.<Number>();

			var _scale:Number = scale;
			var _off_col:Array = [];
			
			var g:Graphics = this.graphics;
			g.clear();
			
			var _r:Number = (Math.cos(n_timer*freq_r*0.01)/2+0.5)*255 & 0xFF;
			var _g:Number =	(Math.cos(n_timer*freq_g*0.01)/2+0.5)*255 & 0xFF;
			var _b:Number = (Math.cos(n_timer*freq_b*0.01)/2+0.5)*255 & 0xFF;
			
			for each ( motion in motions ) {
				for each ( var _l:TrailLine in motion._lines ) {
					verts = _l._lines;
					proj = new Vector.<Number>();
					Utils3D.projectVectors(m, verts, proj, uvts);
					l = proj.length;
					for ( i = 0; i<l; i+=2 ) {
						if ( i == 0 ) {
							g.lineStyle(0,0,0);
							g.beginFill(0x0077FF, 1);
							g.drawCircle(proj[i]+cx, proj[i+1]+cy, 2);
							g.endFill();
							g.moveTo(proj[i]+cx, proj[i+1]+cy);
						} else {
							_r -= i*0.1;
							if ( _r < 0 ) _r = 255;
							g.lineStyle(1, _r << 16 | _g << 8 | _b, (l-1-i)/l*0.7333);
							g.lineTo(proj[i]+cx, proj[i+1]+cy);
						}
					}
				}
			}
			
			frame_count += speed;
			speed = mouseX*0.1;
			tf.text = "spped: "+speed;
		}
		
		
		
	}
}