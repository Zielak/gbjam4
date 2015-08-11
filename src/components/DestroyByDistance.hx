
package components;

import luxe.Component;
import luxe.options.ComponentOptions;
import luxe.Rectangle;

import luxe.Sprite;
import luxe.Vector;
import snow.api.Timer;

class DestroyByDistance extends Component
{

    public var distance:Float;
    var _dist:Float;

    var timer:Timer;

    override public function new( options:DestroyByDistanceOptions )
    {
        distance = options.distance;

        super(options);

        timer = Luxe.timer.schedule(0.5, step, true);
    }

    function step()
    {
        var _v:Vector = Vector.Subtract( entity.pos, Luxe.camera.center );

        if(_v.length > distance)
        {
            // entity.events.fire('destroy.bydistance');
            // trace('${entity.name} destroyed');
            entity.destroy();

            timer.stop();
            timer = null;

            var sprite:Sprite = cast(entity, Sprite);
            if( sprite != null ){
                sprite.geometry.drop();
            }
            entity = null;
        }
    }

    override function update(dt:Float):Void
    {

    }

}

typedef DestroyByDistanceOptions = {
    > ComponentOptions,

    var distance:Float;
}
