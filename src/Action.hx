
class Action {
    
    var action:Void->Void;

    // Property to be read by sequence.
    @:isVar public var delay:Float;

    // Check if action fired.
    @:isVar public var fired (default, null):Bool;

    public function new( options:ActionOptions )
    {
        fired = false;

        delay = options.delay;
        action = options.action;
    }

    public function fire()
    {
        if(fired) return;

        action();
        fired = true;
    }

}

typedef ActionOptions = {

    var action:Void->Void;
    var delay:Float;
}
