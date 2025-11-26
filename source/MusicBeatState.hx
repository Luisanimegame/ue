package;

import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.util.FlxTimer;
#if mobile
import flixel.FlxCamera;
import flixel.input.actions.FlxActionInput;
import mobile.FlxVirtualPad;
import mobile.HitBox;
import mobile.Mobilecontrols;
#end

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var totalBeats:Int = 0;
	private var totalSteps:Int = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;
		
	#if mobile
	var vPad:FlxVirtualPad;
	var mcontrols:Mobilecontrols;

	var trackedinputs:Array<FlxActionInput> = [];

	public function addVPad(?DPad:FlxDPadMode, ?Action:FlxActionMode) {
		vPad = new FlxVirtualPad(DPad, Action);
		vPad.alpha = 0.75;
		add(vPad);
		controls.setVirtualPad(vPad, DPad, Action);
		trackedinputs = controls.trackedinputs;
		controls.trackedinputs = [];
	}
	
	public function addVPadCamera() {
	  var camcontrol = new FlxCamera(); 
    FlxG.cameras.add(camcontrol, false); 
    camcontrol.bgColor.alpha = 0; 
    vPad.cameras = [camcontrol];
	}

	public function removeVPad() {
	  if (vPad != null) {
	    controls.removeFlxInput(trackedinputs);
	    remove(vPad);
	  }
	}
	
	public function addMControls()
	{
	  mcontrols = new Mobilecontrols();
	  switch (mcontrols.mode.toLowerCase())
	  {
	    case 'vpad_right' | 'vpad_left' | 'vpad_custom':
	      controls.setVirtualPad(mcontrols.vPad, FULL, NONE);
	    case 'hitbox':
	      controls.setHitBox(mcontrols.hitbox);
	    default:
	  }

	  trackedinputs = controls.trackedinputs;
	  controls.trackedinputs = [];

	  var camcontrol = new FlxCamera();
	  FlxG.cameras.add(camcontrol, false);
	  camcontrol.bgColor.alpha = 0;
	  mcontrols.cameras = [camcontrol];

	  mcontrols.visible = false;
	  
	  add(mcontrols);
	}

	public function removeMControls()
	{
	  if (mcontrols != null) {
	    controls.removeFlxInput(trackedinputs);
	    remove(mcontrols);
	  }
	}
	#end
	
	override function destroy()
	{
	  #if mobile
	  controls.removeFlxInput(trackedinputs);
	  #end

	  super.destroy();
	  
	  #if mobile
	  if (vPad != null) {
	    vPad.destroy();
	    vPad = null;
	  }
	  
	  if (mcontrols != null) {
	    mcontrols.destroy();
	    mcontrols = null;
	  }
	  #end
	}

	override function create()
	{
		#if (!web)
		TitleState.soundExt = '.ogg';
		#end

		super.create();
	}

	override function update(elapsed:Float)
	{
		everyStep();

		updateCurStep();
		// Needs to be ROUNED, rather than ceil or floor
		updateBeat();

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		curBeat = Math.round(curStep / 4);
	}

	/**
	 * CHECKS EVERY FRAME
	 */
	private function everyStep():Void
	{
		if (Conductor.songPosition > lastStep + Conductor.stepCrochet - Conductor.safeZoneOffset
			|| Conductor.songPosition < lastStep + Conductor.safeZoneOffset)
		{
			if (Conductor.songPosition > lastStep + Conductor.stepCrochet)
			{
				stepHit();
			}
		}
	}

	private function updateCurStep():Void
	{
		curStep = Math.floor(Conductor.songPosition / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		totalSteps += 1;
		lastStep += Conductor.stepCrochet;

		// If the song is at least 3 steps behind
		if (Conductor.songPosition > lastStep + (Conductor.stepCrochet * 3))
		{
			lastStep = Conductor.songPosition;
			totalSteps = Math.ceil(lastStep / Conductor.stepCrochet);
		}

		if (totalSteps % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		lastBeat += Conductor.crochet;
		totalBeats += 1;
	}
}
