package;

import FreeplayState.FreeplaySong;
import sys.FileSystem;
import flixel.graphics.frames.FlxAtlasFrames;
import ControlsSettingsSubState.ControlsSettingsSub;
import openfl.display.Preloader.DefaultPreloader;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import lime.utils.Assets;
import EngineSettings.Settings;
import Alphabet.AlphaCharacter;

using StringTools;

class FNFOption extends Alphabet {
	public var updateSelected:Float->Void;
	public var checkbox:FlxSprite;
	public var checkboxChecked:Bool = false;
	public var value:Array<AlphaCharacter> = [];
	public var desc:String = "";
	public var locked:Bool = false;
	
	public override function update(elapsed:Float) {
		super.update(elapsed);
		if (checkbox != null) {
			checkbox.scale.set(FlxMath.lerp(checkbox.scale.x, 0.6, CoolUtil.wrapFloat(0.25 * 30 * elapsed, 0, 1)), FlxMath.lerp(checkbox.scale.y, 0.6, CoolUtil.wrapFloat(0.25 * 30 * elapsed, 0, 1)));
		}
	}

	public function new(x:Float, y:Float, text:String, desc:String, updateOnSelected:Float->Void, checkBox:Bool = false, checkBoxChecked:Bool = false, value:String = "", locked:Bool = false) {
		super(x, y, text, true, false, FlxColor.WHITE);
		this.desc = desc;
		this.updateSelected = updateOnSelected;
		this.locked = locked;
		if (checkBox) {
			checkbox = new FlxSprite(0, 0);
			checkbox.frames = Paths.getSparrowAtlas("checkboxThingie", "preload");
			checkbox.animation.addByPrefix("checked", "Check Box Selected Static", 30, false);
			checkbox.animation.addByPrefix("unchecked", "Check Box unselected", 30, false);
			checkbox.animation.play("unchecked");
			checkbox.scale.x = checkbox.scale.y = 0.6;
			checkbox.updateHitbox();
			checkbox.animation.play(checkBoxChecked ? "checked" : "unchecked");
			checkbox.antialiasing = true;
			checkbox.x = -checkbox.width * 1.25;
			// checkbox.y = -(members[0].height / 2);
			add(checkbox);
			this.checkboxChecked = checkBoxChecked;
		}
		setValue(value, true);
	}

	public function check(checked:Bool) {
		if (checkbox != null && !locked) {
			// checkbox.animation.play("check", true, !checked);
			checkbox.animation.play(checked ? "checked" : "unchecked", true);
			checkbox.scale.set(0.6 * 1.15, 0.6 * 1.15);
		}
	}

	public function setValue(v:String, bypass:Bool = false) {
		// trace(v);
		if (!locked || bypass) {
		if (value.length != 0) {
			for (l in value) {
				remove(l);
				l.destroy();
			}
			value = [];
		}
		if (v.length == 0) return;
		var lastLetterPos:Float = 20;
		var i = v.length - 1;
		while (i != -1) {
			var char:String = v.charAt(i);
			// trace(i);
			// trace(char);
			var type = -1;
			// var capital = char.toUpperCase() == char;
			if (Alphabet.AlphaCharacter.alphabet.indexOf(char.toLowerCase()) != -1) type = 0;
			if (Alphabet.AlphaCharacter.numbers.indexOf(char) != -1) type = 1;
			if (Alphabet.AlphaCharacter.symbols.indexOf(char) != -1) type = 2;

			var alphaCharacter:Alphabet.AlphaCharacter = new Alphabet.AlphaCharacter(Std.int(FlxG.width - 120 - lastLetterPos), 20, FlxColor.WHITE);

			alphaCharacter.setGraphicSize(Std.int(alphaCharacter.width * 0.5));
			switch(type) {
				case 0:
					alphaCharacter.createLetter(char);
					alphaCharacter.updateHitbox();
					value.push(alphaCharacter);
					add(alphaCharacter);
					alphaCharacter.y -= 60;
					alphaCharacter.x -= AlphaCharacter.widths[char] != null ? (Std.int(AlphaCharacter.widths[char] / 2)) : Std.int(alphaCharacter.width);
					lastLetterPos += AlphaCharacter.widths[char] != null ? (Std.int(AlphaCharacter.widths[char] / 2)) : Std.int(alphaCharacter.width) + 5;
				case 1:
					alphaCharacter.createNumber(char, true);
					alphaCharacter.updateHitbox();
					value.push(alphaCharacter);
					add(alphaCharacter);
					alphaCharacter.y -= 60;
					lastLetterPos += AlphaCharacter.widths[char] != null ? (Std.int(AlphaCharacter.widths[char] / 2)) : Std.int(alphaCharacter.width) + 5;
					alphaCharacter.offset.x = 17.5;
				case 2:
					alphaCharacter.createSymbol(char);
					alphaCharacter.updateHitbox();
					value.push(alphaCharacter);
					add(alphaCharacter);
					if (char == ".") {
						alphaCharacter.y -= Std.int(57 / 2);
					}
					lastLetterPos += AlphaCharacter.widths[char] != null ? (Std.int(AlphaCharacter.widths[char] / 2)) : Std.int(alphaCharacter.width) + 5;
				default:
					lastLetterPos += 30;
					alphaCharacter.destroy();
			}
			// lastLetterPos += 10;
			i--;
		}
	}
	}

	public function up(elapsed:Float) {
		// super.update(elapsed);
		// if (checkbox != null)
		// 	if (checkbox.animation.curAnim.finished)
		// 		checkbox.animation.play(checkboxChecked ? "checked" : "unchecked", true);
	}
}
typedef MenuCategory = {
	public var name:String;
	public var description:String;
	public var options:Array<Option>;
	public var center:Bool;	
	public var locked:Bool; //locks a category so you can't enter it.
}
typedef Option = {
	public var text:String;
	public var description:String;
	public var updateOnSelected:(Float,FNFOption)->Void;
	public var checkbox:Bool;
	public var checkboxChecked:Void->Bool;
	public var value:Void->String;
	public var locked:Bool; //locks an option so you can't change it.
}
class OptionsMenu extends MusicBeatState
{
	var selector:FlxText;
	var curSelected:Int = 0;
	var usable:Bool = false;
	public static var fromFreeplay:Bool = false;

	var menuBGx:Float = 0;
	var menuBGy:Float = 0;
	public var optionsAlphabets:FlxSpriteGroup = new FlxSpriteGroup();

	public function new(x:Float, y:Float, ?transIn, ?transOut) {
		super(transIn, transOut);
		menuBGx = x;
		menuBGy = -y;
	}

	public var desc:FlxText;

