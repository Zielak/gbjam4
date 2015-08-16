
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

    var _v:Vector;

    override public function new( options:DestroyByDistanceOptions )
    {
        distance = options.distance;

        super(options);

        timer = Luxe.timer.schedule(0.5, step, true);
    }

    function step()
    {
        _v = Vector.Subtract( entity.pos, Luxe.camera.center );

        if(_v.length > distance)
        {
            // entity.events.fire('destroy.bydistance');
            // trace('${entity.name} destroyed');
            timer.stop();
            timer = null;
            _v = null;
            this.entity.destroy();
            entity = null;
        }
    }


}

typedef DestroyByDistanceOptions = {
    > ComponentOptions,

    var distance:Float;
}
