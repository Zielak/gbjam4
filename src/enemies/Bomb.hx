
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

    var s_death_vol:Float = 0.2;

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
        if(this.destroyed) return;
        anim.animation = 'idle';
        anim.play();


        add( new components.Collider({
            size: new Vector(8,8),
        }) );


        if(events == null) return;
        events.listen('collision.hit', function(_)
        {
            var sp:SoundProp = get_sound_prop();
            Luxe.audio.pitch('bomb', Math.random()*0.4 + 0.8);
            Luxe.audio.pan('bomb', sp.pan);
            Luxe.audio.volume('bomb', sp.volume * s_death_vol);
            Luxe.audio.play('bomb');

            destroy();
        });

    }

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
