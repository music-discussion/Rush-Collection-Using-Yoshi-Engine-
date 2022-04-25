package dev_toolbox.character_editor;

import EngineSettings.Settings;
import flixel.animation.FlxAnimation;
import flixel.graphics.frames.FlxFrame;
import flixel.ui.FlxSpriteButton;
import flixel.ui.FlxButton;
import NoteShader.ColoredNoteShader;
import haxe.Json;
import sys.io.File;
import sys.FileSystem;
import flixel.math.FlxPoint;
import dev_toolbox.CharacterJSON.CharacterAnim;
import flixel.FlxG;
import flixel.addons.ui.*;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.util.FlxColor;

using StringTools;

class CharacterEditor extends MusicBeatState {
    var camHUD:FlxCamera;
    public var character:Character;
    var animSelection:FlxUIDropDownMenu;
    var anim:FlxUITabMenu;
    var dad:Character;
    var bf:Character;
    var animationTab:FlxUI;
    var closeButton:FlxUIButton;
    var saveButton:FlxUIButton;
    var addAnimButton:FlxUIButton;
    var setShadowRef:FlxUIButton;
    var removeAnimButton:FlxUIButton;
    var animSettingsTabs:FlxUITabMenu;
    var animSettings:FlxUI;
    var offsetX:FlxUINumericStepper;
    var scale:FlxUINumericStepper;
    var offsetY:FlxUINumericStepper;
    var loopCheckBox:FlxUICheckBox;
    var indices:FlxUIInputText;
    var framerate:FlxUINumericStepper;
    var flipCheckbox:FlxUICheckBox = null;
    var canBeBFSkinned:FlxUICheckBox = null;
    var isBFskin:FlxUICheckBox = null;
    var canBeGFSkinned:FlxUICheckBox = null;
    var editAsPlayer:FlxUICheckBox = null;
    var showCharacterReferences:FlxUICheckBox = null;
    var isGFskin:FlxUICheckBox = null;
    var antialiasing:FlxUICheckBox = null;
    var globalOffsetX:FlxUINumericStepper = null;
    var globalOffsetY:FlxUINumericStepper = null;
    var camOffsetX:FlxUINumericStepper = null;
    var camOffsetY:FlxUINumericStepper = null;
    var healthBar:FlxUISprite;
    var cross:FlxSprite;
    var c:String = "";
    var arrows:Array<FlxClickableSprite> = [];
    var shadowCharacter:Character;
    var usePlayerColors:FlxUICheckBox = null;

    var isPlayer:Bool = false;
    var usePlayerArrowColors:Bool = false;

    var currentAnim(default, set):String = "";

    public static var fromFreeplay:Bool = false;

    public function set_currentAnim(v:String) {
        currentAnim = v;
        updateAnim();
        return currentAnim;
    }

    public static var current:CharacterEditor;

    public function updateAnim() {
        var anim = character.animation.getByName(currentAnim);
        if (anim == null) return;
        if (framerate != null) framerate.value = anim.frameRate;
        if (loopCheckBox != null) loopCheckBox.checked = anim.looped;
        character.playAnim(currentAnim);
        // shadowCharacter.playAnim(currentAnim);

        if (offsetX == null || offsetY == null) return;
        var offsets = character.animOffsets[currentAnim];
        if (offsets == null) offsets = [0, 0];
        offsetX.value = offsets[0];
        offsetY.value = offsets[1];
        // shadowCharacter.offset.set(offsetX.value, offsetY.value);
    }

