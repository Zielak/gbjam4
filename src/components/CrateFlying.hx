package components;

import luxe.Sprite;

class CrateFlying extends luxe.Component
{
    
    var sprite:Sprite;

    override function onadded()
    {
        sprite = cast(entity, Sprite);
        sprite.depth = 100;
    }

}
