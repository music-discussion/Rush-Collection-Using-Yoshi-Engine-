package dev_toolbox.stage_editor;

import openfl.display.Application;
import openfl.display.Window;
import sys.FileSystem;
import sys.FileSystem;
import haxe.io.Path;
import flixel.text.FlxText.FlxTextBorderStyle;
import EngineSettings.Settings;
import flixel.input.mouse.FlxMouse;
import lime.ui.MouseCursor;
import openfl.ui.Mouse;
import flixel.addons.ui.*;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import sys.io.File;
import haxe.Json;
import Stage.StageJSON;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

using StringTools;
// typedef SpawnedElements = {
//     var sprite:FlxSprite;
//     var jsonData:StageSprite;
// }

class StageEditor extends MusicBeatState {
    public static var fromFreeplay = false;
    public var ui:FlxSpriteGroup;
    // var spawnedElements:Array<SpawnedElements>;
    public var camHUD:FlxCamera;
    public var camGame:FlxCamera;
    public var dummyHUDCamera:FlxCamera;
    public var stage:StageJSON;
    public var stageFile:String;
    public var bfDefPos:FlxPoint = new FlxPoint(770, 100 + 350);
    public var gfDefPos:FlxPoint = new FlxPoint(400, 130 - 9);
    public var dadDefPos:FlxPoint = new FlxPoint(100, 100);

    public var bf:FlxStageSprite; // Not a Character since loading it would take too much time
    public var gf:FlxStageSprite; // Not a Character since loading it would take too much time
    public var dad:FlxStageSprite; // Not a Character since loading it would take too much time

    public var selectedObj(default, set):FlxStageSprite;

    public static var animTypes:Array<StrNameLabel> = [
        new StrNameLabel("OnBeat", "On Beat"),
        new StrNameLabel("OnBeatForce", "On Beat (Force)"),
        new StrNameLabel("Loop", "Loop")
    ];

    function set_selectedObj(n:FlxStageSprite):FlxStageSprite {
        selectedObj = n;
        objName.text = selectedObj != null ? selectedObj.name : "(No selected sprite)";
        if (selectedObj == null) {
             // global shit
            for (e in [posLabel, sprPosX, sprPosY, scaleLabel, scaleNum, antialiasingCheckbox, scrFacX, scrFacY, scrollFactorLabel]) {
                e.visible = false;
            }
            // sparrow shit
            for (e in [sparrowAnimationTitle, animationNameTitle, animationNameTextBox, animationFPSNumeric, fpsLabel, animationLabel, animationTypeLabel, applySparrowButton]) {
                e.visible = false;
            }

            // for dumb syncing w/ characters
            // if (selectedObj != null) {
            //     sprPosX.value = selectedObj.x;
            //     sprPosY.value = selectedObj.y;
            //     scrFacX.value = selectedObj.scrollFactor.x;
            //     scrFacY.value = selectedObj.scrollFactor.y;
            //     scaleNum.value = (selectedObj.scale.x + selectedObj.scale.y) / 2;
            //     antialiasingCheckbox.checked = selectedObj.antialiasing;
            // }
        } else {
            for (e in [posLabel, sprPosX, sprPosY, scaleLabel, scaleNum, antialiasingCheckbox, scrFacX, scrFacY, scrollFactorLabel]) {
                e.visible = true;
            }
            sprPosX.value = selectedObj.x;
            sprPosY.value = selectedObj.y;
            scrFacX.value = selectedObj.scrollFactor.x;
            scrFacY.value = selectedObj.scrollFactor.y;
            scaleNum.value = (selectedObj.scale.x + selectedObj.scale.y) / 2;
            antialiasingCheckbox.checked = selectedObj.antialiasing;

            if (selectedObj.type.toLowerCase() == "sparrowatlas" && selectedObj.anim != null) {
                for (e in [sparrowAnimationTitle, animationNameTitle, animationNameTextBox, animationFPSNumeric, fpsLabel, animationLabel, animationTypeLabel, applySparrowButton]) {
                    e.visible = true;
                }
                animationNameTextBox.text = selectedObj.anim.name;
                animationFPSNumeric.value = selectedObj.anim.fps;
                animationLabel.selectedId = selectedObj.anim.type;

            } else {
                for (e in [sparrowAnimationTitle, animationNameTitle, animationNameTextBox, animationFPSNumeric, fpsLabel, animationLabel, animationTypeLabel, applySparrowButton]) {
                    e.visible = false;
                }
            }

            if (homies.contains(selectedObj.type)) {
                for (e in [scaleLabel, scaleNum, antialiasingCheckbox]) {
                    e.visible = false;
                }
            }
        }

        for(b in selectOnlyButtons) {
            var resolvedName = resolveButtonName(b.label.text);
            if (selectedObj != null && selectedObj.name == b.label.text) {
                b.label.text = '> $resolvedName <';
                // b.label.setFormat(null, 8, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            } else {
                b.label.text = '$resolvedName';
                // b.label.setFormat(null, 8, FlxColor.BLACK, CENTER, FlxTextBorderStyle.NONE);
                // b.label.scale.x = 1;
            }
        }

        return selectedObj;
    }


