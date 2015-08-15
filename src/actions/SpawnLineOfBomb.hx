package actions;

import Action.ActionOptions;
import enemies.Bomb;
import luxe.Vector;

class SpawnLineOfBomb extends Action {

    override public function action()
    {

        var bomb:Bomb;
        var v:Vector;

        // trace('place: ${Spawner.pick_place(front, false)}');

        for(i in -7...8){
            v = Spawner.pick_place(front, false);
            // trace('BOMB ${i}');

            if(Game.direction == left || Game.direction == right){
                // trace('y: ${v.y}');
                v.y += -Game.height*0.25 + i * Tile.TILE_SIZE;
                v.y = Math.round( v.y/16 )*16;
                // trace(' -> y: ${v.y}');
            }else{
                // trace('x: ${v.x}');
                v.x += -Game.width*0.25  + i * Tile.TILE_SIZE;
                v.x = Math.round( v.x/16 )*16;
                // trace(' -> x: ${v.x}');
            }


            bomb = new Bomb({
                pos: v,
                scene: Game.scene,
            });
            bomb.add( new components.DestroyByDistance({distance: 200}) );
        }

        // trace('${_x}, ${_y}');


    }

}
