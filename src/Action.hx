
class Action {
    

    var time:Float = 0;

    // Property to be read by sequence.
    @:isVar public var delay(default, null):Float;

    // Check if action fired.
    @:isVar public var fired (default, null):Bool;

    public function new( options:ActionOptions )
    {
        fired = false;

        delay = options.delay;
    }

    public function update(dt:Float)
    {
        time += dt;

        if(time >= delay){
            fire();
        }
    }

    function fire()
    {
        if(fired) return;

        action();
        time = 0;
        fired = true;
    }

    public function action() {}

    public function reset()
    {
        time = 0;
        fired = false;
    }

}

typedef ActionOptions = {

    var delay:Float;
}
