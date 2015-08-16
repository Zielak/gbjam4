
package enemies;

import luxe.options.ComponentOptions;
import luxe.options.SpriteOptions;
import luxe.Rectangle;
import luxe.Sound;
import enemies.Enemy.SoundProp;
import luxe.Sprite;
import luxe.Vector;
import luxe.components.sprite.SpriteAnimation;
import components.Collider;

class Crate extends Enemy
{
    var s_death_vol:Float = 0.6;
    
    override public function new(options:SpriteOptions)
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
        super.init();

        var animation_json = '
            {
                "idle" : {
                    "frame_size":{ "x":"16", "y":"16" },
                    "frameset": ["1"],
                    "loop": "true",
                    "speed": "12"
                },
                "die" : {
                    "frame_size":{ "x":"16", "y":"16" },
                    "frameset": ["2-7"],
                    "loop": "false",
                    "speed": "12"
                }
            }
        ';

        anim.add_from_json( animation_json );
        anim.animation = 'idle';
        // anim.play();

        // anim.add_event('die', 7, 'die.finished');


        events.listen('collision.hit', function(e:ColliderEvent)
        {
            var sp:SoundProp = get_sound_prop();
            Luxe.audio.pitch('crate', Math.random()*0.4 + 0.8);
            Luxe.audio.pan('crate', sp.pan);
            Luxe.audio.volume('crate', sp.volume * s_death_vol);
            Luxe.audio.play('crate');


            Luxe.events.fire('crate.hit.enemy');

            Luxe.events.fire('spawn.puff', {
                pos:pos.clone(), speed: 25+Math.random()*25, angle: Math.random()*2*Math.PI});
            Luxe.events.fire('spawn.puff', {
                pos:pos.clone(), speed: 25+Math.random()*25, angle: Math.random()*2*Math.PI});
            
            this.destroy();
        });

    }



}

