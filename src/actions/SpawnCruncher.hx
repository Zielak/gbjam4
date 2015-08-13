package actions;

import Action.ActionOptions;
import enemies.Cruncher;
import luxe.Vector;
import Spawner.SpawnPlace;

class SpawnCruncher extends Action {

    var spawn_type:SpawnPlace;
    
    override public function new( options:SpawnCruncherOptions )
    {
        super(options);

        if(options.spawn_type != null){
            spawn_type = options.spawn_type;
        }else{
            spawn_type = front;
        }
    }


    override public function action()
    {

        var cruncher:Cruncher = new Cruncher({
            pos: Spawner.pick_place(spawn_type),
            scene: Game.scene,
        });

        cruncher.add( new components.DestroyByDistance({distance: 200}) );



        // Set Vector speeds and direction
        var _v:Vector = Game.directional_vector();
        if(spawn_type == front){
            _v.x = -_v.x;
            _v.y = -_v.y;

            // slower from front
            _v.multiplyScalar(0.65);
        }

        if(spawn_type == back){
            // faster from back (so they can catch up)
            _v.multiplyScalar(2.2);
        }


        if(spawn_type == front
        || spawn_type == back)
        {
            cruncher.add( new components.Movement({velocity:_v}));
        }
    }

}

typedef SpawnCruncherOptions = {
    > ActionOptions,

    @:optional var spawn_type:SpawnPlace;
}



