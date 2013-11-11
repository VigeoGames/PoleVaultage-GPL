package;

import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.constraint.Constraint;
import nape.constraint.LineJoint;
import nape.constraint.PivotJoint;
import nape.constraint.WeldJoint;
import nape.dynamics.InteractionGroup;
import nape.phys.Compound;
import nape.shape.Circle;
import nape.util.Debug;
import nme.display.Stage;
import nme.Lib;
import org.flixel.FlxCamera;
import org.flixel.FlxText;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Quint;

import nape.phys.Body;
import nape.phys.BodyType;
import nape.space.Broadphase;
import nape.shape.Polygon;
import nape.util.ShapeDebug;
import nape.space.Space;
import nape.geom.Vec2;
import nape.constraint.AngleJoint;

import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.plugin.photonstorm.FlxDisplay;
import org.flixel.plugin.photonstorm.FlxMath;

import nme.ui.Mouse;

import com.eclecticdesignstudio.motion.Actuate;
import org.flixel.FlxTimer;

import pl.vigeo.polevaultage.Player;

/**
 * @author Adrian K. <goshki@gmail.com>
 */
class PlayState extends FlxState {
    public static var FENCE_LOCATION_X:Float = 1000 + Math.random() * 500;
    public static var FENCE_HEIGHT:Int = 150;
    
    public static var LANE_DISTANCE:Int = 32;
    public static var LANE_X_OFFSET:Int = 16;
    
    private var debug:Debug;
    private var space:Space;
    
    public var rootGroup:InteractionGroup;
    
    private var player01:Player;
    private var player02:Player;
    
    public var players:Array<Player>;
    
    private var player01Ground:Body;
    private var player02Ground:Body;
    
    public var fencesLong:Array<Body>;
    public var fencesNormal:Array<Body>;
    
    public static var CALLBACK_TYPE_POLE_FENCE_COLLISION:CbType = new CbType();
    public static var CALLBACK_TYPE_PLAYER_WALL_COLLISION:CbType = new CbType();
    public static var CALLBACK_TYPE_PLAYER_GROUND_COLLISION:CbType = new CbType();
    
    public var gameActive:Bool;
    private var switchingToMenu:Bool;
    private var timeOut:Bool;
    public var hasWinner:Bool;
    
    var whiteStrip01:FlxSprite;
    var whiteStrip02:FlxSprite;
    
    private var one01:FlxSprite;
    private var two01:FlxSprite;
    private var three01:FlxSprite;
    private var go01:FlxSprite;
    private var one02:FlxSprite;
    private var two02:FlxSprite;
    private var three02:FlxSprite;
    private var go02:FlxSprite;
    
    
    private var timeLeft:Float;
    private var timer01:FlxText;
    private var timer02:FlxText;
    
    private var enterTooltip:FlxSprite;
    private var shiftTooltip:FlxSprite;
    
    private var player01FenceTouchDetector:FlxSprite;
    private var player02FenceTouchDetector:FlxSprite;
    
    public static var MAX_HEIGHT:Float = 0.0;
    
    private var restartInfo:FlxText;
    
    private function createNapeDebug():Void {
        debug = new ShapeDebug( 100, 100, 0x333333 );
        debug.drawShapeAngleIndicators = false;
        debug.drawConstraints = true;
        debug.drawBodies = true;
        Lib.current.stage.addChild( debug.display );
        space = new Space( new Vec2( 0, 981 ), Broadphase.SWEEP_AND_PRUNE );
    }
    
    private function addFenceFragment( lane:Int ):Void {
        var fenceFragment:FlxSprite = new FlxSprite( FENCE_LOCATION_X - lane * LANE_X_OFFSET, FlxG.height - lane * LANE_DISTANCE - 192 + 42, AssetManager.imgFence );
        add( fenceFragment );
    }
    
