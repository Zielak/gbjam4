
package ;

import components.Collider;
import components.CrateHolder;
import luxe.Rectangle;
import luxe.Sprite;
import luxe.Vector;
import luxe.components.sprite.SpriteAnimation;

import components.Input;


class Player extends Sprite
{

    public static inline var SIZE:Float = 16;

    var movespeed:Float     = 0;
    var maxmovespeed:Float  = 1.5;
    var accelerate:Float    = 6;
    var decelerate:Float    = 4;

    var dashing:Bool        = false;
    var dashspeed:Float     = 1.8;

    var dashcd:Float        = 0;
    var dashcdmax:Float     = 0.7;

    var dashtime:Float      = 0;
    var dashtimemax:Float   = 0.4;


    var velocity:Vector;
    var game_v:Vector;

    @:isVar var all_velocity(get, null):Vector;
    var _all_velocity:Vector;
    function get_all_velocity():Vector
    {
        _all_velocity.copy_from(velocity);
        _all_velocity.add(game_v);
        return _all_velocity;
    }

    var realPos:Vector;
    var posTimer:snow.api.Timer;

    var bounds:Rectangle;

    var _speed:Float = 0;
    var _angle:Float = 0;

    var input:Input;
    var collider:Collider;
    var anim:SpriteAnimation;
    var crateHolder:CrateHolder;

    override function init()
    {
        // fixed_rate = 1/60;

        velocity = new Vector(0,0);
        game_v = new Vector(0,0);
        _all_velocity = new Vector(0,0);

        realPos = pos.clone();
        posTimer = Luxe.timer.schedule(1/60, update_pos, true);

        bounds = new Rectangle(
            SIZE/2,
            SIZE,
            Game.width-SIZE,
            Game.height-SIZE*2
        );

        input = new Input({name: 'input'});
        add(input);


        collider = new Collider({
            testAgainst: ['cruncher', 'bomb'],
            size: new Vector(10,10),
            offset: new Vector(0,0),
        });
        add(collider);

        add( new components.Immortal({
            time: 9999999
        }));

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
                },
                "walk_crate" : {
                    "frame_size":{ "x":"16", "y":"16" },
                    "frameset": ["6","7","6","8"],
                    "pingpong":"false",
                    "loop": "true",
                    "speed": "12"
                },
                "dash" : {
                    "frame_size":{ "x":"16", "y":"16" },
                    "frameset": ["5"],
                    "pingpong":"false",
                    "loop": "true",
                    "speed": "12"
                },
                "death" : {
                    "frame_size":{ "x":"16", "y":"16" },
                    "frameset": ["9-11","hold 2","12-14"],
                    "pingpong":"false",
                    "loop": "false",
                    "speed": "14"
                },
                "deathsits" : {
                    "frame_size":{ "x":"16", "y":"16" },
                    "frameset": ["15-16"],
                    "pingpong":"false",
                    "loop": "true",
                    "speed": "8"
                }
            }
        ';

        anim.add_from_json( animation_json );
        anim.animation = 'walk';
        anim.play();


        crateHolder = new CrateHolder({name:'crate_holder'});
        add(crateHolder);

        events.listen('collision.hit', function(_){
            Luxe.events.fire('player.hit.enemy');
            if( !has('immortal') ) {
                add( new components.Immortal({time:3}) );
                add( new components.Blinking({
                    time_off: 0.05,
                    time_on: 0.1,
                    remove_after: 3,
                }) );
            }
        });


        Luxe.events.listen('game.over.*', function(_){
            play_animation('death');
        });

    } //ready



    override function update(dt:Float):Void
    {
        if(Game.playing && !Game.delayed)
        {


            if(!dashing){
                setSpeed(dt);
                _angle = input.angle;
                velocity.set_xy(_speed, 0);
            }else{
                velocity.set_xy(dashspeed, 0);
            }

            if(_angle != -1 && _speed > 0) velocity.angle2D = _angle;

                // Dash stuff
            setDashing(dt);

            if(!dashing){
                if(input.Bpressed && crateHolder.holding){
                    // Bpressed for the throwing
                    events.fire('input.Bpressed', {direction:velocity.clone()});
                }else if(input.B && !crateHolder.holding){
                    // B for the grabbin
                    events.fire('input.B');
                }
            }
            

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

            // Animation
            set_animation();
        }else{
            // anim.speed = 0;
        }

        // draw_collider();
    }

    function update_pos()
    {
        pos.copy_from(realPos);
        // pos = pos.int();
        pos.x = Math.round(pos.x);
        pos.y = Math.round(pos.y);
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

    function setDashing(dt:Float)
    {
        if(dashing){
            dashtime -= dt;
            if(dashtime <= 0) stopDashing();
        }else{
            if(dashcd > 0) dashcd -= dt;

            if(dashcd <= 0
            && input.move
            && input.A
            && !crateHolder.holding
            ){
                startDashing();
            }
        }
    }

    function startDashing()
    {
        dashing = true;
        dashtime = dashtimemax;

        if(!has('immortal') ) collider.enabled = false;

        Luxe.events.fire('spawn.puff', {
            pos: pos.clone(),
            velocity: Game.directional_vector(),
        });

        // anim.animation = 'dash';
        // anim.play();

        Luxe.events.fire('player.dash');
    }

    function stopDashing()
    {
        dashing = false;
        dashtime = 0;
        dashcd = dashcdmax;

        if(!has('immortal')) collider.enabled = true;

        // anim.animation = 'walk';
        // anim.play();
    }

    function set_animation()
    {
        if(all_velocity.length < 0.2)
        {
            if(!crateHolder.holding){
                play_animation('idle');
            }else{
                anim.animation = 'walk_crate';
                anim.frame = 1;
                anim.stop();
            }
        }
        else if(all_velocity.length >= 0.2)
        {
            // set anim speed
            if(Game.speed < 0.5){
                anim.speed = 12;
            }else{
                anim.speed = 9 + 8*(1 - Game.hope);
            }

            // Set animation
            if(!crateHolder.holding){
                if(!dashing){
                    play_animation('walk');
                }else{
                    play_animation('dash');
                }
            }else{
                play_animation('walk_crate');
            }
        }
    }

    function play_animation(_name:String)
    {
        if( !anim.playing ){
            anim.play();
        }
        if( anim.animation != _name ){
            anim.animation = _name;
            anim.play();
        }
    }


    function draw_collider()
    {
        if(collider == null) return;

        Game.drawer.drawShape( collider.shape );
    }

}
