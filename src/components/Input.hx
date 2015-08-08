
package components;

import luxe.Component;
import luxe.Input;

class Input extends Component
{

    // Movement
    public var left:Bool    = false;
    public var right:Bool   = false;
    public var up:Bool      = false;
    public var down:Bool    = false;

    public var angle:Float  = 0;

    // movement pressed?
    public var move:Bool    = false;
    
    // action button
    public var A:Bool  = false;
    public var B:Bool  = false;

    override function init():Void
    {
        Luxe.input.bind_key('left',     Key.key_a);
        Luxe.input.bind_key('right',    Key.key_d);
        Luxe.input.bind_key('up',       Key.key_w);
        Luxe.input.bind_key('down',     Key.key_s);

        Luxe.input.bind_key('left',     Key.left);
        Luxe.input.bind_key('right',    Key.right);
        Luxe.input.bind_key('up',       Key.up);
        Luxe.input.bind_key('down',     Key.down);

        Luxe.input.bind_key('A',   Key.key_k);
        Luxe.input.bind_key('B',   Key.key_l);

        Luxe.input.bind_key('A',   Key.key_c);
        Luxe.input.bind_key('B',   Key.key_x);
    }

    override function update(dt:Float):Void
    {
        updateKeys();
    }


    function updateKeys():Void
    {
        left  = Luxe.input.inputdown('left');
        right = Luxe.input.inputdown('right');
        up = Luxe.input.inputdown('up');
        down = Luxe.input.inputdown('down');

        A  = Luxe.input.inputdown('A');
        B  = Luxe.input.inputdown('B');

        if(left && right){
            left = right = false;
        }
        if(up && down){
            up = down = false;
        }

        if( !move && (up || down || left || right) ){
            move = true;
        }else if( move && !(up || down || left || right) ){
            move = false;
        }

        // Set angle
        if ( up )
        {
            angle = Math.PI*3 / 2;//-90;
            if ( left)
                angle -= Math.PI/4;
            else if ( right)
                angle += Math.PI/4;
        }
        else if ( down )
        {
            angle = Math.PI/2;//90;
            if ( left )
                angle += Math.PI/4;
            else if ( right )
                angle -= Math.PI/4;
        }
        else if ( left )
            angle = Math.PI;
        else if ( right )
            angle = 0;

    }


}