    override public function create():Void {
        super.create();
        FlxG.bgColor = 0xFF999999;
        //FlxG.bgColor = 0xFFFFFFFF;
        
        FENCE_LOCATION_X = 1000 + Math.random() * 500;
        
        FlxG.setDebuggerLayout( FlxG.DEBUGGER_RIGHT );
        
        FlxG.log( "Set debugger layout" );

        //FENCE_LOCATION_X = 2000 + FlxG.random() * 1000;
        //FENCE_HEIGHT = Math.round( 300 + FlxG.random() * 300 );
        
        FlxG.log( "Play statistics logged" );
        
        createNapeDebug();
        
        FlxG.log( "Nape debug created" );
        
        rootGroup = new InteractionGroup();
        rootGroup.ignore = true;
        
        FlxG.resetCameras( new FlxCamera( 0, 0, FlxG.width, FlxG.height, 1 ) );
        FlxG.addCamera( new FlxCamera( 0, cast( FlxG.height / 2, Int ), FlxG.width, FlxG.height, 1 ) );
        
        FlxG.log( "Cameras reset" );
        
        FlxG.cameras[0].height = cast( FlxG.height / 2, Int );
        FlxG.cameras[1].height = cast( FlxG.height / 2, Int );
        
        FlxG.log( "Cameras heights set" );
        
        players = [];
        fencesLong = [];
        fencesNormal = [];
        
        #if flash
        var fenceHeight:UInt = cast( FENCE_HEIGHT, UInt );
        #else
        var fenceHeight:Int = FENCE_HEIGHT;
        #end
        
        for ( i in 0...60 ) {
            add( new FlxSprite( -56 + i * 48, FlxG.height - 50, ( i == 0 ) ? AssetManager.imgLaneStart01 : AssetManager.imgLane ) );
            add( new FlxSprite( -40 + i * 48, FlxG.height - 20, ( i == 0 ) ? AssetManager.imgLaneStart01 : AssetManager.imgLane ) );
            add( new FlxSprite( -24 + i * 48, FlxG.height + 10, ( i == 0 ) ? AssetManager.imgLaneStart02 : AssetManager.imgLane ) );
            if ( i * 48 > FENCE_LOCATION_X ) {
                break;
            }
        }
        
        FlxG.log( "Lanes created" );
        
        add( new FlxSprite( -8, FlxG.height - 50, AssetManager.imgStartingLine ) );
        
        FlxG.log( "Starting line created" );
        
        addFenceFragment( 9 );
        addFenceFragment( 8 );
        addFenceFragment( 7 );
        addFenceFragment( 6 );
        addFenceFragment( 5 );
        addFenceFragment( 4 );
        addFenceFragment( 3 );
        addFenceFragment( 2 );
        
        FlxG.log( "Fence created" );
        
        
        // Player two, in the background, lower viewport
        
        player02 = new Player( 1, this, space, Player.PLAYER_02_CONTROL_KEY );
        add( player02 );
        
        for ( i in 0...0 ) {
            add( new FlxSprite( i * 100 - 100 + 1 * LANE_X_OFFSET, FlxG.height - 1 * LANE_DISTANCE ).makeGraphic( 100, 150, ( FlxG.random() > 0.5 ? 0xFF999999 : 0xFFBBBBBB ) ) );
        }
        
        addFenceFragment( 1 );
        
        add( new FlxSprite( FENCE_LOCATION_X - 1 * LANE_X_OFFSET, FlxG.height - 1 * LANE_DISTANCE - FENCE_HEIGHT ).makeGraphic( 1, fenceHeight, 0xFFFFC017 ) );
        player02FenceTouchDetector = new FlxSprite( FENCE_LOCATION_X - 1 * LANE_X_OFFSET, FlxG.height - 1 * LANE_DISTANCE - FENCE_HEIGHT ).makeGraphic( 100, fenceHeight, 0xFFFFC017 );
        player02FenceTouchDetector.visible = false;
        add( player02FenceTouchDetector );
        
        player02Ground = new Body( BodyType.STATIC );
        player02Ground.shapes.add( new Polygon( Polygon.rect( -100, FlxG.height - 1 * LANE_DISTANCE, 10000, 240 ) ) );
        player02Ground.space = space;
        player02Ground.group = player02.collisionGroup;
        player02Ground.cbTypes.add( CALLBACK_TYPE_PLAYER_GROUND_COLLISION );
        player02Ground.userData.playerLane = 1;
        player02Ground.userData.type = "ground";
        
        FlxG.cameras[1].follow( player02.cameraTarget );
        
        // Player one, in the foreground, upper viewport
        
        player01 = new Player( 0, this, space, Player.PLAYER_01_CONTROL_KEY );
        add( player01 );
        
        for ( i in 0...0 ) {
            add( new FlxSprite( i * 100 - 100 + 0 * LANE_X_OFFSET, FlxG.height - 0 * LANE_DISTANCE ).makeGraphic( 100, 150, ( FlxG.random() > 0.5 ? 0xFF555555 : 0xFF777777 ) ) );
        }
        
        addFenceFragment( 0 );
        
        add( new FlxSprite( FENCE_LOCATION_X - 0 * LANE_X_OFFSET, FlxG.height - 0 * LANE_DISTANCE - FENCE_HEIGHT ).makeGraphic( 1, fenceHeight, 0xFFBF1717 ) );
        player01FenceTouchDetector = new FlxSprite( FENCE_LOCATION_X - 0 * LANE_X_OFFSET, FlxG.height - 0 * LANE_DISTANCE - FENCE_HEIGHT ).makeGraphic( 100, fenceHeight, 0xFFBF1717 );
        player01FenceTouchDetector.visible = false;
        add( player01FenceTouchDetector );
        
        addFenceFragment( -1 );
        addFenceFragment( -2 );
        addFenceFragment( -3 );
        addFenceFragment( -4 );
        addFenceFragment( -5 );
        addFenceFragment( -6 );
        addFenceFragment( -7 );
        addFenceFragment( -8 );
        addFenceFragment( -9 );
        addFenceFragment( -10 );
        addFenceFragment( -11 );
        addFenceFragment( -12 );
        addFenceFragment( -13 );
        addFenceFragment( -14 );
        addFenceFragment( -15 );
        
        player01Ground = new Body( BodyType.STATIC );
        player01Ground.shapes.add( new Polygon( Polygon.rect( -100, FlxG.height - 0 * LANE_DISTANCE, 10000, 240 ) ) );
        player01Ground.space = space;
        player01Ground.group = player01.collisionGroup;
        player01Ground.cbTypes.add( CALLBACK_TYPE_PLAYER_GROUND_COLLISION );
        player01Ground.userData.playerLane = 0;
        player01Ground.userData.type = "ground";
        
        FlxG.cameras[0].follow( player01.cameraTarget );
        
        // Players in the array
        
        players.push( player01 );
        players.push( player02 );
        
        // Obstacle for player one
        
        var fence01Long:Body = new Body( BodyType.STATIC );
        fence01Long.shapes.add( new Polygon( Polygon.rect( FENCE_LOCATION_X - 0 * LANE_X_OFFSET, FlxG.height - 0 * LANE_DISTANCE - FENCE_HEIGHT, 100, FENCE_HEIGHT ) ) );
        fence01Long.space = space;
        fence01Long.group = player01.collisionGroup;
        fence01Long.cbTypes.add( CALLBACK_TYPE_POLE_FENCE_COLLISION );
        fence01Long.cbTypes.add( CALLBACK_TYPE_PLAYER_WALL_COLLISION );
        fence01Long.userData.playerLane = 0;
        fence01Long.userData.type = "fence";
        
        fencesLong.push( fence01Long );
        
        var fence01Normal:Body = new Body( BodyType.STATIC );
        fence01Normal.shapes.add( new Polygon( Polygon.rect( FENCE_LOCATION_X - 0 * LANE_X_OFFSET, FlxG.height - 0 * LANE_DISTANCE - FENCE_HEIGHT, 5, FENCE_HEIGHT ) ) );
        fence01Normal.group = player02.collisionGroup;
        fence01Normal.userData.playerLane = 0;
        fence01Normal.userData.type = "fence";
        
        fencesNormal.push( fence01Normal );
        
        // Obstacle for player two
        
        var fence02Long:Body = new Body( BodyType.STATIC );
        fence02Long.shapes.add( new Polygon( Polygon.rect( FENCE_LOCATION_X - 1 * LANE_X_OFFSET, FlxG.height - 1 * LANE_DISTANCE - FENCE_HEIGHT, 100, FENCE_HEIGHT ) ) );
        fence02Long.space = space;
        fence02Long.group = player02.collisionGroup;
        fence02Long.cbTypes.add( CALLBACK_TYPE_POLE_FENCE_COLLISION );
        fence02Long.cbTypes.add( CALLBACK_TYPE_PLAYER_WALL_COLLISION );
        fence02Long.userData.playerLane = 1;
        fence02Long.userData.type = "fence";
        
        fencesLong.push( fence02Long );
        
        var fence02Normal:Body = new Body( BodyType.STATIC );
        fence02Normal.shapes.add( new Polygon( Polygon.rect( FENCE_LOCATION_X - 1 * LANE_X_OFFSET, FlxG.height - 1 * LANE_DISTANCE - FENCE_HEIGHT, 5, FENCE_HEIGHT ) ) );
        fence02Normal.group = player02.collisionGroup;
        fence02Normal.userData.playerLane = 1;
        fence02Normal.userData.type = "fence";
        
        fencesNormal.push( fence02Normal );
        
        // Collision listener
        
        space.listeners.add( new InteractionListener( CbEvent.BEGIN, InteractionType.COLLISION, CALLBACK_TYPE_POLE_FENCE_COLLISION, CALLBACK_TYPE_POLE_FENCE_COLLISION, onCollision ) );
        space.listeners.add( new InteractionListener( CbEvent.BEGIN, InteractionType.COLLISION, CALLBACK_TYPE_PLAYER_WALL_COLLISION, CALLBACK_TYPE_PLAYER_WALL_COLLISION, onPlayerWallCollision ) );
        space.listeners.add( new InteractionListener( CbEvent.BEGIN, InteractionType.COLLISION, CALLBACK_TYPE_PLAYER_GROUND_COLLISION, CALLBACK_TYPE_PLAYER_GROUND_COLLISION, onPlayerGroundCollision ) );
        
        addCountdownNumbers();
        setupCountdownTweens();
        addCountdownTimers();
        
        enterTooltip = new FlxSprite( 0, 0, AssetManager.imgEnterTooltip );
        enterTooltip.x = player01.x + 4;
        enterTooltip.y = player01.y - 52;
        enterTooltip.cameras = [ FlxG.cameras[0] ];
        add( enterTooltip );
        
        shiftTooltip = new FlxSprite( 0, 0, AssetManager.imgShiftTooltip );
        shiftTooltip.x = player02.x + 4;
        shiftTooltip.y = player02.y - 52;
        shiftTooltip.cameras = [ FlxG.cameras[1] ];
        add( shiftTooltip );
        
        restartInfo = new FlxText( 0, 0, FlxG.width, "If stuck, press F1 to restart the game" ).setFormat( AssetManager.uiFont, 16, 0xFFFFFFFF, "center" );
        restartInfo.scrollFactor.make( 0, 0 );
        restartInfo.cameras = [ FlxG.cameras[0] ];
        add( restartInfo );
        
        FlxG.playMusic( "GameTheme" );
        FlxG.music.fadeIn( 0.5 );
        
        FlxG.watch( PlayState, "MAX_HEIGHT", "MAX_HEIGHT" );
    }
    
