
import components.Movement;
import luxe.Color;
import luxe.Rectangle;
import luxe.Sprite;
import luxe.States;

import luxe.utils.Maths;
import luxe.utils.Random;
import luxe.Vector;
import phoenix.Texture;

class Game extends State {

    public static inline var width:Int = 160;
    public static inline var height:Int = 144;

    var player:Player;
    var lightmask:Sprite;
    var gal:Sprite;

    var spawner:Spawner;

    var hud:Hud;

    var _realCamPos:Vector;
    var _camTravelled:Float;

    public static var random:Random;

    // Gameplay time
    public static var level:Int;
    public static var gameType:GameType;

    // is game on? If not, then it's probably preparing (startup stuff)
    public static var playing:Bool = false;

    // quick delay during gameplay, like getting mushroom in Mario
    public static var delayed:Bool = false;

    public static var difficulty:Float = 0;
    public static var time:Float = 0;
    public static var hope:Float = 1;


        // Distance to Gal
    var gal_distance_start:Float = 0.8;
    public static var gal_distance:Float = 0.8;
        // How fast are we running to her normally?
    public static var GAL_MULT:Float = 0.015;

        // How much hope are we loosing each update?
    public static var HOPE_MULT:Float = 0.025;


    public static var speed:Float = 52;
        // Distance travelled
    public static var distance:Float = 0;
        // Distance to Gal
    public static var distance_gal:Float = 1;

    public static var direction:Direction = right;
    var prevent_quick_dir_change:Float = 0;
    var prevent_quick_dir_change_max:Float = 3;
    public static function directional_vector():Vector
    {
        var _vec:Vector = new Vector(speed,0);
        // trace('---------------before and after--------------');
        // trace(Game.direction.getName());
        // trace(_vec);
        switch(Game.direction){
            case Direction.right: _vec.angle2D = 0;
            case Direction.down:  _vec.angle2D = Math.PI/2;
            case Direction.left:  _vec.angle2D = Math.PI;
            case Direction.up:    _vec.angle2D = 3*Math.PI/2;
        }
        // trace(_vec);
        return _vec.clone();
    }

    public function new()
    {
        super({ name:'game' });


        Game.random = new Random(Math.random());

        Game.level = 1;
        Game.gameType = classic;

        _realCamPos = new Vector();
    }

    override function onenter<T>(_:T) 
    {

        // trace('bounds : ${bounds}');
        // trace('Luxe.camera.pos : ${Luxe.camera.pos}');

        reset();

        create_hud();
        create_player();
        create_lightmask();

        spawner = new Spawner({name: 'spawner'});
        _camTravelled = 0;

        spam_tiles();

        Luxe.timer.schedule(3, function(){
            playing = true;
            Luxe.events.fire('game.start');
        });


        Luxe.events.fire('game.init');

    }

    function reset()
    {
        Game.difficulty = 0;
        Game.time = 0;
        Game.hope = 1;
        Game.gal_distance = gal_distance_start;

        Game.direction = right;

        Game.distance = 0;

        Game.playing = false;
        Game.delayed = false;


        Luxe.camera.pos.set_xy( -Game.width*1.5, -Game.height*1.5 );
        _realCamPos.copy_from(Luxe.camera.pos);

        // random.seed = Math.random();

        Luxe.events.fire('game.reset');
    }

    function game_over()
    {
        Luxe.events.fire('game.over');
        playing = false;
    }

    function create_hud()
    {
        hud = new Hud({
            name: 'hud',
        });
    }


    function create_player()
    {
        trace('game create_player');

        player = new Player({
            name: 'player',
            texture: Luxe.resources.texture('assets/images/player.gif'),
            size: new Vector(16,16),
            pos: new Vector(160/2, 144/2),
            centered: true,
            depth: 10,
        });
        player.texture.filter_mag = nearest;
        player.texture.filter_min = nearest;

    }

    function create_lightmask()
    {
        lightmask = new Sprite({
            name: 'lightmask',
            texture: Luxe.resources.texture('assets/images/lightmask.png'),
            size: new Vector(512,512),
            pos: player.pos.clone(),
            centered: true,
            depth: 11
        });
        lightmask.add( new components.Follow({
            name: 'follow',
            target: player,
            follow_type: components.Follow.FollowType.instant,
        }));
        lightmask.add( new components.Light({
            name: 'light',
        }) );
    }

    function spam_tiles()
    {
        var _x:Float = 0;
        var _y:Float = 0;
        var _tile:Tile;

        var xm:Int = Math.floor( Game.width / Tile.TILE_SIZE ) + 1;
        var ym:Int = Math.floor( Game.height / Tile.TILE_SIZE ) + 1;

        for(x in 0...xm){
            for(y in 0...ym){
                _x = x * Tile.TILE_SIZE;
                _y = y * Tile.TILE_SIZE;
                
                _tile = new Tile({
                    pos: new Vector(_x, _y),
                });
            }
        }
    }


    override function update(dt:Float)
    {
        if(playing && !delayed)
        {
            Game.hope -= dt * Game.HOPE_MULT;
            Game.time += dt;
            Game.distance += Game.speed * dt;
            Game.gal_distance -= dt * Game.GAL_MULT;

            _realCamPos.x += Game.directional_vector().x * dt;
            _realCamPos.y += Game.directional_vector().y * dt;

            _camTravelled += Game.directional_vector().length * dt;
            if(_camTravelled > Tile.TILE_SIZE-1){
                _camTravelled -= Tile.TILE_SIZE-1;
                Luxe.events.fire('spawn.tilescolrow');
            }

            Luxe.camera.pos.copy_from(_realCamPos);
            Luxe.camera.pos.x = Math.round(Luxe.camera.pos.x);
            Luxe.camera.pos.y = Math.round(Luxe.camera.pos.y);

            direction_change(dt);

        }

        if(hope <= 0){
            game_over();
        }

        // Game.hope = Math.sin(Game.time/2)/2 + 0.5;
    }


    function direction_change(dt:Float)
    {
        prevent_quick_dir_change += dt;
        if(prevent_quick_dir_change >= prevent_quick_dir_change_max)
        {
            if(Math.random() > 0.8)
            {
                var _d = Math.round( Math.random() );
                switch(Game.direction)
                {
                    case right:
                        Game.direction = (_d==1) ? up : down;
                    case down:
                        Game.direction = (_d==1) ? left : right;
                    case left:
                        Game.direction = (_d==1) ? up : down;
                    case up:
                        Game.direction = (_d==1) ? left : right;
                }
                prevent_quick_dir_change = 0;

                Luxe.events.fire('game.directon.changed');
            }
        }
    }
}


enum GameType {
    endless;
    classic;
}

enum Direction {
    left;
    down;
    right;
    up;
}
