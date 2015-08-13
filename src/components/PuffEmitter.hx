package components;

import luxe.Component;
import luxe.Sprite;

class PuffEmitter extends Component{

    var cd:Float = 0;
    var max_cd:Float = 0.15;

    var sprite:Sprite;

    override function onadded()
    {
        sprite = cast(entity, Sprite);
    }

    override function init()
    {
        puff();
    }

    override function update(dt:Float)
    {
        if(cd > 0){
            cd -= dt;
        }else{
            puff();
        }
    }

    function puff()
    {

        Luxe.events.fire('spawn.puff', {pos: entity.pos, depth: sprite.depth });

        cd = max_cd;
    }

}

