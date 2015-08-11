package components;

import luxe.Component;

class PuffEmitter extends Component{

    var cd:Float = 0;
    var max_cd:Float = 0.3;

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
        Luxe.events.fire('spawn.puff', {pos: entity.pos.clone()});

        cd = max_cd;
    }

}