    function resolveButtonName(name:String):String {if (name.startsWith("> ") && name.endsWith(" <")) return name.substr(2, name.length - 4); else return name;}
    public var camThingy:FlxSprite;
    public var tabs:FlxUITabMenu;

    public var homies:Array<String> = ["BF", "GF", "Dad"];

    public var stageTab:FlxUI;
    public var globalSetsTab:FlxUI;
    public var selectedObjTab:FlxUI;

    public var defCamZoomNum:FlxUINumericStepper;

    public var objName:FlxUIText;
    public var posLabel:FlxUIText;
    public var sprPosX:FlxUINumericStepper;
    public var sprPosY:FlxUINumericStepper;
    public var scrollFactorLabel:FlxUIText;
    public var scrFacX:FlxUINumericStepper;
    public var scrFacY:FlxUINumericStepper;
    public var scaleLabel:FlxUIText;
    public var scaleNum:FlxUINumericStepper;
    public var antialiasingCheckbox:FlxUICheckBox;
    public var sparrowAnimationTitle:FlxUIText;
    public var animationNameTitle:FlxUIText;
    public var animationNameTextBox:FlxUIInputText;
    public var animationLabel:FlxUIDropDownMenu;
    public var animationFPSNumeric:FlxUINumericStepper;
    public var fpsLabel:FlxUIText;
    public var animationTypeLabel:FlxUIText;
    public var applySparrowButton:FlxUIButton;

    public var oldTab = "";
    public var selectOnly(default, set):FlxStageSprite = null;
    public var selectOnlyButtons:Array<FlxUIButton> = [];
    public var moveOffset:FlxPoint = new FlxPoint(0, 0);
    public var objBeingMoved:FlxStageSprite = null;
    
    public var closed:Bool = false;

    function set_selectOnly(s:FlxStageSprite):FlxStageSprite {
        selectOnly = s;

        for (m in members) {
            if (Std.isOfType(m, FlxStageSprite)) {
                var sprite = cast(m, FlxStageSprite);
                if (sprite == selectOnly || selectOnly == null) {
                    sprite.colorTransform.redOffset = 0;
                    sprite.colorTransform.greenOffset = 0;
                    sprite.colorTransform.blueOffset = 0;
                    sprite.colorTransform.redMultiplier = 1;
                    sprite.colorTransform.greenMultiplier = 1;
                    sprite.colorTransform.blueMultiplier = 1;
                } else {
                    sprite.colorTransform.redOffset = 128;
                    sprite.colorTransform.greenOffset = 128;
                    sprite.colorTransform.blueOffset = 128;
                    sprite.colorTransform.redMultiplier = 0.25;
                    sprite.colorTransform.greenMultiplier = 0.25;
                    sprite.colorTransform.blueMultiplier = 0.25;
                }
            }
        }
        camGame.bgColor = selectOnly == null ? FlxColor.BLACK : 0xFF888888;

        return s;
    }


    public override function new(stage:String) {
        this.stageFile = stage;
        super();
    }

    public function bye() {
        if (fromFreeplay)
            FlxG.switchState(new PlayState());
        else
            FlxG.switchState(new ToolboxHome(ToolboxHome.selectedMod));
    }

    function addStageTab() {
        stageTab = new FlxUI(null, tabs);
        stageTab.name = "stage";

        var names:FlxUIText = new FlxUIText(10, 10, 280, "Sprites");
        names.alignment = CENTER;

        var all = new FlxUIButton(10, names.y + names.height + 10, "(Can Select All)", function() {
            selectOnly = null;
        });
        all.resize(280, 20);

        stageTab.add(names);
        stageTab.add(all);

        var deleteSpriteButton = new FlxUIButton(10, FlxG.height - 70, "Delete", function() {
            if (selectedObj == null) {
                var t = ToolboxMessage.showMessage("Error", "No sprite was selected", function() {}, camHUD);
                t.cameras = [dummyHUDCamera, camHUD];
                openSubState(t);
                return;
            }
            if (homies.contains(selectedObj.type)) {
                var t = ToolboxMessage.showMessage("Error", 'You can\'t delete ${selectedObj.name}', function() {}, camHUD);
                t.cameras = [dummyHUDCamera, camHUD];
                openSubState(t);
                return;
            }
            var t = new ToolboxMessage("Delete a sprite", 'Are you sure you want to delete "${selectedObj.name}"? This operation is irreversible.', [
                {
                    label: "Yes",
                    onClick: function(t) {
                        for(s in stage.sprites) {
                            if (s.name == selectedObj.name) {
                                stage.sprites.remove(s);
                                selectedObj = null;
                                selectOnly = null;
                                updateStageElements();
                                break;
                            }
                        }
                    }
                },
                {
                    label: "No",
                    onClick: function(t) {}
                }
            ]);
            t.cameras = [dummyHUDCamera, camHUD];
            openSubState(t);
        });
        deleteSpriteButton.color = 0xFFFF4444;
        deleteSpriteButton.label.color = FlxColor.WHITE;

        var addSpriteButton = new FlxUIButton(deleteSpriteButton.x + deleteSpriteButton.width + 10, deleteSpriteButton.y, "Add", function() {
            openSubState(new StageSpriteCreator(this));
        });

        var layerUpButton = new FlxUIButton(10, FlxG.height - 100, "<", function() {
            if (selectedObj != null) {
                moveLayer(selectedObj, -1);
            }
        });
        layerUpButton.resize(20, 20);
        layerUpButton.label.angle = 90;
        layerUpButton.cameras = [dummyHUDCamera, camHUD];

        var layerDownButton = new FlxUIButton(layerUpButton.x + layerUpButton.width, layerUpButton.y, ">", function() {
            if (selectedObj != null) {
                moveLayer(selectedObj, 1);
            }
        });
        layerDownButton.resize(20, 20);
        layerDownButton.label.angle = 90;
        layerDownButton.cameras = [dummyHUDCamera, camHUD];

        var moveLayerLabel = new FlxUIText(10, layerUpButton.y + (layerUpButton.height / 2), 0, "Move Sprite Layer (Q / E)");
        moveLayerLabel.y -= moveLayerLabel.height / 2;
        layerDownButton.x += moveLayerLabel.width;
        layerUpButton.x += moveLayerLabel.width;


        stageTab.add(deleteSpriteButton);
        stageTab.add(addSpriteButton);
        stageTab.add(layerUpButton);
        stageTab.add(layerDownButton);
        stageTab.add(moveLayerLabel);
        tabs.addGroup(stageTab);
    }

