
package ;

import luxe.options.EntityOptions;
import luxe.Entity;
import luxe.Input;
import luxe.Rectangle;
import luxe.Sprite;
import luxe.Text;
import luxe.tween.Actuate;
import luxe.utils.Maths;
import luxe.Vector;
import luxe.Visual;
import luxe.Color;
import luxe.components.sprite.SpriteAnimation;

import phoenix.Batcher;
import phoenix.Camera;
import phoenix.Texture.ClampType;
import phoenix.Texture.FilterType;


class Hud extends Entity
{

    @:isVar public var hud_batcher(default, null):Batcher;

    var camera:Camera;

    // var textField:Text;
    // var textFieldString:String;

    // var textFieldPhys:Text;
    // var textFieldPhysString:String;


    var fader:Sprite;
    var fader_anim:SpriteAnimation;

    var hearth:Sprite;
    var hearth_anim:SpriteAnimation;


    var hope_bar_bg:Sprite;
    var hope_bar_line:Sprite;
    var hp_size:Float;

    var dist_bar_bg:Sprite;
    var dist_me:Sprite;
    var dist_gal:Sprite;

    var dist_bar_bg_y:Float;
    var dist_me_y:Float;
    var dist_gal_y:Float;


    var love_txt:Text;
    var distance_txt:Text;
    

    public var top_padding:Int = 12;
    public var bot_padding:Int = 12;
    
    override public function init():Void
    {
        camera = new Camera({
            camera_name: 'hud_camera',
        });
        camera.zoom = 4;
        camera.pos.set_xy( -Game.width*1.5, -Game.height*1.5 );

        hud_batcher = Luxe.renderer.create_batcher({
            name : 'hud_batcher',
            layer : 5,
            no_add : false,
            camera: camera,
        });




        initEvents();

        setup_fader();

        if(!Game.tutorial){
            setupHUD();
        }else{
            Luxe.events.listen('hud.show.hope_bar', function(_){
                setup_hopebar();
                setup_hearth();
            });
            Luxe.events.listen('hud.show.distance_bar', function(_){
                setup_distancebar();
            });
        }

    }

    override function ondestroy()
    {
        fader.destroy();
        fader_anim.stop();
        hearth.destroy();
        hearth_anim.stop();
        hope_bar_bg.destroy();
        hope_bar_line.destroy();
        dist_bar_bg.destroy();
        dist_me.destroy();
        dist_gal.destroy();
        
        fader = null;
        fader_anim = null;
        hearth = null;
        hearth_anim = null;
        hope_bar_bg = null;
        hope_bar_line = null;
        dist_bar_bg = null;
        dist_me = null;
        dist_gal = null;
    }

    function initEvents()
    {
        Luxe.events.listen('player.hit.enemy', function(_)
        {
            if(Game.tutorial) return;

            // Animate DIST_ME
            dist_me.pos.y -= 15;
            Actuate.tween(dist_me.pos, 0.4, {y:dist_me_y})
            .onUpdate(function(){
                dist_me.pos.y = Math.round(dist_me.pos.y);
            });

            // Animate DIST_GAL
            dist_gal.pos.y -= 15;
            Actuate.tween(dist_gal.pos, 1, {y:dist_gal_y})
            .onUpdate(function(){
                dist_gal.pos.y = Math.round(dist_gal.pos.y);
            });

            // Animate DIST_BAR_BG
            dist_bar_bg.pos.y -= 5;
            Actuate.tween(dist_bar_bg.pos, 0.3, {y:dist_bar_bg_y})
            .onUpdate(function(){
                dist_bar_bg.pos.y = Math.floor(dist_bar_bg.pos.y);
            });
        });


        Luxe.events.listen('game.over.*', function(_){
            hearth_anim.stop();
        });



    }



    function setupHUD()
    {
        setup_hopebar();
        setup_hearth();
        if(Game.gameType == classic) setup_distancebar();
        // setup_lovetxt();
        // setup_distancetxt();
    }