    public function save() {
        var anims:Array<CharacterAnim> = [];
        @:privateAccess
        var it = character.animation._animations.keys();
        while(it.hasNext()) {
            var anim = it.next();
            var a = character.animation.getByName(anim);
            if (a == null) continue;
            if (a.name == "") continue;
            var animName = character.frames.getByIndex(a.frames[0]).name;
            var realAnimName = animName;
            for (i in 0...4) {
                var animFrames:Array<FlxFrame> = new Array<FlxFrame>();
                @:privateAccess
                character.animation.findByPrefix(animFrames, realAnimName); // adds valid frames to animFrames

                if (animFrames.length > 0)
                {
                    var frameIndices:Array<Int> = new Array<Int>();
                    @:privateAccess
                    character.animation.byPrefixHelper(frameIndices, animFrames, realAnimName); // finds frames and appends them to the blank array

                    if (frameIndices.length == a.frames.length) {
                        break;
                    }
                }
                realAnimName = realAnimName.substr(0, realAnimName.length - 1);
            }
            var offset = character.animOffsets[anim];
            if (offset == null) offset = [0, 0];
            if (offset.length == 0) offset = [0, 0];
            if (offset.length == 1) offset = [offset[0], 0];
            try {
                anims.push({
                    name: anim,
                    anim: realAnimName,
                    framerate: Std.int(a.frameRate),
                    x: offset[0],
                    y: offset[1],
                    loop: a.looped,
                    indices: null
                    });
            } catch(e) {
                trace('Failed to save animation :');
                trace(e);
            }
        }
        var json:CharacterJSON = {
            anims: anims,
            globalOffset: {
                x: character.x - (isPlayer ? 770 : 100),
                y: character.y - 100
            },
            camOffset: {
                x: character.camOffset.x,
                y: character.camOffset.y
            },
            antialiasing: character.antialiasing,
            scale: (character.scale.x + character.scale.y) / 2,
            danceSteps: ['idle'],
            healthIconSteps: [[20, 0], [0, 1]],
            flipX: isPlayer ? !character.flipX : character.flipX,
            healthbarColor: healthBar.color.toWebString(),
            arrowColors: usePlayerColors.checked ? null : [
                for (c in arrows) {
                    var shader = cast(c.shader, ColoredNoteShader);
                    FlxColor.fromRGBFloat(shader.r.value[0], shader.g.value[0], shader.b.value[0]).toWebString();
                }]
        }
        File.saveContent('${Paths.modsPath}/${ToolboxHome.selectedMod}/characters/$c/Character.json', Json.stringify(json, "\t"));
        // if (isBFskin.checked) {
        //     if (ModSupport.modConfig[ToolboxHome.selectedMod].BFskins == null) ModSupport.modConfig[ToolboxHome.selectedMod].BFskins = [];
        //     var exists = false;
        //     for (e in ModSupport.modConfig[ToolboxHome.selectedMod].BFskins) {
        //         if (e.char == c) {
        //             exists = true;
        //             break;
        //         }
        //     }
        //     if (!exists) {
        //         ModSupport.modConfig[ToolboxHome.selectedMod].BFskins.push({
                    
        //         });
        //     }
        //     if (!ModSupport.modConfig[ToolboxHome.selectedMod].BFskins.contains(c)) {
        //         ModSupport.saveModData(ToolboxHome.selectedMod);
        //     }
        // } else {
        //     if (ModSupport.modConfig[ToolboxHome.selectedMod].BFskins.contains(c)) {
        //         ModSupport.modConfig[ToolboxHome.selectedMod].BFskins.remove(c);
        //         ModSupport.saveModData(ToolboxHome.selectedMod);
        //     }
        // }
        if (canBeBFSkinned.checked) {
            if (!ModSupport.modConfig[ToolboxHome.selectedMod].skinnableBFs.contains(c)) {
                ModSupport.modConfig[ToolboxHome.selectedMod].skinnableBFs.push(c);
                ModSupport.saveModData(ToolboxHome.selectedMod);
            }
        } else {
            if (ModSupport.modConfig[ToolboxHome.selectedMod].skinnableBFs.contains(c)) {
                ModSupport.modConfig[ToolboxHome.selectedMod].skinnableBFs.remove(c);
                ModSupport.saveModData(ToolboxHome.selectedMod);
            }
        }
        if (canBeGFSkinned.checked) {
            if (!ModSupport.modConfig[ToolboxHome.selectedMod].skinnableGFs.contains(c)) {
                ModSupport.modConfig[ToolboxHome.selectedMod].skinnableGFs.push(c);
                ModSupport.saveModData(ToolboxHome.selectedMod);
            }
        } else {
            if (ModSupport.modConfig[ToolboxHome.selectedMod].skinnableGFs.contains(c)) {
                ModSupport.modConfig[ToolboxHome.selectedMod].skinnableGFs.remove(c);
                ModSupport.saveModData(ToolboxHome.selectedMod);
            }
        }
    }
    public function new(char:String) {
        if (FlxG.sound.music == null) FlxG.sound.playMusic(Paths.music("characterEditor", "preload"));
        #if desktop
            Discord.DiscordClient.changePresence("In the Character Editor...", null, "Character Editor Icon");
        #end
        super();
        current = this;
        this.c = char;

        var conf = ModSupport.modConfig[ToolboxHome.selectedMod];
        if (conf.BFskins == null) conf.BFskins = [];
        if (conf.GFskins == null) conf.GFskins = [];
        if (conf.skinnableGFs == null) conf.skinnableGFs = [];
        if (conf.skinnableBFs == null) conf.skinnableBFs = [];

        // CREATES STAGE
        
        var bg = new FlxSprite(-600, -200).loadGraphic(Paths.image('default_stage/stageback', 'shared'));
        bg.antialiasing = true;
        bg.scrollFactor.set(0.9, 0.9);
        bg.active = false;
        add(bg);

        var stageFront = new FlxSprite(-650, 600).loadGraphic(Paths.image('default_stage/stagefront', 'shared'));
        stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
        stageFront.updateHitbox();
        stageFront.antialiasing = true;
        stageFront.scrollFactor.set(0.9, 0.9);
        stageFront.active = false;
        add(stageFront);

        var stageCurtains = new FlxSprite(-500, -300).loadGraphic(Paths.image('default_stage/stagecurtains', 'shared'));
        stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
        stageCurtains.updateHitbox();
        stageCurtains.antialiasing = true;
        stageCurtains.scrollFactor.set(1.3, 1.3);
        stageCurtains.active = false;
        add(stageCurtains);

        dad = new Character(100, 100, "Friday Night Funkin':dad");
        dad.color = 0xFF000000;
        dad.alpha = 1 / 3;
        dad.visible = Settings.engineSettings.data.charEditor_showDadAndBF;
        add(dad);

        shadowCharacter = new Character(100, 100, '${ToolboxHome.selectedMod}:$char');
        shadowCharacter.color = 0xFF000000;
        shadowCharacter.alpha = 1 / 3;
        shadowCharacter.visible = false;
        add(shadowCharacter);

        bf = new Boyfriend(770, 100, "Friday Night Funkin':bf");
        bf.color = 0xFF000000;
        bf.alpha = 1 / 3;
        bf.visible = Settings.engineSettings.data.charEditor_showDadAndBF;
        add(bf);



        character = new Character(100, 100, '${ToolboxHome.selectedMod}:$char');
        // character.curCharacter = '${ToolboxHome.selectedMod}:$char';
        // character.frames = Paths.getModCharacter();
        // character.loadJSON(true);
        character.setPosition(100 + character.charGlobalOffset.x, 100 + character.charGlobalOffset.y);
        shadowCharacter.setPosition(100 + character.charGlobalOffset.x, 100 + character.charGlobalOffset.y);
        
        add(character);

        cross = new FlxSprite(0, 0).loadGraphic(Paths.image("cross", "preload"));
        add(cross);

        anim = new FlxUITabMenu(null, [
            {
                name : "anims",
                label : "Animations"
            }
        ], true);
        anim.scrollFactor.set();
        anim.x = 10;
        anim.y = 10;

        
        animationTab = new FlxUI(null, anim);
        animationTab.name = "anims";
        anim.addGroup(animationTab);
        
        animSelection = new FlxUIDropDownMenu(10, 10, [new StrNameLabel("idle", "idle")], function(id) {
            currentAnim = id;
        });
        animSelection.cameras = [camHUD];

        addAnimButton = new FlxUIButton(animSelection.x + animSelection.width + 10, 10, "Add", function() {
            openSubState(new NewAnimDialogue());
        });
        addAnimButton.resize(50, 20);

        removeAnimButton = new FlxUIButton(addAnimButton.x + addAnimButton.width + 10, 10, "Remove", function() {
            if (character.animation.curAnim == null) return;
            if (character.animation.curAnim.name == "") return;
            openSubState(new ToolboxMessage("Remove Animation", 'Are you sure you want to remove the ${character.animation.curAnim.name} animation ?', [
                {
                    label : "Yes",
                    onClick : function(e) {
                        updateAnimSelection(null, true);
                    }
                },
                {
                    label : "No",
                    onClick : function(e) {}
                }
            ]));
        });

        setShadowRef = new FlxUIButton(removeAnimButton.x + removeAnimButton.width + 10, 10, "Set as shadow reference", function() {
            shadowCharacter.visible = true;
            shadowCharacter.playAnim(currentAnim);
            var offset = character.animOffsets.get(currentAnim);
            if (offset == null) offset = [0, 0];
            if (offset.length == 0) offset = [0, 0];
            if (offset.length == 1) offset = [offset[0], 0];
            shadowCharacter.offset.set(offset[0], offset[1]);
        });
        setShadowRef.resize(150, 20);
        anim.resize(setShadowRef.x + setShadowRef.width + 20, 80);
        
        removeAnimButton.resize(76, 20);
        animationTab.add(addAnimButton);
        animationTab.add(removeAnimButton);
        animationTab.add(animSelection);
        animationTab.add(setShadowRef);
        updateAnimSelection();

        closeButton = new FlxUIButton(1257, 3, "X", function() {
            if (fromFreeplay) {
                FlxG.switchState(new PlayState());
            } else {
                FlxG.switchState(new ToolboxHome(ToolboxHome.selectedMod));
            }
        });
        closeButton.color = 0xFFFF4444;
        closeButton.resize(20, 20);
        closeButton.label.color = FlxColor.WHITE;

        saveButton = new FlxUIButton(1167, 3, "Save", function() {
            save();
            if (character.json != null) {
                openSubState(ToolboxMessage.showMessage("Success", "Character successfully saved."));
            } else {
                openSubState(new ToolboxMessage("Success", "Your character have been successfully saved. However, your character don't seems to load any JSON file, so that means these modifications won't have effects. Do you want the engine to fix the problem ? A backup of your Character.hx will be created.", [
                    {
                        label : "Yes",
                        onClick : function(e) {
                            var p = '${Paths.modsPath}/${ToolboxHome.selectedMod}/characters/$c';
                            sys.io.File.copy('$p/Character.hx', '$p/Character-old.hx');
                            sys.io.File.saveContent('$p/Character.hx', 'function create() {\r\n\tcharacter.frames = Paths.getCharacter(character.curCharacter);\r\n\tcharacter.loadJSON(true); // Setting to true will override getColors() and dance().\r\n}');
                            FlxG.switchState(new CharacterEditor(this.c));
                        }
                    },
                    {
                        label : "No",
                        onClick : function(e) {}
                    }
                ]));
            }
            
        });
        saveButton.resize(80, 20);

        
        animSettingsTabs = new FlxUITabMenu(null, [
            {
                name: "settings",
                label: "Animation Settings"
            }
        ], true);
        animSettings = new FlxUI(null, animSettingsTabs);
        animSettings.name = "settings";
        animSettingsTabs.scrollFactor.set();

        var label:FlxUIText = new FlxUIText(10, 10, 280, "Animation Framerate");
        animSettings.add(label);
        framerate = new FlxUINumericStepper(10, label.y + label.height, 1, 24, 1, 120, 0);
        animSettings.add(framerate);
        var label:FlxUIText = new FlxUIText(10, framerate.y + framerate.height + 10, 280, "Animation Offset");
        animSettings.add(label);
        offsetX = new FlxUINumericStepper(10, label.y + label.height, 10, 0, -999, 999, 0);
        offsetY = new FlxUINumericStepper(20 + offsetX.width, label.y + label.height, 10, 0, -999, 999, 0);
        animSettings.add(offsetX);
        animSettings.add(offsetY);
        loopCheckBox = new FlxUICheckBox(10, offsetX.y + offsetX.height + 10, null, null, "Loop Animation", 250, null, function() {
            if (loopCheckBox.checked) character.playAnim(character.animation.curAnim.name);
        });
        animSettings.add(loopCheckBox);

        // var label:FlxUIText = new FlxUIText(10, loopCheckBox.y + loopCheckBox.height + 10, 280, "Indices (separate by \",\", leave blank for no indices)");
        // animSettings.add(label);
        // indices = new FlxUIInputText(10, label.y + label.height, 280, "");
        // animSettings.add(indices);


        animSettingsTabs.addGroup(animSettings);
        animSettingsTabs.resize(300, 200);
        animSettingsTabs.setPosition(1280 - animSettingsTabs.width - 10, 10);
        editAsPlayer = new FlxUICheckBox(anim.x + anim.width + 10, 10, null, null, "Edit as player", 250, null, function() {
            character.flipX = flipCheckbox.checked;
            if (editAsPlayer.checked) {
                character.flipX = !character.flipX;
            }
            shadowCharacter.flipX = character.flipX;
        });
        editAsPlayer.scrollFactor.set();
        add(editAsPlayer);

        showCharacterReferences = new FlxUICheckBox(anim.x + anim.width + 10, editAsPlayer.y + editAsPlayer.height + 10, null, null, "Show Dad and BF", 250, null, function() {
            Settings.engineSettings.data.charEditor_showDadAndBF = dad.visible = bf.visible = showCharacterReferences.checked;
        });
        showCharacterReferences.scrollFactor.set();
        showCharacterReferences.checked = Settings.engineSettings.data.charEditor_showDadAndBF;
        add(showCharacterReferences);

        var characterSettingsTabs = new FlxUITabMenu(null, [
            {
                name: "char",
                label: "Char. Settings"
            },
            {
                name: "health",
                label: "Health Color"
            },
            {
                name: "arrow",
                label: "Arrow Colors"
            }
        ], true);
        var charSettings = new FlxUI(null, characterSettingsTabs);
        characterSettingsTabs.resize(300, 200);
        charSettings.name = "char";
        characterSettingsTabs.scrollFactor.set();
        

        flipCheckbox = new FlxUICheckBox(10, 10, null, null, "Flip Character", 120, null, function() {
            character.flipX = flipCheckbox.checked;
            if (isPlayer) character.flipX = !character.flipX;
            shadowCharacter.flipX = character.flipX;
        });
        flipCheckbox.checked = character.flipX;
        // add(flipCheckbox);

        antialiasing = new FlxUICheckBox(flipCheckbox.x + 145, 10, null, null, "Anti-Aliasing", 120, null, function() {
            character.antialiasing = antialiasing.checked;
            shadowCharacter.antialiasing = antialiasing.checked;
        });
        antialiasing.checked = character.antialiasing;
        // add(antialiasing);
        characterSettingsTabs.addGroup(charSettings);
        characterSettingsTabs.x = 1280 - characterSettingsTabs.width - 10;
        characterSettingsTabs.y = animSettingsTabs.y + animSettingsTabs.height + 10;
        globalOffsetX = new FlxUINumericStepper(10, 36, 10, 0, -999, 999, 0);
        globalOffsetY = new FlxUINumericStepper(globalOffsetX.x + globalOffsetX.width + 5, 36, 10, 0, -999, 999, 0);
        
        isBFskin = new FlxUICheckBox(10, globalOffsetX.y + globalOffsetX.height + 10, null, null, "Is a BF skin", 120);
        canBeBFSkinned = new FlxUICheckBox(10, isBFskin.y + isBFskin.height + 10, null, null, "Can be skinned (BF)", 120);
        canBeBFSkinned.checked = ModSupport.modConfig[ToolboxHome.selectedMod].skinnableBFs.contains(c);
        isGFskin = new FlxUICheckBox(canBeBFSkinned.x + 145, globalOffsetX.y + globalOffsetX.height + 10, null, null, "Is a GF skin", 120);
        canBeGFSkinned = new FlxUICheckBox(canBeBFSkinned.x + 145, isGFskin.y + isGFskin.height + 10, null, null, "Can be skinned (GF)", 120);
        canBeGFSkinned.checked = ModSupport.modConfig[ToolboxHome.selectedMod].skinnableGFs.contains(c);

        
        var label:FlxUIText = new FlxUIText(globalOffsetY.x + globalOffsetY.width + 10, globalOffsetY.y + (globalOffsetY.height / 2), 32, "Scale:");
        label.y -= (label.height / 2);
        scale = new FlxUINumericStepper(10 + label.x + label.width, globalOffsetY.y, 0.1, 1, 0.1, 10, 1);

        
        var label2:FlxUIText = new FlxUIText(10, canBeGFSkinned.y + canBeGFSkinned.height + 10, 280, "Camera Offset");
        
        camOffsetX = new FlxUINumericStepper(10, label2.y + label2.height, 10, 0, -999, 999, 0);
        camOffsetY = new FlxUINumericStepper(camOffsetX.x + camOffsetX.width + 5, label2.y + label2.height, 10, 0, -999, 999, 0);
        camOffsetX.value = character.camOffset.x;
        camOffsetY.value = character.camOffset.y;
        
        charSettings.add(label);
        charSettings.add(scale);
        charSettings.add(flipCheckbox);
        charSettings.add(antialiasing);
        charSettings.add(globalOffsetX);
        charSettings.add(globalOffsetY);
        charSettings.add(canBeGFSkinned);
        // charSettings.add(isGFskin);
        charSettings.add(canBeBFSkinned);
        // charSettings.add(isBFskin);
        charSettings.add(label2);
        charSettings.add(camOffsetX);
        charSettings.add(camOffsetY);

        
        
        globalOffsetX.value = character.charGlobalOffset.x;
        globalOffsetY.value = character.charGlobalOffset.y;
        scale.value = (character.scale.x + character.scale.y) / 2;

        add(characterSettingsTabs);
        add(animSettingsTabs);
        add(anim);

        
        var healthSettings = new FlxUI(null, characterSettingsTabs);
        healthSettings.name = "health";

        healthBar = new FlxUISprite(10, 35);
        healthBar.makeGraphic(255, 10, 0xFFFFFFFF);
        healthBar.pixels.lock();
        for (x in 0...healthBar.pixels.width) {
            healthBar.pixels.setPixel(x, 0, 0xFF000000);
            healthBar.pixels.setPixel(x, 1, 0xFF000000);
            healthBar.pixels.setPixel(x, 8, 0xFF000000);
            healthBar.pixels.setPixel(x, 9, 0xFF000000);
        }
        for (y in 0...healthBar.pixels.height) {
            healthBar.pixels.setPixel(0, y, 0xFF000000);
            healthBar.pixels.setPixel(1, y, 0xFF000000);
            healthBar.pixels.setPixel(253, y, 0xFF000000);
            healthBar.pixels.setPixel(254, y, 0xFF000000);
        }
        healthBar.pixels.unlock();
        var icon = new HealthIcon(character.curCharacter, false, ToolboxHome.selectedMod);
        icon.setGraphicSize(50, 50);
        icon.updateHitbox();
        icon.x = healthBar.x + healthBar.width - 25;
        icon.y = healthBar.y + (healthBar.height / 2) - 25;

        var color = 0xFFFFFFFF;
        var charColors = character.getColors();
        if (charColors.length > 0) {
            color = charColors[0];
        }
        healthBar.color = color;
        healthSettings.add(healthBar);
        healthSettings.add(icon);

        var changeHealthColorButton = new FlxUIButton(135, healthBar.y + healthBar.height + 20, "Edit", function() {
            openSubState(new ColorPicker(healthBar.color, function(newColor) {
                healthBar.color = newColor;
            }));
        });
        changeHealthColorButton.resize(30, 20);
        healthSettings.add(changeHealthColorButton);

        var autoGenerateHealthColor = new FlxUIButton(10, changeHealthColorButton.y + changeHealthColorButton.height + 10, "Use Mixed Colors (using light)", function() {
            healthBar.color = CoolUtil.calculateAverageColorLight(icon.pixels);
            
        });
        autoGenerateHealthColor.resize(280, 20);

        var autoGenerateHealthColor2 = new FlxUIButton(10, autoGenerateHealthColor.y + autoGenerateHealthColor.height, "Use Mixed Colors", function() {
            healthBar.color = CoolUtil.calculateAverageColor(icon.pixels);
        });
        autoGenerateHealthColor2.resize(280, 20);

        var autoGenerateHealthColor4 = new FlxUIButton(10, autoGenerateHealthColor2.y + autoGenerateHealthColor2.height, "Use Most Present Color", function() {
            healthBar.color = CoolUtil.getMostPresentColor2(icon.pixels);
        });
        autoGenerateHealthColor4.resize(280, 20);


        healthSettings.add(autoGenerateHealthColor);
        healthSettings.add(autoGenerateHealthColor2);
        healthSettings.add(autoGenerateHealthColor4);

        characterSettingsTabs.addGroup(healthSettings);
        add(saveButton);
        add(closeButton);

        
        
        var arrowSettings = new FlxUI(null, characterSettingsTabs);
        arrowSettings.name = "arrow";
        if (character.animation.curAnim != null) {
            currentAnim = character.animation.curAnim.name;
        }
        for (i in 0...4) {
            var note:FlxClickableSprite = null;
            note = new FlxClickableSprite(150 + (50 * (i - 2)), 10);
            note.onClick = function() {
                var shader = cast(note.shader, ColoredNoteShader);
                openSubState(new ColorPicker(FlxColor.fromRGBFloat(shader.r.value[0], shader.g.value[0], shader.b.value[0]), function(col) {
                    shader.r.value = [col.redFloat];
                    shader.g.value = [col.greenFloat];
                    shader.b.value = [col.blueFloat];
                }));
            };
            note.hoverColor = 0xFFFFFFFF;
            note.frames = Paths.getSparrowAtlas("NOTE_assets_colored", "shared");
            var anims = ["purple", "blue", "green", "red"];
            note.animation.addByPrefix("arrow", anims[i], 0, true);
            note.animation.play("arrow");
            note.setGraphicSize(50);
            note.updateHitbox();
            note.antialiasing = true;
            var c:FlxColor = charColors[i + 1];
            if (c == 0) {
                c = 0xFFFFFFFF;
            }
            note.shader = new ColoredNoteShader(c.red, c.green, c.blue, false);
            arrowSettings.add(note);
            arrows.push(note);
        }
        usePlayerColors = new FlxUICheckBox(10, 70, null, null, "Use player's colors", 100, null, function() {
            usePlayerArrowColors = usePlayerColors.checked;
        });
        if (character.json != null) usePlayerColors.checked = character.json.arrowColors == null;
        arrowSettings.add(usePlayerColors);
        characterSettingsTabs.addGroup(arrowSettings);
    }

