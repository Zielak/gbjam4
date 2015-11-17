import luxe.Rectangle;
import luxe.Sound;
import luxe.States;
import luxe.Color;
import luxe.components.sprite.SpriteAnimation;
import luxe.Entity;
import luxe.Input;
import luxe.Sprite;
import luxe.Timer;
import luxe.tween.Actuate;
import luxe.Vector;
import luxe.Visual;
import phoenix.Texture;

class MenuState extends State {

    var bg:Sprite;
    var logo:Sprite;
    var help:Sprite;
    var accept:Sprite;

    var shine:Visual;

    var timer:Timer;

    var showing_help:Bool;
    var input_wait:Bool;

    var s_start:Sound;

    public function new()
    {
        super({ name:'menu' });

    }


    override function onenter<T>(_:T) 
    {

        Luxe.renderer.clear_color = new Color().rgb(C.c1);
        Luxe.camera.pos.set_xy( -Game.width*1.5, -Game.height*1.5 );


        timer = new Timer(Luxe.core);
        showing_help = false;
        input_wait = true;

        s_start = Luxe.audio.get('start');

        bg = new Sprite({
            texture: Luxe.resources.texture('assets/images/rush_logo_bg.gif'),
            pos: Luxe.camera.center,
            depth: 1,
        });
        bg.texture.filter_mag = bg.texture.filter_min = FilterType.nearest;
        bg.color.a = 0;


        logo = new Sprite({
            texture: Luxe.resources.texture('assets/images/rush_logo.gif'),
            pos: Luxe.camera.center,
            depth: 1.1,
        });
        logo.texture.filter_mag = logo.texture.filter_min = FilterType.nearest;
        logo.color.a = 0;


        help = new Sprite({
            texture: Luxe.resources.texture('assets/images/help.gif'),
            pos: Luxe.camera.center,
            depth: 1.2,
        });
        help.texture.filter_mag = help.texture.filter_min = FilterType.nearest;
        help.color.a = 0;



        var va:Vector = new Vector(Game.width/2 , Game.height*0.9);
        va.x = Math.round(va.x);
        va.y = Math.round(va.y);

        accept = new Sprite({
            texture: Luxe.resources.texture('assets/images/text.gif'),
            uv: new Rectangle(0, 132, 54, 10),
            pos: va,
            size: new Vector(54, 10),
            centered: true,
            depth: 1.3,
        });
        accept.texture.filter_mag = accept.texture.filter_min = FilterType.nearest;
        accept.color.a = 0;


        shine = new Visual({
            geometry: Luxe.draw.box({
                x: 0, y: 0,
                w: Game.width,
                h: Game.height,
                color: new Color(1,1,1,0),
            }),
        });


        seq1();

    }


    override function onleave<T>(_:T)
    {
        timer = null;
        bg.destroy();
        logo.destroy();
        help.destroy();
        accept.destroy();
        shine.destroy();
    }



    function seq1()
    {
        bg.color.a = 0;
        bg.color.tween(1.5, {a: 1});

        timer.schedule(1, function(){
            logo.color.tween(1.5, {a: 1});
            timer.schedule(1, function(){
                seq2();
            });
        });
    }

    function seq2()
    {
        input_wait = false;
    }


    override public function onkeydown( event:KeyEvent )
    {
        if(input_wait) return;

        if(showing_help){
            if(event.keycode == Key.key_h
            || event.keycode == Key.key_c
            || event.keycode == Key.key_x
            || event.keycode == Key.key_k
            || event.keycode == Key.key_l
            || event.keycode == Key.space
            || event.keycode == Key.enter){
                hide_help();
            }
        }
        else
        {
            if(event.keycode == Key.key_h){
                show_help();
            }
            if(event.keycode == Key.key_c
            || event.keycode == Key.key_x
            || event.keycode == Key.key_k
            || event.keycode == Key.key_l
            || event.keycode == Key.space
            || event.keycode == Key.enter){
                start_game();
            }
        }

    }


    override function update(dt:Float)
    {
        
    }


    function show_help()
    {
        input_wait = true;

        help.color.tween(1, {a:1});
        timer.schedule(1, function(){
            accept.add( new components.Blinking({
                time_on: 0.5,
                time_off: 0.1,
            }) );
            showing_help = true;
            input_wait = false;
        });
    }

    function hide_help()
    {
        input_wait = true;
        accept.remove('blinking');
        accept.color.a = 0;

        help.color.tween(0.7, {a:0});
        timer.schedule(0.7, function(){
            showing_help = false;
            input_wait = false;
        });
    }

    function start_game()
    {
        input_wait = true;
        Luxe.events.fire('state.menu.start_game');
        s_start.play();

        shine.color.a = 0.7;
        shine.color.tween(0.5, {a: 0});

        bg.color.tween(1, {a: 0});
        logo.color.tween(1, {a: 0});

        timer.schedule(1.1, function(){
            Luxe.events.fire('state.menu.finished');
        });
    }

}