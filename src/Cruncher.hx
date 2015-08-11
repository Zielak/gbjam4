
import luxe.options.ComponentOptions;
import luxe.options.SpriteOptions;
import luxe.Rectangle;
import luxe.Sprite;
import luxe.Vector;
import luxe.components.sprite.SpriteAnimation;

class Cruncher extends Sprite
{
    
    var anim:SpriteAnimation;

    override public function new(options:CruncherOptions)
    {
        options.name = 'cruncher';
        options.name_unique = true;
        options.texture = Luxe.resources.texture('assets/images/cruncher.gif');
        options.size = new Vector(16,16);
        options.centered = true;
        options.depth = 8;

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
                "walk" : {
                    "frame_size":{ "x":"16", "y":"16" },
                    "frameset": ["1","2","3","2"],
                    "loop": "true",
                    "speed": "12"
                }
            }
        ';

        anim.add_from_json( animation_json );
        anim.animation = 'walk';
        anim.play();


        add( new components.Collider({
            
        }) );


        events.listen('collision.hit', function(_)
        {
            Luxe.events.fire('spawn.puff', {
                pos:pos.clone(), velocity: new Vector(0,1)});
            Luxe.events.fire('spawn.puff', {
                pos:pos.clone(), velocity: new Vector(1,0)});
            Luxe.events.fire('spawn.puff', {
                pos:pos.clone(), velocity: new Vector(0,-1)});
            Luxe.events.fire('spawn.puff', {
                pos:pos.clone(), velocity: new Vector(-1,0)});
            destroy();
        });
    }

    override public function ondestroy()
    {
        anim.stop();
        anim = null;
        this.geometry.drop();
    }

}

typedef CruncherOptions = {
    > SpriteOptions,
}
