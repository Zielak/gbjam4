package actions;

import Action.ActionOptions;
import enemies.Crate;
import luxe.Vector;

class SpawnCrate extends Action {


    var pos:Vector;

    override public function new(options:SpawnCrateOptions)
    {
        if(options.pos != null){
            pos = options.pos;
        }else{
            pos = null;
        }

        super(options);
    }

    override public function action()
    {
        if(pos == null){
            pos = Spawner.pick_place(front);
        }

        var bomb:Crate = new Crate({
            pos: pos,
            scene: Game.scene,
        });

        bomb.add( new components.DestroyByDistance({distance: 300}) );
    }

}

typedef SpawnCrateOptions = {
    > ActionOptions,

    var pos:Vector;
}
