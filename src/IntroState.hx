import luxe.States;
import luxe.Color;
import luxe.components.sprite.SpriteAnimation;
import luxe.Entity;
import luxe.Input;
import luxe.Sprite;
import luxe.Timer;
import luxe.Vector;
import phoenix.Texture;


class IntroState extends State {

    var darek_logo:Sprite;
    var music_by:Sprite;
    var gbjam_logo:Sprite;

    var fader:Sprite;
    var fader_anim:SpriteAnimation;

    var timer:Timer;

    public function new()
    {
        super({ name:'intro' });

    }

    override function onenter<T>(_:T) 
    {

        Luxe.renderer.clear_color = new Color().rgb(C.c1);
        Luxe.camera.pos.set_xy( -Game.width*1.5, -Game.height*1.5 );

        timer = new Timer(Luxe.core);

        gbjam_logo = new Sprite({
            texture: Luxe.resources.texture('assets/images/intro_gbjam.gif'),
            pos: new Vector( Luxe.camera.center.x-0.5, Luxe.camera.center.y ),
            depth: 2,
        });
        gbjam_logo.texture.filter_mag = gbjam_logo.texture.filter_min = FilterType.nearest;


        darek_logo = new Sprite({
            texture: Luxe.resources.texture('assets/images/intro_darekLogo.gif'),
            pos: Luxe.camera.center,
            depth: 2,
        });
        darek_logo.texture.filter_mag = darek_logo.texture.filter_min = FilterType.nearest;


        music_by = new Sprite({
            texture: Luxe.resources.texture('assets/images/intro_music.gif'),
            pos: Luxe.camera.center,
            depth: 2,
        });
        music_by.texture.filter_mag = music_by.texture.filter_min = FilterType.nearest;


        fader = new Sprite({
            texture: Luxe.resources.texture('assets/images/faderBlack.gif'),
            pos: Luxe.camera.center,
            size: new Vector(160, 144),
            depth: 5,
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
                    "speed": "8"
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

        gbjam_logo.color.a = 0;
        darek_logo.color.a = 0;
        music_by.color.a = 0;
        seq1();
    }

    override function onleave<T>(_:T)
    {
        gbjam_logo.destroy();
        darek_logo.destroy();
        music_by.destroy();
        fader.destroy();
        timer = null;
    }
        // GBJAM
    function seq1()
    {
        trace('seq1');
        fader_anim.animation = 'fadein';
        fader_anim.play();

        gbjam_logo.color.tween(1, {a:1});

        fader_anim.play();

        timer.schedule(1.5, function()
        {
            gbjam_logo.color.tween(1, {a:0});

            fader_anim.animation = 'fadeout';
            fader_anim.play();
            timer.schedule(0.5, function(){
                seq2();
            });
        });
    }

        // DAREK GREENLY
    function seq2()
    {
        trace('seq2');
        fader_anim.animation = 'fadein';
        fader_anim.play();

        darek_logo.color.tween(1, {a:1});

        fader_anim.play();

        timer.schedule(1.5, function()
        {
            darek_logo.color.tween(1, {a:0});

            fader_anim.animation = 'fadeout';
            fader_anim.play();
            timer.schedule(0.5, function(){
                seq3();
            });
        });
    }

        // PEDRO AVELAR
    function seq3()
    {
        trace('seq3');
        fader_anim.animation = 'fadein';
        fader_anim.play();

        music_by.color.tween(1, {a:1});

        fader_anim.play();

        timer.schedule(1.5, function()
        {
            music_by.color.tween(1, {a:0});

            fader_anim.animation = 'fadeout';
            fader_anim.play();
            timer.schedule(0.5, function(){
                seq4();
            });
        });
    }

    function seq4()
    {
        trace('seq4');

        Luxe.events.fire('state.intro.finished');
    }

}