    public function addAnim(name:String, anim:String):Bool {
        character.animation.addByPrefix(name, anim, 24, false);
        shadowCharacter.animation.addByPrefix(name, anim, 24, false);
        updateAnimSelection(name);
        if (character.animation.getByName(name) != null) {
            return true;
        } else {
            return false;
        }
    }

    public function updateAnimSelection(?newAnimName:String, ?removeOldAnim:Bool = false) {
        var oldSelec = animSelection.selectedLabel;
        var anims:Array<StrNameLabel> = [];
        @:privateAccess
        var it = character.animation._animations.keys();
        while (it.hasNext()) {
            var n = it.next();
            if (n != "") anims.push(new StrNameLabel(n, n));
        }
        if (newAnimName == null && (character.animation.getByName(oldSelec) == null || removeOldAnim)) {
            var newAnim = anims.length < 1 ? "" : anims[0].name;
            if (newAnim == oldSelec) newAnim = (anims[1] != null ? anims[1].name : "");
            newAnimName = newAnim;
            character.playAnim(newAnim);
            shadowCharacter.playAnim(newAnim);
            for (e in anims) {
                if (e.name == oldSelec) {
                    anims.remove(e);
                    break;
                }
            }
        }
        if (anims.length == 0) anims.push(new StrNameLabel(" ", " ")); // Since bitchass drop down menu crashes with no elements
        animSelection.setData(anims);

        if (newAnimName != null) {
            animSelection.selectedLabel = newAnimName;
            currentAnim = newAnimName;

        } else {
            animSelection.selectedLabel = oldSelec;
        }
        if (removeOldAnim == true) {
            character.animation.remove(oldSelec);
            shadowCharacter.animation.remove(oldSelec);
        }
    }

