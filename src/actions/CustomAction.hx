package actions;

import Action;

class CustomAction extends Action {
    
    var custom_action:Void->Void;

    override public function new( options:CustomActionOptions )
    {
        super(options);
        custom_action = options.action;
    }

    override public function action()
    {
        custom_action();
    }

}

typedef  CustomActionOptions = {
    > ActionOptions,

    var action:Void->Void;
}
