package actions;

import Action.ActionOptions;
import luxe.tween.Actuate;
import luxe.Vector;

class ChangeDirection extends Action {


    var _spd:Float = 0;



    override public function action()
    {
        
        trace('ChangeDirection?');
        _spd = Game.speed;
        slow_down();

    }



    function slow_down()
    {
        trace('ChangeDirection.slow_down');
        Actuate.tween(Game, 0.5, {speed: 0})
        .onComplete(change_direction);
    }

    function change_direction()
    {
        trace('ChangeDirection.change_direction');
        
        var _d = Math.round( Math.random() );

        switch(Game.direction)
        {
            case right:
                Game.direction = (_d==1) ? up : down;
            case down:
                Game.direction = (_d==1) ? left : right;
            case left:
                Game.direction = (_d==1) ? up : down;
            case up:
                Game.direction = (_d==1) ? left : right;
        }

        Luxe.events.fire('game.directon.changed');

        restore_speed();
    }

    function restore_speed()
    {
        trace('ChangeDirection.restore_speed');
        Actuate.tween(Game, 1, {speed: _spd});
    }

}
