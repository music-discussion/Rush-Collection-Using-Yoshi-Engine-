package;

import PlayState.SongEvent;
import sys.io.File;
import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

typedef SwagSong =
{
	var events:Array<SongEvent>;
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Int;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var validScore:Bool;
	var keyNumber:Null<Int>;
	var noteTypes:Array<String>;
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Int;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;
	public var keyNumber:Int = 4;
	public var noteTypes:Array<String> = ["Friday Night Funkin':Default Note"];

	public var player1:String = 'bf';
	public var player2:String = 'dad';

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		var rawJson = Assets.getText(Paths.json(folder.toLowerCase() + '/' + jsonInput.toLowerCase())).trim();

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}

		// FIX THE CASTING ON WINDOWS/NATIVE
		// Windows???
		// trace(songData);

		// trace('LOADED FROM JSON: ' + songData.notes);
		/* 
			for (i in 0...songData.notes.length)
			{
				trace('LOADED FROM JSON: ' + songData.notes[i].sectionNotes);
				// songData.notes[i].sectionNotes = songData.notes[i].sectionNotes
			}

				daNotes = songData.notes;
				daSong = songData.song;
				daBpm = songData.bpm; */

		return parseJSONshit(rawJson);
	}
	
	public static function loadModFromJson(jsonInput:String, mod:String, ?folder:String):SwagSong
	{
		var rawJson = "";
		//so sometimes the game goes for a json like "rush-e.json.json"
		//we gotta fix that.
		// Edit: I give up. It doesn't work. and I can find out where the problem is because oof Yosh Engine's stupid non trace.
		if (folder == null) 
		{
			var jsonPath = '$jsonInput/$jsonInput';
			var completedJson = jsonPath;
			var suffix = "";
			if (!completedJson.endsWith(".json"))
				suffix = ".json";
			if (completedJson.endsWith(".json.json"))
				suffix = "";
			rawJson = Assets.getText(Paths.modJson(completedJson + suffix, 'mods/$mod'));
		}
		else
		{
			var jsonPath = '$folder/$jsonInput';
			var completedJson = jsonPath;
			var suffix = "";
			if (!completedJson.endsWith(".json"))
				suffix = ".json";
			if (completedJson.endsWith(".json.json"))
				suffix = "";
			rawJson = Assets.getText(Paths.modJson(completedJson + suffix, 'mods/$mod'));
		}

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}

		return parseJSONshit(rawJson);
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	}
}
