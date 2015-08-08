
package components;

import luxe.Color;
import luxe.Component;
import luxe.Input;
import luxe.options.ComponentOptions;
import luxe.Sprite;
import luxe.Vector;
import luxe.Visual;
import phoenix.Batcher;
import phoenix.RenderTexture;
import phoenix.Shader;

class LowresShader extends Component
{
    var pixel_size:Vector;
    var color_ramp:Float = 1 / 10;

    var enabled:Bool = true;

    var final_output : RenderTexture;
    var final_batch : Batcher;
    var final_view : Sprite;
    var final_shader : Shader;


    override public function new(_options:LowresShaderOptions)
    {
        super(_options);

        // if(_options.color_ramp != color_ramp){
        //     color_ramp = _options.color_ramp;
        // }

        if(_options.pixel_size != null){
            pixel_size = _options.pixel_size;
        }else{
            pixel_size = new Vector(Game.width, Game.height);
        }
    }

    override function onadded()
    {
        
    }

    override function onremoved()
    {

    }

    override function init()
    {


        /** This is where we will draw to, the render texture */
        final_output = new RenderTexture({
            id: 'rtt',
            width: Math.floor(Luxe.screen.size.x),
            height: Math.floor(Luxe.screen.size.y),
        });
        
        /** This is a batcher separate from the default rendering so we can control when it draws */
        final_batch = Luxe.renderer.create_batcher({
            no_add:true,
            layer:5,
        });

        /** This is the shader we will apply to the overall drawing */
        final_shader = Luxe.resources.shader('lowres');
        
        //set the defaults
        // final_shader.set_float('pixel_w', pixel_size.x );
        // final_shader.set_float('pixel_h', pixel_size.y );



        final_view = new Sprite({
            centered : false,
            pos : new Vector(0,0),
            size : Luxe.screen.size,
            texture : final_output,
            shader : final_shader,
            batcher : final_batch,
        });

    }

    public function onprerender()
    {
        if(!enabled) return;
            //set to the custom render target
        Luxe.renderer.target = final_output;
        // Luxe.renderer.clear(new Color(0,0,0,1));



    } //onprerender

    public function onpostrender() {

        if(!enabled) return;

        //      //set back to the default window target
        Luxe.renderer.target = null;

        //     //clear to a bright red so we can see any weirdness
        // Luxe.renderer.clear(new Color(0,0,0,0));

        //     //control the blending for this sprite, because the drawing writes
        //     //alpha values into the texture, making parts of the texture see through
        //     //if we draw this on a red background, it would show through.
        //     //comment this line to see it happen (like open the debug console)
        Luxe.renderer.blend_mode(BlendMode.src_alpha, BlendMode.one_minus_src_alpha);

        //     //now we draw the custom view sprite using the batcher
        final_batch.draw();

        //     //reset the blending
        // Luxe.renderer.blend_mode();

    } //onpostrender

    override function update(dt:Float)
    {

    }

    override public function onkeydown( event:KeyEvent )
    {
        if(event.keycode == Key.key_p){
            enabled = !enabled;
            final_view.visible = enabled;
        }
    }

}

typedef LowresShaderOptions = {
    > ComponentOptions,

    @:optional var pixel_size:Vector;
    @:optional var color_ramp:Float;
}
