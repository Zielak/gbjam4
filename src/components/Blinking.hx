package components;

import luxe.options.ComponentOptions;
import luxe.Sprite;
import snow.api.Timer;

class Blinking extends luxe.Component {

    var time_on:Float;
    var time_off:Float;
    var remove_after:Float = -1;

    var time:Float;
    var timer:Timer;

    var sprite:Sprite;

    var visible:Bool;
    
    override public function new ( options:BlinkingOptions )
    {
        options.name = 'blinking';
        super(options);

        time_on = options.time_on;
        time_off = options.time_off;
        if(options.remove_after != null){
            remove_after = options.remove_after;
        }

        time = time_on;
        visible = true;

        if(remove_after > 0){
            timer = Luxe.timer.schedule(remove_after, function(){
                remove('blinking');
            });
        }
    }

    override function onadded()
    {
        sprite = cast entity;

        if(sprite == null) throw 'ONLY ON SPRITES, DUDE!';
    }

    override function onremoved()
    {
        timer = null;
        sprite.color.a = 1;
        sprite = null;
    }

    override function update(dt:Float)
    {
        time -= dt;

        if(time <= 0){
            if(visible){
                sprite.color.a = 0;
                visible = false;
                time = time_off;
            }else{
                sprite.color.a = 1;
                visible = true;
                time = time_on;
            }
        }
    }

}

typedef BlinkingOptions = {
    > ComponentOptions,

    var time_on:Float;
    var time_off:Float;
    @:optional var remove_after:Float;
}