    function setup_fader()
    {
        trace('setup_fader');
        fader = new Sprite({
            texture: Luxe.resources.texture('assets/images/faderBlack.gif'),
            pos: camera.center,
            size: new Vector(160, 144),
            depth: 10,
            batcher: hud_batcher,
        });
        fader.texture.filter_mag = fader.texture.filter_min = FilterType.nearest;

        // Fader Animation

        fader_anim = new SpriteAnimation({ name:'anim' });
        fader.add( fader_anim );

        var animation_json = '
            {
                "fadeout" : {
                    "frame_size":{ "x":"160", "y":"144" },
                    "frameset": ["6","5","4","3","2","1"],
                    "pingpong":"false",
                    "loop": "false",
                    "speed": "16"
                },
                "fadein" : {
                    "frame_size":{ "x":"160", "y":"144" },
                    "frameset": ["1-6"],
                    "pingpong":"false",
                    "loop": "false",
                    "speed": "16"
                }
            }
        ';

        fader_anim.add_from_json( animation_json );
        fader_anim.animation = 'fadein';
        fader_anim.play();
    }

    function setup_hearth()
    {
        hearth = new Sprite({
            name: 'hearth',
            size: new Vector(16,16),
            pos: new Vector(80, top_padding),
            texture: Luxe.resources.texture('assets/images/hearth.gif'),
            depth: 2,
            batcher: hud_batcher,
        });
        hearth.texture.filter_min = hearth.texture.filter_mag = FilterType.nearest;

        hearth_anim = new SpriteAnimation({ name:'anim' });
        hearth.add( hearth_anim );

        var animation_json = '
            {
                "beat" : {
                    "frame_size":{ "x":"16", "y":"16" },
                    "frameset": ["1-4","hold 2","1-4","hold 2","1-4","5-6"],
                    "pingpong":"false",
                    "loop": "true",
                    "speed": "10"
                },
                "beat_low" : {
                    "frame_size":{ "x":"16", "y":"16" },
                    "frameset": ["1-4","hold 2","1-4","hold 2","1-4","5-6"],
                    "pingpong":"false",
                    "loop": "true",
                    "speed": "18"
                },
                "beat_medium" : {
                    "frame_size":{ "x":"16", "y":"16" },
                    "frameset": ["1-4","hold 2","1-4","5-6"],
                    "pingpong":"false",
                    "loop": "true",
                    "speed": "23"
                },
                "beat_hard" : {
                    "frame_size":{ "x":"16", "y":"16" },
                    "frameset": ["1-4","5-6"],
                    "pingpong":"false",
                    "loop": "true",
                    "speed": "28"
                }
            }
        ';

        hearth_anim.add_from_json( animation_json );
        hearth_anim.animation = 'beat';
        hearth_anim.play();
    }

    function setup_hopebar()
    {

        hope_bar_bg = new Sprite({
            name: 'hope_bar_bg',
            size: new Vector( 90,7 ),
            pos: new Vector( Game.width/2, top_padding-0.5 ),
            texture: Luxe.resources.texture('assets/images/hud.gif'),
            uv: new Rectangle(0,0,90,7),
            batcher: hud_batcher,
        });
        hope_bar_bg.texture.filter_min = hope_bar_bg.texture.filter_mag = FilterType.nearest;

        hope_bar_line = new Sprite({
            name: 'hope_bar_line',
            size: new Vector( 86,5 ),
            pos: new Vector( Game.width/2, top_padding-0.5 ),
            texture: Luxe.resources.texture('assets/images/hud.gif'),
            uv: new Rectangle(2,9,86,5),
            batcher: hud_batcher,
        });
        hope_bar_line.texture.filter_min = hope_bar_line.texture.filter_mag = FilterType.nearest;

        hp_size = hope_bar_line.size.x;

        // hope_bar_line.texture.clamp_s = hope_bar_line.texture.clamp_t = ClampType.repeat;
    }

