package components;

import components.Movement;
import components.PuffEmitter;
import luxe.Component;
import luxe.Entity;
import luxe.Vector;

class CrateHolder extends Component {


    public static inline var GRAB_RANGE:Float = 10;
    public static inline var THROW_SPEED:Float = 90;
    public static inline var POS_X:Float = 0;
    public static inline var POS_Y:Float = -3;

    @:isVar public var holding (default, null):Bool;
    @:isVar public var crate (default, null):Entity;

    var crates:Array<Entity>;

    var _player:Vector;
    var _v:Vector;


    override function init()
    {
        holding = false;
        crate = null;
        _player = new Vector();
        _v = new Vector();

        entity.events.listen('input.Bpressed', function(e:CrateHolderEvents)
        {
            // Wait, am I holding anything?
            if(holding){
                throw_away(e.direction);
            }else{
                try_grabbing();
            }
        });
    }

    override function update(dt:Float)
    {
        // Keep held crate over player's head

        if(holding && crate != null)
        {
            crate.pos.x = entity.pos.x + POS_X;
            crate.pos.y = entity.pos.y + POS_Y;
        }
    }

    function try_grabbing()
    {
        // Get all, then closest, then check range
        Luxe.scene.get_named_like('crate', crates);

        if(crates.length > 0)
        {
            _player.copy_from( entity.pos );
            for(c in crates)
            {
                // Check distance
                _v = Vector.Subtract(_player, c.pos);

                if(_v.length <= GRAB_RANGE){
                    grab(c);
                    break;
                }
            }
            
        }

    }

    function grab(c:Entity)
    {
        if(holding) return;

        crate = c;

        entity.events.fire('crate.grab');
    }

    function throw_away(direction:Vector)
    {
        if(!holding) return;

        direction.normalize();
        direction.multiplyScalar(THROW_SPEED);

        direction.x += Game.directional_vector().x;
        direction.y += Game.directional_vector().y;

        Luxe.events.fire('spawn.puff', {pos: entity.pos.clone()});

        crate.add( new Movement({
            name: 'movement',
            velocity: direction,
        }));
        crate.add( new DestroyByDistance({
            name: 'distance',
            distance: 200,
        }));
        crate.add( new PuffEmitter({name:'puff_emitter'}));

        // I should be just forgetting about this entity
        // and not removing it. Let it fly!!
        crate = null;

        entity.events.fire('crate.throw_away');
    } 

}

typedef CrateHolderEvents = {
    var direction:Vector;
}