    public override function update(elapsed:Float) {
        offsetX.stepSize = (FlxControls.pressed.SHIFT ? 1 : 10);
        offsetY.stepSize = (FlxControls.pressed.SHIFT ? 1 : 10);
        globalOffsetX.stepSize = (FlxControls.pressed.SHIFT ? 1 : 10);
        globalOffsetY.stepSize = (FlxControls.pressed.SHIFT ? 1 : 10);
        camOffsetX.stepSize = (FlxControls.pressed.SHIFT ? 1 : 10);
        camOffsetY.stepSize = (FlxControls.pressed.SHIFT ? 1 : 10);

        super.update(elapsed);

        isPlayer = editAsPlayer.checked;
        var move:FlxPoint = new FlxPoint(0, 0);
        if (FlxControls.pressed.RIGHT) move.x += 1;
        if (FlxControls.pressed.UP) move.y -= 1;
        if (FlxControls.pressed.LEFT) move.x -= 1;
        if (FlxControls.pressed.DOWN) move.y += 1;
        FlxG.camera.scroll.x += move.x * 400 * elapsed * (FlxControls.pressed.SHIFT ? 2.5 : 1);
        FlxG.camera.scroll.y += move.y * 400 * elapsed * (FlxControls.pressed.SHIFT ? 2.5 : 1);
        character.x = (isPlayer ? 770 : 100) + globalOffsetX.value;
        character.y = 100 + globalOffsetY.value;
        shadowCharacter.setPosition(character.x, character.y);


        character.camOffset.x = camOffsetX.value;
        character.camOffset.y = camOffsetY.value;



        if (character.animation.curAnim != null) {
            if (character.animation.curAnim.name != "") {
                // YOU CANT STOP ME HAXEFLIXEL

                // WTF LOL
                // var anim = character.animation.getByName(character.animation.curAnim.name);
                var anim = character.animation.curAnim;
                @:privateAccess
                anim.looped = loopCheckBox.checked;
                @:privateAccess
                anim.frameRate = framerate.value;

                character.animOffsets[character.animation.curAnim.name] = [offsetX.value, offsetY.value];
                character.offset.set(character.animOffsets[character.animation.curAnim.name][0], character.animOffsets[character.animation.curAnim.name][1]);
            }
        }
        character.scale.set(scale.value, scale.value);
        shadowCharacter.scale.set(scale.value, scale.value);
        var midpoint = character.getMidpoint();
        cross.x = -25 + midpoint.x + 150 + character.camOffset.x;
        cross.y = -25 + midpoint.y - 100 + character.camOffset.y;
        // FlxG.camera.scroll.x = midpoint.x + character.camOffset.x + 150 - 640;
        // FlxG.camera.scroll.y = midpoint.y + character.camOffset.y - 100 - 360;
    }
}

