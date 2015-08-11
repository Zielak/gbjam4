
import components.Movement;
import luxe.Entity;
import luxe.Timer;
import luxe.Vector;

class Spawner extends Entity {
    
    var sequences:Array<Sequence>;
    var current_sequence:Int = 0;
    
        // holds temp time, of current sequence's duration
    var sequence_duration:Float = 0;

    var time:Float = 0;
    var crate_cd:Float = 0;
    var crate_max_cd:Float = 3;

    override function init()
    {
        time = 0;
        next_crate_cd();

        populate_sequences();

        Luxe.events.listen('spawn.tilescolrow', function(_){
            spawn_tiles();
        });

        Luxe.events.listen('spawn.puff', function(e:SpawnEvent){
            var p:Puff = new Puff({pos:e.pos});
            if(e.velocity != null){
                p.add(new Movement({velocity:e.velocity}));
            }
        });
        
        pick_sequence();
    }


    override function update(dt:Float)
    {
        if(Game.playing && !Game.delayed)
        {
            time += dt;
            crate_cd -= dt;
            
            if( sequences.length > 0 ){
                if( sequences[current_sequence].update(dt) ){
                    pick_sequence();
                }
            }
        }
    }

    function pick_sequence()
    {
        if(sequences.length > 0){
            current_sequence = Math.floor( Math.random()*(sequences.length) );
            sequence_duration = sequences[current_sequence].duration;
            sequences[current_sequence].reset();
        }
    }

    function spawn_tiles()
    {
        
        var col:Bool = false;
        var count:Int;

        var _w:Float;
        var _x:Float;
        var _y:Float;
        var _tile:Tile;

        switch(Game.direction)
        {
            case right: 
                col = true;
                count = Math.ceil(Game.height / Tile.TILE_SIZE);

            case down:  
                col = false;
                count = Math.ceil(Game.width / Tile.TILE_SIZE);

            case left:  
                col = true;
                count = Math.ceil(Game.height / Tile.TILE_SIZE);

            case up:    
                col = false;
                count = Math.ceil(Game.width / Tile.TILE_SIZE);
        }


        for(i in -2...count+2)
        {
            if(Math.random() > 0.6) continue;

            if(col)
            {
                if(Game.direction == left){
                    _x = Luxe.camera.center.x - Game.width/2 - Tile.TILE_SIZE*2;
                }else{
                    _x = Luxe.camera.center.x + Game.width/2 + Tile.TILE_SIZE*2;
                }
                _y = Luxe.camera.center.y - Game.height/2 + i*Tile.TILE_SIZE;
            }
            else
            {
                _x = Luxe.camera.center.x - Game.width/2 + i*Tile.TILE_SIZE;

                if(Game.direction == up){
                    _y = Luxe.camera.center.y - Game.height/2 - Tile.TILE_SIZE*2;
                }else{
                    _y = Luxe.camera.center.y + Game.height/2 + Tile.TILE_SIZE*2;
                } 
            }

            _x = Math.floor( _x/16 )*16;
            _y = Math.floor( _y/16 )*16;

            _tile = new Tile({
                pos: new Vector(_x, _y),
            });
            // trace('tile spawned');
        }
    }
    
    function next_crate_cd()
    {
        crate_cd = crate_max_cd + Math.random()*2;
    }
    
    function spawn_crate()
    {
        // Spawn crate here!
        
        next_crate_cd();
    }

    // SHAME SHAME SHAME
    // - ain't nobody got time to make JSON parser
    function populate_sequences()
    {
        sequences = new Array<Sequence>();

        var actions:Array<Action>;

        // Spawn stationary bombs
        actions = new Array<Action>();

        actions.push(new actions.SpawnBomb({delay: 1}));
        actions.push(new actions.SpawnBomb({delay: 1}));
        actions.push(new actions.SpawnBomb({delay: 1}));
        actions.push(new actions.SpawnBomb({delay: 1}));
        actions.push(new actions.SpawnBomb({delay: 1}));

        sequences.push(new Sequence({actions: actions, delay: 1}) );


        // Spawn FRONTAL Crunchers
        actions = new Array<Action>();
        for(i in 0...4){
            actions.push(new actions.SpawnCruncher({
                delay: 1, spawn_type:fromFront
            }));
        }
        sequences.push(new Sequence({actions: actions, delay: 2}) );



        // Spawn BACK Crunchers
        actions = new Array<Action>();
        for(i in 0...5){
            actions.push(new actions.SpawnCruncher({
                delay: 1.5, spawn_type:fromBack
            }));
        }
        sequences.push(new Sequence({actions: actions}) );



        // Spawn BACK & FRONT Crunchers
        actions = new Array<Action>();
        for(i in 0...5){
            actions.push(new actions.SpawnCruncher({
                delay: 3, spawn_type:fromBack
            }));
            actions.push(new actions.SpawnCruncher({
                delay: 0, spawn_type:fromFront
            }));
        }
        sequences.push(new Sequence({actions: actions, delay: 2}) );

    }

}

typedef SpawnEvent = {
    var pos:Vector;

    @:optional var velocity:Vector;
}
