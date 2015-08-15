package actions;

import Action.ActionOptions;
import luxe.tween.Actuate;
import luxe.Vector;

class ChangeSpeed extends Action {


    var target_speed:Float = 0;
    var smooth_time:Float = 0;

    override public function new(options:ChangeSpeedOptions)
    {
        super(options);

        if(options.smooth_time != null){
            smooth_time = Math.abs( options.smooth_time );
        }else{
            smooth_time = 0;
        }

        target_speed = options.target_speed;
    }

    override public function action()
    {
        if(smooth_time > 0){
            Actuate.tween(Game, smooth_time, {speed: target_speed} );
        }else{
            Game.speed = target_speed;
        }
        // trace('Game speed changed to: ${Game.speed}');
    }

}

typedef ChangeSpeedOptions = {
    > ActionOptions,

    var target_speed:Float;
    @:optional var smooth_time:Float;
}