    private function addCountdownNumbers():Void {
        whiteStrip01 = new FlxSprite( 0, 0 ).makeGraphic( FlxG.width, 48, 0xFFFFFFFF );
        FlxDisplay.screenCenter( whiteStrip01, true, true );
        whiteStrip01.cameras = [ FlxG.cameras[0] ];
        whiteStrip01.scrollFactor.make( 0, 0 );
        add( whiteStrip01 );
        whiteStrip02 = new FlxSprite( 0, 0 ).makeGraphic( FlxG.width, 48, 0xFFFFFFFF );
        whiteStrip02.y = -whiteStrip02.height / 2;
        whiteStrip02.cameras = [ FlxG.cameras[1] ];
        whiteStrip02.scrollFactor.make( 0, 0 );
        add( whiteStrip02 );
        
        
        var fontSize:Float = 128;
        one01 = new FlxText( 0, 0, FlxG.width, "1" ).setFormat( AssetManager.uiFont, fontSize, 0xFFBF1717, "center" );
        FlxDisplay.screenCenter( one01, true, true );
        one01.cameras = [ FlxG.cameras[0] ];
        one01.scrollFactor.make( 0, 0 );
        one01.visible = false;
        add( one01 );
        one02 = new FlxText( 0, 0, FlxG.width, "1" ).setFormat( AssetManager.uiFont, fontSize, 0xFFBF1717, "center" );
        one02.y = -one02.height / 2;
        one02.cameras = [ FlxG.cameras[1] ];
        one02.scrollFactor.make( 0, 0 );
        one02.visible = false;
        add( one02 );
        two01 = new FlxText( 0, 0, FlxG.width, "2" ).setFormat( AssetManager.uiFont, fontSize, 0xFFBF1717, "center" );
        FlxDisplay.screenCenter( two01, true, true );
        two01.cameras = [ FlxG.cameras[0] ];
        two01.scrollFactor.make( 0, 0 );
        two01.visible = false;
        add( two01 );
        two02 = new FlxText( 0, 0, FlxG.width, "2" ).setFormat( AssetManager.uiFont, fontSize, 0xFFBF1717, "center" );
        two02.y = -two02.height / 2;
        two02.cameras = [ FlxG.cameras[1] ];
        two02.scrollFactor.make( 0, 0 );
        two02.visible = false;
        add( two02 );
        three01 = new FlxText( 0, 0, FlxG.width, "3" ).setFormat( AssetManager.uiFont, fontSize, 0xFFBF1717, "center" );
        FlxDisplay.screenCenter( three01, true, true );
        three01.cameras = [ FlxG.cameras[0] ];
        three01.scrollFactor.make( 0, 0 );
        three01.visible = false;
        add( three01 );
        three02 = new FlxText( 0, 0, FlxG.width, "3" ).setFormat( AssetManager.uiFont, fontSize, 0xFFBF1717, "center" );
        three02.y = -three02.height / 2;
        three02.cameras = [ FlxG.cameras[1] ];
        three02.scrollFactor.make( 0, 0 );
        three02.visible = false;
        add( three02 );
        go01 = new FlxText( 0, 0, FlxG.width, "GOOO!!!" ).setFormat( AssetManager.uiFont, fontSize, 0xFFBF1717, "center" );
        FlxDisplay.screenCenter( go01, true, true );
        go01.cameras = [ FlxG.cameras[0] ];
        go01.scrollFactor.make( 0, 0 );
        go01.visible = false;
        add( go01 );
        go02 = new FlxText( 0, 0, FlxG.width, "GOOO!!!" ).setFormat( AssetManager.uiFont, fontSize, 0xFFBF1717, "center" );
        go02.y = -go02.height / 2;
        go02.cameras = [ FlxG.cameras[1] ];
        go02.scrollFactor.make( 0, 0 );
        go02.visible = false;
        add( go02 );
    }
    
