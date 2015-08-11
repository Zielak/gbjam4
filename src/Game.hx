
import components.Movement;
import luxe.Input;
import luxe.Color;
import luxe.Rectangle;
import luxe.Scene;
import luxe.Sprite;
import luxe.States;

import luxe.utils.Maths;
import luxe.utils.Random;
import luxe.Vector;
import phoenix.Texture;
import snow.api.Timer;

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
    var camTimer:Timer;

    public static var random:Random;

    public static var scene:Scene;

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


    public static var speed:Float = 60;
        // Distance travelled (what)
    public static var distance:Float = 0;
        // Distance to Gal
    public static var distance_gal:Float = 1;

    public static var direction:Direction = right;
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

        Game.scene = new Scene('gamescene');

        Game.level = 1;
        Game.gameType = classic;

        _realCamPos = new Vector();
        camTimer = Luxe.timer.schedule(1/60, update_camera, true);
    }

    override function onenter<T>(_:T) 
    {

        // trace('bounds : ${bounds}');
        // trace('Luxe.camera.pos : ${Luxe.camera.pos}');

        reset();

        create_hud();
        create_player();
        create_lightmask();

        init_events();

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
            depth: 100
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

    function init_events()
    {
        Luxe.events.listen('game.gal_distance.*', function(e:GameEvent){
            if(e.gal_distance != null) Game.gal_distance += e.gal_distance;
        });
        Luxe.events.listen('game.hope.*', function(e:GameEvent){
            if(e.hope != null) Game.hope += e.hope;
        });
    }



    function spam_tiles()
    {
        var _x:Float = 0;
        var _y:Float = 0;
        var _tile:Tile;

        var xm:Int = Math.floor( Game.width / Tile.TILE_SIZE ) + 2;
        var ym:Int = Math.floor( Game.height / Tile.TILE_SIZE ) + 2;

        for(x in -1...xm){
            for(y in -1...ym){
                if(Math.random() > 0.7) continue;
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
            // Game.hope -= dt * Game.HOPE_MULT;
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

        }

        if(hope <= 0){
            game_over();
        }

        // Game.hope = Math.sin(Game.time/2)/2 + 0.5;
    }

    function update_camera()
    {
        Luxe.camera.pos.copy_from(_realCamPos);
        Luxe.camera.pos.x = Math.round(Luxe.camera.pos.x);
        Luxe.camera.pos.y = Math.round(Luxe.camera.pos.y);
    }



    // HAXXX
    override public function onkeydown( event:KeyEvent )
    {
        if(event.keycode == Key.key_h){
            Game.hope = 1;
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

typedef GameEvent = {
    @:optional var gal_distance:Float;
    @:optional var hope:Float;
    @:optional var difficulty:Float;

}
