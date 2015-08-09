
class Sequence {
    
    var action:Void->Void;

    // read by spawner.
    public var difficulty:Float;
    public var delay:Float;


    // Check if action fired.
    @:isVar public var fired (default, null):Bool;

    public function new( options:SequenceOptions )
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

typedef SequenceOptions = {

    var action:Void->Void;
    var delay:Float;
}
