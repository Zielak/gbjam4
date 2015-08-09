
package ;

import luxe.options.EntityOptions;
import luxe.Entity;
import luxe.Input;
import luxe.Rectangle;
import luxe.Sprite;
import luxe.Text;
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

    var hearth:Sprite;
    var hearth_anim:SpriteAnimation;
    var _cur_ani:String;


    var hope_bar_bg:Sprite;
    var hope_bar_line:Sprite;
    var hp_size:Float;
    

    public var top_padding:Int = 12;
    
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

        setupHUD();
    }

    function initEvents()
    {

    }



    function setupHUD()
    {

        setup_hopebar();
        setup_hearth();

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

    override function update(dt:Float):Void
    {

        choose_hearth_animation();

        update_hope_bar();
        
    }


    function choose_hearth_animation()
    {
        _cur_ani = hearth_anim.animation;

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
        hope_bar_line.size.x = Math.round( hp_size * Game.hope / 2 ) * 2;
        hope_bar_line.uv.w = Math.round( hp_size * Game.hope / 2 ) * 2;
    }






}
