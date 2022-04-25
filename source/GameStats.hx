import openfl.text.TextFormat;
import openfl.system.System;
import EngineSettings.Settings;
import openfl.text.TextField;
import flixel.FlxG;

class GameStats extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

    var peak = 0;

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("_sans", 12, color);
		text = "FPS: ";

		cacheCount = 0;
		currentTime = 0;
		times = [];

		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			var time = Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end

		width = 350;
	}

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
		{
			times.shift();
		}

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);
		try {
		if (FlxG.save.data.isNull == null) {
			Settings.loadDefault(); FlxG.save.data.isNull = false;} 
		

		if (visible = (Settings.engineSettings.data.fps_showFPS || Settings.engineSettings.data.fps_showMemory || Settings.engineSettings.data.fps_showMemoryPeak))
		{
			text = "";
			if (Settings.engineSettings.data.fps_showFPS)
				text += "FPS: " + currentFPS + "\n";

			#if (gl_stats && !disable_cffi && (!html5 || !canvas))
			text += "\ntotalDC: " + Context3DStats.totalDrawCalls();
			text += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
			text += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
			#end
			var mem = System.totalMemory;
			if (mem > peak) peak = mem;
			if (Settings.engineSettings != null) {
				if (Settings.engineSettings.data.fps_showMemory)
					text += "Memory: " + CoolUtil.getSizeLabel(System.totalMemory) + "\n";
				if (Settings.engineSettings.data.fps_showMemoryPeak)
					text += "Mem Peak: " + CoolUtil.getSizeLabel(peak) + "\n";
				if (Settings.engineSettings.data.fps_showYoshiEngineVer)
					text += 'Yoshi Engine v${Main.engineVer.join(".")}';
			}
		}} catch (e) {}


		cacheCount = currentCount;
	}
}
