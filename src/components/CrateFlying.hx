package components;

import luxe.Component;
import luxe.Sprite;

class CrateFlying extends Component
{
    
    var sprite:Sprite;

    override function onadded()
    {
        sprite = cast(entity, Sprite);
        sprite.depth = 100;
    }

    override function ondestroy()
    {
        sprite = null;
    }

}
