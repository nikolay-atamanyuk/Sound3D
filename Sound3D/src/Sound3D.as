package
{
	import away3d.cameras.HoverCamera3D;
	import away3d.containers.View3D;
	import away3d.core.base.Object3D;
	import away3d.core.clip.FrustumClipping;
	import away3d.core.math.Number3D;
	import away3d.core.render.Renderer;
	import away3d.lights.DirectionalLight3D;
	import away3d.materials.WireColorMaterial;
	import away3d.primitives.Sphere;
	import away3d.primitives.Trident;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	/**
	 * This example is developed by Ezhi to story-play-game.com. If you
	 * have a questions, you can write me on e-mail: ezhi@story-play-game.com
	 */	
	[SWF(backgroundColor="#869ca7", frameRate="60", width="800", height="600")]
	public class Sound3D extends Sprite
	{
		// away vars
		private var view:View3D;
		private var camera:HoverCamera3D;
		
		//zero position
		private var orts:Trident;
		
		private var leftEar:Sphere;
		private var rightEar:Sphere;
		
		//test vars
		private var bee:Sphere;
		
		private var rotateSpeed:Number=3;	//rotate speed in degree
		
		private var phi:Number=Math.PI/2;
		private var psi:Number=Math.PI/2;
		private var deltaPhi:Number=0;
		private var deltaPsi:Number=0;
		
		private var r:Number=100;
		private var deltaR:Number=0;
		private var maxR:Number=200;
		private var minR:Number=20;
		
		private var pos:Number3D=new Number3D();
		
		[Embed(source="//..//assets//bee.mp3")]
		private var beeSrc:Class 
		private var beeSound:Sound;
		private var channel:SoundChannel;
		private var channelTransform:SoundTransform;
		private var maxAudibility:Number=maxR;
		
		private var tmpDirection:Number3D=new Number3D();
		private var tmpCross:Number3D=new Number3D();
		
		public function Sound3D()
		{
			stage.quality = StageQuality.HIGH;
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			stage.align = StageAlign.TOP_LEFT;
			stage.stageFocusRect = false;
			
			addEventListener(Event.ADDED_TO_STAGE, initApp);
		}
		
		public function initApp(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, initApp);
			
			// init render --------------------------------
			camera = new HoverCamera3D({zoom:10, focus:50, x:0, y:200, z:-50, lookat:"center"});
			camera.distance = 300;
			camera.maxtiltangle = 10;
			camera.mintiltangle = 10;
			camera.targetpanangle = camera.panangle = -180;
			camera.targettiltangle = camera.tiltangle = camera.mintiltangle;
			
			view = new View3D();
			view.camera=camera;
			view.clipping=new FrustumClipping({minZ:10});
			
			view.renderer= Renderer.BASIC;
			view.x = stage.stageWidth / 2;
			view.y = stage.stageHeight / 2;
			addChild(view);
			// --------------------------------------------
			
			// init light ---------------------------------
			var light:DirectionalLight3D= new DirectionalLight3D({color:0xFFFFFF, ambient:0.25, diffuse:0.45, specular:0.9});
			light.x = 200;
			light.z = 100;
			light.y = 1000;
			view.scene.addChild( light );
			// --------------------------------------------
			
			// help field ---------------------------------
			var help:TextField=new TextField();
			help.width=150;
			help.height=200;
			help.text="arrow left - fly left\n";
			help.appendText("arrow right - fly right\n");
			help.appendText("arrow up - fly up\n");
			help.appendText("arrow down - fly down\n");
			help.appendText("page up - fly forward\n");
			help.appendText("page down - fly backward\n");
			help.appendText("delete - stop fly\n");
			help.appendText("space - to begin position");
			this.addChild(help);
			//---------------------------------------------
			
			// orts ---------------------------------------
			this.orts=new Trident(50,true);
			this.view.scene.addChild(orts);
			// --------------------------------------------
			
			// test objets --------------------------------
			this.leftEar=new Sphere({radius:5, segmentsW:4, segmentsH:2});
			this.leftEar.material=new WireColorMaterial(0xffccff);
			this.leftEar.position=new Number3D(-20,0,0);
			this.view.scene.addChild(this.leftEar);
			
			this.rightEar=new Sphere({radius:5, segmentsW:4, segmentsH:2});
			this.rightEar.material=new WireColorMaterial(0xffccff);
			this.rightEar.position=new Number3D(20,0,0);
			this.view.scene.addChild(this.rightEar);
			
			this.bee=new Sphere({radius:10, segmentsW:8, segmentsH:6});
			this.bee.material=new WireColorMaterial(0xccffcc);
			this.view.scene.addChild(this.bee);
			
			this.beeSound=new beeSrc() as Sound;
			this.channelTransform=new SoundTransform(0, 0);
			this.channel=this.beeSound.play(0,10000,this.channelTransform);
			// --------------------------------------------
			
			// init listeners -----------------------------
			stage.addEventListener(Event.ENTER_FRAME, render);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
			// --------------------------------------------
		}
		
		private function render(event:Event):void  
		{ 
			this.psi+=this.deltaPsi;
			this.phi+=this.deltaPhi;
			if(this.r<=this.maxR && this.r>=this.minR)
				this.r+=this.deltaR;
			
			if(this.r>this.maxR)
				this.r=this.maxR;
			if(this.r<this.minR)
				this.r=this.minR;
			
			pos.x=this.r*Math.sin(this.psi)*Math.cos(this.phi);
			pos.z=this.r*Math.sin(this.psi)*Math.sin(this.phi);
			pos.y=this.r*Math.cos(this.psi);
			this.bee.position=pos;
			
			camera.hover();
			view.render();
			
			this.channelTransform.volume=this.calcVolume(this.orts, this.bee);
//			this.channelTransform.pan=this.calcPan(this.orts, this.bee);	//clear effect
			this.channelTransform.pan=this.calcPan(this.orts, this.bee)*0.8;	//more reality effect
			this.channel.soundTransform=this.channelTransform;
		}
		
		private function calcPan(listener:Object3D, bee:Object3D):Number
		{
			/*
			//variant 1 - clear math rezult
			this.tmpDirection.sub(bee.scenePosition, listener.scenePosition);

			this.tmpCross.cross(this.tmpDirection, listener.sceneTransform.up);
			this.tmpDirection.clone(this.tmpCross);
			this.tmpCross.cross(listener.sceneTransform.up, this.tmpDirection);
			this.tmpCross.normalize();
			
			//for normalize vector dot takes cos between vectors
			return this.tmpCross.dot(listener.sceneTransform.right);
			*/
			
			//variant 2 - easy calc rezult
			this.tmpDirection.sub(bee.scenePosition, listener.scenePosition);
			this.tmpDirection.normalize();
			//for normalize vector dot takes cos between vectors
			return this.tmpDirection.dot(listener.sceneTransform.right);
		}
		
		private function calcVolume(listener:Object3D, bee:Object3D):Number
		{
			this.tmpDirection.sub(bee.scenePosition, listener.scenePosition);
			return -this.tmpDirection.modulo/this.maxAudibility+1;
		}
		
		private function onKeyDown(event:KeyboardEvent):void
		{
			
			switch(event.keyCode)
			{
				case Keyboard.LEFT:						//rotate left
					this.deltaPhi=Math.PI*rotateSpeed/360;
					break;
				case Keyboard.RIGHT:					//rotate right
					this.deltaPhi=-Math.PI*rotateSpeed/360;
					break;
				
				case Keyboard.UP:						//rotate up
					this.deltaPsi=-Math.PI*rotateSpeed/360;
					break;
				case Keyboard.DOWN:						//rotate up
					this.deltaPsi=Math.PI*rotateSpeed/360;
					break;
				
				case Keyboard.PAGE_UP:					//further
					this.deltaR=0.5;
					break;
				case Keyboard.PAGE_DOWN:				//closer
					this.deltaR=-0.5;
					break;
				
				case Keyboard.DELETE:					//stop
					this.deltaPhi=0;
					this.deltaPsi=0;
					this.deltaR=0;;
					break;
				
				case Keyboard.SPACE: 					//back to the start
					this.phi=Math.PI/2;
					this.psi=Math.PI/2;
					this.r=100;
					this.deltaPhi=0;
					this.deltaPsi=0;
					this.deltaR=0;
					break;   
				
				case 79: //o - show/hide orts
					this.orts.visible=!this.orts.visible;
					break;
			}
		}
	}
}
