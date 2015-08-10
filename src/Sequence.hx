
class Sequence {
    
    var actions:Array<Action>;

    // read by spawner.
    public var difficulty:Float;
    
    var time:Float = 0;
    
    var duration:Float;
    var delay:Float = 0;
    var ending:Float = 0;

    public function new( options:SequenceOptions )
    {
        if(options.delay != null){
            delay = options.delay;
        }
        if(options.ending != null){
            ending = options.ending;
        }
        action = options.action;
        
            // get sequence's duration
        for(i in actions)
        {
            duration 
        }
        duration += delay + ending;
    }
    
    public function update(dt:Float)
    {
        time += dt;
        
        /*
        if(something){
            actions[current_action].update();
        }
        */
    }

}

typedef SequenceOptions = {

    var actions:Array<Action>;
    
    @:optional var delay:Float;
    @:optional var ending:Float;
}
