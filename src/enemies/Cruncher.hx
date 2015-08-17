package enemies;

import luxe.options.ComponentOptions;
import luxe.options.SpriteOptions;
import luxe.Rectangle;
import luxe.Sound;
import enemies.Enemy.SoundProp;
import luxe.Sprite;
import luxe.Vector;

class Cruncher extends Enemy
{
    

    var s_death_vol:Float = 0.5;

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
        super.init();

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
        if(!this.destroyed){
            anim.animation = 'walk';
            anim.play();
        }else{
            trace('he did it!');
        }
        

        add( new components.Collider({
            size: new Vector(8,8),
        }) );


        if(events == null) return;
        events.listen('collision.hit', function(_)
        {
            var sp:SoundProp = get_sound_prop();
            Luxe.audio.pitch('cruncher_die', Math.random()*0.4 + 0.8);
            Luxe.audio.pan('cruncher_die', sp.pan);
            Luxe.audio.volume('cruncher_die', sp.volume * s_death_vol);
            Luxe.audio.play('cruncher_die');

            destroy();
        });
    }


    override function puff()
    {
        Luxe.events.fire('spawn.puff', {
            pos:pos.clone(), speed: 25+Math.random()*25, angle: Math.random()*2*Math.PI});
        Luxe.events.fire('spawn.puff', {
            pos:pos.clone(), speed: 25+Math.random()*25, angle: Math.random()*2*Math.PI});
        Luxe.events.fire('spawn.puff', {
            pos:pos.clone(), speed: 25+Math.random()*25, angle: Math.random()*2*Math.PI});
        Luxe.events.fire('spawn.puff', {
            pos:pos.clone(), speed: 25+Math.random()*25, angle: Math.random()*2*Math.PI});
    }

}

typedef CruncherOptions = {
    > SpriteOptions,
}
