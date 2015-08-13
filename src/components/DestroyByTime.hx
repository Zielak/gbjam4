
package components;

import luxe.Component;
import luxe.options.ComponentOptions;
import luxe.Rectangle;

import luxe.Visual;
import luxe.Vector;
import snow.api.Timer;

class DestroyByTime extends Component
{

    var time:Float;

    override public function new( options:DestroyByTimeOptions )
    {
        time = options.time;

        options.name = 'destroybytime';

        super(options);

        Luxe.timer.schedule(time, killme);
    }

    function killme()
    {

        // entity.events.fire('destroy.bytime');
        entity.destroy();

        var _vis:Visual = cast(entity, Visual);
        if( _vis != null ){
            if( _vis.geometry != null ){
                _vis.geometry.drop();
            }
        }
        entity = null;
    }

}

typedef DestroyByTimeOptions = {
    > ComponentOptions,

    var time:Float;
}
