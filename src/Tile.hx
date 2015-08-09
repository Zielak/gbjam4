
import components.DestroyByDistance;
import components.Movement;
import luxe.components.sprite.SpriteAnimation;
import luxe.Sprite;
import luxe.Component;
import luxe.options.SpriteOptions;
import luxe.utils.Maths;
import luxe.Vector;

class Tile extends Sprite {
    
    public static inline var TILE_SIZE:Float = 16;
    public static inline var TILES_COUNT:Int = 4;

    var tile_id:Int = -1;
    var tiles_x:Int;
    var tiles_y:Int;

    var mover:Movement;
    
    override public function new(_options:TileOptions)
    {
        _options.name_unique = true;
        _options.name = 'Tile';
        _options.centered = true;
        _options.texture = Luxe.resources.texture('assets/images/tiles.gif');
        _options.texture.filter_mag = nearest;
        _options.texture.filter_min = nearest;
        _options.size = new Vector(TILE_SIZE,TILE_SIZE);

        super( _options);

        if(_options.tile_id != null)
        {
            tile_id = _options.tile_id;
        }

        tiles_x = Math.floor(_options.texture.width / TILE_SIZE); 
        tiles_y = Math.floor(_options.texture.height / TILE_SIZE);
    }


    override function init()
    {

        // events.listen('movement.killBounds', function(){
        //     Luxe.events.fire('tile.outofbounds');
        // });

        if(tile_id == -1){
            tile_id = Math.floor( Math.random()*TILES_COUNT );
        }

        this.uv.w = TILE_SIZE;
        this.uv.h = TILE_SIZE;

        this.uv.x = tile_id * TILE_SIZE;

        add( new DestroyByDistance( {
            name: 'distance',
            distance: 160,
        }));
    }

}



typedef TileOptions = {
    > SpriteOptions,

    @:optional var tile_id:Int;
}

