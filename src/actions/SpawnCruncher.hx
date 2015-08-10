package actions;

import Action.ActionOptions;
import luxe.Vector;

class SpawnCruncher extends Action {

    var spawn_type:CruncherSpawnType;
    
    override public function new( options:SpawnCruncherOptions )
    {
        super(options);

        if(options.spawn_type != null){
            spawn_type = options.spawn_type;
        }else{
            spawn_type = still;
        }
    }


    override public function action()
    {

        var _x:Float = Luxe.camera.center.x;
        var _y:Float = Luxe.camera.center.y;

        var _v:Vector = Game.directional_vector();

        // Pick random place in front of camera's center

        var s:Float = 0.5;

        if(spawn_type == still
        || spawn_type == fromFront
        || spawn_type == fromBack)
        {
            if(Game.direction == left || Game.direction == right){
                _y += -Game.height*s/2 + Game.random.float(0, Game.height*s);
            }
            if(Game.direction == up || Game.direction == down){
                _x += -Game.width*s/2 + Game.random.float(0, Game.width*s);
            }
        }

        if(spawn_type == still
        || spawn_type == fromFront)
        {
            switch(Game.direction){
                case right : _x += Game.width/2 + Tile.TILE_SIZE;
                case down  : _y += Game.height/2 + Tile.TILE_SIZE;
                case left  : _x -= Game.width/2 - Tile.TILE_SIZE;
                case up    : _y -= Game.height/2 - Tile.TILE_SIZE;
            }
        }
        else if (spawn_type == fromBack)
        {
            switch(Game.direction){
                case right : _x -= Game.width/2 + Tile.TILE_SIZE*2;
                case down  : _y -= Game.height/2 + Tile.TILE_SIZE*2;
                case left  : _x += Game.width/2 + Tile.TILE_SIZE*2;
                case up    : _y += Game.height/2 + Tile.TILE_SIZE*2;
            }
        }
        else if (spawn_type == fromSides)
        {
            // switch(Game.direction){
            //     case left  : _x += Game.width/2 + Tile.TILE_SIZE;
            //     case up    : _y += Game.height/2 + Tile.TILE_SIZE;
            //     case right : _x -= Game.width/2 - Tile.TILE_SIZE;
            //     case down  : _y -= Game.height/2 - Tile.TILE_SIZE;
            // }
        }


        // Round up the position
        _x = Math.round( _x/16 )*16;
        _y = Math.round( _y/16 )*16;

        var cruncher:Cruncher = new Cruncher({
            pos: new Vector( _x, _y ),
        });

        cruncher.add( new components.DestroyByDistance({distance: 300}) );


        // Set Vector speeds and direction
        if(spawn_type == fromFront){
            _v.x = -_v.x;
            _v.y = -_v.y;

            // slower from front
            _v.multiplyScalar(0.65);
        }

        if(spawn_type == fromBack){
            // faster from back (so they can catch up)
            _v.multiplyScalar(2.2);
        }


        if(spawn_type == still
        || spawn_type == fromFront
        || spawn_type == fromBack)
        {
            cruncher.add( new components.Movement({velocity:_v}));
        }
    }

}

typedef SpawnCruncherOptions = {
    > ActionOptions,

    @:optional var spawn_type:CruncherSpawnType;
}

enum CruncherSpawnType {
    still;
    fromFront;
    fromBack;
    fromSides;
}

