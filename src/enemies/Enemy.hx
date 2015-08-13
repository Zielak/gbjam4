package enemies;

import components.Collider;
import luxe.Sprite;
import luxe.components.sprite.SpriteAnimation;


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
        if(anim != null) anim.stop();
        remove('anim');
        anim = null;
        this.geometry.drop();
    }


}
