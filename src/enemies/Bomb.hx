
package enemies;

import luxe.options.ComponentOptions;
import luxe.options.SpriteOptions;
import luxe.Rectangle;
import luxe.Sprite;
import luxe.Vector;

class Bomb extends Enemy
{

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
            size: new Vector(10,10),
        }) );


        events.listen('collision.hit', function(_)
        {
            Luxe.events.fire('spawn.puff', {
                pos:pos.clone(), velocity: new Vector(0,30)});
            Luxe.events.fire('spawn.puff', {
                pos:pos.clone(), velocity: new Vector(30,0)});
            Luxe.events.fire('spawn.puff', {
                pos:pos.clone(), velocity: new Vector(0,-30)});
            Luxe.events.fire('spawn.puff', {
                pos:pos.clone(), velocity: new Vector(-30,0)});
            destroy();
        });

    }


}

typedef BombOptions = {
    > SpriteOptions,
}