    private function addDistanceMeters():Void {
        
    }
    
    private function toggleVisibility( numbers:Array<FlxSprite> ):Void -> Void {
        return function():Void {
            for ( i in 0...numbers.length ) {
                var number:FlxSprite = numbers[i];
                number.visible = !number.visible;
            }
        }
    }
    
    private function killSprites( sprites:Array<FlxSprite> ):Void -> Void {
        return function():Void {
            for ( i in 0...sprites.length ) {
                var sprite:FlxSprite = sprites[i];
                sprite.kill();
                remove( sprite, true );
            }
        }
    }
    
    private function startGame():Void {
        gameActive = true;
        go01.visible = true;
        go02.visible = true;
        Actuate.tween( go01.scale, 1.0, { x: 2.0, y: 2.0 } ).ease( Quint.easeIn ).onComplete( killSprites( [ go01, go02 ] ) );
        Actuate.tween( go01, 1.0, { alpha: 0, y: go01.y - go01.height / 2 } ).ease( Quint.easeIn );
        Actuate.tween( go02.scale, 1.0, { x: 2.0, y: 2.0 } ).ease( Quint.easeIn );
        Actuate.tween( go02, 1.0, { alpha: 0, y: go02.y - go02.height / 2 } ).ease( Quint.easeIn );
    }
    
