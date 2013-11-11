package;

import nme.display.Sprite;
import nme.Lib;
import nme.display.Sprite;
import nme.events.Event;
import org.flixel.FlxGame;


/**
 * @author Adrian K. <goshki@gmail.com>
 */
class Main extends Sprite {
	public function new() {
		super();
		var game:FlxGame = new PoleVaultage();
		addChild( game );
	}
    
	public static function main() {
		Lib.current.addChild( new Main() );
	}
}
