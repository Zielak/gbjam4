
package ;

import luxe.Sprite;
import luxe.Vector;
import luxe.components.sprite.SpriteAnimation;

import components.Input;


class Player extends Sprite
{

    public static inline var SIZE:Float = 16;

    var movespeed:Float     = 0;
    var maxmovespeed:Float  = 1.25;
    var accelerate:Float    = 3;
    var decelerate:Float    = 4;

    var velocity:Vector;
    var realPos:Vector;

    var _speed:Float = 0;
    var _angle:Float = 0;

    var input:Input;
    var anim:SpriteAnimation;

    override function init()
    {
        // fixed_rate = 1/60;

        velocity = new Vector(0,0);
        realPos = pos.clone();

        input = new Input({name: 'input'});

        add(input);

        // Animation

        anim = new SpriteAnimation({ name:'anim' });
        add( anim );

        var animation_json = '
            {
                "idle" : {
                    "frame_size":{ "x":"16", "y":"16" },
                    "frameset": ["1"],
                    "pingpong":"false",
                    "loop": "false",
                    "speed": "18"
                },
                "walk" : {
                    "frame_size":{ "x":"16", "y":"16" },
                    "frameset": ["1","2","1","3"],
                    "pingpong":"false",
                    "loop": "true",
                    "speed": "12"
                }
            }
        ';

        anim.add_from_json( animation_json );
        anim.animation = 'walk';
        anim.play();



    } //ready



    override function update(dt:Float):Void
    {
        setSpeed(dt);

        _angle = input.angle;
        velocity.set_xy(_speed, 0);

        if(_angle != -1 && _speed > 0) velocity.angle2D = _angle;



            // Apply
        realPos.add(velocity);

            // Bounds
        if( realPos.x > Game.width-SIZE/2 ) realPos.x = Game.width-SIZE/2;
        if( realPos.x < SIZE/2 ) realPos.x = SIZE/2;

        if( realPos.y > Game.height-SIZE/2 ) realPos.y = Game.height-SIZE/2;
        if( realPos.y < SIZE/2 ) realPos.y = SIZE/2;

        pos.copy_from(realPos);
        // pos = pos.int();
        pos.x = Math.round(pos.x);
        pos.y = Math.round(pos.y);

        if(input.move){
            // trace('player pos: ${pos.x}, ${pos.y}');
        }

        // Animation
        anim.speed = 9 + 8*(1 - Game.hope);

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
