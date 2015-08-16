package actions;

import Action.ActionOptions;
import enemies.Bomb;
import luxe.Vector;

class SpawnBomb extends Action {

    var _pos:Vector;

    override public function new ( options:SpawnBombOptions )
    {
        super(options);

        if(options.pos != null){
            _pos = options.pos;
        }
    }

    override public function action()
    {
        var bomb:Bomb;
        if(_pos != null){
            bomb = new Bomb({
                pos: _pos,
                scene: Game.scene,
            });
        }else{
            bomb = new Bomb({
                pos: Spawner.pick_place(front),
                scene: Game.scene,
            });
        }

        bomb.add( new components.DestroyByDistance({distance: 300}) );

    }



}


typedef SpawnBombOptions = {
    > ActionOptions,

    @:optional var pos:Vector;
}