    function addGlobalSetsTab() {
        globalSetsTab = new FlxUI(null, tabs);
        globalSetsTab.name = "globalSets";

        defCamZoomNum = new FlxUINumericStepper(290, 10, 0.05, stage.defaultCamZoom == null ? 1 : stage.defaultCamZoom, 0.1, 5, 2);
        defCamZoomNum.x -= defCamZoomNum.width;
        var defCamZoomLabel = new FlxUIText(10, defCamZoomNum.y + (defCamZoomNum.height / 2), 0, "Camera Zoom");
        defCamZoomLabel.y -= defCamZoomLabel.height / 2;
        globalSetsTab.add(defCamZoomLabel);
        globalSetsTab.add(defCamZoomNum);
        tabs.addGroup(globalSetsTab);
    }

    public override function onDropFile(path:String) {
        trace(path);
        var fileExt = Path.extension(path).toLowerCase();
        var stagePath = '${Paths.modsPath}/${ToolboxHome.selectedMod}/images/stages/${stageFile}';
        var fileName = Path.withoutDirectory(Path.withoutExtension(path));
        FileSystem.createDirectory('$stagePath/');

        var pathWithoutExt = Path.withoutExtension(path);

        var doSparrow = function() {
            if (FileSystem.exists('$stagePath/${fileName}.png') ||
                FileSystem.exists('$stagePath/${fileName}.xml')) {
                
                
                for (i in 0...100) { // now try iterating backwards, bitch (lmao)
                    if (!FileSystem.exists('$stagePath/${fileName}${i}.png') &&
                        !FileSystem.exists('$stagePath/${fileName}${i}.xml')) {
                            fileName = '${fileName}${i}';
                            break;
                    }
                }
            }
            File.copy('$pathWithoutExt.png', '$stagePath/${fileName}.png');
            File.copy('$pathWithoutExt.xml', '$stagePath/${fileName}.xml');
			
			ModSupport.loadMod(ToolboxHome.selectedMod); // reload all assets

            stage.sprites.push({
                type: "SparrowAtlas",
                scrollFactor: [1, 1],
                name: fileName,
                src: 'stages/${stageFile}/${fileName}',
                animation: {
                    name: "",
                    fps: 24,
                    type: "Loop"
                }
            });
            updateStageElements();
        }
        switch(fileExt) {
            case "png":
                if (FileSystem.exists('$pathWithoutExt.xml')) {
                    // Creates a directory where to put all of the bitmaps
                    // if (FileSystem.exists('/${fileName}.png') ||
                    //     FileSystem.exists('$stagePath/${fileName}.xml')) {
                    //     showMessage("Error", "A Sparrow Atlas with the same name already exists.");
                    //     return;
                    // }
                    // File.copy('$pathWithoutExt.png', '$stagePath/${fileName}.png');
                    // File.copy('$pathWithoutExt.xml', '$stagePath/${fileName}.xml');
                    // trace("TODO");

                    doSparrow();
                } else {
                    if (FileSystem.exists('$stagePath/${fileName}.png')) {
                        doSparrow();
                    } else {
                        File.copy('$pathWithoutExt.png', '$stagePath/${fileName}.png');
						ModSupport.loadMod(ToolboxHome.selectedMod);
                    }
                    stage.sprites.push({
                        type: "Bitmap",
                        scrollFactor: [1, 1],
                        name: fileName,
                        src: 'stages/${stageFile}/${fileName}'
                    });
                    updateStageElements();
                }
            case "xml":
                if (FileSystem.exists('$pathWithoutExt.png')) {
                    doSparrow();
                } else {
                    showMessage("Error", "No PNG file was found for your Sparrow Atlas. Make sure there's a corresponding PNG file.");
                    return;
                }
            default:
                showMessage("Error", "Dropped file must be of type \"png\" or \"xml\"");
                return;
        }

        lime.app.Application.current.window.focus();
    }
    function addSelectedObjectTab() {
        selectedObjTab = new FlxUI(null, tabs);
        // selectedObjTab
        selectedObjTab.name = "selectedElem";

        objName = new FlxUIText(10, 10, 280, "(No selected sprite)", 12);
        posLabel = new FlxUIText(10, objName.y + objName.height + 10, 280, "Sprite position");

        sprPosX = new FlxUINumericStepper(10, posLabel.y + (posLabel.height / 2), 10, 0, -99999, 99999);
        sprPosX.y -= sprPosX.height / 2;
        sprPosY = new FlxUINumericStepper(10, sprPosX.y, 10, 0, -99999, 99999);

        sprPosY.x = 290 - sprPosY.width;
        sprPosX.x = sprPosY.x - sprPosY.width - 5;

        scrollFactorLabel = new FlxUIText(10, posLabel.y + sprPosX.height + 5, 280, "Scroll Factor");

        scrFacX = new FlxUINumericStepper(10, scrollFactorLabel.y + (scrollFactorLabel.height / 2), 0.05, 1, -99999, 99999, 2);
        scrFacX.y -= scrFacX.height / 2;
        scrFacY = new FlxUINumericStepper(10, scrFacX.y, 0.05, 1, -99999, 99999, 2);

        scrFacY.x = 290 - scrFacY.width;
        scrFacX.x = scrFacY.x - scrFacY.width - 5;

        scaleLabel = new FlxUIText(10, scrollFactorLabel.y + scrFacX.height + 5, 280, "Scale");
        scaleNum = new FlxUINumericStepper(10, scaleLabel.y + (scaleLabel.height / 2), 0.1, 0, 0, 10, 2);
        scaleNum.y -= scaleLabel.height / 2;
        scaleNum.x = 290 - scaleNum.width;

        antialiasingCheckbox = new FlxUICheckBox(10, scaleNum.y + scaleNum.height, null, null, "Anti-aliasing", 100, null, function() {
            // sets antialiasing
            if (selectedObj != null) selectedObj.antialiasing = antialiasingCheckbox.checked;
        });

        sparrowAnimationTitle = new FlxUIText(10, antialiasingCheckbox.y + antialiasingCheckbox.height + 10, 280, "Sparrow Animation Settings");
        sparrowAnimationTitle.alignment = CENTER;
        animationNameTitle = new FlxUIText(10, sparrowAnimationTitle.y + sparrowAnimationTitle.height + 10, 280, "Animation Name");

        animationNameTextBox = new FlxUIInputText(10, animationNameTitle.y + animationNameTitle.height, 280, "", 8);
        animationFPSNumeric = new FlxUINumericStepper(10, animationNameTextBox.y + animationNameTextBox.height + 5, 1, 24, 1, 120, 0);
        // animationFPSNumeric.x -= animationFPSNumeric.width;

        fpsLabel = new FlxUIText(10, animationFPSNumeric.y + (animationFPSNumeric.height / 2), 0, "FPS: ");
        fpsLabel.y -= fpsLabel.height / 2;
        animationFPSNumeric.x += fpsLabel.width;

        animationLabel = new FlxUIDropDownMenu(10, animationFPSNumeric.y + animationFPSNumeric.height + 10, animTypes, function(id) {
            // animationLabel.label
        });

        animationTypeLabel = new FlxUIText(10, animationLabel.y + (10), 0, "Animation Type: ");
        animationTypeLabel.y -= animationTypeLabel.height / 2;
        animationLabel.x += animationTypeLabel.width;

        applySparrowButton = new FlxUIButton(150, animationLabel.y + 30, "Apply", function () {
            selectedObj.anim = {
                type: animationLabel.selectedId,
                name: animationNameTextBox.text,
                fps: Std.int(animationFPSNumeric.value)
            };
            selectedObj.animation.addByPrefix(selectedObj.anim.name, selectedObj.anim.name, selectedObj.anim.fps, selectedObj.anim.type.toLowerCase() == "loop");
            selectedObj.animation.play(selectedObj.anim.name);
        });



       

        selectedObjTab.add(objName);
        selectedObjTab.add(posLabel);
        selectedObjTab.add(sprPosX);
        selectedObjTab.add(sprPosY);
        selectedObjTab.add(scrollFactorLabel);
        selectedObjTab.add(scrFacX);
        selectedObjTab.add(scrFacY);
        selectedObjTab.add(scaleLabel);
        selectedObjTab.add(scaleNum);
        selectedObjTab.add(antialiasingCheckbox);
        selectedObjTab.add(sparrowAnimationTitle);
        selectedObjTab.add(animationNameTitle);
        selectedObjTab.add(animationNameTextBox);
        selectedObjTab.add(animationFPSNumeric);
        selectedObjTab.add(fpsLabel);
        selectedObjTab.add(animationLabel);
        selectedObjTab.add(animationTypeLabel);
        selectedObjTab.add(applySparrowButton);
        tabs.addGroup(selectedObjTab);

        selectedObj = null;
    }
    public override function create() {
        if (FlxG.sound.music == null) {
            FlxG.sound.playMusic(Paths.music("characterEditor", "preload"));
            // FlxG.sound.music.volume = 0;
        }
        #if desktop
            Discord.DiscordClient.changePresence("In the Stage Editor...", null, "Stage Editor Icon");
        #end
        super.create();
        persistentDraw = true;
        persistentUpdate = false;

        // camGame = new FlxCamera(Settings.engineSettings.data.moveCameraInStageEditor ? -150 : 0, 0, FlxG.width, FlxG.height, 1);
        camGame = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
        camHUD = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
        dummyHUDCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
        FlxG.cameras.reset(dummyHUDCamera);
        FlxG.cameras.add(camGame, true);
		FlxG.cameras.add(camHUD, false);
        camHUD.bgColor = 0x00000000;

        // FlxG.cameras.setDefaultDrawTarget(camGame, true);

        camThingy = new FlxSprite(0, 0).loadGraphic(Paths.image('ui/camThingy', 'shared'));
        camThingy.cameras = [dummyHUDCamera, camHUD];
        camThingy.alpha = 0.5;
        camThingy.x = ((FlxG.width - 300) / 2) - (camThingy.width / 2);
        camThingy.scrollFactor.set(0, 0);
        add(camThingy);

        tabs = new FlxUITabMenu(null, [
            {
                label: "Elements",
                name: "stage"
            },
            {
                label: "Selected Elem.",
                name: "selectedElem"
            },
            {
                label: "Global Settings",
                name: "globalSets"
            }
        ], true);

        stage = Json.parse(File.getContent('${Paths.modsPath}/${ToolboxHome.selectedMod}/stages/${stageFile}.json'));
        camGame.zoom = stage.defaultCamZoom == null ? 1 : stage.defaultCamZoom;

        if (stage.bfOffset == null || stage.bfOffset.length == 0) stage.bfOffset = [0, 0];
        if (stage.bfOffset.length < 2) stage.bfOffset = [stage.bfOffset[0], 0];

        if (stage.gfOffset == null || stage.gfOffset.length == 0) stage.gfOffset = [0, 0];
        if (stage.gfOffset.length < 2) stage.gfOffset = [stage.gfOffset[0], 0];

        if (stage.dadOffset == null || stage.dadOffset.length == 0) stage.dadOffset = [0, 0];
        if (stage.dadOffset.length < 2) stage.dadOffset = [stage.dadOffset[0], 0];

        bf = new FlxStageSprite(bfDefPos.x + stage.bfOffset[0], bfDefPos.y + stage.bfOffset[1]);
        bf.name = "Boyfriend";
        bf.type = "BF";

        gf = new FlxStageSprite(gfDefPos.x + stage.gfOffset[0], gfDefPos.y + stage.gfOffset[1]);
        gf.name = "Girlfriend";
        gf.type = "GF";

        dad = new FlxStageSprite(dadDefPos.x + stage.dadOffset[0], dadDefPos.y + stage.dadOffset[1]);
        dad.name = "Dad";
        dad.type = "Dad";

        for(e in [bf, gf, dad]) {
            e.frames = Paths.getSparrowAtlas("stageEditorChars", "shared");
            switch(e.type) {
                case "BF":
                    e.animation.addByPrefix("dance", "BF idle dance", 24);
                case "GF":
                    e.animation.addByPrefix("dance", "GF Dancing Beat", 24);
                case "Dad":
                    e.animation.addByPrefix("dance", "Dad idle dance", 24);
            }
            e.animation.play("dance");
            e.antialiasing = true;
            e.updateHitbox();
        }

        addStageTab();
        addSelectedObjectTab();
        addGlobalSetsTab();

        var hideButton:FlxUIButton = null;
        hideButton = new FlxUIButton(FlxG.width - 320, 20, ">", function() {
            closed = !closed;
            hideButton.label.text = closed ? "<" : ">";
        });
        hideButton.scrollFactor.set(1, 1);
        hideButton.resize(20, FlxG.height - 20);
        hideButton.cameras = [camHUD];
        add(hideButton);

        tabs.addGroup(stageTab);

        tabs.cameras = [dummyHUDCamera, camHUD];
        tabs.resize(300, FlxG.height - 20);
        tabs.x = FlxG.width - tabs.width;
        tabs.y = 20;
        add(tabs);
        var closeButton = new FlxUIButton(FlxG.width - 20, 0, "X", function() {
            if (unsaved) {
                
                var t = new ToolboxMessage("Warning", "Some changes to the stage weren't saved. Do you want to save them ?", [
                    {
                        label: "Save",
                        onClick: function(mes) {
                            save();
                            bye();
                        }
                    },
                    { 
                        label: "Don't Save",
                        onClick: function(mes) {
                            bye();
                        }
                    },
                    {
                        label: "Cancel",
                        onClick: function(mes) {}
                    }
                ], null, camHUD);
                t.cameras = [dummyHUDCamera, camHUD];
                openSubState(t);
            } else {
                bye();
            }
        });
        closeButton.resize(20, 20);
        closeButton.color = 0xFFFF4444;
        closeButton.label.color = FlxColor.WHITE;
        closeButton.cameras = [dummyHUDCamera, camHUD];

        var saveButton = new FlxUIButton(FlxG.width - 20, 0, "Save", function() {
            try {
                save();
            } catch(e) {
                openSubState(ToolboxMessage.showMessage('Error', 'Failed to save stage\n\n$e', null, camHUD));
                return;
            }
            openSubState(ToolboxMessage.showMessage('Success', 'Stage saved successfully !', null, camHUD));
        });
        saveButton.x -= saveButton.width;
        saveButton.cameras = [dummyHUDCamera, camHUD];
        saveButton.scrollFactor.set(1, 1);
        add(saveButton);
        add(closeButton);
        updateStageElements();

    }
    
