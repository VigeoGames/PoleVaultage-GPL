package ;
import nme.display.Bitmap;
import nme.media.Sound;
import nme.Assets;

/**
 * @author Adrian K. <goshki@gmail.com>
 */
class AssetManager {
    public static var uiFont( getUiFont, null ):String;
    
	private static function getUiFont():String {
		return Assets.getFont( "pole-vaultage-assets-fonts/Acme7Wide.ttf" ).fontName;
	}
    
    public static var timerFont( getTimerFont, null ):String;
    
	private static function getTimerFont():String {
		return Assets.getFont( "pole-vaultage-assets-fonts/ProggySquare.ttf" ).fontName;
	}
    
    public static var imgVigeoLogo:Class<Bitmap> = ImgVigeoLogo;
    
    public static var imgVigeoLogo01:Class<Bitmap> = ImgVigeoLogo01;
    
    public static var imgVigeoLogo02:Class<Bitmap> = ImgVigeoLogo02;
    
    public static var imgVigeoLogo03:Class<Bitmap> = ImgVigeoLogo03;
    
    public static var imgVigeoLogo04:Class<Bitmap> = ImgVigeoLogo04;
    
    public static var imgVigeoLogo05:Class<Bitmap> = ImgVigeoLogo05;
    
    public static var imgJumperRed:Class<Bitmap> = ImgJumperRed;
    
    public static var imgJumperYellow:Class<Bitmap> = ImgJumperYellow;
    
    public static var imgFence:Class<Bitmap> = ImgFence;
    
    public static var imgStartingLine:Class<Bitmap> = ImgStartingLine;
    
    private static var imgLane01:Class<Bitmap> = ImgLane01;
    
    private static var imgLane02:Class<Bitmap> = ImgLane02;
    
    private static var imgLane03:Class<Bitmap> = ImgLane03;
    
    private static var imgLane04:Class<Bitmap> = ImgLane04;
    
    public static var imgLane(getImgLane, null):Class<Bitmap>;
    
    public static function getImgLane():Class<Bitmap> {
        var random:Float = Math.random();
        if ( random < 0.25 ) {
            return imgLane01;
        } else if ( random < 0.5 ) {
            return imgLane02;
        } else if ( random < 0.75 ) {
            return imgLane03;
        } else {
            return imgLane04;
        }
    }
    
    public static var imgLaneStart01:Class<Bitmap> = ImgLaneStart01;
    
    public static var imgLaneStart02:Class<Bitmap> = ImgLaneStart02;
    
    public static var imgEnterTooltip:Class<Bitmap> = ImgEnterTooltip;
    
    public static var imgShiftTooltip:Class<Bitmap> = ImgShiftTooltip;
    
    public static var imgFlash:Class<Bitmap> = ImgFlash;
    
    public static var imgTutorial01:Class<Bitmap> = ImgTutorial01;
    
    public static var imgTutorial02:Class<Bitmap> = ImgTutorial02;
    
    public static var imgTutorial03:Class<Bitmap> = ImgTutorial03;
}

class ImgVigeoLogo extends Bitmap {
	public function new() { super( Assets.getBitmapData( "vigeologo-assets-img/vigeo-games-logo.png" ) ) ; }
}

class ImgVigeoLogo01 extends Bitmap {
	public function new() { super( Assets.getBitmapData( "vigeologo-assets-img/color-01.png" ) ) ; }
}

class ImgVigeoLogo02 extends Bitmap {
	public function new() { super( Assets.getBitmapData( "vigeologo-assets-img/color-02.png" ) ) ; }
}

class ImgVigeoLogo03 extends Bitmap {
	public function new() { super( Assets.getBitmapData( "vigeologo-assets-img/color-03.png" ) ) ; }
}

class ImgVigeoLogo04 extends Bitmap {
	public function new() { super( Assets.getBitmapData( "vigeologo-assets-img/color-04.png" ) ) ; }
}

class ImgVigeoLogo05 extends Bitmap {
	public function new() { super( Assets.getBitmapData( "vigeologo-assets-img/color-05.png" ) ) ; }
}

class ImgJumperRed extends Bitmap {
	public function new() { super( Assets.getBitmapData( "pole-vaultage-assets-img/jumper-red.png" ) ) ; }
}

class ImgJumperYellow extends Bitmap {
	public function new() { super( Assets.getBitmapData( "pole-vaultage-assets-img/jumper-yellow.png" ) ) ; }
}

class ImgFence extends Bitmap {
	public function new() { super( Assets.getBitmapData( "pole-vaultage-assets-img/fence.png" ) ) ; }
}

class ImgStartingLine extends Bitmap {
	public function new() { super( Assets.getBitmapData( "pole-vaultage-assets-img/starting-line.png" ) ) ; }
}

class ImgLane01 extends Bitmap {
	public function new() { super( Assets.getBitmapData( "pole-vaultage-assets-img/lane-01.png" ) ) ; }
}

class ImgLane02 extends Bitmap {
	public function new() { super( Assets.getBitmapData( "pole-vaultage-assets-img/lane-02.png" ) ) ; }
}

class ImgLane03 extends Bitmap {
	public function new() { super( Assets.getBitmapData( "pole-vaultage-assets-img/lane-03.png" ) ) ; }
}

class ImgLane04 extends Bitmap {
	public function new() { super( Assets.getBitmapData( "pole-vaultage-assets-img/lane-04.png" ) ) ; }
}

class ImgLaneStart01 extends Bitmap {
	public function new() { super( Assets.getBitmapData( "pole-vaultage-assets-img/lane-start-01.png" ) ) ; }
}

class ImgLaneStart02 extends Bitmap {
	public function new() { super( Assets.getBitmapData( "pole-vaultage-assets-img/lane-start-02.png" ) ) ; }
}

class ImgEnterTooltip extends Bitmap {
	public function new() { super( Assets.getBitmapData( "pole-vaultage-assets-img/enter-tooltip.png" ) ) ; }
}

class ImgShiftTooltip extends Bitmap {
	public function new() { super( Assets.getBitmapData( "pole-vaultage-assets-img/space-tooltip.png" ) ) ; }
}

class ImgFlash extends Bitmap {
	public function new() { super( Assets.getBitmapData( "pole-vaultage-assets-img/flash.png" ) ) ; }
}

class ImgTutorial01 extends Bitmap {
	public function new() { super( Assets.getBitmapData( "pole-vaultage-assets-img/tutorial-01.png" ) ) ; }
}

class ImgTutorial02 extends Bitmap {
	public function new() { super( Assets.getBitmapData( "pole-vaultage-assets-img/tutorial-02.png" ) ) ; }
}

class ImgTutorial03 extends Bitmap {
	public function new() { super( Assets.getBitmapData( "pole-vaultage-assets-img/tutorial-03.png" ) ) ; }
}
