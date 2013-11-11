package;

import nme.Lib;
import org.flixel.FlxG;
import org.flixel.FlxGame;
import pl.vigeo.logo.LogoState;
	
/**
 * @author Adrian K. <goshki@gmail.com>
 */
class PoleVaultage extends FlxGame {
	public static var FRAMERATE:Int = 60;
    
    public static var VERSION:String = "0.0.7";
	
	public function new() {
		super( Lib.current.stage.stageWidth, Lib.current.stage.stageHeight, LogoState, 1, FRAMERATE, FRAMERATE, true );
        FlxG.bgColor = 0xFFFFFFFF;
	}
}
