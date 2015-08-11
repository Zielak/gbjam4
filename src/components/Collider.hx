package components;

import luxe.collision.data.ShapeCollision;
import luxe.collision.shapes.Polygon;
import luxe.collision.shapes.Shape;
import luxe.Component;
import luxe.Entity;
import luxe.options.ComponentOptions;
import luxe.Sprite;
import luxe.Vector;

class Collider extends Component {
    
    @:isVar public var shape (default, null):Shape;

    var sprite:Sprite;

    var testAgainst:Array<String>;
    var offset:Vector;
    var size:Vector;

    var _entities:Array<Entity>;

    var collision:ShapeCollision;

    override public function new(options:ColliderOptions)
    {
        options.name = 'collider';

        if(options.testAgainst != null){
            testAgainst = options.testAgainst;
        }

        if(options.offset != null){
            offset = options.offset;
        }else{
            offset = new Vector();
        }

        if(options.size != null){
            size = options.size;
        }else{
            size = new Vector();
        }

        super(options);
    }


    override function onadded()
    {
        sprite = cast(entity, Sprite);

        if(sprite == null) throw 'Use it on Sprites for now.';

        if(size.length <= 0){
            size.x = sprite.size.x;
            size.y = sprite.size.y;
        }

        shape = Polygon.rectangle(
            sprite.pos.x - size.x/2,
            sprite.pos.y - size.y/2,
            size.x, size.y);


    }

    override function init()
    {
        _entities = new Array<Entity>();
    }

    override function update(dt:Float)
    {
        shape.position.copy_from(entity.pos);
        shape.position.add(offset);

        if(testAgainst != null)
        {
            for(n in testAgainst)
            {
                test_collision(n);
            }
        }
    }


    function test_collision( test_name:String )
    {
        var _collider:Collider;

        Luxe.scene.get_named_like( test_name, _entities );

        for(_entity in _entities)
        {
            if(_entity.has('collider'))
            {
                _collider = cast (_entity.get('collider'), Collider);
                if(_collider != null){
                    collision = shape.test( _collider.shape );
                    
                    if(collision == null) continue;

                    if(collision.overlap > 0){
                        _entity.events.fire('collision.hit');

                        entity.events.fire('collision.hit', {name:test_name});
                    }
                }
            }
        }
    }

}



typedef ColliderOptions = {
    > ComponentOptions,

    @:optional var offset:Vector;
    @:optional var size:Vector;
    @:optional var testAgainst:Array<String>;
}
