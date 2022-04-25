import lime.utils.Assets;
import mod_support_stuff.*;
import haxe.Json;

import sys.FileSystem;

using StringTools;

typedef SongConfJson = {
    var songs:Array<SongConfSong>;
}

typedef SongConfSong = {
    var name:String;
    var scripts:Array<String>;
    var cutscene:String;
    var end_cutscene:String;
    
    var difficulties:Array<SongConfSong>;
}

typedef SongConfResult = {
    var scripts:Array<ModScript>;
    var cutscene:ModScript;
    var end_cutscene:ModScript;
}
class SongConf {
    public static function parse(mod:String, song:String):SongConfResult {
        // TODO : gotta finish stage editor first
        // Anyways, doin this shit

        var scripts:Array<ModScript> = [];
        var cutscene:ModScript = null;
        var end_cutscene:ModScript = null;



        // var songConfPath = '${Paths.modsPath}/$mod/song_conf';
        var songConfPath = Paths.getPath('song_conf', TEXT, 'mods/$mod');
        if (Assets.exists('$songConfPath.json')) {
            var json:SongConfJson = null;
            try {
                json = Json.parse(Assets.getText('$songConfPath.json'));
            } catch(e) {
                PlayState.trace(Std.string(e));
            }
            if (json != null) {
                for(s in json.songs) {
                    if (s.name.toLowerCase().trim() == song.toLowerCase().trim()) {
                        // GVBGUIGVBZIO IM ANGRY AF
                        if (s.scripts != null) for (s in s.scripts) scripts.push(getModScriptFromValue(mod, s));
                        if (s.cutscene != null) cutscene = getModScriptFromValue(mod, s.cutscene);
                        if (s.end_cutscene != null) end_cutscene = getModScriptFromValue(mod, s.end_cutscene);
                        if (s.difficulties != null) {
                            var diff = PlayState.storyDifficulty;
                            for (d in s.difficulties) {
                                if (d.name.toLowerCase().replace("-", " ") == diff.toLowerCase().replace("-", " ")) {
                                    // GOOD MATCH
                                    if (d.scripts != null) for(s in d.scripts) scripts.push(getModScriptFromValue(mod, s));
                                    if (d.cutscene != null) cutscene = getModScriptFromValue(mod, d.cutscene);
                                    if (d.end_cutscene != null) cutscene = getModScriptFromValue(mod, d.end_cutscene);

                                    break;
                                }
                            }
                        }
                        break;
                    }
                }
            }
        } else {
            // classic script method
            var interp = Script.create('${Paths.modsPath}/$mod/song_conf');
            if (interp != null) {
                interp.setVariable("song", song.toLowerCase().trim());
                interp.setVariable("difficulty", PlayState.storyDifficulty);
                
                interp.setVariable("stage", "");
                interp.setVariable("cutscene", "");
                interp.setVariable("end_cutscene", "");
                interp.setVariable("modchart", "");
                interp.setVariable("scripts", []);
                interp.loadFile('${Paths.modsPath}/$mod/song_conf');

                var stage:String = interp.getVariable("stage");
                var modchart:String = interp.getVariable("modchart");
                var _cutscene:String = interp.getVariable("cutscene");
                var _end_cutscene:String = interp.getVariable("end_cutscene");
                var sc:Array<String> = interp.getVariable("scripts");

                for(s in sc) scripts.push(getModScriptFromValue(mod, s));

                if (_cutscene != null && _cutscene.trim() != "") cutscene = getModScriptFromValue(mod, _cutscene);
                if (_end_cutscene != null && _end_cutscene.trim() != "") end_cutscene = getModScriptFromValue(mod, _end_cutscene);
                if (modchart != null && modchart.trim() != "") scripts.push(getModScriptFromValue(mod, '$mod:modcharts/$modchart'));
                if (stage != null && stage.trim() != "") scripts.push(getModScriptFromValue(mod, '$mod:stages/$stage'));
            }
        }

        if (scripts.length == 0) {
            scripts = [
                {
                    path : "Friday Night Funkin'/stages/default_stage",
                    mod : "Friday Night Funkin'"
                }
            ];
        }
        // if (cutscene != "")
        //     ModSupport.song_cutscene = getModScriptFromValue(cutscene);
        // else
        //     ModSupport.song_cutscene = null;
        
        // if (end_cutscene != "")
        //     ModSupport.song_end_cutscene = getModScriptFromValue(end_cutscene);
        // else
        //     ModSupport.song_end_cutscene = null;

        return {
            scripts: scripts,
            cutscene: cutscene,
            end_cutscene: end_cutscene
        };
    }

    public static function getModScriptFromValue(currentMod:String, value:String):ModScript {
        var splitValue = value.split(":");
        if (splitValue[0] == "") {
            PlayState.log.push('Script not found for $value.');
            return {mod : "Friday Night Funkin'", path : "Friday Night Funkin'/modcharts/unknown"};
        }
        if (splitValue.length == 1) {
            var scriptPath = splitValue[0];
            if (FileSystem.exists('${Paths.modsPath}/$currentMod/$scriptPath')) {
                splitValue.insert(0, currentMod);
            } else {
                var valid = false;
                for (ext in Main.supportedFileTypes) {
                    if (FileSystem.exists('${Paths.modsPath}/$currentMod/$scriptPath.$ext')) {
                        splitValue.insert(0, currentMod);
                        valid = true;
                        break;
                    }
                }
                if (!valid) {
                    if (FileSystem.exists('${Paths.modsPath}/Friday Night Funkin\'/$scriptPath')) {
                        splitValue.insert(0, "Friday Night Funkin'");
                    } else {
                        var valid = false;
                        for (ext in Main.supportedFileTypes) {
                            if (FileSystem.exists('${Paths.modsPath}/Friday Night Funkin\'/$scriptPath.$ext')) {
                                splitValue.insert(0, "Friday Night Funkin'");
                                valid = true;
                                break;
                            }
                        }
                        
                        if (!valid) {
                            PlayState.log.push('Script not found for $value.');
                            return {mod : "Friday Night Funkin'", path : "Friday Night Funkin'/modcharts/unknown"};
                        }
                    }
                }
            }
        }

        var m = splitValue[0];
        var path = splitValue[1];
        return {
            mod : m,
            path : '$m/$path'
        }
    }
}