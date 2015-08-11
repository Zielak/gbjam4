
import luxe.options.ComponentOptions;
import luxe.options.SpriteOptions;
import luxe.Rectangle;
import luxe.Sprite;
import luxe.Vector;
import luxe.components.sprite.SpriteAnimation;

class Crate extends Sprite
{
    
    var anim:SpriteAnimation;

    override public function new(options:CrateOptions)
    {
        options.name = 'crate';
        options.name_unique = true;
        options.texture = Luxe.resources.texture('assets/images/crate.gif');
        options.size = new Vector(16,16);
        options.centered = true;
        options.depth = 7;

        super(options);

        this.texture.filter_mag = nearest;
        this.texture.filter_min = nearest;
    }

    override function init()
    {
        anim = new SpriteAnimation({ name:'anim' });
        add( anim );

        var animation_json = '
            {
                "idle" : {
                    "frame_size":{ "x":"16", "y":"16" },
                    "frameset": ["1"],
                    "loop": "true",
                    "speed": "12"
                },
                "held" : {
                    "frame_size":{ "x":"16", "y":"16" },
                    "frameset": ["1"],
                    "loop": "true",
                    "speed": "12"
                },
                "flying" : {
                    "frame_size":{ "x":"16", "y":"16" },
                    "frameset": ["1"],
                    "loop": "true",
                    "speed": "12"
                }
            }
        ';

        anim.add_from_json( animation_json );
        anim.animation = 'idle';
        anim.play();

    }

    override public function ondestroy()
    {
        anim.stop();
        anim = null;
        this.geometry.drop();
    }

}

typedef BombOptions = {
    > SpriteOptions,
}
