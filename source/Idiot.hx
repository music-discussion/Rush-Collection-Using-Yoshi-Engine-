package;

import openfl.system.ApplicationDomain;
import lime.app.Application;
import flixel.util.FlxDestroyUtil;
import flixel.graphics.frames.FlxFramesCollection;
import haxe.io.Bytes;
import openfl.media.Sound;
import sys.FileSystem;
import sys.io.File;
import lime.system.System;
import lime.utils.AssetLibrary;
import openfl.display.BitmapData;
import openfl.utils.Assets;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

import flash.system.System;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.events.Event;
import vlc.VlcBitmap;

import mod_support_stuff.MP4Video;

import lime.ui.Window;

using StringTools;

class Idiot extends MusicBeatState
{
    var vidCompleted:Bool = false;

	public var sprite:FlxSprite;

    public var vidPlayer:FlxSprite = null;
    var count = 0;

    override function create()
    {
        if (FlxG.sound.music.playing)
            FlxG.sound.music.stop();
        vidPlayer = MP4Video.playMP4("assets\\videos\\idiot.mp4", null, true);
        add(vidPlayer);
        vidPlayer.scale.set(4, 4);
        Application.current.window.title = "You are an Idiot!!";
        super.create();
        Application.current.window.onClose.add(function ()
        {
            var b = {
                x: 0, 
                y: 0, 
                width: 800, 
                title: "You are an idiot!!", 
                resizable: false, 
                parameters: null, 
                height: 600, 
                alwaysOnTop: true,
                hidden: false
            }
            // /*
            Application.current.createWindow(b);
            Application.current.createWindow(b);
            Application.current.createWindow(b);
            Application.current.createWindow(b);
            Application.current.createWindow(b);
            Application.current.createWindow(b);
            Application.current.window.alert("You have messed up! The only way out is to reset your PC!!!", "you really are an idiot.");
           // */
        });
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        FlxG.fullscreen = true;
        if (vidCompleted)
            System.exit(0);

        for (i in Application.current.windows)
        {
            i.onClose.add(function ()
            {
                trace("closed");
                var b = {
                    x: 0, 
                    y: 0, 
                    width: 800, 
                    title: "You are an idiot!!", 
                    resizable: false, 
                    parameters: null, 
                    height: 600, 
                    alwaysOnTop: true,
                    hidden: false
                }
                // /*
                Application.current.createWindow(b);
                Application.current.createWindow(b);
                Application.current.createWindow(b);
                Application.current.createWindow(b);
                Application.current.createWindow(b);
                Application.current.createWindow(b);
                //Application.current.window.alert("You have messed up! The only way out is to reset your PC!!!", "you really are an idiot.")
                   // */
            });
        }

        if (FlxG.keys.pressed.SHIFT)
        {
            count++;

            if (count >= 2000)
                #if debug
                System.exit(0);
                #end
        }
    }
}