    function setup_distancebar()
    {
        dist_bar_bg = new Sprite({
            name: 'dist_bar_bg',
            size: new Vector( 90,4 ),
            pos: new Vector( Game.width/2, Game.height - bot_padding ),
            texture: Luxe.resources.texture('assets/images/hud.gif'),
            uv: new Rectangle(0,16,90,4),
            depth: 2,
            batcher: hud_batcher,
        });
        dist_bar_bg.texture.filter_min = dist_bar_bg.texture.filter_mag = FilterType.nearest;

        dist_me = new Sprite({
            name: 'dist_me',
            size: new Vector(10,12),
            pos: new Vector(Game.width/2 - dist_bar_bg.size.x/2, Game.height - bot_padding-3),
            texture: Luxe.resources.texture('assets/images/hud.gif'),
            uv: new Rectangle(0,20,10,12),
            depth: 2.1,
            batcher: hud_batcher,
        });
        dist_me.texture.filter_min = dist_me.texture.filter_mag = FilterType.nearest;

        dist_gal = new Sprite({
            name: 'dist_gal',
            size: new Vector(10,12),
            pos: new Vector(Game.width/2 + dist_bar_bg.size.x/2, Game.height - bot_padding-2),
            texture: Luxe.resources.texture('assets/images/hud.gif'),
            uv: new Rectangle(10,20,10,12),
            depth: 2.2,
            batcher: hud_batcher,
        });
        dist_gal.texture.filter_min = dist_gal.texture.filter_mag = FilterType.nearest;

        dist_bar_bg_y = dist_bar_bg.pos.y;
        dist_me_y = dist_me.pos.y;
        dist_gal_y = dist_gal.pos.y;

        update_distance_bar();

    }

    function setup_lovetxt()
    {
        love_txt = new Text({
            bounds: new Rectangle(Game.width/2-90, top_padding+10, 90, 10),
            batcher: hud_batcher,
            color: new Color().rgb(C.c4),
            point_size: 8,
        });
        
    }
    function update_lovetext()
    {
        distance_txt.text = 'distance: ${Math.round(Game.distance)}';
    }

    function setup_distancetxt()
    {
        distance_txt = new Text({
            bounds: new Rectangle(Game.width/2 + 20, top_padding+10, 90 - 20, 10),
            batcher: hud_batcher,
            color: new Color().rgb(C.c4),
            point_size: 8,
        });
    }
    function update_distancetxt()
    {
        distance_txt.text = 'love: ${Math.round(Game.love)}';
    }

    override function update(dt:Float):Void
    {

        if(Game.playing)
        {
            if(hearth != null) choose_hearth_animation();

            if(hope_bar_bg != null) update_hope_bar();
            if(dist_bar_bg != null) update_distance_bar();

            // update_lovetext();
            // update_distancetxt();
        }
    }


    function choose_hearth_animation()
    {
        if( Game.hope > 0.8 && hearth_anim.animation != 'beat')
        {
            hearth_anim.animation = 'beat';
            hearth_anim.play();
        }
        else if( (Game.hope > 0.6 && Game.hope <= 0.8) && hearth_anim.animation != 'beat_low')
        {
            hearth_anim.animation = 'beat_low';
            hearth_anim.play();
        }
        else if( (Game.hope > 0.3 && Game.hope <= 0.6) && hearth_anim.animation != 'beat_medium')
        {
            hearth_anim.animation = 'beat_medium';
            hearth_anim.play();
        }
        else if( Game.hope <= 0.3 && hearth_anim.animation != 'beat_hard')
        {
            hearth_anim.animation = 'beat_hard';
            hearth_anim.play();
        }
    }

    function update_hope_bar()
    {
        hope_bar_line.size.x = Math.round( hp_size * Maths.clamp(Game.hope, 0, 1) / 2 ) * 2;
        hope_bar_line.uv.w = Math.round( hp_size * Maths.clamp(Game.hope, 0, 1) / 2 ) * 2;
    }

    function update_distance_bar()
    {
        dist_me.pos.x = Maths.lerp( Game.width/2 + dist_bar_bg.size.x/2 - 6, Game.width/2 - dist_bar_bg.size.x/2, Game.gal_distance );
        dist_me.pos.x = Math.round( dist_me.pos.x );
    }






}
