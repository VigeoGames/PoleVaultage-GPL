package;

import nme.Lib;
import org.flixel.FlxG;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.plugin.photonstorm.FlxDisplay;
import org.flixel.FlxU;
import pl.vigeo.polevaultage.Player;

/**
 * @author Adrian K. <goshki@gmail.com>
 */
class MenuState extends FlxState {
    public var startPromptLabel:FlxText;
    public var gameCopyright:FlxText;
    public var musicCopyright:FlxText;
    
	override public function create():Void {
        var url = Lib.current.loaderInfo.loaderURL;
        FlxG.log( url );
        if ( url == null || url == "" ) {
            url = Lib.current.loaderInfo.url;
            FlxG.log( url );
        }
        if ( FlxG.music != null ) {
            FlxG.music.destroy();
            FlxG.music = null;
        }
        FlxG.bgColor = 0xFFFFFFFF;
        var title:FlxSprite = new FlxText( 0, 0, FlxG.width, "POLE VAULTAGE!" ).setFormat( null, 32, 0xBF1717, "center" );
        FlxDisplay.screenCenter( title, true, true );
        title.y -= 100;
        add( title );
        startPromptLabel = new FlxText( 0, FlxG.height / 2 + 30, FlxG.width, "PRESS " + Player.PLAYER_01_CONTROL_KEY + " OR " + Player.PLAYER_02_CONTROL_KEY + " TO START" );
        startPromptLabel.y -= 100;
        add( startPromptLabel.setFormat( AssetManager.uiFont, 8, 0xBF1717, "center" ) );
        var tutorial01:FlxSprite = new FlxSprite( FlxG.width / 2 - 200, FlxG.height / 2 - 10, AssetManager.imgTutorial01 );
        add( tutorial01 );
        var tutorial02:FlxSprite = new FlxSprite( FlxG.width / 2 - 50, FlxG.height / 2 - 10, AssetManager.imgTutorial02 );
        add( tutorial02 );
        var tutorial03:FlxSprite = new FlxSprite( FlxG.width / 2 + 100, FlxG.height / 2 - 10, AssetManager.imgTutorial03 );
        add( tutorial03 );
        
        var tutorial01Text:FlxText = new FlxText( FlxG.width / 2 - 200, FlxG.height / 2 + 100, 100 ).setFormat( AssetManager.uiFont, 8, 0xBF1717 );
        tutorial01Text.text = "Tap the button repeatedly to gain speed";
        add( tutorial01Text );
        
        var tutorial02Text:FlxText = new FlxText( FlxG.width / 2 - 50, FlxG.height / 2 + 100, 100 ).setFormat( AssetManager.uiFont, 8, 0xBF1717 );
        tutorial02Text.text = "Hold the button down to lower the pole when close to the fence";
        add( tutorial02Text );
        
        var tutorial03Text:FlxText = new FlxText( FlxG.width / 2 + 100, FlxG.height / 2 + 100, 100 ).setFormat( AssetManager.uiFont, 8, 0xBF1717 );
        tutorial03Text.text = "Release the button when pole touches the ground and bends";
        add( tutorial03Text );
        
        add( new FlxText( 0, FlxG.height - 16, FlxG.width, "version: " + PoleVaultage.VERSION ).setFormat( AssetManager.uiFont, 8, 0xBF1717 ) );
        gameCopyright = new FlxText( FlxG.width - 350, FlxG.height - 16, 350, "Pole Vaultage! for TIGSource Sports Compo, by goshki" ).setFormat( AssetManager.uiFont, 8, 0xBF1717, "right" );
        add( gameCopyright );
        musicCopyright = new FlxText( FlxG.width - 150, FlxG.height - 32, 150, "music: '97' by lightsoda" ).setFormat( AssetManager.uiFont, 8, 0xBF1717, "right" );
        add( musicCopyright );
	}
    
	override public function update():Void {
		super.update();
        startPromptLabel.visible = Std.int( Lib.getTimer() / 500 ) % 2 > 0;
        if ( FlxG.keys.justPressed( Player.PLAYER_01_CONTROL_KEY ) || FlxG.keys.justPressed( Player.PLAYER_02_CONTROL_KEY ) ) {
            FlxG.fade( 0xFFFFFFFF, 1, false, startGame );
        }
        if ( FlxG.mouse.justPressed() ) {
            if ( gameCopyright.overlapsPoint( FlxG.mouse.getWorldPosition() ) ) {
                FlxU.openURL( "http://twitter.com/goshki" );
            } else if ( musicCopyright.overlapsPoint( FlxG.mouse.getWorldPosition() ) ) {
                FlxU.openURL( "http://soundcloud.com/lightsoda/97-1" );
            }
        }
    }
    
    private function startGame():Void {
        FlxG.switchState( new PlayState() );
    }
}