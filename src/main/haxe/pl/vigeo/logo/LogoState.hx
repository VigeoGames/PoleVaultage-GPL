package pl.vigeo.logo;

import nme.Assets;
import nme.Lib;
import nme.geom.Rectangle;
import nme.media.Sound;
import org.flixel.FlxCamera;
import org.flixel.FlxPoint;
import org.flixel.FlxSound;
import org.flixel.FlxTimer;
import org.flixel.FlxText;
import org.flixel.FlxTextField;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxG;
import org.flixel.FlxGame;
import org.flixel.FlxU;
import org.flixel.plugin.photonstorm.FlxGradient;
import nme.ui.Mouse;
import nme.system.System;
import org.flixel.plugin.photonstorm.FlxDisplay;
import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Elastic;
import com.eclecticdesignstudio.motion.easing.Sine;

/**
 * @author Adrian K. <goshki@gmail.com>
 */
class LogoState extends FlxState {
    /**
     * Amount of time delay from creation to animation start.
     */
    private static var ANIMATION_DELAY:Float = 0.5;
        
    public var logo:FlxSprite;
    public var logo01:FlxSprite;
    public var logo02:FlxSprite;
    public var logo03:FlxSprite;
    public var logo04:FlxSprite;
    public var logo05:FlxSprite;
    
    public var vigeoGamesLabel:FlxText;
    public var vigeoGamesUrl:FlxText;
    
	override public function create():Void {
        FlxG.bgColor = 0xFFFFFFFF;
        
        logo05 = new FlxSprite( 0, 0, AssetManager.imgVigeoLogo05 );
        FlxDisplay.screenCenter( logo05, true, true );
        logo05.scale.x = logo05.scale.y = 0;
        add( logo05 );
        logo04 = new FlxSprite( 0, 0, AssetManager.imgVigeoLogo04 );
        FlxDisplay.screenCenter( logo04, true, true );
        logo04.scale.x = logo04.scale.y = 0;
        add( logo04 );
        logo03 = new FlxSprite( 0, 0, AssetManager.imgVigeoLogo03 );
        FlxDisplay.screenCenter( logo03, true, true );
        logo03.scale.x = logo03.scale.y = 0;
        add( logo03 );
        logo02 = new FlxSprite( 0, 0, AssetManager.imgVigeoLogo02 );
        FlxDisplay.screenCenter( logo02, true, true );
        logo02.scale.x = logo02.scale.y = 0;
        add( logo02 );
        logo01 = new FlxSprite( 0, 0, AssetManager.imgVigeoLogo01 );
        FlxDisplay.screenCenter( logo01, true, true );
        logo01.scale.x = logo01.scale.y = 0;
        add( logo01 );
        
        logo = new FlxSprite( 0, 0, AssetManager.imgVigeoLogo );
        FlxDisplay.screenCenter( logo, true, true );
        logo.alpha = 0;
        add( logo );
        
        vigeoGamesLabel = new FlxText( 0, FlxG.height / 2 + 50, FlxG.width, "VIGEO GAMES" ).setFormat( AssetManager.uiFont, 16,
            0xBF1717, "center" );
        vigeoGamesLabel.alpha = 0;
		add( vigeoGamesLabel );
        
        vigeoGamesUrl = new FlxText( 0, vigeoGamesLabel.y + vigeoGamesLabel.height - 10, FlxG.width, "http://vigeogam.es/" )
            .setFormat( AssetManager.uiFont, 8, 0xBFA18F, "center" );
        vigeoGamesUrl.alpha = 0;
		add( vigeoGamesUrl );
        
        // Center everything horizontally
        
        var wholeSetHeight:Int = Std.int( vigeoGamesUrl.y + vigeoGamesUrl.height - logo.y );
        var wholeSetY:Int = Std.int( ( FlxG.height - wholeSetHeight ) / 2 );
        var offsetY:Int = Std.int( logo.y - wholeSetY );
        
        logo.y -= offsetY;
        logo01.y -= offsetY;
        logo02.y -= offsetY;
        logo03.y -= offsetY;
        logo04.y -= offsetY;
        logo05.y -= offsetY;
        vigeoGamesLabel.y -= offsetY;
        vigeoGamesUrl.y -= offsetY;
        
        new FlxTimer().start( ANIMATION_DELAY, 1, startLogoAnimation );
	}
    
    private function killLogoColors():Void {
        logo01.kill();
        logo02.kill();
        logo03.kill();
        logo04.kill();
        logo05.kill();
    }
    
    private function startLogoAnimation( timer:FlxTimer ):Void {
        FlxG.play( "VigeoTheme" );
        
        Actuate.tween( logo05.scale, 1, { x: 1, y: 1 } ).ease( Elastic.easeOut );
        Actuate.tween( logo04.scale, 1, { x: 1, y: 1 } ).ease( Elastic.easeOut ).delay( 0.210 );
        Actuate.tween( logo03.scale, 1, { x: 1, y: 1 } ).ease( Elastic.easeOut ).delay( 0.410 );
        Actuate.tween( logo02.scale, 1, { x: 1, y: 1 } ).ease( Elastic.easeOut ).delay( 0.610 );
        Actuate.tween( logo01.scale, 1, { x: 1, y: 1 } ).ease( Elastic.easeOut ).delay( 1.150 );
        Actuate.tween( logo, 2, { alpha: 1 } ).ease( Sine.easeOut ).delay( 1.600 ).onComplete( killLogoColors );
        Actuate.tween( vigeoGamesLabel, 2, { alpha: 1 } ).ease( Sine.easeOut ).delay( 1.600 );
        Actuate.tween( vigeoGamesUrl, 2, { alpha: 1 } ).ease( Sine.easeOut ).delay( 1.600 );
        
        new FlxTimer().start( 5.0, 1, fadeToMenu );
    }
    
    private function fadeToMenu( timer:FlxTimer ):Void {
        FlxG.fade( 0xFFFFFFFF, 1, false, switchToMenu );
    }
	
	override public function update():Void {
		super.update();
        if ( FlxG.mouse.justPressed() && ( vigeoGamesLabel.overlapsPoint( FlxG.mouse.getWorldPosition() ) ||
            vigeoGamesUrl.overlapsPoint( FlxG.mouse.getWorldPosition() ) ) ) {
            FlxU.openURL( "http://vigeogam.es/" );
        }
    }
    
    private function switchToMenu():Void {
        FlxG.switchState( new MenuState() );
    }
}