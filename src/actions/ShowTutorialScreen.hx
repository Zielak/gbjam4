package actions;

import Action.ActionOptions;
import luxe.Input;
import luxe.Rectangle;
import luxe.Sprite;
import luxe.tween.Actuate;
import luxe.Vector;
import phoenix.Texture;
import phoenix.geometry.Geometry;
import snow.api.Timer;

class ShowTutorialScreen extends Action {

    var screen:Sprite;
    var accept:Sprite;
    var can_close:Bool = false;

    var _texture:Texture;

    var timer:Timer;

    override public function new( options:ShowTutorialScreenOptions )
    {
        super(options);

        _texture = Luxe.resources.texture(options.screen);

        if(options.uv == null){
            options.uv = new Rectangle(0,0,_texture.width, _texture.height);
        }

        screen = new Sprite({
            name: 'screen',
            name_unique: true,
            texture: _texture,
            uv: options.uv,
            pos: options.pos,
            size: new Vector(options.uv.x,options.uv.y),
            centered: true,
            depth: 900,
        });
        screen.color.a = 0;


        var va:Vector = new Vector(Game.width/2 , Game.height*0.9);
        va.x = Math.round(va.x);
        va.y = Math.round(va.y);

        _texture = Luxe.resources.texture('assets/images/gal.gif');

        accept = new Sprite({
            name: 'accept',
            texture: _texture,
            pos: va,
            size: new Vector(_texture.width, _texture.height),
            centered: true,
            depth: 900.1,
        });
        accept.color.a = 0;

    }

    override public function action()
    {

        Game.delayed = true;

        show_screen();

        Luxe.timer.schedule(2, showaccept);

        // Pick random place in front of camera's center

    }


    function show_screen()
    {
        screen.pos.y += 4;
        screen.color.tween(0.5, {a:1});
        Actuate.tween(screen.pos, 0.8, {y: screen.pos.y-4});
    }

    function showaccept()
    {
        can_close = true;
        accept.color.a = 1;

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
        Game.delayed = false;

        accept.color.a = 0;
        screen.color.tween(0.7, {a:0})
        .onComplete(function(){
            screen.destroy();
            accept.destroy();
        });

        finish();
    }

}

typedef ShowTutorialScreenOptions = {
    > ActionOptions,

    var screen:String;
    var pos:Vector;
    @:optional var uv:Rectangle;

    @:optional var circle_pos:Vector;
    @:optional var circle_size:Vector;
};