    private function setupCountdownTweens():Void {
        Actuate.timer( 1.6 ).onComplete( toggleVisibility( [ three01, three02 ] ) );
        Actuate.timer( 2.4 ).onComplete( killSprites( [ three01, three02 ] ) );
        Actuate.timer( 2.4 ).onComplete( toggleVisibility( [ two01, two02 ] ) );
        Actuate.timer( 3.2 ).onComplete( killSprites( [ two01, two02 ] ) );
        Actuate.timer( 3.2 ).onComplete( toggleVisibility( [ one01, one02 ] ) );
        Actuate.timer( 4.0 ).onComplete( killSprites( [ one01, one02 ] ) );
        Actuate.timer( 4.0 ).onComplete( startGame );
    }
    
    private function addCountdownTimers():Void {
        timeLeft = 60;
        var fontSize:Float = 64;
        var timeLeftAsTimecode:String = TimeUtil.floatSecondsToTimecode( timeLeft );
        timer01 = new FlxText( 0, 0, FlxG.width, timeLeftAsTimecode ).setFormat( AssetManager.timerFont, fontSize, 0xFFBF1717, "right" );
        FlxDisplay.screenCenter( timer01, true, true );
        timer01.cameras = [ FlxG.cameras[0] ];
        timer01.scrollFactor.make( 0, 0 );
        add( timer01 );
        timer02 = new FlxText( 0, 0, FlxG.width, timeLeftAsTimecode ).setFormat( AssetManager.timerFont, fontSize, 0xFFBF1717, "right" );
        timer02.y = -timer02.height / 2;
        timer02.cameras = [ FlxG.cameras[1] ];
        timer02.scrollFactor.make( 0, 0 );
        add( timer02 );
    }
    
