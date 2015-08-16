
import luxe.AppConfig;
import luxe.Color;
import luxe.components.sprite.SpriteAnimation;
import luxe.Entity;
import luxe.Input;
import luxe.Sprite;
import luxe.States;
import luxe.Timer;
import luxe.Vector;
import phoenix.Texture;

class Main extends luxe.Game
{

    var machine:States;

    var shader:Entity;

    override public function config( _config:AppConfig ) : luxe.AppConfig{

        // Screens
        _config.preload.textures.push({ id:'assets/images/faderBlack.gif' });
        _config.preload.textures.push({ id:'assets/images/rush_logo.gif' });
        _config.preload.textures.push({ id:'assets/images/rush_logo_bg.gif' });
        _config.preload.textures.push({ id:'assets/images/intro_darekLogo.gif' });
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
        _config.preload.sounds.push({ id:'assets/sounds/Rush_Explosion.wav', name:'bomb', is_stream:false });
        _config.preload.sounds.push({ id:'assets/sounds/Rush_Grab_Box.wav', name:'pickup', is_stream:false });
        _config.preload.sounds.push({ id:'assets/sounds/Rush_Throw_Crate.wav', name:'throw', is_stream:false });
        _config.preload.sounds.push({ id:'assets/sounds/Rush_Jump.wav', name:'jump', is_stream:false });
        _config.preload.sounds.push({ id:'assets/sounds/cruncher_die.wav', name:'cruncher_die', is_stream:false });
        _config.preload.sounds.push({ id:'assets/sounds/crate_break.wav', name:'create', is_stream:false });

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
            gal_mult: 0.0065,
            gal_distance_start: 0.95,
            hope_mult: 0.1,
            tutorial: false,
        }) );
        machine.add( new GameOverState() );
        
        machine.set('game');



        shader = new Entity({
            name: 'entity',
        });
        shader.add( new components.LowresShader({
            name: 'lowres',
            pixel_size: new Vector( Game.width/Luxe.camera.zoom, Game.height/Luxe.camera.zoom ),
        }) );

        init_events();

    } //ready

    function init_events()
    {
        Luxe.events.listen('game.over.quit', function(_){
            Luxe.timer.schedule(5, function(){
                machine.set('gameover');
            });
        });

        Luxe.events.listen('state.intro.finished', function(_){
            machine.set('menu');
        });

        Luxe.events.listen('state.menu.finished', function(_){
            machine.set('game');
        });
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


