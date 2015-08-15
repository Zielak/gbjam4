package actions;

import Action.ActionOptions;
import luxe.Color;
import luxe.Input;
import luxe.Rectangle;
import luxe.Sprite;
import luxe.tween.Actuate;
import luxe.Vector;
import luxe.Visual;
import phoenix.Batcher;
import phoenix.Texture;
import phoenix.geometry.Geometry;
import snow.api.Timer;

class ShowTutorialScreen extends Action {

    var screen:Sprite;
    var accept:Sprite;

    var circle:Visual;
    var circle_pos:Vector = null;
    var circle_size:Float = 20;

    var can_close:Bool = false;

    var wait_event:String = '';
    var wait_input:Bool = false;

    var _event_id:String;

    var _texture:Texture;

    var timer:Timer;

    override public function new( options:ShowTutorialScreenOptions )
    {
        super(options);

        if(options.circle_pos != null){
            circle_pos = options.circle_pos;
        }
        if(options.wait_event != null){
            wait_event = options.wait_event;
        }
        if(options.wait_input != null){
            wait_input = options.wait_input;
        }

        _texture = Luxe.resources.texture(options.screen);
        _texture.filter_mag = _texture.filter_min = FilterType.nearest;

        if(options.uv == null){
            options.uv = new Rectangle(0,0,_texture.width, _texture.height);
        }

        // Find hud_batcher plz
        var _batcher:Batcher = Luxe.renderer.batcher;
        for(b in Luxe.renderer.batchers){
            if(b.name == 'hud_batcher'){
                _batcher = b;
                break;
            }
        }

        screen = new Sprite({
            name: 'screen',
            name_unique: true,
            texture: _texture,
            uv: options.uv,
            pos: options.pos,
            size: new Vector(options.uv.w,options.uv.h),
            centered: true,
            depth: 900,
            batcher: _batcher,
        });
        screen.color.a = 0;



        // if we're waiting for player input or not?
        if(wait_input)
        {
            var va:Vector = new Vector(Game.width/2 , Game.height*0.8);
            va.x = Math.round(va.x);
            va.y = Math.round(va.y);

            _texture = Luxe.resources.texture('assets/images/text.gif');
            _texture.filter_mag = _texture.filter_min = FilterType.nearest;

            accept = new Sprite({
                name: 'accept',
                name_unique: true,
                texture: _texture,
                uv: new Rectangle(0, 132, 54, 10),
                pos: va,
                size: new Vector(54, 10),
                centered: true,
                depth: 900.1,
                batcher: _batcher,
            });
            accept.color.a = 0;
        }
        
        // Alco place a circle
        if(circle_pos != null)
        {
            if(options.circle_size != null){
                circle_size = options.circle_size;
            }

            circle = new Visual({
                pos: circle_pos,
                geometry: Luxe.draw.ring({
                    x : Luxe.screen.w/2,
                    y : Luxe.screen.h/2,
                    r : options.circle_size,
                    color : new Color(1,1,1,1),
                }),
                batcher: _batcher,
            });
            circle.visible = false;
        }


    }

    override public function action()
    {

        show_screen();

        if(wait_input){
            Luxe.timer.schedule(0.3, showaccept);
        }

        if(wait_event.length > 0)
        {
            _event_id = Luxe.events.listen(wait_event, function(_){
                hide_screen();
                Luxe.events.unlisten(_event_id);
            });
        }
    }


    function show_screen()
    {
        screen.pos.y += 4;
        // screen.color.tween(1, {a:1});
        screen.color.a = 1;
        Actuate.tween(screen.pos, 0.8, {y: screen.pos.y-4});

        if(circle != null){
            circle.visible = true;

            // circle.add( new components.Blinking({
            //     time_on: 0.5,
            //     time_off: 0.2,
            // }));
        }
    }

    function showaccept()
    {
        // trace('showaccept()');
        can_close = true;

        accept.add( new components.Blinking({
            time_on: 0.5,
            time_off: 0.1,
        }) );

        start_input_timer();
    }

    function start_input_timer()
    {
        timer = Luxe.timer.schedule(1/60, check_input, true);
    }

    function check_input()
    {
        if(Luxe.input.inputdown('A') || Luxe.input.inputdown('B')){
            timer.stop();
            hide_screen();
        }
    }

    function hide_screen()
    {
        trace('hide_screen()');

        if(wait_input){
            accept.color.a = 0;
            accept.remove('blinking');
            accept.destroy();
        }
        
        screen.color.tween(0.7, {a:0})
        .onComplete(function(){
            screen.destroy();
        });

        if(circle != null){
            circle.remove('blinking');
            circle.visible = false;
        }

        finish();
    }

}

typedef ShowTutorialScreenOptions = {
    > ActionOptions,

    var screen:String;
    var pos:Vector;
    @:optional var uv:Rectangle;

    @:optional var wait_event:String;
    @:optional var wait_input:Bool;

    @:optional var circle_pos:Vector;
    @:optional var circle_size:Float;
};