    private function updateCountdownTimers():Void {
        var timeLeftAsTimecode:String = TimeUtil.floatSecondsToTimecode( timeLeft );
        timer01.text = timer02.text = timeLeftAsTimecode;
    }
    
    private function onCollision( interactionCallback:InteractionCallback ):Void {
        if ( interactionCallback.int1.castBody.userData.type == null && interactionCallback.int2.castBody.userData.type == null ) {
            return;
        }
        if ( interactionCallback.int1.castBody.userData.playerLane == interactionCallback.int2.castBody.userData.playerLane ) {
            var playerLane:Int = interactionCallback.int1.castBody.userData.playerLane;
            var player:Player = players[playerLane];
            FlxG.log( "" + Lib.getTimer() + " Pole-wall collision for player on lane " + playerLane );
            player.createPhysicalPlayer02();
            player.disableGroundJoint();
            player.readyToRestart();
            //interactionCallback.int1.castBody.userData.playerLane = null;
            //interactionCallback.int2.castBody.userData.playerLane = null;
        }
    }
    
    private function onPlayerWallCollision( interactionCallback:InteractionCallback ):Void {
        if ( interactionCallback.int1.castBody.userData.type == null && interactionCallback.int2.castBody.userData.type == null ) {
            return;
        }
        if ( interactionCallback.int1.castBody.userData.playerLane == interactionCallback.int2.castBody.userData.playerLane ) {
            var playerLane:Int = interactionCallback.int1.castBody.userData.playerLane;
            var player:Player = players[playerLane];
            FlxG.log( "" + Lib.getTimer() + " Player-wall collision for player on lane " + playerLane );
            player.removeWallCollisionCallbackType();
            player.readyToRestart();
        }
    }
    
