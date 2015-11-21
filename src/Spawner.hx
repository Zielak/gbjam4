
import components.Blinking;
import components.Movement;
import enemies.Crate;
import luxe.Color;
import luxe.Entity;
import luxe.Rectangle;
import luxe.Timer;
import luxe.tween.Actuate;
import luxe.Vector;
import luxe.Visual;

class Spawner extends Entity {

    var tilespawn_density:Float;
    var tilespawn_density_max:Float = 0.65;
    
    var sequences:Array<Sequence>;
    var current_sequence:Sequence;

    var gameover_seq:Sequence;
    
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
        var s:Float = 0.9;

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
        else if (spawnPlace == left)
        {
            switch(Game.direction){
                case left  : _x += Game.width/2 + Tile.TILE_SIZE;
                case up    : _y += Game.height/2 + Tile.TILE_SIZE;
                case right : _x -= Game.width/2 - Tile.TILE_SIZE;
                case down  : _y -= Game.height/2 - Tile.TILE_SIZE;
            }
        }

        // Round up the position
        _x = Math.round( _x/16 )*16;
        _y = Math.round( _y/16 )*16;

        return new Vector(_x , _y);
    }

    override function init()
    {
        trace('SPAWNER: init');
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

            p.add(new Blinking({
                time_on: Math.random()*0.5 + 0.2,
                time_off: Math.random()*0.3 + 0.1,
            }));

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
            _v.length = 750;

            for(t in _arr){
                if(Math.random() > 0.5){
                    t.add(new components.Movement({velocity: _v}) );
                }
            }
            tilespawn_density = 0.25;
            spam_tiles();
        });

        Luxe.events.listen('game.over.hope', function(_){
            init_game_over_sequences('hope');
        });
        Luxe.events.listen('game.over.distance', function(_){
            init_game_over_sequences('distance');
        });

        this.events.listen('sequence.gal', function(_){
            init_gal_sequences();
        });
    }

    function init_sequences()
    {
        if(!Game.tutorial){
            Actuate.tween( Game, 2, {speed:Game.SPEED_INIT});
            populate_sequences();
            pick_sequence();
        }else{
            init_tutorial();
        }
    }

    function init_tutorial()
    {

        inline function nice_vector(_x:Float, _y:Float):Vector
        {
            var v = new Vector( Math.floor(_x), Math.floor(_y) );
            v.x = Math.floor( v.x/Tile.TILE_SIZE )*Tile.TILE_SIZE;
            v.y = Math.floor( v.y/Tile.TILE_SIZE )*Tile.TILE_SIZE;

            return v;
        }

        sequences = new Array<Sequence>();
        
        var actions:Array<Action> = new Array<Action>();

        // Speed
        actions.push(new actions.ChangeSpeed({
            target_speed: 0,
            delay: 0,
        }));

        /**
         * WALK OVER CRATE TO GRAB IT
         */
        actions.push(new actions.SpawnCrate({
            pos: nice_vector(Game.width*0.75, Game.height*0.6),
            delay: 2,
        }));
            // Spawn more crates for the hasty people
        for(i in 0...10){
            actions.push(new actions.SpawnCrate({
                pos: nice_vector(Game.width*0.75, Game.height*0.6),
                delay: 0,
            }));
        }
        actions.push(new actions.ShowTutorialScreen({
            delay: 0.5,
            screen: 'assets/images/text.gif',
            uv: new Rectangle(0, 176, 134, 24),
            pos: new Vector(Game.width/2, 48),
            wait: true,
            wait_event: 'player.grab.crate',
            circle_pos: nice_vector(Game.width*0.75, Game.height*0.5),
            circle_size: 20
        }));
        
        /**
         * POINT AND CLICK TO THROW IT
         */
        // Spawn bomb first
        actions.push(new actions.SpawnBomb({delay: 1.2,
            pos: nice_vector(Game.width*0.25, Game.height*0.3)
        }));
        actions.push(new actions.SpawnBomb({delay: 0.2,
            pos: nice_vector(Game.width*0.15, Game.height*0.5)
        }));
        actions.push(new actions.SpawnBomb({delay: 0.2,
            pos: nice_vector(Game.width*0.25, Game.height*0.7)
        }));
        actions.push(new actions.ShowTutorialScreen({
            delay: 0,
            screen: 'assets/images/text.gif',
            uv: new Rectangle(0, 200, 106, 24),
            pos: new Vector(Game.width/2, 48),
            wait: true,
            wait_event: 'player.throw.crate',
        }));
        
        /**
         * JUMP OVER IT, [SPACE]
         */
        actions.push(new actions.SpawnBomb({delay: 2,
            pos: nice_vector(Game.width*0.6, Game.height*0.65)
        }));
        actions.push(new actions.ShowTutorialScreen({
            delay: 0.5,
            screen: 'assets/images/text.gif',
            uv: new Rectangle(0, 80, 86, 24),
            pos: new Vector(Game.width/2, 48),
            wait: true,
            wait_event: 'player.dash',
        }));

        // GO GET HER
        actions.push(new actions.CustomAction({
            delay: 3,
            action: function(){
                Luxe.events.fire('hud.show.distance_bar');
            },
        }));
        actions.push(new actions.ShowTutorialScreen({
            delay: 0,
            screen: 'assets/images/text.gif',
            uv: new Rectangle(0, 104, 72, 12),
            pos: new Vector(Game.width/2, 64),
            wait: true,
            wait_input: true,
        }));

        // Speed
        actions.push(new actions.ChangeSpeed({
            target_speed: Game.SPEED_INIT,
            delay: 1.5,
            smooth_time: 2,
        }));


        // Don't loose hope
        actions.push(new actions.CustomAction({
            delay: 3,
            action: function(){
                Luxe.events.fire('hud.show.hope_bar');
            },
        }));
        actions.push(new actions.ShowTutorialScreen({
            delay: 0,
            screen: 'assets/images/text.gif',
            uv: new Rectangle(0, 120, 114, 12),
            pos: new Vector(Game.width/2, 28),
            wait: true,
            wait_input: true,
        }));

        actions.push(new actions.Wait({
            delay: 3,
        }));


        sequences.push(new Sequence({name: 'tutorial', actions: actions, difficulty: 0}) );

    }

    function finish_tutorial()
    {
        Game.tutorial = false;

        Luxe.events.fire('tutorial.finished');

        init_sequences();
    }


    function init_game_over_sequences(reason:String)
    {
        trace('init_game_over_sequences');
        var arr:Array<Entity> = new Array<Entity>();
        arr = Game.scene.get_named_like('cruncher', arr);
        for(e in arr){
            e.destroy();
        }
        arr = Game.scene.get_named_like('bomb', arr);
        for(e in arr){
            e.destroy();
        }
        arr = null;

        var actions:Array<Action> = new Array<Action>();

        // Speed
        actions.push(new actions.ChangeSpeed({
            target_speed: 0,
            delay: 0,
        }));

        if(reason == 'hope')
        {
            actions.push(new actions.ShowTutorialScreen({
                delay: 0.5,
                screen: 'assets/images/text.gif',
                uv: new Rectangle(0, 24, 108, 24),
                pos: new Vector(Game.width/2, 40),
                wait: true,
                wait_input: true,
            }));
        }
        else if(reason == 'distance')
        {
            actions.push(new actions.ShowTutorialScreen({
                delay: 0.5,
                screen: 'assets/images/text.gif',
                uv: new Rectangle(0, 0, 86, 24),
                pos: new Vector(Game.width/2, 40),
                wait: true,
                wait_input: true,
            }));

        }

        actions.push(new actions.CustomAction({
            delay: 1,
            action: function(){
                Luxe.events.fire('game.over.quit');
            }
        }));

        gameover_seq = new Sequence({name:'game over', actions: actions, difficulty: -1});

    }



    function init_gal_sequences()
    {
        trace('init_gal_sequences');

        var actions:Array<Action> = new Array<Action>();

        // It's nice to see you
        actions.push(new actions.ShowTutorialScreen({
            delay: 4,
            screen: 'assets/images/text.gif',
            uv: new Rectangle(0, 144, 72, 24),
            pos: new Vector(Game.width/2, 40),
            wait: true,
            wait_input: true,
        }));
        

        actions.push(new actions.CustomAction({
            delay: 1,
            action: function(){
                Luxe.events.fire('game.over.quit');
            }
        }));

        gameover_seq = new Sequence({name:'game over gal', actions: actions, difficulty: -1});

    }


    override function update(dt:Float)
    {
        if(Game.playing && !Game.delayed && !Game.tutorial)
        {
            time += dt;
            crate_cd -= dt;

            if(tilespawn_density < tilespawn_density_max){
                tilespawn_density += dt/18;
            }

            if(crate_cd <= 0){
                spawn_crate();
            }
            
            if( sequences.length > 0 ){
                if( current_sequence.update(dt) ){
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

            if(sequences[0].finished)
            {
                finish_tutorial();
            }
        }
        if(!Game.playing && Game.gameover)
        {
            if(gameover_seq==null){

            }
            else if( gameover_seq.update(dt) )
            {
                trace('gonna fire event');
                Luxe.events.fire('game.over.quit');
                gameover_seq==null;
            }
        }
    }

    function pick_sequence()
    {
        var _seq:Sequence;

        if(sequences.length > 0)
        {
            _seq = current_sequence;

            // Make array aligned to difficulty
            var _ts:Array<Sequence> = new Array<Sequence>();

            for(s in sequences){
                if( s.difficulty < 0 ||
                    ( s.difficulty > Game.difficulty - 0.15 && s.difficulty < Game.difficulty + 0.15 )
                ){
                    _ts.push(s);
                }
            }
            // trace('SEQUENCE: picked ${_ts.length} sequences by difficulty: ${Game.difficulty}');

            // can't be the same as last one
            while(_seq == current_sequence)
            {
                _seq = _ts[ Math.floor( Math.random()*(_ts.length) )] ;
            }
            // trace('SEQUENCE: chosen seq: "${_seq.name}" diff:${_seq.difficulty} ');


            current_sequence = _seq;

            sequence_duration = current_sequence.duration;
            // trace('SEQUENCE: sequence_duration = ${sequence_duration}');
            current_sequence.reset();
        }
    }


    /**
     * Populates the screen with new tiles. Probably one time use
     */
    function spam_tiles()
    {
        // trace('spam tiles');
        var _x:Float = 0;
        var _y:Float = 0;

        var xm:Int = Math.floor( Game.width / Tile.TILE_SIZE ) + 2;
        var ym:Int = Math.floor( Game.height / Tile.TILE_SIZE ) + 2;

        for(x in -1...xm){
            for(y in -1...ym){
                if(Math.random() > tilespawn_density) continue;
                _x = x * Tile.TILE_SIZE;
                _y = y * Tile.TILE_SIZE;
                
                new Tile({
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
        // trace('spawn tiles');
        
        var col:Bool = false;
        var count:Int;

        var _w:Float;
        var _x:Float;
        var _y:Float;
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

            new Tile({
                pos: new Vector(_x, _y),
            });
        }
    }

    
    
    function next_crate_cd()
    {
        crate_cd = crate_max_cd + Math.random()*2 - Game.difficulty*1.3;
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
        actions.push(new actions.SpawnLineOfBomb({delay: 0.5}));
        sequences.push(new Sequence({name:'line of bombs', actions: actions,difficulty: 0.03}) );
        sequences.push(new Sequence({name:'line of bombs', actions: actions,difficulty: 0.3}) );
        sequences.push(new Sequence({name:'line of bombs', actions: actions,difficulty: 0.68}) );
        sequences.push(new Sequence({name:'line of bombs', actions: actions,difficulty: 0.84}) );

        // | MORE lines of bombs
        actions = new Array<Action>();
        actions.push(new actions.SpawnLineOfBomb({delay: 1}));
        actions.push(new actions.SpawnLineOfBomb({delay: 2}));
        actions.push(new actions.SpawnLineOfBomb({delay: 1.5}));
        actions.push(new actions.SpawnLineOfBomb({delay: 1}));
        sequences.push(new Sequence({name:'MORE line of bombs', actions: actions, ending: 1.5, difficulty: 0.33}) );


        // HELL OF line bombs
        actions = new Array<Action>();
        actions.push(new actions.SpawnCruncher({delay: 0.1, spawn_type: front}));
        actions.push(new actions.SpawnCruncher({delay: 0.1, spawn_type: front}));
        actions.push(new actions.SpawnLineOfBomb({delay: 1}));
        actions.push(new actions.SpawnLineOfBomb({delay: 1.5}));
        actions.push(new actions.SpawnCruncher({delay: 0.1, spawn_type: front}));
        actions.push(new actions.SpawnCruncher({delay: 0.1, spawn_type: front}));
        actions.push(new actions.SpawnLineOfBomb({delay: 1.5}));
        actions.push(new actions.SpawnLineOfBomb({delay: 1.5}));
        actions.push(new actions.SpawnCruncher({delay: 0.2, spawn_type: front}));
        actions.push(new actions.SpawnCruncher({delay: 0.2, spawn_type: front}));
        actions.push(new actions.SpawnCruncher({delay: 0.2, spawn_type: front}));
        actions.push(new actions.SpawnLineOfBomb({delay: 1.5}));
        sequences.push(new Sequence({name:'HELL line of bombs', actions: actions, ending: 1.5, difficulty: 0.7}) );


        // Spawn stationary bombs
        actions = new Array<Action>();
        for(i in 0...13){
            actions.push(new actions.SpawnBomb({delay: 0.6}));
        }
        sequences.push(new Sequence({name:'bombs', actions: actions, difficulty: 0.05}) );

        // Spawn MORE BOMBS
        actions = new Array<Action>();
        for(i in 0...18){
            actions.push(new actions.SpawnBomb({delay: 0.45}));
        }
        sequences.push(new Sequence({name:'MORE bombs',actions: actions, difficulty: 0.17}) );

        // BOMB HELL
        actions = new Array<Action>();
        for(i in 0...16){
            actions.push(new actions.SpawnBomb({delay: 0.5}));
            actions.push(new actions.SpawnBomb({delay: 0}));
        }
        sequences.push(new Sequence({name:'HELL bombs',actions: actions, difficulty: 0.55}) );


        // UBER MENSH BOMBORDIER
        actions = new Array<Action>();
        for(i in 0...13){
            actions.push(new actions.SpawnBomb({delay: 0.3}));
            actions.push(new actions.SpawnBomb({delay: 0.1}));
            actions.push(new actions.SpawnCruncher({delay: 0.2, spawn_type: front}));
        }
        sequences.push(new Sequence({name:'UBER bombs',actions: actions, difficulty: 0.69}) );







        // HARDCORE MIX of Bombs and Crunchers!
        actions = new Array<Action>();
        for(i in 0...13){
            actions.push(new actions.SpawnBomb({delay: 0.5}));
            actions.push(new actions.SpawnBomb({delay: 0.3}));
        }
        actions.push(new actions.SpawnCruncher({delay: 0.3, spawn_type: back}));
        actions.push(new actions.SpawnCruncher({delay: 0.1, spawn_type: front}));
        actions.push(new actions.SpawnCruncher({delay: 0.1, spawn_type: back}));
        for(i in 0...15){
            actions.push(new actions.SpawnBomb({delay: 0.25}));
            actions.push(new actions.SpawnBomb({delay: 0.2}));
        }
        actions.push(new actions.SpawnCruncher({delay: 0.3, spawn_type: front}));
        actions.push(new actions.SpawnCruncher({delay: 0.1, spawn_type: back}));
        actions.push(new actions.SpawnCruncher({delay: 0.1, spawn_type: front}));
        for(i in 0...15){
            actions.push(new actions.SpawnBomb({delay: 0.2}));
            actions.push(new actions.SpawnBomb({delay: 0.2}));
        }
        sequences.push(new Sequence({name:'HARDCORE MIX',actions: actions, difficulty: 0.6}) );
        sequences.push(new Sequence({name:'HARDCORE MIX',actions: actions, difficulty: 0.89}) );






        // Spawn FRONTAL Crunchers
        actions = new Array<Action>();
        for(i in 0...4){
            actions.push(new actions.SpawnCruncher({
                delay: 1, spawn_type: front
            }));
        }
        sequences.push(new Sequence({name:'frontal crunchers',actions: actions, delay: 0.5, difficulty: 0.1}) );

        // Spawn more frontal Crunchers
        actions = new Array<Action>();
        for(i in 0...6){
            actions.push(new actions.SpawnCruncher({
                delay: 0.7, spawn_type: front
            }));
        }
        sequences.push(new Sequence({name:'MORE frontal crunchers',actions: actions, delay: 0.25, difficulty: 0.35}) );






        // Spawn BACK Crunchers
        actions = new Array<Action>();
        for(i in 0...4){
            actions.push(new actions.SpawnCruncher({
                delay: 1.5, spawn_type: back
            }));
        }
        sequences.push(new Sequence({name:'back crunchers', actions: actions, difficulty: 0}) );

        // Spawn HELL of BACK Crunchers
        actions = new Array<Action>();
        for(i in 0...10){
            actions.push(new actions.SpawnCruncher({
                delay: 0.7, spawn_type: back
            }));
        }
        sequences.push(new Sequence({name:'HELL back crunchers', actions: actions, difficulty: 0.7}) );







        // Spawn BACK & FRONT Crunchers
        actions = new Array<Action>();
        for(i in 0...10){
            actions.push(new actions.SpawnCruncher({
                delay: 1, spawn_type: back
            }));
            actions.push(new actions.SpawnCruncher({
                delay: 0, spawn_type: front
            }));
        }
        sequences.push(new Sequence({name:'front&back crunchers',actions: actions, delay: 0, difficulty: 0.2}) );



        // Spawn MORE BACK & FRONT Crunchers
        actions = new Array<Action>();
        for(i in 0...12){
            actions.push(new actions.SpawnCruncher({
                delay: 0.65, spawn_type: back
            }));
            actions.push(new actions.SpawnCruncher({
                delay: 0.1, spawn_type: front
            }));
        }
        sequences.push(new Sequence({name:'MORE front&back crunchers',actions: actions, delay: 0, difficulty: 0.4}) );




        // Spawn UBER SPIEL BACK & FRONT Crunchers
        actions = new Array<Action>();
        for(i in 0...30){
            actions.push(new actions.SpawnCruncher({
                delay: 0.5, spawn_type: back
            }));
            actions.push(new actions.SpawnCruncher({
                delay: 0.2, spawn_type: front
            }));
        }
        sequences.push(new Sequence({name:'UBER SPIEL',actions: actions, delay: 0.3, difficulty: 0.9}) );




        // Change direction
        actions = new Array<Action>();
        actions.push(new actions.ChangeDirection({delay: 1.5}));
        actions.push(new actions.Wait({delay: 1.5}));
        sequences.push(new Sequence({name:'change direction',actions: actions, difficulty: -1}) );

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
    left;
    right;
}
