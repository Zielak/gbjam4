package components;

import luxe.Component;
import luxe.Sprite;
import luxe.utils.Maths;

import phoenix.Texture.ClampType;

class Light extends Component{

    public static inline var MAX_SIZE:Float = 700;
    public static inline var MIN_SIZE:Float = 64;

    var MIN_SIZE_MULT:Float = 5;
    var MAX_SIZE_MULT:Float = 2;

    var MIN_POS_MULT:Float = -2;
    var MAX_POS_MULT:Float = -0.5;

    public var test:Bool = false;

    var texture_w:Float;
    var texture_h:Float;

    var _t:Float = 0;

    var size:Float = 1;
    var max_size:Float;

    var sprite:Sprite;

    // Used to animate light expansion
    var anim_float:Float = 0;

    override function onadded()
    {
        sprite = cast(entity, Sprite);
        if(sprite == null) throw 'add Light on a Sprite!';

        texture_w = sprite.texture.width;
        texture_h = sprite.texture.height;

        Luxe.events.listen('crate.hit.enemy', function(_){
            anim_float = 0.4;
        });
    }

    override function onremoved()
    {
        sprite = null;
    }
    
    override function update(dt:Float)
    {
        if(sprite == null) return;

        size = Game.hope;

        if(anim_float > 0){
            anim_float -= dt;
        }else if(anim_float < 0){
            anim_float = 0;
        }

        size += anim_float;

        sprite.color.a = Maths.clamp(size*2, 0.8, 1);

        if(test)
        {
            _t += dt;
            size = ( Math.sin(_t) /2 ) + 0.5;
        }


        sprite.uv.x = texture_w * Maths.lerp(MIN_POS_MULT, MAX_POS_MULT, size);
        sprite.uv.y = texture_h * Maths.lerp(MIN_POS_MULT, MAX_POS_MULT, size);
        sprite.uv.w = texture_w * Maths.lerp(MIN_SIZE_MULT, MAX_SIZE_MULT, size);
        sprite.uv.h = texture_h * Maths.lerp(MIN_SIZE_MULT, MAX_SIZE_MULT, size);
    }

}

