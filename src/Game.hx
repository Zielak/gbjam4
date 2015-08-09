
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

    var spawner:Spawner;

    var hud:Hud;

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

    // How much hope are we loosing each update?
    public static var HOPE_MULT:Float = 0.1;



    public static var direction:Direction = right;

    public function new()
    {
        super({ name:'game' });


        Game.random = new Random(Math.random());

        Game.level = 1;
        Game.gameType = Classic;
    }

    override function onenter<T>(_:T) 
    {

        // trace('bounds : ${bounds}');
        // trace('Luxe.camera.pos : ${Luxe.camera.pos}');

        reset();

        create_hud();

        // init_events();

        create_player();
        create_lightmask();

        spam_tiles();

    }

    function reset()
    {
        Game.difficulty = 0;
        Game.time = 0;
        Game.hope = 1;

        Game.direction = right;

        Game.playing = false;
        Game.delayed = false;

        // random.seed = Math.random();
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
            follow_type: components.Follow.FollowType.smooth,
            lerp: 0.12,
        }));
        lightmask.add( new components.Light({
            name: 'light',
        }) );
    }

    function spam_tiles()
    {
        var _x:Float = 0;
        var _y:Float = 0;

        for(i in 0...40){
            _x = Math.floor( Game.random.float(0, Luxe.screen.w/Luxe.camera.zoom)/16 )*16;
            _y = Math.floor( Game.random.float(0, Luxe.screen.h/Luxe.camera.zoom)/16 )*16;
            
            new Tile({
                pos: new Vector(_x, _y),
            });

            // Luxe.draw.box({
            //     x: _x,
            //     y: _y,
            //     color: new Color( Game.random.float(0.3, 1), Game.random.float(0.3, 1), Game.random.float(0.3, 1) ),
            //     w: 16, h: 16,
            // });
        }
    }


    override function update(dt:Float)
    {
        Game.time += dt;
        if(playing && !delayed)
        {
            Game.hope -= dt * Game.HOPE_MULT;
        }

        Game.hope = Math.sin(Game.time/2)/2 + 0.5;
    }
}


enum GameType {
    Endless;
    Classic;
}

enum Direction {
    left;
    bottom;
    right;
    top;
}
