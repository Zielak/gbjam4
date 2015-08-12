
import luxe.options.ComponentOptions;
import luxe.options.SpriteOptions;
import luxe.Rectangle;
import luxe.Sprite;
import luxe.Vector;
import luxe.components.sprite.SpriteAnimation;

class Puff extends Sprite
{
    
    var anim:SpriteAnimation;

    override public function new(options:SpriteOptions)
    {
        options.name = 'puff';
        options.name_unique = true;
        options.texture = Luxe.resources.texture('assets/images/puff.gif');
        options.size = new Vector(16,16);
        options.centered = true;
        options.depth = 4;

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
                    "frameset": ["1-8"],
                    "loop": "false",
                    "speed": "12"
                }
            }
        ';

        anim.add_from_json( animation_json );
        anim.animation = 'idle';
        anim.play();
        anim.speed = 12 + Math.random()*12;

        anim.add_event('idle',8,'puff.ends');

        this.events.listen('puff.ends', function(_){
            // trace('puff ends');
            this.destroy();

            // this.geometry.drop();
            // 
            // anim.stop();
            // anim = null;
            // remove('anim');
            // anim = null;
        });

    }

    override function ondestroy()
    {
        // trace('puff ondestroyed');
    }

}