    public var unsaved = false;
    public function save() {
        updateJsonData();
        File.saveContent('${Paths.modsPath}/${ToolboxHome.selectedMod}/stages/${stageFile}.json', Json.stringify(stage, "\t"));
        unsaved = false;
    }
    public function updateStageElements() {
        var alreadySpawnedSprites:Map<String, FlxStageSprite> = [];
        var toDelete:Array<FlxStageSprite> = [];
        for (e in selectOnlyButtons) {
            remove(e);
            stageTab.remove(e);
            e.destroy();
        }
        selectOnlyButtons = [];
        for (e in members) {
            if (Std.isOfType(e, FlxStageSprite)) {
                var sprite = cast(e, FlxStageSprite);
                if (!homies.contains(sprite.type)) {
                    alreadySpawnedSprites[sprite.name] = sprite;
                    toDelete.push(sprite);
                }
                remove(sprite);
            }
        }
        for(s in stage.sprites) {
            var spr = alreadySpawnedSprites[s.name];
            if (spr != null) {
                toDelete.remove(spr);
                add(spr);
            } else {
                switch(s.type) {
                    case "SparrowAtlas":
                        spr = Stage.generateSparrowAtlas(s, ToolboxHome.selectedMod);
                        trace(spr);
                        add(spr);
                    case "Bitmap":
                        spr = Stage.generateBitmap(s, ToolboxHome.selectedMod);
                        trace(spr);
                        add(spr);
                    case "BF":
                        if (s.scrollFactor == null) s.scrollFactor = [1, 1];
                        while (s.scrollFactor.length < 2) s.scrollFactor.push(1);
                        bf.scrollFactor.set(s.scrollFactor[0], s.scrollFactor[1]);
                        add(bf);
                        spr = bf;
                    case "GF":
                        if (s.scrollFactor == null) s.scrollFactor = [1, 1];
                        while (s.scrollFactor.length < 2) s.scrollFactor.push(1);
                        gf.scrollFactor.set(s.scrollFactor[0], s.scrollFactor[1]);
                        add(gf);
                        spr = gf;
                    case "Dad":
                        if (s.scrollFactor == null) s.scrollFactor = [1, 1];
                        while (s.scrollFactor.length < 2) s.scrollFactor.push(1);
                        dad.scrollFactor.set(s.scrollFactor[0], s.scrollFactor[1]);
                        add(dad);
                        spr = dad;
                }
            }
            if (spr != null) {
                var button = new FlxUIButton(10, 58 + (selectOnlyButtons.length * 20), (selectedObj == spr || objBeingMoved == spr || selectOnly == spr) ? '> ${spr.name} <' : spr.name, function() {
                    if (selectOnly == spr) {
                        selectOnly = selectedObj = null;
                    } else {
                        selectedObj = spr;
                        selectOnly = spr;
                    }
                });
                button.visible = tabs.selected_tab_id == "stage";
                if (homies.contains(spr.type)) {
                    button.label.color = FlxColor.WHITE;
                    switch(spr.type.toLowerCase()) {
                        case "bf":
                            button.color = 0xFF31B0D1;
                        case "gf":
                            button.color = 0xFFA5004D;
                        case "dad":
                            button.color = 0xFFAF66CE;
                    }
                }
                button.resize(280, 20);
                stageTab.add(button);
                selectOnlyButtons.push(button);
            }
        }
    }

