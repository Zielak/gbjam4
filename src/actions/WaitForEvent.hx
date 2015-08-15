package actions;

import Action;

class WaitForEvent extends Action {
    
    var event:String;
    var eid:String;

    override public function new( options:WaitForEventOptions )
    {
        options.wait = true;

        super(options);

        event = options.event;
    }

    override public function action()
    {
        eid = Luxe.events.listen(event, function(_){
            Luxe.events.unlisten(eid);
            finish();
        });
    }

}

typedef  WaitForEventOptions = {
    > ActionOptions,

    var event:String;
}
