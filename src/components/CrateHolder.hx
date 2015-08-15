package components;

import components.CrateFlying;
import components.Movement;
import components.PuffEmitter;
import enemies.Crate;
import luxe.Component;
import luxe.Entity;
import luxe.Vector;

class CrateHolder extends Component {


    public static inline var GRAB_RANGE:Float = 10;
    public static inline var THROW_SPEED:Float = 120;
    public static inline var POS_X:Float = 0;
    public static inline var POS_Y:Float = -3;

    @:isVar public var holding (default, null):Bool;
    @:isVar public var crate (default, null):Crate;

    var cd:Float = 0;
    var cd_max:Float = 0.2;

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
                // trace('throw_away(e.direction)');
                throw_away(e.direction);
            }
        });
        entity.events.listen('input.B', function(_)
        {
            // trace('holding = ${holding}');
            // Try grabbing those crates!
            if(!holding){
                try_grabbing();
            }
        });
    }

    override function update(dt:Float)
    {
        // Keep held crate over player's head

        if(holding)
        {
            // trace('update crate pos');
            crate.pos.x = entity.pos.x + POS_X;
            crate.pos.y = entity.pos.y + POS_Y;
        }

        if(cd > 0){
            cd -= dt;
        }
    }

    function try_grabbing()
    {
        // Can't grab when holding
        // and can't grab too fast
        if(holding || cd > 0) return;

        var crates = new Array<Entity>();
        // Get all, then closest, then check range
        Game.scene.get_named_like('crate', crates);

        if(crates.length > 0)
        {
            _player.copy_from( entity.pos );
            for(c in crates)
            {
                // Check distance
                _v = Vector.Subtract(_player, c.pos);

                if(_v.length <= GRAB_RANGE){

                    if(c.has('crate_flying')) continue;

                    grab(c);
                    break;
                }
            }
            
        }

    } 

    function grab(c:Entity)
    {
        if(holding) return;
        holding = true;

        cd = cd_max;

        crate = cast(c, Crate);

        entity.events.fire('crate.grab');
        Luxe.events.fire('player.grab.crate');
    }

    function throw_away(direction:Vector)
    {
        // trace('throw_away() dir: ${direction}');
        if(!holding) return;
        // trace('holding: ${holding}');

        if(direction.length == 0 && Game.speed == 0) direction.x = -1;

        direction = direction.normalize();
        direction.multiplyScalar(THROW_SPEED);

        if(direction.length < 1){
            direction = Game.directional_vector().normalize().multiplyScalar(THROW_SPEED);
        }

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
        crate.add( new CrateFlying({name:'crate_flying'}));
        crate.add( new Collider({
            testAgainst: ['cruncher', 'bomb'],
            size: new Vector(12,12),
        }) );
        

        // I should be just forgetting about this entity
        // and not removing it. Let it fly!!
        // crate = null;
        holding = false;


        entity.events.fire('crate.throw_away');
        Luxe.events.fire('player.throw.crate');

    } 

}

typedef CrateHolderEvents = {
    var direction:Vector;
}
