
import luxe.AppConfig;
import luxe.Color;
import luxe.components.sprite.SpriteAnimation;
import luxe.Entity;
import luxe.Input;
import luxe.Sound;
import luxe.Sprite;
import luxe.States;
import luxe.Timer;
import luxe.Vector;
import phoenix.Texture;

class Main extends luxe.Game
{

    var rush_loop:Sound;
    var rush_intro:Sound;
    var rush_ending:Sound;

    var machine:States;

    var shader:Entity;

    override public function config( _config:AppConfig ) : luxe.AppConfig{

        // Screens
        _config.preload.textures.push({ id:'assets/images/faderBlack.gif' });
        _config.preload.textures.push({ id:'assets/images/rush_logo.gif' });
        _config.preload.textures.push({ id:'assets/images/rush_logo_bg.gif' });
        _config.preload.textures.push({ id:'assets/images/intro_darekLogo.gif' });
        _config.preload.textures.push({ id:'assets/images/intro_music.gif' });
        _config.preload.textures.push({ id:'assets/images/intro_gbjam.gif' });
        _config.preload.textures.push({ id:'assets/images/text.gif' });
        _config.preload.textures.push({ id:'assets/images/help.gif' });

        // Player
        _config.preload.textures.push({ id:'assets/images/player.gif' });
        _config.preload.textures.push({ id:'assets/images/gal.gif' });

        // Enemies
        _config.preload.textures.push({ id:'assets/images/cruncher.gif' });
        _config.preload.textures.push({ id:'assets/images/bomb.gif' });
        _config.preload.textures.push({ id:'assets/images/crate.gif' });

        // HUD
        _config.preload.textures.push({ id:'assets/images/hud.gif' });
        _config.preload.textures.push({ id:'assets/images/hearth.gif' });

        // World
        _config.preload.textures.push({ id:'assets/images/tiles.gif' });
        _config.preload.textures.push({ id:'assets/images/lightmask.png' });
        _config.preload.textures.push({ id:'assets/images/puff.gif' });



        // Sounds
        _config.preload.sounds.push({ id:'assets/sounds/Rush_Explosion.ogg', name:'bomb', is_stream:false });
        _config.preload.sounds.push({ id:'assets/sounds/Rush_Grab_Box.ogg', name:'pickup', is_stream:false });
        _config.preload.sounds.push({ id:'assets/sounds/Rush_Throw_Crate.ogg', name:'throw', is_stream:false });
        _config.preload.sounds.push({ id:'assets/sounds/Rush_Jump.ogg', name:'jump', is_stream:false });
        _config.preload.sounds.push({ id:'assets/sounds/cruncher_die.ogg', name:'cruncher_die', is_stream:false });
        _config.preload.sounds.push({ id:'assets/sounds/crate_break.ogg', name:'create', is_stream:false });
        _config.preload.sounds.push({ id:'assets/sounds/start.ogg', name:'start', is_stream:false });

        // Music
        _config.preload.sounds.push({ id:'assets/music/Rush_Intro.ogg', name:'rush_intro', is_stream:true });
        _config.preload.sounds.push({ id:'assets/music/Rush_Ending.ogg', name:'rush_ending', is_stream:true });
        _config.preload.sounds.push({ id:'assets/music/Go_Get_Her.ogg', name:'rush_loop', is_stream:true });

        // Shaders
        _config.preload.shaders.push({
            id:"lowres", frag_id:"assets/shaders/lowres.glsl", vert_id:"default"
        });

        return _config;

    }

    override function ready() {

        Luxe.renderer.clear_color = new Color().rgb(C.c1);
        Luxe.camera.zoom = 4;
        Luxe.camera.pos.set_xy( -Game.width*1.5, -Game.height*1.5 );

        

        // Machines
        machine = new States({ name:'statemachine' });

        machine.add( new IntroState() );
        machine.add( new MenuState() );
        machine.add( new Game({
            gal_mult: 0.0053,
            gal_distance_start: 0.95,
            hope_mult: 0.1,
            tutorial: true,
        }) );
        // machine.add( new GameOverState() );
        
        machine.set('intro');



        shader = new Entity({
            name: 'entity',
        });
        shader.add( new components.LowresShader({
            name: 'lowres',
            pixel_size: new Vector( Game.width/Luxe.camera.zoom, Game.height/Luxe.camera.zoom ),
        }) );

        init_events();

        init_audio();

    } //ready

    function init_events()
    {
        Luxe.events.listen('game.over.quit', function(_){
            Luxe.timer.schedule(5, function(){
                // machine.set('gameover');
            });
            machine.set('menu');
        });

        Luxe.events.listen('state.intro.finished', function(_){
            machine.set('menu');
        });

        Luxe.events.listen('state.menu.finished', function(_){
            machine.set('game');
        });


        // player pressed start in main menu
        Luxe.events.listen('state.menu.start_game', function(_){
            // stop everything just in case
            rush_ending.stop();
            rush_loop.stop();
            rush_intro.stop();
        });

        // player enters the Game State
        Luxe.events.listen('game.init', function(_){
            // stop everything just in case
            rush_intro.play();
            rush_intro.on('end', start_loop);
        });

        Luxe.events.listen('game.over.*', function(_){
            rush_loop.stop();
        });

        Luxe.events.listen('game.over.gal', function(_){
            rush_loop.stop();
            rush_intro.stop();
            rush_ending.stop();

            rush_ending.play();

        });
    }

    function start_loop(_)
    {
        rush_loop.loop();
        //Luxe.audio.loop('rush_loop');
        rush_intro.off('end', start_loop);
        //Luxe.audio.off('rush_intro', 'end', start_loop);
    }

    function init_audio()
    {
        Luxe.audio.on("rush_ending", "load", function(e){
            rush_ending = e;
            rush_ending.volume = 0.2;
        });
        
        Luxe.audio.on("rush_intro", "load", function(e){
            rush_intro = e;
            rush_intro.volume = 0.2;
        });
        
        Luxe.audio.on("rush_loop", "load", function(e){
            rush_loop = e;
            rush_loop.volume = 0.33;
        });

        // Luxe.audio.play('rush_ending');
        rush_ending.play();
    }

    override function onkeyup( e:KeyEvent ) {

        if(e.keycode == Key.escape) {
            // Luxe.shutdown();
        }

    } //onkeyup

    override function update(dt:Float) {

    } //update



    /**
     * Shader stuff
     */
    override function onprerender()
    {
        shader.get('lowres').onprerender();
    }

    override function onpostrender()
    {
        shader.get('lowres').onpostrender();
    }


} //Main




class GameOverState extends State {

    public function new()
    {
        super({ name:'gameover' });
    }
}