	public var settings:Array<MenuCategory> = [

	];
	function addControlsCategory() {
		var kBinds:MenuCategory = {
			name : "Keybinds",
			description : "Change your keybinds here !",
			options : [],
			center : false,
			locked :  false
		};
		kBinds.options.push({
			text : "[Keybinds]",
			description : "",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return "";},
			locked: false
		});
		var controlKeys:Array<Int> = [];
		var it = ModSupport.modConfig.keys();
		while(it.hasNext()) {
			var e = it.next();
			var config = ModSupport.modConfig[e];
			if (config.keyNumbers != null) {
				for (k in config.keyNumbers) {
					if (!controlKeys.contains(k)) controlKeys.push(k);
				}
			}
		}
		haxe.ds.ArraySort.sort(controlKeys, function(x, y) {
			return x - y;
		});
		for (index => value in controlKeys) {
			kBinds.options.push({
				text : Std.string(value) + ' keys',
				description : "Change your keybinds for " + Std.string(value) + " keys charts.",
				updateOnSelected: function(elapsed:Float, o:FNFOption) {
					if (controls.ACCEPT) {
						// FlxG.switchState(new ControlsSettings(value));
						var s = new ControlsSettingsSub(value, FlxG.camera);
						s.closeCallback = function() {
							o.setValue([for(i in 0...value) ControlsSettingsSub.getKeyName(cast(Reflect.field(Settings.engineSettings.data, 'control_' + value + '_$i'), FlxKey), true)].join(" "));
						};
						openSubState(s);
					}
				},
				checkbox: false,
				checkboxChecked: function() {return false;},
				locked: false,
				value: function() {return [for(i in 0...value) ControlsSettingsSub.getKeyName(cast(Reflect.field(Settings.engineSettings.data, 'control_' + value + '_$i'), FlxKey), true)].join(" ");}
			});
		}

