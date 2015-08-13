
import luxe.AppConfig;
import luxe.Color;
import luxe.Entity;
import luxe.Input;
import luxe.States;
import luxe.Vector;

class Main extends luxe.Game
{

    var machine:States;

    var shader:Entity;

    override public function config( _config:AppConfig ) : luxe.AppConfig{

        // Screens
        _config.preload.textures.push({ id:'assets/images/faderBlack.gif' });
        _config.preload.textures.push({ id:'assets/images/intro_darekLogo.gif' });
        _config.preload.textures.push({ id:'assets/images/intro_gbjam.gif' });
        _config.preload.textures.push({ id:'assets/images/text.gif' });

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
        _config.preload.textures.push({ id:'assets/images/faderBlack.gif' });

        // World
        _config.preload.textures.push({ id:'assets/images/tiles.gif' });
        _config.preload.textures.push({ id:'assets/images/lightmask.png' });
        _config.preload.textures.push({ id:'assets/images/puff.gif' });

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

        // machine.add( new IntroState() );
        // machine.add( new MenuState() );
        machine.add( new Game({
            gal_mult: 0.015,
            gal_distance_start: 0.8,
            hope_mult: 0.03,
            tutorial: true,
        }) );
        // machine.add( new GameOverState() );
        
        machine.set('game');



        shader = new Entity({
            name: 'entity',
        });
        shader.add( new components.LowresShader({
            name: 'lowres',
            pixel_size: new Vector( Game.width/Luxe.camera.zoom, Game.height/Luxe.camera.zoom ),
        }) );


        // phoenix.Texture.default_filter = phoenix.Texture.FilterType.nearest;

    } //ready

    override function onkeyup( e:KeyEvent ) {

        if(e.keycode == Key.escape) {
            Luxe.shutdown();
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


class IntroState extends State {

    public function new()
    {
        super({ name:'intro' });
    }

}

class MenuState extends State {

    public function new()
    {
        super({ name:'menu' });
    }

}


class GameOverState extends State {

    public function new()
    {
        super({ name:'gameover' });
    }
}


