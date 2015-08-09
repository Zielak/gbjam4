
package components;

import luxe.Component;
import luxe.Rectangle;

import luxe.Vector;

class Movement extends Component
{

    public var yspeed:Float;
    public var xspeed:Float;
    public var bounds:Rectangle;
    public var killBounds:Rectangle;

    override function init()
    {
        if(killBounds == null && bounds != null)
        {
            killBounds.copy_from(bounds);
        }
    } //ready


    override function onfixedupdate(rate:Float):Void
    {
        pos.x += xspeed * rate;
        pos.y += yspeed * rate;

        if(pos.x > killBounds.w
        || pos.x < killBounds.x
        || pos.y > killBounds.h
        || pos.y < killBounds.y)
        {
            entity.destroy(true);
        }

        if(pos.x > bounds.w) pos.x = bounds.w;
        if(pos.x < bounds.x) pos.x = bounds.x;
        if(pos.y > bounds.h) pos.y = bounds.h;
        if(pos.y < bounds.y) pos.y = bounds.y;

    }

}