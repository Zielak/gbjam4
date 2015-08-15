package components;

import components.Collider;
import luxe.options.ComponentOptions;
import luxe.Sprite;
import snow.api.Timer;

class Immortal extends luxe.Component {

    var time:Float = 1;

    var collider:Collider;

    override public function new(options:ImmortalOptions)
    {
        options.name = 'immortal';
        super(options);
        time = options.time;
    }

    override function onadded()
    {
        if( this.has('collider') ){
            collider = cast get('collider');
        }

        if(collider == null){
            this.remove('immortal');
        }

        collider.enabled = false;
    }

    override function update(dt:Float)
    {
        time -= dt;
        if(time <= 0){
            collider.enabled = true;
            collider = null;
            remove('immortal');
        }
    }



}

typedef ImmortalOptions = {
    > ComponentOptions,

    var time:Float;
}