		kBinds.options.push({
			text : "[]",
			description : "",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return "";},
				locked: false
		});
		settings.push(kBinds);
	}

	function addGameplayCategory() {

		var gameplay:MenuCategory = {
			name : "Gameplay",
			description : "Configure Gameplay settings like accuracy, downscroll and scroll speed.",
			options : [],
			center : false,
			locked :  false
		};
		gameplay.options.push({
			text : "[Gameplay]",
			description : "",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return "";},
			locked: false
		});
		gameplay.options.push({
			text : "Downscroll",
			description : "When enabled, makes the note go from up to down instead of down to up.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.downscroll = !Settings.engineSettings.data.downscroll;
					o.checkboxChecked = Settings.engineSettings.data.downscroll;
					o.check(Settings.engineSettings.data.downscroll);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.downscroll;},
			value: function() {return "";},
				locked: false
		});
		gameplay.options.push({
			text : "Middlescroll",
			description : "When enabled, moves your strums to the center, and hides the opponents' ones.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				/*if (controls.ACCEPT) {
					Settings.engineSettings.data.middleScroll = !Settings.engineSettings.data.middleScroll;
					o.checkboxChecked = Settings.engineSettings.data.middleScroll;
					o.check(Settings.engineSettings.data.middleScroll);
				}*/
				Settings.engineSettings.data.middleScroll = false;
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.middleScroll;},
			value: function() {return "";},
				locked: true
		});
		gameplay.options.push({
			text : "Custom scroll speed",
			description : "If enabled, sets the scroll speed value to the desired value for all charts. Defaults to disabled.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.customScrollSpeed = !Settings.engineSettings.data.customScrollSpeed;
					o.checkboxChecked = Settings.engineSettings.data.customScrollSpeed;
					o.check(Settings.engineSettings.data.customScrollSpeed);
				}
				if (controls.LEFT_P) {
					Settings.engineSettings.data.scrollSpeed = round(Settings.engineSettings.data.scrollSpeed - 0.1, 2);
					if (Settings.engineSettings.data.scrollSpeed < 0.1) Settings.engineSettings.data.scrollSpeed = 0.1;

					var str = Std.string(Settings.engineSettings.data.scrollSpeed);
					if (str.indexOf(".") == -1) str += ".0";

					o.setValue(str);
				}
				if (controls.RIGHT_P) {
					Settings.engineSettings.data.scrollSpeed = round(Settings.engineSettings.data.scrollSpeed + 0.1, 2);
					if (Settings.engineSettings.data.scrollSpeed > 10) Settings.engineSettings.data.scrollSpeed = 10;

					var str = Std.string(Settings.engineSettings.data.scrollSpeed);
					if (str.indexOf(".") == -1) str += ".0";

					o.setValue(str);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.customScrollSpeed;},
			value: function() {return Std.string(Settings.engineSettings.data.scrollSpeed).indexOf(".") == -1 ? Std.string(Settings.engineSettings.data.scrollSpeed) + ".0" : Std.string(Settings.engineSettings.data.scrollSpeed);},
				locked: false
		});
		gameplay.options.push({
			text : "Note Offset",
			description : "Sets the note offset.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.LEFT_P) {
					Settings.engineSettings.data.noteOffset -= 10;
					o.setValue('${Std.string(Settings.engineSettings.data.noteOffset)} ms');
				}
				if (controls.RIGHT_P) {
					Settings.engineSettings.data.noteOffset += 10;
					o.setValue('${Std.string(Settings.engineSettings.data.noteOffset)} ms');
				}
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return '${Std.string(Settings.engineSettings.data.noteOffset)} ms';},
				locked: false
		});
		gameplay.options.push({
			text : "Botplay",
			description : "When enabled, will let a bot play the game instead of you. Useful for recording mod showcases.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				/*if (controls.ACCEPT) {
					Settings.engineSettings.data.botplay = !Settings.engineSettings.data.botplay;
					o.checkboxChecked = Settings.engineSettings.data.botplay;
					o.check(Settings.engineSettings.data.botplay);
				}*/
				Settings.engineSettings.data.botplay = false;
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.botplay;},
			value: function() {return "";},
				locked: true
		});
		gameplay.options.push({
			text : "Reset Button",
			description : "When checked, will allow the player to press R to blue ball itself.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.resetButton = !Settings.engineSettings.data.resetButton;
					o.checkboxChecked = Settings.engineSettings.data.resetButton;
					o.check(Settings.engineSettings.data.resetButton);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.resetButton;},
			value: function() {return "";},
				locked: false
		});
		gameplay.options.push({
			text : "Ghost tapping",
			description : "When unchecked, will miss everytime the player presses while there's no notes.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.ghostTapping = !Settings.engineSettings.data.ghostTapping;
					o.checkboxChecked = Settings.engineSettings.data.ghostTapping;
					o.check(Settings.engineSettings.data.ghostTapping);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.ghostTapping;},
			value: function() {return "";},
				locked: false
		});
		gameplay.options.push({
			text : "Accuracy mode",
			description : "Sets the accuracy mode. \"Simple\" means based on the rating, \"Complex\" means based on the press delay.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					var newVar = Settings.engineSettings.data.accuracyMode + 1;
					if (newVar >= ScoreText.accuracyTypesText.length) newVar = 0;
					Settings.engineSettings.data.accuracyMode = newVar;
					o.setValue(ScoreText.accuracyTypesText[newVar]);
				}
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return ScoreText.accuracyTypesText[Settings.engineSettings.data.accuracyMode];},
				locked: false
		});
		gameplay.options.push({
			text : "[]",
			description : "",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return "";},
				locked: false
		});

		settings.push(gameplay);
	}

	function addHealthBarRatingCategory() {
		var guiOptions:MenuCategory = {
			name : "GUI Options",
			description : "Configure GUI options like enabling and disabling the timer, accuracy, misses, ect...",
			options : [],
			center : false,
			locked :  false
		};
		guiOptions.options.push(
		{
			text : "[GUI Options]",
			description : "",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return "";},
				locked: false
		});
		guiOptions.options.push({
			text : "GUI scale",
			description : "Sets the main GUI's scale. Defaults to 1.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.LEFT_P) {
					Settings.engineSettings.data.noteScale = round((Settings.engineSettings.data.noteScale * 2) - 0.1, 2) / 2;
					if (Settings.engineSettings.data.noteScale < 0.1) Settings.engineSettings.data.noteScale = 0.1;

					var str = Std.string(Settings.engineSettings.data.noteScale);
					if (str.indexOf(".") == -1) str += ".0";

					o.setValue(str);
				}
				if (controls.RIGHT_P) {
					Settings.engineSettings.data.noteScale = round((Settings.engineSettings.data.noteScale * 2) + 0.1, 2) / 2;
					if (Settings.engineSettings.data.noteScale > 10) Settings.engineSettings.data.noteScale = 10;

					var str = Std.string(Settings.engineSettings.data.noteScale);
					if (str.indexOf(".") == -1) str += ".0";

					o.setValue(str);
				}
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
				locked: false,
			value: function() {return Std.string(Settings.engineSettings.data.noteScale).indexOf(".") == -1 ? Std.string(Settings.engineSettings.data.noteScale) + ".0" : Std.string(Settings.engineSettings.data.noteScale);}
		});
		guiOptions.options.push({
			text : "Show timer",
			description : "If enabled, shows a timer at the top of the screen displaying the current song's position.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.showTimer = !Settings.engineSettings.data.showTimer;
					o.checkboxChecked = Settings.engineSettings.data.showTimer;
					o.check(Settings.engineSettings.data.showTimer);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.showTimer;},
			value: function() {return "";},
				locked: false
		});
		guiOptions.options.push({
			text : "Show press delay",
			description : "If enabled, will show the delay in milliseconds above the strums everytime you press.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.showPressDelay = !Settings.engineSettings.data.showPressDelay;
					o.checkboxChecked = Settings.engineSettings.data.showPressDelay;
					o.check(Settings.engineSettings.data.showPressDelay);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.showPressDelay;},
			value: function() {return "";},
				locked: false
		});
		guiOptions.options.push({
			text : "Bump press delay",
			description : "If checked, will do a bump animation on the press delay label everytime you hit a note. Enabled by default.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.animateMsLabel = !Settings.engineSettings.data.animateMsLabel;
					o.checkboxChecked = Settings.engineSettings.data.animateMsLabel;
					o.check(Settings.engineSettings.data.animateMsLabel);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.animateMsLabel;},
			value: function() {return "";},
				locked: false
		});
		guiOptions.options.push({
			text : "Show accuracy",
			description : "If enabled, will add your accuracy next to the score.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.showAccuracy = !Settings.engineSettings.data.showAccuracy;
					o.checkboxChecked = Settings.engineSettings.data.showAccuracy;
					o.check(Settings.engineSettings.data.showAccuracy);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.showAccuracy;},
			value: function() {return "";},
				locked: false
		});
		guiOptions.options.push({
			text : "Show accuracy mode",
			description : "When checked, will show the accuracy mode next to the accuracy.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.showAccuracyMode = !Settings.engineSettings.data.showAccuracyMode;
					o.checkboxChecked = Settings.engineSettings.data.showAccuracyMode;
					o.check(Settings.engineSettings.data.showAccuracyMode);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.showAccuracyMode;},
			value: function() {return "";},
				locked: false
		});
		guiOptions.options.push({
			text : "Show number of misses",
			description : "If enabled, will add the amount of misses next to the score.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.showMisses = !Settings.engineSettings.data.showMisses;
					o.checkboxChecked = Settings.engineSettings.data.showMisses;
					o.check(Settings.engineSettings.data.showMisses);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.showMisses;},
			value: function() {return "";},
				locked: false
		});
		guiOptions.options.push({
			text : "Show ratings amount",
			description : "If enabled, will add the number of notes hit for each rating at the right of the screen.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.showRatingTotal = !Settings.engineSettings.data.showRatingTotal;
					o.checkboxChecked = Settings.engineSettings.data.showRatingTotal;
					o.check(Settings.engineSettings.data.showRatingTotal);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.showRatingTotal;},
			value: function() {return "";},
				locked: false
		});
		guiOptions.options.push({
			text : "Show average hit delay",
			description : "If enabled, will add your average delay in milliseconds next to the score.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.showAverageDelay = !Settings.engineSettings.data.showAverageDelay;
					o.checkboxChecked = Settings.engineSettings.data.showAverageDelay;
					o.check(Settings.engineSettings.data.showAverageDelay);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.showAverageDelay;},
			value: function() {return "";},
				locked: false
		});
		guiOptions.options.push({
			text : "Show rating",
			description : "If enabled, will show your rating next to the score (ex : FC).",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.showRating = !Settings.engineSettings.data.showRating;
					o.checkboxChecked = Settings.engineSettings.data.showRating;
					o.check(Settings.engineSettings.data.showRating);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.showRating;},
			value: function() {return "";},
				locked: false
		});
		guiOptions.options.push({
			text : "Animate the info bar",
			description : "If enabled, will \"pop\" the info bar at the bottom of the screen everytime you press a note.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.animateInfoBar = !Settings.engineSettings.data.animateInfoBar;
					o.checkboxChecked = Settings.engineSettings.data.animateInfoBar;
					o.check(Settings.engineSettings.data.animateInfoBar);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.animateInfoBar;},
			value: function() {return "";},
				locked: false
		});
		guiOptions.options.push({
			text : "Show watermark",
			description : "When checked, will show a watermark at the top right of the screen with the mod name, the mod song and the Yoshi Engine version. \n(why would you use this -Discussions)",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.watermark = !Settings.engineSettings.data.watermark;
					o.checkboxChecked = Settings.engineSettings.data.watermark;
					o.check(Settings.engineSettings.data.watermark);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.watermark;},
			value: function() {return "";},
				locked: false
		});
		guiOptions.options.push({
			text : "Minimal mode",
			description : "When checked, will minimize the Score Text width.
[When Disabled] Score: 123456 | Misses: 0 | Accuracy: 100% (Simple) | Average: 5ms | S (MFC)
[When Enabled] 123456 pts | 0 Misses | 100% (S) | ~ 5ms | S (MFC)",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.minimizedMode = !Settings.engineSettings.data.minimizedMode;
					o.checkboxChecked = Settings.engineSettings.data.minimizedMode;
					o.check(Settings.engineSettings.data.minimizedMode);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.minimizedMode;},
			value: function() {return "";},
				locked: false
		});
		
		guiOptions.options.push({
			text : "Score Text Size",
			description : "Sets the score text size. 16 is base game size, 20 is Psych size. Defaults to 18.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				var changed = false;
				if (controls.LEFT_P) {
					Settings.engineSettings.data.scoreTextSize -= 1;
					changed = true;
				}
				if (controls.RIGHT_P) {
					Settings.engineSettings.data.scoreTextSize += 1;
					changed = true;
				}
				if (changed) {
					if (Settings.engineSettings.data.scoreTextSize < 8) Settings.engineSettings.data.scoreTextSize = 8;
					if (Settings.engineSettings.data.scoreTextSize > 40) Settings.engineSettings.data.scoreTextSize = 40;
					o.setValue('${Std.string(Settings.engineSettings.data.scoreTextSize)}');
				}
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return '${Std.string(Settings.engineSettings.data.scoreTextSize)}';},
				locked: false
		});
		
		settings.push(guiOptions);
	}

	function addCustomNotesCategory() {
		var customisation:MenuCategory = {
			name : "Customisation",
			description : "Customise and make FNF yours ! Note colors, custom note skins, Boyfriend skins, Girlfriend skins.",
			options : [],
			center : false,
			locked :  false
		};

		customisation.options.push({
			text : "[Customisation]",
			description : "",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return "";},
				locked: false
		});
		customisation.options.push({
			text : "Glow CPU strums",
			description : "Check this to glow CPU strums whenever they hit a note.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.glowCPUStrums = !Settings.engineSettings.data.glowCPUStrums;
					o.checkboxChecked = Settings.engineSettings.data.glowCPUStrums;
					o.check(Settings.engineSettings.data.glowCPUStrums);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.glowCPUStrums;},
			value: function() {return "";},
				locked: false
		});
		customisation.options.push({
			text : "Custom note colors",
			description : "Check this to enable custom note colors.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.customArrowColors = !Settings.engineSettings.data.customArrowColors;
					o.checkboxChecked = Settings.engineSettings.data.customArrowColors;
					o.check(Settings.engineSettings.data.customArrowColors);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.customArrowColors;},
			value: function() {return "";},
				locked: false
		});
		customisation.options.push({
			text : "Enable Note Motion Blur",
			description : "Check this to enable motion blur on notes. If enabled, will make the notes smoother, but can slow down the graphics. Defaults to disabled.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.noteMotionBlurEnabled = !Settings.engineSettings.data.noteMotionBlurEnabled;
					o.checkboxChecked = Settings.engineSettings.data.noteMotionBlurEnabled;
					o.check(Settings.engineSettings.data.noteMotionBlurEnabled);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.noteMotionBlurEnabled;},
			value: function() {return "";},
				locked: false
		});
		customisation.options.push({
			text : "Note Motion Blur Multiplier",
			description : "The multiplier of how blurry the notes will get when Enable Motion Blur is enabled. If you think the notes still feels like stuttering, increasing this option may help. Higher values means blurrier notes. Defaults to 1.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				var changed = false;
				if (controls.LEFT_P) {
					Settings.engineSettings.data.noteMotionBlurMultiplier -= 0.1;
					changed = true;
				}
				if (controls.RIGHT_P) {
					Settings.engineSettings.data.noteMotionBlurMultiplier += 0.1;
					changed = true;
				}
				if (changed) {
					if (Settings.engineSettings.data.noteMotionBlurMultiplier < 0.1) Settings.engineSettings.data.noteMotionBlurMultiplier = 0.1;
					if (Settings.engineSettings.data.noteMotionBlurMultiplier > 3) Settings.engineSettings.data.noteMotionBlurMultiplier = 3;
					o.setValue(Std.string(FlxMath.roundDecimal(Settings.engineSettings.data.noteMotionBlurMultiplier, 1)));
				}
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return Std.string(FlxMath.roundDecimal(Settings.engineSettings.data.noteMotionBlurMultiplier, 1));},
				locked: false
		});
		customisation.options.push({
			text : "Transparent note tails",
			description : "If enabled, will make sustain notes (note tails) semi-transparent.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.transparentSubstains = !Settings.engineSettings.data.transparentSubstains;
					o.checkboxChecked = Settings.engineSettings.data.transparentSubstains;
					o.check(Settings.engineSettings.data.transparentSubstains);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.transparentSubstains;},
			value: function() {return "";},
				locked: false
		});
		customisation.options.push({
			text : "Apply notes colors on everyone",
			description : "If checked, will also apply your character note colors to the opponent.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.customArrowColors_allChars = !Settings.engineSettings.data.customArrowColors_allChars;
					o.checkboxChecked = Settings.engineSettings.data.customArrowColors_allChars;
					o.check(Settings.engineSettings.data.customArrowColors_allChars);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.customArrowColors_allChars;},
			value: function() {return "";},
				locked: false
		});
		

		customisation.options.push({
			text : "Customize Note Colors",
			description : "Select this to customize note colors.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					FlxG.switchState(new OptionsNotesColors());
				}
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return "";},
				locked: false
		});

		#if sys
			if (sys.FileSystem.exists(Paths.getSkinsPath() + "/notes/")) {
				var skins:Array<String> = [];
				skins.insert(0, "default");
				var sPath = Paths.getSkinsPath();
				for (f in FileSystem.readDirectory('$sPath/notes/')) {
					if (f.endsWith(".png") && !FileSystem.isDirectory('$sPath/notes/$f')) {
						var skinName = f.substr(0, f.length - 4);
						if (FileSystem.exists('$sPath/notes/$skinName.xml')) {
							skins.push(skinName);
						}
					}
				}

				if (skins.indexOf(Settings.engineSettings.data.customArrowSkin) == -1) Settings.engineSettings.data.customArrowSkin = "default";
				var pos:Int = skins.indexOf(Settings.engineSettings.data.customArrowSkin);

				customisation.options.push({
					text : "Arrow skin",
					description : "Select an arrow skin here. To install one, open the \"skins\" folder and follow the instructions in the text file.",
					updateOnSelected: function(elapsed:Float, o:FNFOption) {
						var changed = false;
						if (controls.LEFT_P) {
							pos--;
							changed = true;
						}
						if (controls.RIGHT_P || controls.ACCEPT) {
							pos++;
							changed = true;
						}
						if (changed) {
							if (pos < 0) pos = skins.length - 1;
							if (pos >= skins.length) pos = 0;
							Settings.engineSettings.data.customArrowSkin = skins[pos];
							o.setValue(Settings.engineSettings.data.customArrowSkin);
						}
					},
					checkbox: false,
					checkboxChecked: function() {return false;},
					value: function() {return Settings.engineSettings.data.customArrowSkin;},
						locked: false
				});
			}
			
			var bfSkins:Array<String> = [for (s in sys.FileSystem.readDirectory(Paths.getSkinsPath() + "/bf/")) if (FileSystem.isDirectory('${Paths.getSkinsPath()}/bf/$s')) s];
			bfSkins.insert(0, "default");
			bfSkins.remove("template");
	
			if (bfSkins.indexOf(Settings.engineSettings.data.customBFSkin) == -1) Settings.engineSettings.data.customBFSkin = "default";
			var posBF:Int = bfSkins.indexOf(Settings.engineSettings.data.customBFSkin);
	
			customisation.options.push({
				text : "Boyfriend skin",
				description : "Select a Boyfriend skin from a mod, or from your skins folder.",
				updateOnSelected: function(elapsed:Float, o:FNFOption) {
					var changed = false;
					if (controls.LEFT_P) {
						posBF--;
						changed = true;
					}
					if (controls.RIGHT_P || controls.ACCEPT) {
						posBF++;
						changed = true;
					}
					if (changed) {
						if (posBF < 0) posBF = bfSkins.length - 1;
						if (posBF >= bfSkins.length) posBF = 0;
						Settings.engineSettings.data.customBFSkin = bfSkins[posBF].toLowerCase();
						o.setValue(Settings.engineSettings.data.customBFSkin);
					}
				},
				checkbox: false,
				checkboxChecked: function() {return false;},
				value: function() {return Settings.engineSettings.data.customBFSkin;},
					locked: false
			});
		

			var gfSkins:Array<String> = [for (s in sys.FileSystem.readDirectory(Paths.getSkinsPath() + "/gf/")) if (FileSystem.isDirectory('${Paths.getSkinsPath()}/gf/$s')) s];
			gfSkins.insert(0, "default");
			gfSkins.remove("template");

			var posGF:Int = gfSkins.indexOf(Settings.engineSettings.data.customGFSkin);
	
			if (gfSkins.indexOf(Settings.engineSettings.data.customGFSkin) == -1) Settings.engineSettings.data.customGFSkin = "default";
	
			customisation.options.push({
				text : "Girlfriend skin",
				description : "Select a Girlfriend skin from a mod, or from your skins folder.",
				updateOnSelected: function(elapsed:Float, o:FNFOption) {
					var changed = false;
					if (controls.LEFT_P) {
						posGF--;
						changed = true;
					}
					if (controls.RIGHT_P || controls.ACCEPT) {
						posGF++;
						changed = true;
					}
					if (changed) {
						if (posGF < 0) posGF = gfSkins.length - 1;
						if (posGF >= gfSkins.length) posGF = 0;
						Settings.engineSettings.data.customGFSkin = gfSkins[posGF].toLowerCase();
						o.setValue(Settings.engineSettings.data.customGFSkin);
					}
				},
				checkbox: false,
				checkboxChecked: function() {return false;},
				value: function() {return Settings.engineSettings.data.customGFSkin;},
					locked: false
			});
			
		#end

		#if desktop
		customisation.options.push({
			text : "Open skin folder",
			description : "Select this to open the skins folder.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					var p = Paths.getSkinsPath().replace("/", "\\");
					trace(p);
					#if windows
						Sys.command('explorer "$p"');	
					#end
					#if linux
						Sys.command('nautilus', [p]);	
					#end
				}
				
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return "";},
				locked: false
		});
		#end

		customisation.options.push({
			text : "[]",
			description : "",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return "";},
				locked: false
		});

		settings.push(customisation);
	}

	function addPerformanceCategory() {
		var performance:MenuCategory = {
			name : "Graphic Settings",
			description : "Optimise the engine with memory and graphics settings.",
			options : [],
			center : false,
			locked :  false
		};
		performance.options.push({
			text : "[Graphic Settings]",
			description : "",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return "";},
				locked: false
		});
		
		var stageQualities = ["Best", "High", "Low", "Medium"];
		performance.options.push(
		{
			text : "Stage Quality",
			description : "Sets the Stage Quality of the game. You can choose between 4 different types:
- Low: No antialiasing, no bitmap smoothing
- Medium: 2x2 pixel grid antialiasing, no bitmap smoothing
- High: 4x4 pixel grid antialiasing, smooths bitmaps if the game is static
- Best: 4x4 pixel grid antialiasing, always smooth bitmaps",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				var changed = false;
				if (controls.RIGHT_P) {
					changed = true;
					Settings.engineSettings.data.stageQuality++;
				}
				if (controls.LEFT_P) {
					changed = true;
					Settings.engineSettings.data.stageQuality--;
				}
				if (changed) {
					if (Settings.engineSettings.data.stageQuality < 0) Settings.engineSettings.data.stageQuality = stageQualities.length - 1;
					else if (Settings.engineSettings.data.stageQuality >= stageQualities.length) Settings.engineSettings.data.stageQuality = 0;
					o.setValue(stageQualities[Settings.engineSettings.data.stageQuality]);
					FlxG.game.stage.quality = Settings.engineSettings.data.stageQuality;
				}
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return stageQualities[Settings.engineSettings.data.stageQuality];},
				locked: false
		});
		
		performance.options.push(
		{
			text : "Antialiasing",
			description : "If unchecked, will disable anti-aliasing for every sprite, netherless of if the script enables it or not.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.antialiasing = !Settings.engineSettings.data.antialiasing;
					o.check(Settings.engineSettings.data.antialiasing);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.antialiasing;},
			value: function() {return "";},
				locked: false
		});
		
		performance.options.push(
		{
			text : "Note antialiasing",
			#if android
			description : "If unchecked, will disable anti-aliasing for notes, to allow better performance on mobile devices. Does not affect strums. Disabled by default.",
			#else
			description : "If unchecked, will disable anti-aliasing for notes, to allow better performance on lower end PCs. Does not affect strums. Enabled by default.",
			#end
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.noteAntialiasing = !Settings.engineSettings.data.noteAntialiasing;
					o.check(Settings.engineSettings.data.noteAntialiasing);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.noteAntialiasing;},
			value: function() {return "";},
				locked: false
		});
		
		performance.options.push(
		{
			text : "Maximum Framerate",
			description : "Sets the maximum framerate the game can have. If the value is higher than what's your " + #if desktop "computer" #elseif android "phone/tablet" #else "device" #end + " is capable of, slowdowns during animations may happen.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.LEFT_P || (controls.LEFT && FlxControls.pressed.SHIFT)) {
					Settings.engineSettings.data.fpsCap -= 5;
					if (Settings.engineSettings.data.fpsCap < 20) Settings.engineSettings.data.fpsCap = 20;

					o.setValue(Settings.engineSettings.data.fpsCap);
					FlxG.drawFramerate = Settings.engineSettings.data.fpsCap;
					FlxG.updateFramerate = Settings.engineSettings.data.fpsCap;
				}
				if (controls.RIGHT_P || (controls.RIGHT && FlxControls.pressed.SHIFT)) {
					Settings.engineSettings.data.fpsCap += 5;
					if (Settings.engineSettings.data.fpsCap > 400) Settings.engineSettings.data.fpsCap = 400;

					o.setValue(Settings.engineSettings.data.fpsCap);
					FlxG.drawFramerate = Settings.engineSettings.data.fpsCap;
					FlxG.updateFramerate = Settings.engineSettings.data.fpsCap;
				}
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return Settings.engineSettings.data.fpsCap;},
				locked: false
		});
		performance.options.push({
			text : "Enable antialiasing on videos",
			description : "If checked, will enable antialiasing on MP4 videos (cutscenes, ect...)",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.videoAntialiasing = !Settings.engineSettings.data.videoAntialiasing;
					o.checkboxChecked = Settings.engineSettings.data.videoAntialiasing;
					o.check(Settings.engineSettings.data.videoAntialiasing);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.videoAntialiasing;},
			value: function() {return "";},
				locked: false
		});
		performance.options.push({
			text : "Memory Optimisation",
			description : "If checked, will optimize the memory of the game by clearing the assets.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.memoryOptimization = !Settings.engineSettings.data.memoryOptimization;
					o.checkboxChecked = Settings.engineSettings.data.memoryOptimization;
					o.check(Settings.engineSettings.data.memoryOptimization);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.memoryOptimization;},
			value: function() {return "";},
				locked: false
		});
		#if sys
		performance.options.push({
			text : "Auto clear skin cache",
			description : "If checked, will automatically empty cache after each song.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.emptySkinCache = !Settings.engineSettings.data.emptySkinCache;
					o.checkboxChecked = Settings.engineSettings.data.emptySkinCache;
					o.check(Settings.engineSettings.data.emptySkinCache);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.emptySkinCache;},
			value: function() {return "";},
				locked: false
		});
		performance.options.push({
			text : "Clear Cache",
			description : "Select this to clear the cache.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Paths.clearCache();
					Paths.clearModCache();
					o.setValue("Cache Cleared");
				}
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return "";},
				locked: false
		});
		#end
		performance.options.push({
			text : "[]",
			description : "",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return "";},
				locked: false
		});
		settings.push(performance);
	}

	function addMiscCategory() {
		var misc:MenuCategory = {
			name : "Miscellaneous",
			description : "Other options like Green Screen and hiding original game.",
			options : [],
			center : false,
			locked :  false
		};
		misc.options.push({
			text : "[Miscellaneous]",
			description : "",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return "";},
				locked: false
		});
		misc.options.push({
			text : "Green screen mode",
			description : "When enabled, shows a green screen behind the GUI. (???)",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.greenScreenMode = !Settings.engineSettings.data.greenScreenMode;
					o.checkboxChecked = Settings.engineSettings.data.greenScreenMode;
					o.check(Settings.engineSettings.data.greenScreenMode);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.greenScreenMode;},
			value: function() {return "";},
				locked: false
		});
		misc.options.push({
			text : "Hide original game",
			description : "When enabled, hides the base game from the Story Menu and Freeplay if any other mod is present.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				/*if (controls.ACCEPT) {
					Settings.engineSettings.data.hideOriginalGame = !Settings.engineSettings.data.hideOriginalGame;
					o.checkboxChecked = Settings.engineSettings.data.hideOriginalGame;
					o.check(Settings.engineSettings.data.hideOriginalGame);

					StoryMenuState.loadWeeks();
					FreeplayState.loadFreeplaySongs();
				}*/
				Settings.engineSettings.data.hideOriginalGame == true;
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.hideOriginalGame;},
			value: function() {return "";},
				locked: true
		});
		misc.options.push({
			text : "Auto-Pause",
			description : "When enabled, pauses the game automatically when the focus is lost. Checked by default.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.autopause = !Settings.engineSettings.data.autopause;
					o.checkboxChecked = Settings.engineSettings.data.autopause;
					o.check(Settings.engineSettings.data.autopause);
					FlxG.autoPause = Settings.engineSettings.data.autopause;
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.autopause;},
			value: function() {return "";},
				locked: false
		});
		misc.options.push({
			text : "Separate mods in menus",
			description : "If checked, will separate each mod into their own respective list. For example, if the \"Friday Night Funkin'\" mod is selected, only songs and weeks from the Friday Night Funkin' mod will be shown in the menus. Mods with menu scripts will have this option on by default.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.freeplayShowAll = !Settings.engineSettings.data.freeplayShowAll;
					o.checkboxChecked = !Settings.engineSettings.data.freeplayShowAll;
					o.check(!Settings.engineSettings.data.freeplayShowAll);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return !Settings.engineSettings.data.freeplayShowAll;},
			value: function() {return "";},
				locked: false
		});
		misc.options.push({
			text : "Auto add new installed mods",
			description : "If checked, will separate each mod into their own respective list. For example, if the \"Friday Night Funkin'\" mod is selected, only songs and weeks from the Friday Night Funkin' mod will be shown in the menus. Mods with menu scripts will have this option on by default.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.autoSwitchToLastInstalledMod = !Settings.engineSettings.data.autoSwitchToLastInstalledMod;
					o.checkboxChecked = Settings.engineSettings.data.autoSwitchToLastInstalledMod;
					o.check(Settings.engineSettings.data.autoSwitchToLastInstalledMod);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.autoSwitchToLastInstalledMod;},
			value: function() {return "";},
				locked: false
		});
		misc.options.push({
			text : "Show FPS",
			description : "If enabled, will show the current FPS at the top left of the screen.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.fps_showFPS = !Settings.engineSettings.data.fps_showFPS;
					o.checkboxChecked = Settings.engineSettings.data.fps_showFPS;
					o.check(Settings.engineSettings.data.fps_showFPS);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.fps_showFPS;},
			value: function() {return "";},
				locked: false
		});
		misc.options.push({
			text : "Show Memory",
			description : "If enabled, will show the current used memory at the top left of the screen.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.fps_showMemory = !Settings.engineSettings.data.fps_showMemory;
					o.checkboxChecked = Settings.engineSettings.data.fps_showMemory;
					o.check(Settings.engineSettings.data.fps_showMemory);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.fps_showMemory;},
			value: function() {return "";},
				locked: false
		});
		misc.options.push({
			text : "Show Memory Peak",
			description : "If enabled, will show the maximum amount of memory the game used at the top left of the screen.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.fps_showMemoryPeak = !Settings.engineSettings.data.fps_showMemoryPeak;
					o.checkboxChecked = Settings.engineSettings.data.fps_showMemoryPeak;
					o.check(Settings.engineSettings.data.fps_showMemoryPeak);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.fps_showMemoryPeak;},
			value: function() {return "";},
				locked: false
		});
		// misc.options.push({
		// 	text : "Use new charter",
		// 	updateOnSelected: function(elapsed:Float, o:FNFOption) {
		// 		if (controls.ACCEPT) {
		// 			Settings.engineSettings.data.yoshiEngineCharter = !Settings.engineSettings.data.yoshiEngineCharter;
		// 			o.checkboxChecked = Settings.engineSettings.data.yoshiEngineCharter;
		// 			o.check(Settings.engineSettings.data.yoshiEngineCharter);
		// 		}
		// 	},
		// 	checkbox: true,
		// 	checkboxChecked: function() {return Settings.engineSettings.data.yoshiEngineCharter,
		// 	value: ""
		// });
		misc.options.push({
			text : "[]",
			description : "",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return "";},
				locked: false
		});
		settings.push(misc);
	}

	function addDeveloperCategory() {
		var dev:MenuCategory = {
			name : "Developer Menu",
			description: "Developer related options.",
			options : [],
			center : false,
			locked :  true
		};
		dev.options.push({
			text : "[Developer Menu]",
			description : "",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return "";},
			locked : true
		});
		dev.options.push({
			text : "Developer Mode",
			description : "When checked, enables Developer Mode, which gives access to Logs, and autoclears cache after every state change.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				/*if (controls.ACCEPT) {
					Settings.engineSettings.data.developerMode = !Settings.engineSettings.data.developerMode;
					o.check(Settings.engineSettings.data.developerMode);
				}*/
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.developerMode;},
			value: function() {return "";},
				locked : true
		});
		// dev.options.push({ //?????? -Discussions
		// 	text : "Move camera in Stage Editor",
		// 	description : "If checked, will automatically move the camera to the right in Stage Editor, allowing the user to access more space. If you find that effect annoying, uncheck this option.",
		// 	updateOnSelected: function(elapsed:Float, o:FNFOption) {
		// 		if (controls.ACCEPT) {
		// 			Settings.engineSettings.data.moveCameraInStageEditor = !Settings.engineSettings.data.moveCameraInStageEditor;
		// 			o.check(Settings.engineSettings.data.moveCameraInStageEditor);
		// 		}
		// 	},
		// 	checkbox: true,
		// 	checkboxChecked: function() {return Settings.engineSettings.data.moveCameraInStageEditor;},
		// 	value: function() {return "";}
		// });
		settings.push(dev);
	}
	

	function setOptions(bypass:Bool = false, ?o2:MenuCategory) {
		for (op in optionsAlphabets) {
			remove(op);
			optionsAlphabets.remove(op);
			op.destroy();
		}
		optionsAlphabets.clear();
		usable = false;
		var ops = o2;
		if (ops == null) {
			var s:Array<Option> = [];

			for (mc in settings) {
				s.push({
					text : mc.name,
					description : mc.description,
					value : function() {return "";},
					checkboxChecked: function() {return false;},
					checkbox: false,
					locked: mc.locked,
					updateOnSelected: function(elapsed, option) {
						if (controls.ACCEPT) {
							setOptions(mc.locked, mc);
							isInCategory = true;
						}
					}
				});
			}

			ops = {
				name: "Main Menu",
				options: s,
				description: "Select an option to continue.",
				center: true,
				locked: false
			}
		}
		disabledOptions = [];
		for (i in 0...ops.options.length) {
			var o:Option = ops.options[i];
			var op = null;
			var text = o.text;

			var isTitle = ops.center;
			if (o.text.charAt(0) == "[" && o.text.charAt(o.text.length - 1) == "]") {
				text = o.text.substr(1, o.text.length - 2);
				isTitle = true;
				disabledOptions.push(i);
			}
			op = new FNFOption(0, 0 + (i * 80), text, o.description, function(elapsed:Float) {
				o.updateOnSelected(elapsed, op);
			}, o.checkbox, o.checkboxChecked(), "", o.locked);
			for (i in 0...op.length) {
				var a = op.members[i];
				if (a != op.checkbox) {
					a.setGraphicSize(Std.int(a.width * 0.75));
					if (isTitle) {
						a.x = ((FlxG.width - 100) / 2) - (40 * ((o.checkbox ? op.length - 1 : op.length) / 2)) + (a.x * 0.75);
					} else {
						a.x = a.x * 0.75;
					}
				}
			}
			op.setValue(o.value());
			op.x += 50;
			if (!isTitle) op.x += 50;
			optionsAlphabets.add(op);
		}

		optionsAlphabets.y = FlxG.height * 3;
		curSelected = -1;
		changeSelection(1, false);
		FlxTween.tween(optionsAlphabets, {y: (FlxG.height / 2) - (69 / 2) - (curSelected * 80)}, 0.5, {ease : FlxEase.cubeInOut, onComplete: function(t) {
			usable = true;
		}});
	}

	// var textWidth:Float = FlxG.width;
	// var textX:Float = 0;
	override function create()
	{
		addControlsCategory();
		addGameplayCategory();
		addHealthBarRatingCategory();
		addCustomNotesCategory();
		addPerformanceCategory();
		addMiscCategory();
		addDeveloperCategory();

		if (FlxG.sound.music != null) {
			FlxG.sound.music.onComplete = null;
			if (!FlxG.sound.music.playing) {
				FlxG.sound.music.play();
				FlxG.sound.music.looped = true;
			}
		}

		// FlxAtlasFrames.fromTexturePackerJson()
		

		// var yBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGYoshi'));
		// yBG.setGraphicSize(Std.int(yBG.width * 1.1));
		// yBG.updateHitbox();
		// yBG.screenCenter();
		var yBG = CoolUtil.addBG(this);
		yBG.x = -80;
		yBG.scrollFactor.x = 0;
		yBG.scrollFactor.y = 0.18;
		yBG.scale.x = yBG.scale.y = 1.2;
		yBG.updateHitbox();
		yBG.screenCenter();
		yBG.y -= menuBGy;
		add(yBG);

		// var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		var menuBG = CoolUtil.addWhiteBG(this);
		menuBG.color = 0xFFfd719b;
		menuBG.x = -80;
		menuBG.scrollFactor.x = 0;
		menuBG.scrollFactor.y = 0.18;
		menuBG.scale.x = menuBG.scale.y = 1.2;
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.y -= menuBGy;
		// menuBG.color = 0xFF494949;
		// menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		// menuBG.updateHitbox();
		// menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		// var blackSelectionBar = new FlxSprite(0, (FlxG.height / 2) - (69 / 2)).makeGraphic(Std.int(FlxG.width), 69, new FlxColor(0x88000000));
		// blackSelectionBar.alpha = 0;
		// add(blackSelectionBar);
		optionsAlphabets.scrollFactor.set(0, 0);
		add(optionsAlphabets);
		// FlxTween.tween(menuBG, {"color.red" : 0x49, "color.green" : 0x49, "color.blue" : 0x49}, 0.5, {ease : FlxEase.linear, onComplete: function(t:FlxTween) {
		// 	usable = true;
		// }});
		
		// FlxTween.color(menuBG, 0.5, 0xFFFDE871, 0xFF494949, {ease : FlxEase.cubeInOut, onComplete: function(t:FlxTween) {
		// 	usable = true;
		// }});
		FlxTween.tween(menuBG, {alpha : 0}, 0.5, {onComplete: function(t) {
			usable = true;
			remove(menuBG);
			menuBG.destroy();
		}});
		// FlxTween.tween(blackSelectionBar, {alpha : 1}, 0.5, {ease : FlxEase.cubeInOut});

		// controlsStrings = CoolUtil.coolTextFile(Paths.txt('controls'));

		desc = new FlxText(0, 0, 1280, "Select an option...", 8);
		desc.y = 720;
		desc.setFormat(Paths.font("vcr.ttf"), Std.int(20), FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		desc.antialiasing = true;
		desc.borderSize = 2;
		add(desc);

		setOptions(true);
		super.create();

		#if MOBILE_UI
			// enables mobile ui

			var closeButton = new FlxClickableSprite(15, 15);
			closeButton.frames = Paths.getSparrowAtlas("ui_buttons", "preload");
			closeButton.animation.addByPrefix("x", "x button");
			closeButton.animation.play("x");
			closeButton.key = FlxKey.BACKSPACE;
			closeButton.setHitbox();
			closeButton.antialiasing = true;
			closeButton.hoverColor = 0xFF66CAFF;
			add(closeButton);

			var downButton = new FlxClickableSprite(15, FlxG.height - 15);
			downButton.frames = Paths.getSparrowAtlas("ui_buttons", "preload");
			downButton.animation.addByPrefix("down", "down button");
			downButton.animation.play("down");
			downButton.key = FlxKey.DOWN;
			downButton.y -= downButton.height;
			downButton.setHitbox();
			downButton.antialiasing = true;
			downButton.hoverColor = 0xFF66CAFF;
			add(downButton);

			var upButton = new FlxClickableSprite(15, FlxG.height - 15);
			upButton.frames = Paths.getSparrowAtlas("ui_buttons", "preload");
			upButton.animation.addByPrefix("up", "up button");
			upButton.animation.play("up");
			upButton.key = FlxKey.UP;
			upButton.y -= downButton.height + upButton.height;
			upButton.setHitbox();
			upButton.antialiasing = true;
			upButton.hoverColor = 0xFF66CAFF;
			add(upButton);

			var rightButton = new FlxClickableSprite(FlxG.width - 15, FlxG.height - 15);
			rightButton.frames = Paths.getSparrowAtlas("ui_buttons", "preload");
			rightButton.animation.addByPrefix("right", "right button");
			rightButton.animation.play("right");
			rightButton.key = FlxKey.RIGHT;
			rightButton.y -= rightButton.height;
			rightButton.x -= (rightButton.width / 2);
			rightButton.setHitbox();
			rightButton.antialiasing = true;
			rightButton.hoverColor = 0xFF66CAFF;
			add(rightButton);

			var okButton = new FlxClickableSprite(FlxG.width - 15, FlxG.height - 15);
			okButton.frames = Paths.getSparrowAtlas("ui_buttons", "preload");
			okButton.animation.addByPrefix("select", "select button");
			okButton.animation.play("select");
			okButton.key = FlxKey.ENTER;
			okButton.y -= okButton.height;
			okButton.x -= okButton.width + (rightButton.width / 2);
			okButton.antialiasing = true;
			okButton.hoverColor = 0xFF66CAFF;
			add(okButton);

			var leftButton = new FlxClickableSprite(FlxG.width - 15, FlxG.height - 15);
			leftButton.frames = Paths.getSparrowAtlas("ui_buttons", "preload");
			leftButton.animation.addByPrefix("left", "left button");
			leftButton.animation.play("left");
			leftButton.key = FlxKey.LEFT;
			leftButton.y -= leftButton.height;
			leftButton.x -= (leftButton.width / 2) + (rightButton.width / 2) + okButton.width;
			leftButton.setHitbox();
			leftButton.hitbox.x /= 2;
			leftButton.antialiasing = true;
			leftButton.hoverColor = 0xFF66CAFF;
			add(leftButton);

			desc.x = downButton.x + (downButton.width / 2) + 15;
			desc.fieldWidth = FlxG.width - (FlxG.width - leftButton.x) - (downButton.width / 2) - 30;
		#end



		// openSubState(new OptionsSubState());
	}
	var isInCategory = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (!usable) return;

		if (controls.BACK) {
			CoolUtil.playMenuSFX(2);
			if (isInCategory) {
				setOptions(true);
				isInCategory = false;
				return;
			} else {
				if (fromFreeplay)
					FlxG.switchState(new PlayState());
				else
					FlxG.switchState(new MainMenuState());
			}
		}
			
		if (controls.UP_P)
			changeSelection(-1);
		if (controls.DOWN_P)
			changeSelection(1);
		
		optionsAlphabets.y = FlxMath.lerp(optionsAlphabets.y, (FlxG.height / 2) - (69 / 2) - (curSelected * 80), CoolUtil.wrapFloat(0.1 * 60 * elapsed, 0, 1));
		

		for (i in 0...optionsAlphabets.members.length) {
			if (optionsAlphabets.members[i] != null) (cast (optionsAlphabets.members[i], FNFOption)).up(elapsed);
		}
		if (optionsAlphabets.members[curSelected] != null) (cast (optionsAlphabets.members[curSelected], FNFOption)).updateSelected(elapsed);
	}

	function waitingInput():Void
	{
		// if (FlxControls.getIsDown().length > 0)
		// {
		// 	PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxControls.getIsDown()[0].ID, null);
		// }
		// PlayerSettings.player1.controls.replaceBinding(Control)
	}

	var isSettingControl:Bool = false;

	function changeBinding():Void
	{
		if (!isSettingControl)
		{
			isSettingControl = true;
		}
	}

	// https://stackoverflow.com/questions/23689001/how-to-reliably-format-a-floating-point-number-to-a-specified-number-of-decimal
	public static function round(number:Float, ?precision=2): Float
	{
		number *= Math.pow(10, precision);
		return Math.round(number) / Math.pow(10, precision);
	}

	public var disabledOptions:Array<Int> = [];
	// public var ghreuighesioghseuiogseruiogbseruigbseruiogbretgubgiobreg:FlxTween;
	function changeSelection(change:Int = 0, animate:Bool = true)
	{
		#if !switch
		// NGio .logEvent('Fresh');
		#end

		curSelected += change;
		if (curSelected < 0) curSelected = optionsAlphabets.length - 1;
		if (curSelected >= optionsAlphabets.length) curSelected = 0;

		
		while(disabledOptions.contains(curSelected)) {
			curSelected += change;
			if (curSelected < 0) curSelected = optionsAlphabets.length - 1;
			if (curSelected >= optionsAlphabets.length) curSelected = 0;
		}
		for(k=>op in optionsAlphabets.members) {
			if (k == curSelected) {
				op.alpha = 1;
				desc.text = cast(op, FNFOption).desc;
				desc.y = 700 - (desc.height);
			} else {
				op.alpha = (disabledOptions.contains(k)) ? 1 : 0.45;
			}
		}
		if (!animate) return;
		// if (ghreuighesioghseuiogseruiogbseruigbseruiogbretgubgiobreg != null) ghreuighesioghseuiogseruiogbseruigbseruiogbretgubgiobreg.cancel();
		// FlxTween.tween(optionsAlphabets, {y: (FlxG.height / 2) - (69 / 2) - (curSelected * 80)}, 0.1, {ease : FlxEase.quadInOut});
		// optionsAlphabets.y = ;

		CoolUtil.playMenuSFX(0);
	}
}
