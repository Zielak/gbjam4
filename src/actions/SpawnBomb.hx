package actions;

import Action.ActionOptions;
import enemies.Bomb;
import luxe.Vector;

class SpawnBomb extends Action {

    // override function new 

    override public function action()
    {

        var bomb:Bomb = new Bomb({
            pos: Spawner.pick_place(front),
            scene: Game.scene,
        });

        // trace('${_x}, ${_y}');

        bomb.add( new components.DestroyByDistance({distance: 300}) );

    }



}
