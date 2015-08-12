package actions;

import Action.ActionOptions;
import luxe.Input;
import luxe.Sprite;
import luxe.Vector;
import phenix.Texture;
import phoenix.geometry.Geometry;
import snow.api.Timer;

class ShowTutorialScreen extends Action {

    var screen:Sprite;
    var _accept:Sprite;
    var can_close:Bool = false;

    var _texture:Texture;

    var timer:Timer;

    override public function new( options:ShowTutorialScreenOptions )
    {
        super(options);

        _texture = Luxe.resources.texture(options.screen);

        screen = new Sprite({
            name: 'screen',
            name_unique: true,
            texture: _texture,
            pos: options.screen_pos,
            size: new Vector(_texture.width,_texture.height),
            centered: false,
            depth: 15,
        });
        screen.color.a = 0;


        var va:Vector = new Vector(Game.width/2,Game.height*0.9);
        va.x = Math.round(va.x);
        va.y = Math.round(va.y);

        _accept = new Sprite({
            name: 'accept',
            texture: Luxe.resources.texture('assets/images/accept.gif'),
            pos: options.screen_pos,
            size: va,
            centered: true,
            depth: 15.1,
        });
        _accept.color.a = 0;

    }

    override public function action()
    {

        Game.paused = true;

        show_screen();

        Luxe.timer.schedule(2, show_accept);

        // Pick random place in front of camera's center

    }


    function show_screen()
    {
        screen.color.tween(0.5, {a:1});
    }

    function show_accept()
    {
        can_close = true;
        _accept.color.a = 1;

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
        _accept.color.a = 0;
        destroy
        screen.color.tween(0.7, {a:0});
    }

}

typedef ShowTutorialScreenOptions = {
    > ActionOptions,

    var screen:String;
    var screen_pos:Vector;

    @:optional var circle_pos:Vector;
    @:optional var circle_size:Vector;
};
