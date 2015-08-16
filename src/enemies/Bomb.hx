
package enemies;

import enemies.Enemy.SoundProp;
import luxe.options.ComponentOptions;
import luxe.options.SpriteOptions;
import luxe.Rectangle;
import luxe.Sprite;
import luxe.Sound;
import luxe.Vector;

class Bomb extends Enemy
{

    var s_death:Sound;
    var s_death_vol:Float = 0.5;

    override public function new(options:BombOptions)
    {
        options.name = 'bomb';
        options.name_unique = true;
        options.texture = Luxe.resources.texture('assets/images/bomb.gif');
        options.size = new Vector(16,16);
        options.centered = true;
        options.depth = 8.1;

        super(options);

        this.texture.filter_mag = nearest;
        this.texture.filter_min = nearest;
    }

    override function init()
    {
        super.init();

        var animation_json = '
            {
                "idle" : {
                    "frame_size":{ "x":"16", "y":"16" },
                    "frameset": ["1","2"],
                    "loop": "true",
                    "speed": "8"
                }
            }
        ';

        anim.add_from_json( animation_json );
        anim.animation = 'idle';
        anim.play();


        add( new components.Collider({
            size: new Vector(8,8),
        }) );


        events.listen('collision.hit', function(_)
        {
            var sp:SoundProp = get_sound_prop();
            s_death.pitch = Math.random()*0.4 + 0.8;
            s_death.pan = sp.pan;
            s_death.volume = sp.volume * s_death_vol;
            s_death.play();
            s_death = null;

            destroy();
        });

        s_death = Luxe.audio.get('bomb');

    }

    // override function ondestroy()
    // {
    //     super.ondestroy(); 
    //     s_death = null;
    // }


    override function puff()
    {
        Luxe.events.fire('spawn.puff', {
            pos:pos.clone(), velocity: new Vector(0,30)});
        Luxe.events.fire('spawn.puff', {
            pos:pos.clone(), velocity: new Vector(30,0)});
        Luxe.events.fire('spawn.puff', {
            pos:pos.clone(), velocity: new Vector(0,-30)});
        Luxe.events.fire('spawn.puff', {
            pos:pos.clone(), velocity: new Vector(-30,0)});

        Luxe.events.fire('spawn.flash', {
            pos:pos.clone(), 
        });
    }


}

typedef BombOptions = {
    > SpriteOptions,
}
