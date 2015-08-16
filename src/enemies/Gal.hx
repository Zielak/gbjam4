
package enemies;

import components.Collider;
import enemies.Enemy.SoundProp;
import luxe.options.ComponentOptions;
import luxe.options.SpriteOptions;
import luxe.Rectangle;
import luxe.Sprite;
import luxe.Sound;
import luxe.Vector;

class Gal extends Enemy
{

    var collider:Collider;

    override public function new(options:SpriteOptions)
    {
        options.name = 'gal';
        options.texture = Luxe.resources.texture('assets/images/gal.gif');
        options.size = new Vector(16,16);
        options.centered = true;
        options.depth = 9.1;

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
                    "frameset": ["1"],
                    "loop": "true",
                    "speed": "8"
                },
                "hello" : {
                    "frame_size":{ "x":"16", "y":"16" },
                    "frameset": ["1-5","hold 15","6","hold 2","7","hold 1","6"],
                    "loop": "false",
                    "speed": "6"
                }
            }
        ';

        anim.add_from_json( animation_json );
        anim.animation = 'idle';
        anim.play();


        collider = new components.Collider({
            size: new Vector(108,108),
            testAgainst: ['player'],
            offset: new Vector(0,0),
        });
        add(collider);


        events.listen('collision.hit', function(_)
        {
            trace('GAL: hit player <3');

            collider.enabled = false;
            Luxe.timer.schedule(2,function()
            {
                anim.animation = 'hello';
                anim.play();
            });
            Luxe.events.fire('player.hit.gal');
        });


    }


}