    public function updateJsonData() {
        stage.sprites = [];
        for (e in members) {
            if (Std.isOfType(e, FlxStageSprite)) {
                var sprite = cast(e, FlxStageSprite);
                stage.sprites.push({
                    type: sprite.type,
                    src: sprite.spritePath,
                    scrollFactor: [sprite.scrollFactor.x, sprite.scrollFactor.y],
                    scale: ((sprite.scale.x + sprite.scale.y) / 2),
                    pos: [sprite.x, sprite.y],
                    name: sprite.name,
                    antialiasing: sprite.antialiasing,
                    animation: sprite.anim
                });
            }
        }
        stage.bfOffset = [bf.x - bfDefPos.x, bf.y - bfDefPos.y];
        stage.gfOffset = [gf.x - gfDefPos.x, gf.y - gfDefPos.y];
        stage.dadOffset = [dad.x - dadDefPos.x, dad.y - dadDefPos.y];
        
        // stage.defaultCamZoom = 
        unsaved = true;
    }

    public override function update(elapsed:Float) {
        if (tabs.selected_tab_id != oldTab) {
            // if (oldTab == )
            oldTab = tabs.selected_tab_id;
            switch(tabs.selected_tab_id) {
                case "selectedElem":
                    selectedObj = selectedObj;
            }
        }

        var scrollVal = elapsed * 250 * (FlxG.keys.pressed.SHIFT ? 2.5 : 1) / camGame.zoom;
        if (FlxG.keys.pressed.LEFT) {
            camGame.scroll.x -= scrollVal;
            moveOffset.x -= scrollVal;
        }
        if (FlxG.keys.pressed.RIGHT) {
            camGame.scroll.x += scrollVal;
            moveOffset.x += scrollVal;
        }
        if (FlxG.keys.pressed.DOWN) {
            camGame.scroll.y += elapsed * 250 * (FlxG.keys.pressed.SHIFT ? 2.5 : 1) / camGame.zoom;
            moveOffset.y += scrollVal;
        }
        if (FlxG.keys.pressed.UP) {
            camGame.scroll.y -= elapsed * 250 * (FlxG.keys.pressed.SHIFT ? 2.5 : 1) / camGame.zoom;
            moveOffset.y -= scrollVal;
        }

        if (selectedObj != null) {
            if (FlxG.keys.pressed.SHIFT) {
                if (FlxG.keys.justPressed.W)
                    selectedObj.y -= 10;
    
                if (FlxG.keys.justPressed.S)
                    selectedObj.y += 10;
    
                if (FlxG.keys.justPressed.A)
                    selectedObj.x -= 10;
    
                if (FlxG.keys.justPressed.D)
                    selectedObj.x += 10;

            } else {
                if (FlxG.keys.pressed.W)
                    selectedObj.y -= 250 * elapsed / camGame.zoom;
    
                if (FlxG.keys.pressed.S)
                    selectedObj.y += 250 * elapsed / camGame.zoom;
    
                if (FlxG.keys.pressed.A)
                    selectedObj.x -= 250 * elapsed / camGame.zoom;
    
                if (FlxG.keys.pressed.D)
                    selectedObj.x += 250 * elapsed / camGame.zoom;
            }

            if (FlxG.keys.justPressed.Q)
                moveLayer(selectedObj, -1);
    
            if (FlxG.keys.justPressed.E)
                moveLayer(selectedObj, 1);
        }


        if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.BACKSPACE) {
            // resets
            var f = false;
            for(m in members) {
                if (Std.isOfType(m, FlxUIInputText)) {
                    if (cast(m, FlxUIInputText).hasFocus) {
                        f = true;
                        break;
                    }
                }
            }
            if (!f) camGame.scroll.x = camGame.scroll.y = 0;
        }
        try {
            super.update(elapsed);
        } catch(e) {

        }
        var mousePos = FlxG.mouse.getWorldPosition(camGame);
        
