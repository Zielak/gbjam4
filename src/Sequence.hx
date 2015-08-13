
class Sequence {
    
    var actions:Array<Action>;
    var current_action:Int = 0;

    // read by spawner.
    @:isVar public var difficulty (default, null):Float;
    
    var time:Float;
    
    @:isVar public var duration (default, null):Float;
    var delay:Float = 0;
    var ending:Float = 0;

    public var finished:Bool = false;

    public function new( options:SequenceOptions )
    {
        actions = options.actions;

        difficulty = options.difficulty;

        if(options.delay != null){
            delay = options.delay;
        }
        if(options.ending != null){
            ending = options.ending;
        }
        
            // get sequence's duration
        duration = 0;
        for(a in actions)
        {
            duration += a.delay;
        }
        duration += delay + ending;

        time = 0;


        // trace('sequence started...');
        // trace(' -  duration = ${duration}');
    }
    
    public function update(dt:Float):Bool
    {
        if(!finished)
        {
            time += dt;

            if(time >= duration){
                // trace('sequence finished...');
                finished = true;
            }else if(time > delay){
                actions[current_action].update(dt);
                if(actions[current_action].finished) next();
            }
        }
        
        return finished;
        
        // actions[current_action].update();
    }

    public function reset()
    {
        finished = false;
        time = -delay;
        current_action = 0;

        for(a in actions){
            a.reset();
        }
    }

    function next()
    {
        current_action ++;
        if(current_action >= actions.length){
            finished = true;
        }
        // trace(' - Next action [${current_action}]');
    }

}

typedef SequenceOptions = {

    var actions:Array<Action>;
    var difficulty:Float;
    
    @:optional var delay:Float;
    @:optional var ending:Float;
}
