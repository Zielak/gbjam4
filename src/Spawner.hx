
import components.Movement;
import enemies.Crate;
import luxe.Color;
import luxe.Entity;
import luxe.Rectangle;
import luxe.Timer;
import luxe.Vector;
import luxe.Visual;

class Spawner extends Entity {

    var tilespawn_density:Float;
    var tilespawn_density_max:Float = 0.8;
    
    var sequences:Array<Sequence>;
    var current_sequence:Int = 0;
    
        // holds temp time, of current sequence's duration
    var sequence_duration:Float = 0;

    var time:Float = 0;
    var crate_cd:Float = 0;
    var crate_max_cd:Float = 2;


    /**
     * Everyone can pick a place to spawn
     * @return Vector some point out of camera's sight
     */
    static public function pick_place(spawnPlace:SpawnPlace, random:Bool = true):Vector
    {
        var _x:Float = Luxe.camera.center.x;
        var _y:Float = Luxe.camera.center.y;

        // Pick random place in front of camera's center
        var s:Float = 0.5;

        if(random){
            if(spawnPlace == front
            || spawnPlace == back)
            {
                if(Game.direction == left || Game.direction == right){
                    _y += -Game.height*s/2 + Game.random.float(0, Game.height*s);
                }
                if(Game.direction == up || Game.direction == down){
                    _x += -Game.width*s/2 + Game.random.float(0, Game.width*s);
                }
            }
        }

        // if(Game.direction == left || Game.direction == right){
        //     _y += -Game.height*s/2 + Game.random.float(0, Game.height*s);
        // }
        // if(Game.direction == up || Game.direction == down){
        //     _x += -Game.width*s/2 + Game.random.float(0, Game.width*s);
        // }
        
        if(spawnPlace == front)
        {
            switch(Game.direction){
                case right : _x += Game.width/2 + Tile.TILE_SIZE;
                case down  : _y += Game.height/2 + Tile.TILE_SIZE;
                case left  : _x -= Game.width/2 + Tile.TILE_SIZE;
                case up    : _y -= Game.height/2 + Tile.TILE_SIZE;
            }
        }
        else if (spawnPlace == back)
        {
            switch(Game.direction){
                case right : _x -= Game.width/2 + Tile.TILE_SIZE*2;
                case down  : _y -= Game.height/2 + Tile.TILE_SIZE*2;
                case left  : _x += Game.width/2 + Tile.TILE_SIZE*2;
                case up    : _y += Game.height/2 + Tile.TILE_SIZE*2;
            }
        }
        else if (spawnPlace == sides)
        {
            // switch(Game.direction){
            //     case left  : _x += Game.width/2 + Tile.TILE_SIZE;
            //     case up    : _y += Game.height/2 + Tile.TILE_SIZE;
            //     case right : _x -= Game.width/2 - Tile.TILE_SIZE;
            //     case down  : _y -= Game.height/2 - Tile.TILE_SIZE;
            // }
        }

        // Round up the position
        _x = Math.round( _x/16 )*16;
        _y = Math.round( _y/16 )*16;

        return new Vector(_x , _y);
    }

    override function init()
    {
        time = 0;
        next_crate_cd();
        tilespawn_density = 0.3;

        init_events();
        init_sequences();

        spam_tiles();
    }

    function init_events()
    {
        Luxe.events.listen('spawn.tilescolrow', function(_)
        {
            spawn_tiles();
        });

        Luxe.events.listen('spawn.puff', function(e:SpawnEvent)
        {
            var p:Puff = new Puff({pos:e.pos.clone()});

            if(e.depth != null){
                p.depth = e.depth;
            }

            var _v:Vector = null;
            if(e.velocity != null)
            {
                _v = e.velocity;
            }
            else if(e.velocity == null && e.speed != null)
            {
                _v = new Vector(e.speed, 0);
                _v.angle2D = e.angle;
            }

            if(_v != null){
                p.add(new Movement({velocity:_v}));
            }

        });

        Luxe.events.listen('spawn.flash', function(e:SpawnEvent)
        {
            var flash:Visual = new Visual({
                pos: e.pos.clone(),
                geometry: Luxe.draw.circle({
                    x:0, y:0,
                    r: 20,
                    color: new Color(1,1,1,1),
                }),
                depth: 12
            });

            flash.add( new components.DestroyByTime({time:0.1}));

        });

        Luxe.events.listen('player.hit.enemy', function(_)
        {
            var _arr:Array<Entity> = new Array<Entity>();
            Luxe.scene.get_named_like('tile', _arr);
            var _v:Vector = Game.directional_vector();
            
            // _v.angle2D += Math.PI;
            _v.length = 900;

            for(t in _arr){
                t.add(new components.Movement({velocity: _v}) );
            }
            tilespawn_density = 0.25;
            spam_tiles();
        });
    }

    function init_sequences()
    {
        if(!Game.tutorial){
            populate_sequences();
            pick_sequence();
        }else{
            init_tutorial();
        }
    }

