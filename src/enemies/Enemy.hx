package enemies;

import components.Collider;
import luxe.Sprite;
import luxe.components.sprite.SpriteAnimation;
import luxe.utils.Maths;
import luxe.Vector;


class Enemy extends Sprite
{
    
    var anim:SpriteAnimation;

    override public function init()
    {
        anim = new SpriteAnimation({ name:'anim' });
        add( anim );
    }

    override public function ondestroy()
    {
        super.ondestroy();
        puff();
        // if(anim != null) anim.stop();
        // remove('anim');
        anim = null;
        // this.geometry.drop();
    }

    // Override with custom puff effects
    function puff(){}

    function get_sound_prop():SoundProp
    {
        var v:Vector = new Vector();

        v = Vector.Subtract(Luxe.camera.center, this.pos);

        return {
            volume: get_vol(v.length),
            pan: get_pan(v),
        }
    }

    function get_vol(len:Float):Float
    {
         if(len < 80) return 1
         else if(len >= 80 && len <= 160) return (-len/80)+2
         else return 0;
    }

    function get_pan(v:Vector):Float
    {
        // flatten vector
        // trace('ENEMY: ${v} get_pan before');
        if(v.x < 0) v.angle2D = 0;
        if(v.x > 0) v.angle2D = Math.PI;

        // trace('ENEMY: ${v} get_pan after');


        var f:Float = v.x;
        f = Maths.clamp(f, -100, 100);
        return f/200;
    }

}

typedef SoundProp = {
    var volume:Float;
    var pan:Float;
}
