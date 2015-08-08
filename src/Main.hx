
import luxe.Input;
import luxe.States;

class Main extends luxe.Game
{

    var machine:States;

    override function ready() {

        machine = new States({ name:'statemachine' });

        // machine.add( new IntroState() );
        // machine.add( new MenuState() );
        // machine.add( new GameState() );
        // machine.add( new GameOverState() );

        

    } //ready

    override function onkeyup( e:KeyEvent ) {

        if(e.keycode == Key.escape) {
            Luxe.shutdown();
        }

    } //onkeyup

    override function update(dt:Float) {

    } //update


} //Main


class IntroState extends State {

    public function new()
    {
        super({ name:'intro' });
    }

}

class MenuState extends State {

    public function new()
    {
        super({ name:'menu' });
    }

}

class GameState extends State {

    public function new()
    {
        super({ name:'game' });
    }
}

class GameOverState extends State {

    public function new()
    {
        super({ name:'gameover' });
    }
}


