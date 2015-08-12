package enemies;

import components.Collider;
import luxe.Sprite;
import luxe.components.sprite.SpriteAnimation;


class Enemy extends Sprite
{
    
    var anim:SpriteAnimation;

    var _collider:Collider;

    override public function init()
    {
        anim = new SpriteAnimation({ name:'anim' });
        add( anim );
    }

    override public function ondestroy()
    {
        _collider = null;
        if(anim != null) anim.stop();
        anim = null;
        this.geometry.drop();
    }


    override function update(dt:Float) {
        /*
        if(has('collider')){
            _collider = cast get('collider');
            if(_collider != null) Game.drawer.drawShape( _collider.shape );
        }
        */
    }


}
