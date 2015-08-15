
class Action {
    

    var time:Float = 0;

    // Property to be read by sequence.
    @:isVar public var delay(default, null):Float = 0;

    // Wait for this action to finish?
    @:isVar public var wait(default, null):Bool = false;

    // Did action fired?
    @:isVar public var fired(default, null):Bool = false;

    // Check if action is completely finished
    @:isVar public var finished(default, null):Bool = false;

    public function new( options:ActionOptions )
    {
        finished = false;

        delay = options.delay;
        if(options.wait != null){
            wait = options.wait;
        }
    }

    public function update(dt:Float)
    {
        if(fired) return;

        time += dt;

        if(time >= delay){
            fire();
        }
    }

    function fire()
    {
        fired = true;

        action();

        if(!wait) finish();
    }

    /**
     * Override it do create your own actions
     */
    public function action() {}

    /**
     * Call to reset this action and maybe start over
     */
    public function reset()
    {
        time = 0;
        finished = false;
        fired = false;
    }

    /**
     * Used when action isn't autoplay (wait = true)
     * and we're waiting for the final words
     */
    public function finish()
    {
        time = 0;
        finished = true;
    }

}

typedef ActionOptions = {

    var delay:Float;

    @:optional var wait:Bool;
}
