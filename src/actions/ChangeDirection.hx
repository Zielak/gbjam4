package actions;

import Action.ActionOptions;
import luxe.Vector;

class ChangeDirection extends Action {


    var _spd:Float = 0;


    override public function action()
    {
        
        _spd = Game.speed;

    }



    function slow_down()
    {

    }

    function change_direction()
    {
        
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

    }

    function restore_speed()
    {

    }

}
