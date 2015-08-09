
package components;

import luxe.Component;
import luxe.options.ComponentOptions;
import luxe.Rectangle;

import luxe.Vector;

class DestroyByDistance extends Component
{

    public var distance:Float;
    var _dist:Float;
    var _v:Vector;

    override public function new( options:DestroyByDistanceOptions )
    {
        distance = options.distance;

        _v = new Vector( );

        super(options);
    } 

    override function update(dt:Float):Void
    {
        _v = Vector.Subtract( entity.pos, Luxe.camera.center );

        if(_v.length > distance)
        {
            entity.events.fire('destroy.bydistance');
            entity.destroy(true);
        }

    }

}

typedef DestroyByDistanceOptions = {
    > ComponentOptions,

    var distance:Float;
}