        if (objBeingMoved != null) {
            camHUD.alpha = FlxMath.lerp(camHUD.alpha, 0.2, 0.30 * 30 * elapsed);
            
            // if (Settings.engineSettings.data.moveCameraInStageEditor) {
            //     var oldCamGame = camGame.x;
            //     camGame.x = FlxMath.lerp(camGame.x, 0, 0.30 * 30 * elapsed);
            //     var offset = camGame.x - oldCamGame;
            //     moveOffset.x += offset * 2;
            // }
            if (FlxG.mouse.pressed) {
                // new FlxPointer().getScreenPosition();
                objBeingMoved.x = mousePos.x + moveOffset.x;
                objBeingMoved.y = mousePos.y + moveOffset.y;
                if (FlxG.mouse.wheel != 0 && !homies.contains(objBeingMoved.type)) {
                    
                    // if (FlxG.keys.pressed.CONTROL) {
                        objBeingMoved.scale.x = objBeingMoved.scale.y = ((objBeingMoved.scale.x + objBeingMoved.scale.y) / 2) + (0.1 * FlxG.mouse.wheel);
                        objBeingMoved.updateHitbox();
                    // }
                }

                if (selectedObj != null) {
                    sprPosX.value = selectedObj.x;
                    sprPosY.value = selectedObj.y;
                    scrFacX.value = selectedObj.scrollFactor.x;
                    scrFacY.value = selectedObj.scrollFactor.y;
                    scaleNum.value = (selectedObj.scale.x + selectedObj.scale.y) / 2;
                }

                // if (FlxG.mouse.getScreenPosition(camHUD).x >= 315 && !closed) {
                //     closed = true;
                // }
            } else {
                enableGUI(true);
                objBeingMoved = null;
                updateJsonData();
            }
        } else {
            camHUD.alpha = FlxMath.lerp(camHUD.alpha, 1, 0.30 * 30 * elapsed);
            // if (Settings.engineSettings.data.moveCameraInStageEditor) {
            //     camGame.x = FlxMath.lerp(camGame.x, -150, 0.30 * 30 * elapsed);
            // }
            if (FlxG.keys.pressed.CONTROL)
                defCamZoomNum.value += 0.05 * FlxG.mouse.wheel;
            else
                camGame.zoom += 0.1 * FlxG.mouse.wheel;
            if (camGame.zoom < 0.1) camGame.zoom = 0.1;
            if (defCamZoomNum.value < 0.1) defCamZoomNum.value = 0.1;

            if (FlxG.mouse.getScreenPosition(camHUD).x >= FlxG.width - 320 - camHUD.scroll.x) {
                // when on tabs thingy
                if (selectedObj != null) {
                    selectedObj.x = sprPosX.value;
                    selectedObj.y = sprPosY.value;
                    selectedObj.scrollFactor.x = scrFacX.value;
                    selectedObj.scrollFactor.y = scrFacY.value;
                    if (scaleNum.value != selectedObj.scale.x) {
                        selectedObj.scale.set(scaleNum.value, scaleNum.value);
                        selectedObj.updateHitbox();
                    }
                }
            } else {
                
                if (selectedObj != null) {
                    sprPosX.value = selectedObj.x;
                    sprPosY.value = selectedObj.y;
                    scrFacX.value = selectedObj.scrollFactor.x;
                    scrFacY.value = selectedObj.scrollFactor.y;
                    scaleNum.value = (selectedObj.scale.x + selectedObj.scale.y) / 2;
                }

                // when on stage thingy
                var i = members.length - 1;
                if (selectOnly != null) {
                    if (FlxG.mouse.justPressed) {
                        enableGUI(false);
                        select(selectOnly, mousePos);
                    }
                } else {
                    while(i >= 0) {
                        var s = members[i];
                        if (Std.isOfType(s, FlxStageSprite)) {
                            s.cameras = [camGame];
                            var sprite = cast(s, FlxStageSprite);
                            if (overlaps(sprite, mousePos)) {
                                if (FlxG.mouse.justPressed) {
                                    enableGUI(false);
                                    select(sprite, mousePos);
                                }
                                break;
                            }
                        }
                        i--;
                    }
                }
            }
            
        }

