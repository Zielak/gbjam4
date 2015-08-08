
package ;

import luxe.Sprite;
import luxe.Vector;

import components.Input;


class Player extends Sprite
{

    var movespeed:Float     = 0;
    var maxmovespeed:Float  = 1.25;
    var accelerate:Float    = 3;
    var decelerate:Float    = 4;

    var velocity:Vector;
    var realPos:Vector;

    var _speed:Float = 0;
    var _angle:Float = 0;

    var input:Input;

    override function init()
    {
        // fixed_rate = 1/60;

        velocity = new Vector(0,0);
        realPos = pos.clone();

        input = new Input({name: 'input'});

        add(input);

    } //ready



    override function update(dt:Float):Void
    {
        setSpeed(dt);

        _angle = input.angle;
        velocity.set_xy(_speed, 0);

        if(_angle != -1 && _speed > 0) velocity.angle2D = _angle;



            // Apply
        realPos.add(velocity);

        pos.copy_from(realPos);
        // pos = pos.int();
        pos.x = Math.round(pos.x);
        pos.y = Math.round(pos.y);

        if(input.move){
            // trace('player pos: ${pos.x}, ${pos.y}');
        }

    }



    function setSpeed(dt:Float):Void
    {
        if(input.move)
        {
            if( _speed < maxmovespeed ){
                _speed += maxmovespeed * accelerate * dt;
            }
            if( _speed > maxmovespeed ){
                _speed = maxmovespeed;
            }
        }
        else
        {
            if( _speed >= 1){
                _speed -= _speed * decelerate * dt;
            }
            if( _speed < 1 ){
                _speed = 0;
            }
        }
    }


}