    private function onPlayerGroundCollision( interactionCallback:InteractionCallback ):Void {
        if ( interactionCallback.int1.castBody.userData.type == null && interactionCallback.int2.castBody.userData.type == null ) {
            return;
        }
        if ( interactionCallback.int1.castBody.userData.playerLane == interactionCallback.int2.castBody.userData.playerLane ) {
            FlxG.play( "ground-hit", 20.0 );
            var playerLane:Int = interactionCallback.int1.castBody.userData.playerLane;
            var player:Player = players[playerLane];
            FlxG.log( "" + Lib.getTimer() + " Player-ground collision for player on lane " + playerLane );
            if ( player.x > FENCE_LOCATION_X - playerLane * LANE_X_OFFSET + 8 ) {
                FlxG.log( "" + Lib.getTimer() + " Player successfully jumped over wall on lane " + playerLane );
                playerWins( playerLane );
            }
            player.removeGroundCollisionCallbackType();
            player.readyToRestart();
        }
    }
    
    private function playerWins( playerLane:Int ):Void {
        if ( hasWinner ) {
            return;
        }
        hasWinner = true;
        FlxG.play( "applause" );
        timer01.visible = timer02.visible = whiteStrip01.visible = whiteStrip02.visible = false;
        if ( playerLane == 0 ) {
            Actuate.tween( FlxG.cameras[0], 1.0, { height: FlxG.height } ).ease( Quint.easeOut );
            Actuate.tween( FlxG.cameras[1], 1.0, { y: FlxG.height, height: 0 } ).ease( Quint.easeOut );
        } else {
            Actuate.tween( FlxG.cameras[0], 1.0, { height: 0 } ).ease( Quint.easeOut );
            Actuate.tween( FlxG.cameras[1], 1.0, { y: 0, height: FlxG.height } ).ease( Quint.easeOut );
        }
        Actuate.timer( 1.0 ).onComplete( function():Void {
            var winMessage:FlxText = new FlxText( 0, 0, FlxG.width, "PLAYER " + ( playerLane + 1 ) + " WINS!" )
                .setFormat( AssetManager.uiFont, 64, 0xFFBF1717, "center" );
            winMessage.scrollFactor.make( 0, 0 );
            FlxDisplay.screenCenter( winMessage, true, true );
            add( winMessage );
            pulsateWinMessage( winMessage );
        } );
    }
    
    private function pulsateWinMessage( message:FlxText ):Void {
        if ( message == null || message.scale == null ) {
            return;
        }
        var scale:Float = 1.01 - FlxG.random() * 0.02;
        Actuate.tween( message.scale, 0.025 + FlxG.random() * 0.025, { x: scale, y: scale } ).onComplete( pulsateWinMessage, [ message ] );
    }
    
    public function switchFence( lane:Int ):Void {
        fencesLong[lane].space = null;
        fencesNormal[lane].space = space;
    }
    
    private function switchToMenu():Void {
        FlxG.switchState( new MenuState() );
    }
    
    public function restartPlayer( lane:Int ):Void {
        if ( hasWinner ) {
            return;
        }
        if ( lane == 0 ) {
            // RESET player one
            player01Ground.group = null;
            fencesLong[0].group = null;
            fencesNormal[0].group = null;
            player01.destroy();
            remove( player01, true );
            player01 = new Player( 0, this, space, Player.PLAYER_01_CONTROL_KEY );
            add( player01 );
            players[0] = player01;
            FlxG.cameras[0].follow( player01.cameraTarget );
            player01Ground.group = player01.collisionGroup;
            fencesLong[0].group = player01.collisionGroup;
            fencesNormal[0].group = player01.collisionGroup;
            enterTooltip.visible = true;
            player01FenceTouchDetector.revive();
        } else {
            // RESET player two
            player02Ground.group = null;
            fencesLong[1].group = null;
            fencesNormal[1].group = null;
            player02.destroy();
            remove( player02, true );
            player02 = new Player( 1, this, space, Player.PLAYER_02_CONTROL_KEY );
            add( player02 );
            players[1] = player02;
            FlxG.cameras[1].follow( player02.cameraTarget );
            player02Ground.group = player02.collisionGroup;
            fencesLong[1].group = player02.collisionGroup;
            fencesNormal[1].group = player02.collisionGroup;
            shiftTooltip.visible = true;
            player02FenceTouchDetector.revive();
        }
    }
    
