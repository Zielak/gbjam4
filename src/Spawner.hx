
import components.Movement;
import luxe.Entity;
import luxe.Timer;
import luxe.Vector;

class Spawner extends Entity {
    
    var sequences:Array<Sequence>;

    var time:Float = 0;

    override function init()
    {
        time = 0;

        Luxe.events.listen('spawn.tilescolrow', function(_){
            spawn_tiles();
        });
        
    }


    override function update(dt:Float)
    {
        if(Game.playing && !Game.delayed)
        {
            time += dt;
        }
    }


    function spawn_tiles()
    {
        
        var col:Bool = false;
        var count:Int;

        var _w:Float;
        var _x:Float;
        var _y:Float;
        var _tile:Tile;

        switch(Game.direction)
        {
            case right: 
                col = true;
                count = Math.ceil(Game.height / Tile.TILE_SIZE);

            case down:  
                col = false;
                count = Math.ceil(Game.width / Tile.TILE_SIZE);

            case left:  
                col = true;
                count = Math.ceil(Game.height / Tile.TILE_SIZE);

            case up:    
                col = false;
                count = Math.ceil(Game.width / Tile.TILE_SIZE);
        }


        for(i in -4...count+4)
        {
            if(Math.random() > 0.85) continue;

            if(col)
            {
                if(Game.direction == left){
                    _x = Luxe.camera.center.x - Game.width/2 - Tile.TILE_SIZE;
                }else{
                    _x = Luxe.camera.center.x + Game.width/2 + Tile.TILE_SIZE;
                }
                _y = Luxe.camera.center.y - Game.height/2 + i*Tile.TILE_SIZE;
            }
            else
            {
                _x = Luxe.camera.center.x - Game.width/2 + i*Tile.TILE_SIZE;

                if(Game.direction == up){
                    _y = Luxe.camera.center.y - Game.height/2 - Tile.TILE_SIZE;
                }else{
                    _y = Luxe.camera.center.y + Game.height/2 + Tile.TILE_SIZE;
                } 
            }

            _x = Math.floor( _x/16 )*16;
            _y = Math.floor( _y/16 )*16;

            _tile = new Tile({
                pos: new Vector(_x, _y),
            });
            // trace('tile spawned');
        }
    }

}