        stage.defaultCamZoom = defCamZoomNum.value;
        camThingy.scale.x = camThingy.scale.y = camGame.zoom / stage.defaultCamZoom;
        // if (Settings.engineSettings.data.moveCameraInStageEditor) {
        //     FlxG.mouse.cursorContainer.x = FlxG.game.mouseX + 150 + camGame.x;
        // }

        camHUD.scroll.x = FlxMath.lerp(camHUD.scroll.x, closed ? -300 : 0, 0.30 * 30 * elapsed);
        camThingy.x = (FlxG.width / 2) + camGame.x - (camThingy.width / 2);
        dummyHUDCamera.scroll.x = camHUD.scroll.x;
        
    }

    public var isGUIEnabled = true;
    function enableGUI(enable:Bool) {
        if (enable == isGUIEnabled) return;

        tabs.active = enable;
        for (s in members) {
            if (s == null) continue;
            if (s.cameras.contains(camHUD)) {
                s.active = enable;
            }
        }

        isGUIEnabled = enable;
    }
    function select(sprite:FlxStageSprite, mousePos:FlxPoint):Void {
        moveOffset.x = sprite.x - mousePos.x;
        moveOffset.y = sprite.y - mousePos.y;
        objBeingMoved = sprite;
        selectedObj = sprite;
    }
    function overlaps(sprite:FlxStageSprite, mousePos:FlxPoint):Bool {
        return mousePos.x >= sprite.x && mousePos.x < sprite.width + sprite.x && mousePos.y >= sprite.y && mousePos.y < sprite.height + sprite.y;
        // if (FlxG.mouse.overlaps(sprite, camGame)) {
        //     // if (sprite.type == "Bitmap") {
        //     //     var mPos = FlxG.mouse.getPosition();
        //     //     var rX = camGame.scroll.x + ((sprite.x - camGame.scroll.x) / sprite.scrollFactor.x);
        //     //     var rY = camGame.scroll.y + ((sprite.y - camGame.scroll.y) / sprite.scrollFactor.y);
        //     //     var pX = FlxMath.wrap(Std.int((mPos.x - rX) / (sprite.width) * sprite.pixels.width), 0, sprite.pixels.width);
        //     //     var pY = FlxMath.wrap(Std.int((mPos.y - rY) / (sprite.height) * sprite.pixels.height), 0, sprite.pixels.height);
        //     //     trace(pX);
        //     //     trace(pY);
                
        //     //     var pixel:FlxColor = sprite.pixels.getPixel32(pX, pY);
        //     //     sprite.pixels.setPixel32(pX, pY, 0xFFFFFFFF);
        //     //     if (pixel.alphaFloat < 0.1) {
        //     //         return false;
        //     //     } else {
        //     //         return true;
        //     //     }
        //     // } else {
        //         return true;
        //     // }
            
        // }
        // return false;
    }

    function moveLayer(sprite:FlxStageSprite, layer:Int) {
        for(k=>e in stage.sprites) {
            // gets the json representation of the sprite
            if (e.name == sprite.name) {
                if (k + layer < 0 || k + layer > stage.sprites.length) break;

                // OH NO !
                stage.sprites.remove(e);
                // Anyways
                stage.sprites.insert(k + layer, e);

                // Updates the thing
                updateStageElements();
                break;
            }
        }
    }
}