
package components;

import luxe.Component;
import luxe.options.ComponentOptions;
import luxe.Rectangle;

import luxe.Vector;

class Movement extends Component
{

    public var velocity:Vector;

    public var bounds:Rectangle;
    public var killBounds:Rectangle;

    var realPos:Vector;

    override public function new( options:MovementOptions )
    {
        if(options.bounds != null){
            bounds = options.bounds;
        }
        if(options.killBounds != null){
            killBounds = options.killBounds;
        }
        velocity = options.velocity;

        super(options);
    } 

    override function init()
    {
        realPos = entity.pos.clone();

        if(killBounds == null && bounds != null)
        {
            killBounds.copy_from(bounds);
        }
    } //ready

    override function ondestroy()
    {
        velocity = null;
        bounds = null;
        killBounds = null;
        realPos = null;
    }

    override function update(dt:Float):Void
    {
        if(Game.delayed) return;
        // switch(Game.direction)
        // {
        //     case right: velocity.angle2D = Math.PI;
        //     case down:  velocity.angle2D = 3*Math.PI/2;
        //     case left:  velocity.angle2D = 0;
        //     case up:    velocity.angle2D = Math.PI/2;
        // }

        realPos.x += velocity.x * dt;
        realPos.y += velocity.y * dt;

        pos.copy_from(realPos);
        pos.x = Math.round(pos.x);
        pos.y = Math.round(pos.y);


        if(killBounds != null){
            if(pos.x > killBounds.w
            || pos.x < killBounds.x
            || pos.y > killBounds.h
            || pos.y < killBounds.y)
            {
                entity.events.fire('movement.killBounds');
                entity.destroy(true);
            }
        }

        if(bounds != null){
            if(pos.x > bounds.w) pos.x = bounds.w;
            if(pos.x < bounds.x) pos.x = bounds.x;
            if(pos.y > bounds.h) pos.y = bounds.h;
            if(pos.y < bounds.y) pos.y = bounds.y;
        }

    }

}

typedef MovementOptions = {
    > ComponentOptions,

    var velocity:Vector;
    @:optional var bounds:Rectangle;
    @:optional var killBounds:Rectangle;
}