    override public function update():Void {
        super.update();
        //debug.clear();
        space.step( FlxG.elapsed, 40, 40 );
        //debug.draw(space);
        //debug.flush();
        restartInfo.alpha -= FlxG.elapsed / 5;
        if ( restartInfo.alpha <= 0 && restartInfo.visible ) {
            restartInfo.visible = false;
        }
        enterTooltip.x = player01.x + 4;
        enterTooltip.y = player01.y - 52;
        if ( player01.x > player01.lane * PlayState.LANE_X_OFFSET + 100 ) {
            enterTooltip.visible = false;
        }
        if ( player01.currentState == Player.STATE_READY_TO_RESTART ) {
            enterTooltip.visible = true;
        }
        shiftTooltip.x = player02.x + 4;
        shiftTooltip.y = player02.y - 52;
        if ( player02.x > player02.lane * PlayState.LANE_X_OFFSET + 100 ) {
            shiftTooltip.visible = false;
        }
        if ( player02.currentState == Player.STATE_READY_TO_RESTART ) {
            shiftTooltip.visible = true;
        }
        if ( hasWinner && ( FlxG.keys.justPressed( player01.controlKey ) || FlxG.keys.justPressed( player02.controlKey ) || FlxG.keys.justPressed( "SPACE" ) || FlxG.keys.justPressed( "ESCAPE" ) ) && !switchingToMenu ) {
            switchingToMenu = true;
            FlxG.fade( 0xFFFFFFFF, 1, false, switchToMenu );
            if ( FlxG.music != null ) {
                FlxG.music.fadeOut( 1.0 );
            }
        }
        if ( hasWinner || timeOut || !gameActive || switchingToMenu ) {
            return;
        }
        timeLeft -= FlxG.elapsed;
        if ( timeLeft < 0.0 ) {
            timeLeft = 0.0;
            timeOut = true;
            FlxG.fade( 0xFFBF1717, 1, false, switchToMenu );
            if ( FlxG.music != null ) {
                FlxG.music.fadeOut( 1.0 );
            }
        }
        updateCountdownTimers();
        if ( FlxG.keys.justPressed( "F1" ) ) {
            space.clear();
            FlxG.switchState( new PlayState() );
            Lib.current.stage.removeChild( debug.display );
            return;
        }
        if ( FlxG.keys.justPressed( "ESCAPE" ) ) {
            #if !flash
            Lib.close();
            return;
            #else
            FlxG.fade( 0xFFFFFFFF, 1, false, switchToMenu );
            if ( FlxG.music != null ) {
                FlxG.music.fadeOut( 1.0 );
            }
            switchingToMenu = true;
            #end
        }
        if ( player01.x > player01FenceTouchDetector.x && player01.y + player01.height < player01FenceTouchDetector.y ) {
            player01FenceTouchDetector.kill();
        }
        if ( player02.x > player02FenceTouchDetector.x && player02.y + player02.height < player02FenceTouchDetector.y ) {
            player02FenceTouchDetector.kill();
        }
        if ( player01FenceTouchDetector.alive && player01.overlaps( player01FenceTouchDetector ) ) {
            player01.electrocute();
            player01FenceTouchDetector.kill();
        }
        if ( player02FenceTouchDetector.alive && player02.overlaps( player02FenceTouchDetector ) ) {
            player02.electrocute();
            player02FenceTouchDetector.kill();
        }
    }
    
    override public function destroy():Void {
        FlxG.unwatch( PlayState, "MAX_HEIGHT" );
        super.destroy();
    }
}