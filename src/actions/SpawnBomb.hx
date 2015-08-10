package actions;

import Action.ActionOptions;
import luxe.Vector;

class SpawnBomb extends Action {

    override public function action()
    {
        var _x:Float = Luxe.camera.center.x;
        var _y:Float = Luxe.camera.center.y;

        // Pick random place in front of camera's center

        var s:Float = 0.5;

        if(Game.direction == left || Game.direction == right){
            _y += -Game.height*s/2 + Game.random.float(0, Game.height*s);
        }
        if(Game.direction == up || Game.direction == down){
            _x += -Game.width*s/2 + Game.random.float(0, Game.width*s);
        }
        
        switch(Game.direction){
            case right : _x += Game.width/2  + Tile.TILE_SIZE;
            case down  : _y += Game.height/2 + Tile.TILE_SIZE;
            case left  : _x -= Game.width/2  - Tile.TILE_SIZE;
            case up    : _y -= Game.height/2 - Tile.TILE_SIZE;
        }

        // Round up the position
        _x = Math.round( _x/16 )*16;
        _y = Math.round( _y/16 )*16;

        var bomb:Bomb = new Bomb({
            pos: new Vector( _x, _y),
        });

        // trace('${_x}, ${_y}');

        bomb.add( new components.DestroyByDistance({distance: 300}) );

    }

}
