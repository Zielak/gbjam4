
package ;

import luxe.Rectangle;
import luxe.Sprite;
import luxe.Vector;
import luxe.components.sprite.SpriteAnimation;

import components.Input;


class Player extends Sprite
{

    public static inline var SIZE:Float = 16;

    var movespeed:Float     = 0;
    var maxmovespeed:Float  = 1;
    var accelerate:Float    = 8;
    var decelerate:Float    = 1;

    var velocity:Vector;
    var game_v:Vector;
    var realPos:Vector;

    var bounds:Rectangle;

    var _speed:Float = 0;
    var _angle:Float = 0;

    var input:Input;
    var anim:SpriteAnimation;

    override function init()
    {
        // fixed_rate = 1/60;

        velocity = new Vector(0,0);
        game_v = new Vector(0,0);
        realPos = pos.clone();

        bounds = new Rectangle(
            SIZE/2,
            SIZE,
            Game.width-SIZE,
            Game.height-SIZE*2
        );

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
        if(Game.playing && !Game.delayed)
        {
            setSpeed(dt);

            _angle = input.angle;
            velocity.set_xy(_speed, 0);

            if(_angle != -1 && _speed > 0) velocity.angle2D = _angle;

                // Update Bounds
            bounds.x = Luxe.camera.center.x - Game.width/2 + SIZE/2;
            bounds.y = Luxe.camera.center.y - Game.height/2 + SIZE/2;

                // Apply
            realPos.add(velocity);

                // Game velocity too
            game_v.copy_from(Game.directional_vector());
            game_v.x *= dt;
            game_v.y *= dt;
            realPos.add(game_v);

                // Bounds
            if( realPos.x > bounds.x + bounds.w ) realPos.x = bounds.x + bounds.w;
            if( realPos.x < bounds.x ) realPos.x = bounds.x;

            if( realPos.y > bounds.y + bounds.h ) realPos.y = bounds.y + bounds.h;
            if( realPos.y < bounds.y ) realPos.y = bounds.y;

            pos.copy_from(realPos);
            // pos = pos.int();
            pos.x = Math.round(pos.x);
            pos.y = Math.round(pos.y);

            if(input.move){
                // trace('player pos: ${pos.x}, ${pos.y}');
            }

            // Animation
            anim.speed = 9 + 8*(1 - Game.hope);
        }else{
            // anim.speed = 0;
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
