
import luxe.Sprite;
import luxe.Component;
import luxe.options.SpriteOptions;

class Crate extends Sprite {
    
    public static inline var TILE_SIZE:Float = 16;
    public static inline var TILES_COUNT:Int = 2;

    var tile_id:Int = 0;
    
    override public function new(_options:CrateOptions)
    {
        _options.name_unique = true;
        _options.namme = 'crate';
        _options.centered = true;
        _options.texture = Luxe.resources.texture('assets/images/tiles.gif');

        super( _options);

        if(_options.tile_id != null){
            tile_id = _options.tile_id;
        }
    }

}



typedef CrateOptions = {
    > SpriteOptions,

    @:optional var tile_id:Int;
}

