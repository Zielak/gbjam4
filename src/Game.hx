
import components.Movement;
import luxe.Entity;
import luxe.Input;
import luxe.Color;
import luxe.Rectangle;
import luxe.Scene;
import luxe.Sprite;
import luxe.States;

import luxe.collision.ShapeDrawerLuxe;
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




    // Just an array to hold all game's events, to remove
    var game_events:Array<String>;

    public static var random:Random;

    public static var scene:Scene;

    public static var level:Int;
    public static var gameType:GameType;

    // is game on? If not, then it's probably preparing (startup stuff)
    public static var playing:Bool = false;

    // Did we just loose?
    public static var gameover:Bool = false;
    
    // quick delay during gameplay, like getting mushroom in Mario
    public static var delayed:Bool = false;

    // Is tutorial sequence should be playing?
    public static var tutorial:Bool = false;

    public static var difficulty:Float = 0;
    public static var time:Float = 0;
    public static var hope:Float = 1;
    public static var love:Int = 0;


        // Distance to Gal
    var gal_distance_start:Float;
    public static var gal_distance:Float;

        // How fast are we running to her normally?
    public static var gal_mult:Float;

        // How much hope are we loosing each update?
    public static var hope_mult:Float;


    public static inline var SPEED_INIT:Float = 60;
    public static var speed:Float = 60;
        // Distance travelled (what)
    public static var distance:Float = 0;

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

    public function new(options:GameOptions)
    {
        super({ name:'game' });

        Game.gal_mult = options.gal_mult;
        Game.hope_mult = options.hope_mult;
        gal_distance_start = options.gal_distance_start;

        Game.tutorial = options.tutorial;


        Game.random = new Random(Math.random());

        Game.scene = new Scene('gamescene');

        Game.level = 1;
        Game.gameType = classic;

        Game.drawer = new ShapeDrawerLuxe();

        _realCamPos = new Vector();
        camTimer = Luxe.timer.schedule(1/60, update_camera, true);
    }

    override function onleave<T>(_:T)
    {
        hud.destroy();
        player.destroy();
        lightmask.destroy();
        kill_events();
        spawner.destroy();
        Game.scene.empty();
        Luxe.scene.empty();

        Luxe.camera.pos.set_xy( -Game.width*1.5, -Game.height*1.5 );
    }

    override function onenter<T>(_:T) 
    {


        reset();

        create_hud();
        create_player();
        create_lightmask();

        init_events();

        spawner = new Spawner({name: 'spawner'});
        _camTravelled = 0;


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
        Game.love = 0;
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

    function game_over(reason:String)
    {
        Game.playing = false;
        Game.gameover = true;
        Luxe.events.fire('game.over.${reason}');
    }

    function create_hud()
    {
        hud = new Hud({
            name: 'hud',
        });
    }


    function create_player()
    {

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
            depth: 50
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
        game_events = new Array<String>();

        game_events.push( Luxe.events.listen('game.gal_distance.*', function(e:GameEvent){
            if(e.gal_distance != null) Game.gal_distance += e.gal_distance;
        }) );
        game_events.push( Luxe.events.listen('game.hope.*', function(e:GameEvent){
            if(e.hope != null) Game.hope += e.hope;
        }) );

        game_events.push( Luxe.events.listen('player.hit.enemy', function(_){
            Game.gal_distance += 0.06;
            Game.hope -= 0.05;
            Luxe.camera.shake(10);
        }) );

        game_events.push( Luxe.events.listen('crate.hit.enemy', function(_){
            Game.gal_distance -= 0.02;
            Game.hope += 0.25;
            Luxe.camera.shake(4);
        }) );
    }

    function kill_events()
    {
        for(s in game_events)
        {
            Luxe.events.unlisten(s);
        }
    }



    override function update(dt:Float)
    {
        if(Game.playing && !Game.delayed)
        {
            if(!Game.tutorial){
                Game.hope -= dt * ( Game.hope_mult * ( Game.difficulty*0.5 ) );
                Game.distance += Game.speed * dt;
                Game.gal_distance -= dt * Game.gal_mult;
            }else{
                Game.gal_distance = gal_distance_start;
                Game.hope += dt;
            }

            Game.time += dt;

            _realCamPos.x += Game.directional_vector().x * dt;
            _realCamPos.y += Game.directional_vector().y * dt;

            _camTravelled += Game.directional_vector().length * dt;
            
            if(_camTravelled > Tile.TILE_SIZE-1){
                _camTravelled -= Tile.TILE_SIZE-1;
                Luxe.events.fire('spawn.tilescolrow');
            }

        }

        if(Game.hope > 1){
            Game.hope = 1;
        }

        if(!Game.tutorial){
            if(Game.hope <= 0){
                game_over('hope');
            }
            if(Game.gal_distance > 1.1){
                game_over('distance');
            }

            Game.difficulty = 1 - Game.gal_distance;
            if(Game.difficulty > 1){
                difficulty = 1;
            }
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
            // Game.hope = 1;
        }

        if(event.keycode == Key.key_p){
            // Game.delayed = !Game.delayed;
        }
    }





    public static var drawer:ShapeDrawerLuxe;

    override function onrender()
    {

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

typedef GameOptions = {
    var hope_mult:Float;
    var gal_mult:Float;
    var gal_distance_start:Float;
    var tutorial:Bool;
}