    function init_tutorial()
    {

        sequences = new Array<Sequence>();
        
        var actions:Array<Action> = new Array<Action>();

        actions.push(new actions.SpawnCrate({
            pos: new Vector( Math.floor(Game.width*8), Math.floor(Game.height*5) ),
            delay: 1
        }));

        // Grab it, B
        actions.push(new actions.ShowTutorialScreen({
            delay: 1,
            screen: 'assets/images/text.gif',
            uv: new Rectangle(0, 48, 64, 12),
            pos: new Vector(Game.width/2, 48),
        }));
        
        // Throw it, -> + B
        actions.push(new actions.ShowTutorialScreen({
            delay: 3,
            screen: 'assets/images/text.gif',
            uv: new Rectangle(0, 64, 70, 12),
            pos: new Vector(Game.width/2, 48),
        }));
        
        // JUMP OVER IT, -> + A
        actions.push(new actions.ShowTutorialScreen({
            delay: 3,
            screen: 'assets/images/text.gif',
            uv: new Rectangle(0, 80, 86, 24),
            pos: new Vector(Game.width/2, 48),
        }));

        // GO GET HER
        actions.push(new actions.ShowTutorialScreen({
            delay: 3,
            screen: 'assets/images/text.gif',
            uv: new Rectangle(0, 104, 72, 12),
            pos: new Vector(Game.width/2, 48),
        }));

        // Don't loose hope
        actions.push(new actions.ShowTutorialScreen({
            delay: 3,
            screen: 'assets/images/text.gif',
            uv: new Rectangle(0, 120, 112, 12),
            pos: new Vector(Game.width/2, 48),
        }));


        sequences.push(new Sequence({actions: actions, difficulty: 0}) );

    }

    function finish_tutorial()
    {
        Game.tutorial = false;

        Luxe.events.fire('tutorial.finished');

        init_sequences();
    }


    override function update(dt:Float)
    {
        if(Game.playing && !Game.delayed && !Game.tutorial)
        {
            time += dt;
            crate_cd -= dt;

            if(tilespawn_density < tilespawn_density_max){
                tilespawn_density += dt/15;
            }

            if(crate_cd <= 0){
                spawn_crate();
            }
            
            if( sequences.length > 0 ){
                if( sequences[current_sequence].update(dt) ){
                    pick_sequence();
                }
            }
        }
        if(Game.tutorial)
        {
            if(tilespawn_density < tilespawn_density_max){
                tilespawn_density += dt/20;
            }
            sequences[0].update(dt);
        }
    }

    function pick_sequence()
    {
        var _seq:Int;

        if(sequences.length > 0)
        {
            _seq = current_sequence;

            // can't be the same as last one
            while(_seq == current_sequence)
            {
                _seq = Math.floor( Math.random()*(sequences.length) );
            }

            current_sequence = _seq;

            sequence_duration = sequences[current_sequence].duration;
            sequences[current_sequence].reset();
        }
    }


    /**
     * Populates the screen with new tiles. Probably one time use
     */
    function spam_tiles()
    {
        var _x:Float = 0;
        var _y:Float = 0;
        var _tile:Tile;

        var xm:Int = Math.floor( Game.width / Tile.TILE_SIZE ) + 2;
        var ym:Int = Math.floor( Game.height / Tile.TILE_SIZE ) + 2;

        for(x in -1...xm){
            for(y in -1...ym){
                if(Math.random() > tilespawn_density) continue;
                _x = x * Tile.TILE_SIZE;
                _y = y * Tile.TILE_SIZE;
                
                _tile = new Tile({
                    pos: new Vector(_x, _y),
                });
            }
        }
    }


    /**
     * Spawns row or column of tile after camera has moved TILE_SIZE px.
     */
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
            if(Math.random() > tilespawn_density) continue;

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

        var crate:Crate = new Crate({
            pos: Spawner.pick_place(front),
            scene: Game.scene,
        });

        next_crate_cd();
    }

    // SHAME SHAME SHAME
    // - ain't nobody got time to make JSON parser
    function populate_sequences()
    {
        sequences = new Array<Sequence>();

        var actions:Array<Action>;

        // | line of Bombs
        actions = new Array<Action>();
        actions.push(new actions.SpawnLineOfBomb({delay: 3.5}));
        actions.push(new actions.SpawnLineOfBomb({delay: 3}));
        actions.push(new actions.SpawnLineOfBomb({delay: 2.5}));
        actions.push(new actions.SpawnLineOfBomb({delay: 2}));
        sequences.push(new Sequence({actions: actions, ending: 2, difficulty: 0.6}) );


        // Spawn stationary bombs
        actions = new Array<Action>();
        for(i in 0...5){
            actions.push(new actions.SpawnBomb({delay: 0.7}));
        }
        sequences.push(new Sequence({actions: actions, difficulty: 0}) );



        // Spawn FRONTAL Crunchers
        actions = new Array<Action>();
        for(i in 0...4){
            actions.push(new actions.SpawnCruncher({
                delay: 1, spawn_type: front
            }));
        }
        sequences.push(new Sequence({actions: actions, delay: 0.5, difficulty: 0.1}) );



        // Spawn BACK Crunchers
        actions = new Array<Action>();
        for(i in 0...4){
            actions.push(new actions.SpawnCruncher({
                delay: 1.5, spawn_type: back
            }));
        }
        sequences.push(new Sequence({actions: actions, difficulty: 0}) );



        // Spawn BACK & FRONT Crunchers
        actions = new Array<Action>();
        for(i in 0...5){
            actions.push(new actions.SpawnCruncher({
                delay: 3, spawn_type: back
            }));
            actions.push(new actions.SpawnCruncher({
                delay: 0, spawn_type: front
            }));
        }
        sequences.push(new Sequence({actions: actions, delay: 2, difficulty: 0.2}) );




        // Change direction
        actions = new Array<Action>();
        actions.push(new actions.ChangeDirection({delay: 1.5}));
        actions.push(new actions.Wait({delay: 2}));
        sequences.push(new Sequence({actions: actions, difficulty: 0.4}) );

    }

}

typedef SpawnEvent = {
    var pos:Vector;

    @:optional var velocity:Vector;
    @:optional var speed:Float;
    @:optional var angle:Float;
    @:optional var depth:Float;
}

enum SpawnPlace {
    still;
    front;
    back;
    sides;
}
