package pl.vigeo.polevaultage;

import com.eclecticdesignstudio.motion.Actuate;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.ConstraintCallback;
import nape.callbacks.ConstraintListener;
import nape.callbacks.Listener;
import nape.dynamics.InteractionGroup;
import org.flixel.FlxTimer;

import nape.constraint.Constraint;
import nape.constraint.PivotJoint;
import nape.constraint.WeldJoint;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Compound;
import nape.shape.Polygon;
import nape.space.Space;

import nme.Lib;

import org.flixel.FlxG;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.plugin.photonstorm.FlxMath;
import org.flixel.plugin.photonstorm.FlxVelocity;

/**
 * @author Adrian K. <goshki@gmail.com>
 */
class Player extends FlxSprite {
    public static var STATE_ACCELERATING:String = "STATE_ACCELERATING";
    public static var STATE_LOWERING_POLE:String = "STATE_LOWERING_POLE";
    public static var STATE_JUMPING:String = "STATE_JUMPING";
    public static var STATE_ELECTROCUTED:String = "STATE_ELECTROCUTED";
    public static var STATE_FREEFALLING:String = "STATE_FREEFALLING";
    public static var STATE_READY_TO_RESTART:String = "STATE_READY_TO_RESTART";
    
    public static var WIDTH:Int = 8;
    public static var HEIGHT:Int = 12;
    
    public static var PLAYER_01_CONTROL_KEY:String = "ENTER";
    public static var PLAYER_02_CONTROL_KEY:String = "SPACE";
    
    public var controlKey:String;
    
    public var cameraTarget:FlxSprite;
    
    public var currentState:String;
    
    private var state:FlxState;
    private var space:Space;
    
    private var accelerationKeyPressTime:Float;
    
    private var leftHandPosition:FlxPoint;
    private var rightHandPosition:FlxPoint;
    private var leftHandJoint:PivotJoint;
    private var rightHandJoint:PivotJoint;
    
    private var groundJoint:PivotJoint;
    
    private var compound:Compound;
    
    private var player:Body;
    private var ground:Body;
    
    private var fragmentsTotal:Int = 4;
    private var fragmentLength:Float = 25;
    
    private var poleFragments:Array<Body>;
    private var poleJoints:Array<Constraint>;
    
    private var poleFragmentSprites:Array<FlxSprite>;
    
    public var collisionGroup:InteractionGroup;
    
    private var creationTime:Int;
    
    private var restarted:Bool;
    
    public var initialHeight:Float;
    public var maxHeight:Float;
    
    // Index of a lane ocuppied by this player. The lower the index, the closer the player is to the camera
    public var lane:Int;
    
    public var maxPoleStress:Float = 0;
    
    public var shadow:FlxSprite;
    
    public var flash:FlxSprite;
    
    private var electrocuted:Bool;
    
    public function new( lane:Int, state:FlxState, space:Space, controlKey:String ) {
		super();
        creationTime = Lib.getTimer();
        //makeGraphic( WIDTH, HEIGHT, 0xFFBF1717 + 0x105080 * lane );
        loadGraphic( ( lane == 0 ) ? AssetManager.imgJumperRed : AssetManager.imgJumperYellow, true, false, 12, 13 );
        this.state = state;
        this.space = space;
        this.controlKey = controlKey;
        this.lane = lane;
        x = -( lane * PlayState.LANE_X_OFFSET ) - 2;
        y = FlxG.height - HEIGHT - lane * PlayState.LANE_DISTANCE - 1;
        addAnimation( "idle", [ 0 ], 0, false );
        addAnimation( "run-slow", [ 1, 2, 3, 2 ], 12, true );
        addAnimation( "run-medium", [ 1, 2, 3, 2 ], 18, true );
        addAnimation( "run-fast", [ 1, 2, 3, 2 ], 24, true );
        addAnimation( "electrocuted", [ 4 ], 0, false );
        play( "idle" );
        maxVelocity.x = 2000;
        cameraTarget = new FlxSprite();
        collisionGroup = new InteractionGroup();
        collisionGroup.group = cast( FlxG.state, PlayState ).rootGroup;
        drag.x = 300;
        currentState = STATE_ACCELERATING;
        poleFragments = [];
        poleJoints = [];
        poleFragmentSprites = [];
        compound = new Compound();
        compound.space = space;
        createPole();
        leftHandPosition = new FlxPoint( WIDTH * 0.375, HEIGHT / 2 );
        rightHandPosition = new FlxPoint( WIDTH, 0 );
        leftHandJoint = new PivotJoint( space.world, poleFragments[0], new Vec2( -WIDTH * 0.125, -HEIGHT / 4 ), new Vec2( -fragmentLength / 10, 0 ) );
        leftHandJoint.frequency = 30;
        leftHandJoint.space = space;
        leftHandJoint.stiff = false;
        rightHandJoint = new PivotJoint( space.world, poleFragments[0], new Vec2( WIDTH / 2, -HEIGHT / 2 ), new Vec2( fragmentLength / 10, 0 ) );
        rightHandJoint.frequency = 30;
        rightHandJoint.space = space;
        //rightHandJoint.active = false;
        rightHandJoint.stiff = false;
        groundJoint = new PivotJoint( space.world, poleFragments[poleFragments.length - 1], new Vec2( 100, FlxG.height - lane * PlayState.LANE_DISTANCE ), new Vec2( fragmentLength / 2, 0 ) );
        groundJoint.space = space;
        groundJoint.active = false;
        new FlxTimer().start( 1.0, 1, setJointsMaxForce );
        FlxG.watch( this, "currentState", "[" + lane + "] currentState" );
        FlxG.watch( this.velocity, "x", "[" + lane + "] velocity" );
        FlxG.watch( this, "maxHeight", "[" + lane + "] maxHeight" );
        FlxG.watch( this, "maxPoleStress", "[" + lane + "] maxPoleStress" );
        initialHeight = y;
        maxHeight = 0;
        
        shadow = new FlxSprite( x, y + 13 ).makeGraphic( 12, 1, 0xFF000000 );
        flash = new FlxSprite( 0, 0, AssetManager.imgFlash );
        flash.visible = false;
    }
    
    function onPoleJointBroken( cb:ConstraintCallback ):Void {
        if ( cb.constraint.userData.player != this ) {
            return;
        }
        if ( ( player == null ) || ( player.position.x < PlayState.FENCE_LOCATION_X - lane * PlayState.LANE_X_OFFSET ) ) {
            readyToRestart();
        }
        disableGroundJoint();
        if ( !leftHandJoint.active ) {
            return;
        }
        leftHandJoint.active = false;
        FlxG.play( "wood-break" );
    }
    
    private function createPoleJoints():Void {
        for ( i in 0...poleFragments.length - 1 ) {
            var fragment:Body = poleFragments[i];
            var nextFragment:Body = poleFragments[i + 1];
            var joint:Constraint = new WeldJoint( fragment, nextFragment, new Vec2( fragmentLength / 2, 0 ), new Vec2( -fragmentLength / 2, 0 ) );
            joint.stiff = false;
            joint.frequency = 30;
            joint.space = space;
            joint.compound = compound;
            joint.userData.player = this;
            joint.userData.constraintListener = new ConstraintListener( CbEvent.BREAK, joint.cbTypes, onPoleJointBroken );
            space.listeners.add( joint.userData.constraintListener );
            poleJoints.push( joint );
        }
    }
    
    private function createPole():Void {
        for ( i in 0...fragmentsTotal ) {
            var fragment:Body = new Body(BodyType.DYNAMIC);
            fragment.shapes.add( new Polygon( Polygon.rect( -fragmentLength / 2, -1 , fragmentLength, 2 )));
            fragment.position.setxy( x + fragmentLength * i, y );
            fragment.space = space;
            fragment.compound = compound;
            fragment.group = collisionGroup;
            fragment.cbTypes.add( PlayState.CALLBACK_TYPE_POLE_FENCE_COLLISION );
            fragment.userData.playerLane = lane;
            poleFragments.push( fragment );
            var fragmentSprite:FlxSprite = new FlxSprite();
            fragmentSprite.makeGraphic( cast( fragmentLength, Int ), 2, 0xFF333333 );
            poleFragmentSprites.push( fragmentSprite );
        }
        createPoleJoints();
    }
    
    private function clearPoleData():Void {
        for ( i in 0...fragmentsTotal ) {
            var fragment:Body = poleFragments[i];
            fragment.userData.playerLane = null;
        }
    }
    
    private function updateControls():Void {
        if ( !cast( FlxG.state, PlayState ).gameActive ) {
            return;
        }
        flash.visible = false;
        if ( currentState == STATE_ELECTROCUTED ) {
            flash.visible = true;
            flash.x = x - 10;
            flash.y = y - 10;
            flash.angle = Math.random() * 180 - 90;
            flash.visible = Std.int( Lib.getTimer() / 50 ) % 2 > 0;
            angle = Math.random() * 180 - 90;
            return;
        }
        if ( currentState == STATE_ACCELERATING ) {
            acceleration.x = 0;
            if ( FlxG.keys.justPressed( controlKey ) ) {
                accelerationKeyPressTime = 0;
                acceleration.x = 5000;
            }
            if ( FlxG.keys.pressed( controlKey ) ) {
                accelerationKeyPressTime += FlxG.elapsed;
            }
            if ( accelerationKeyPressTime >= 0.35 ) {
                FlxG.log( "" + Lib.getTimer() + " Changing state to STATE_LOWERING_POLE" );
                FlxG.cameras[lane].follow( null );
                currentState = STATE_LOWERING_POLE;
                drag.x = 0;
                acceleration.x = 0;
                Actuate.tween( leftHandPosition, 0.2, { y: -6 } );
                Actuate.tween( rightHandPosition, 0.2, { y: -4 } ).onComplete( function() {
                    FlxG.cameras[lane].follow( this );
                    createPhysicalPlayer02();
                    new FlxTimer().start( 0.15, 1, function( timer:FlxTimer) {
                        if ( player != null ) {
                            player.applyImpulse( new Vec2( 0, -1000 ) );
                        }
                    } );
                } );
            }
        }
        if ( currentState == STATE_LOWERING_POLE ) {
            if ( FlxG.keys.justReleased( controlKey ) && leftHandJoint.active ) {
                FlxG.log( "" + Lib.getTimer() + " Changing state to STATE_JUMPING" );
                currentState = STATE_JUMPING;
                leftHandJoint.active = false;
                groundJoint.active = false;
                if ( player != null ) {
                    player.applyImpulse( new Vec2( 0, -25000 - 20000 * Math.abs( velocity.x / maxVelocity.x ) ) );
                    player.cbTypes.add( PlayState.CALLBACK_TYPE_PLAYER_GROUND_COLLISION );
                }
                for ( i in 0...poleJoints.length ) {
                    var joint:Constraint = poleJoints[i];
                    joint.stiff = true;
                }
            }
        }
        if ( currentState == STATE_READY_TO_RESTART ) {
            if ( FlxG.keys.justPressed( controlKey ) && !cast( FlxG.state, PlayState ).hasWinner ) {
                restarted = true;
                cast( FlxG.state, PlayState ).restartPlayer( lane );
            }
        }
    }
    
    public function createPhysicalPlayer02():Void {
        if ( player != null || ( rightHandJoint != null && rightHandJoint.active == false ) ) {
            FlxG.log( "" + Lib.getTimer() + " Player already exists!" );
            return;
        }
        FlxG.log( "" + Lib.getTimer() + " Creating physical player" );
        compound.breakApart();
        player = new Body( BodyType.DYNAMIC );
        player.shapes.add( new Polygon( Polygon.rect( -WIDTH / 2, -HEIGHT / 2, WIDTH, HEIGHT )));
        player.mass = 75;
        player.position.setxy( x + WIDTH / 2, y + HEIGHT / 2 );
        player.space = space;
        player.group = collisionGroup;
        player.userData.playerLane = lane;
        player.userData.type = "player";
        player.cbTypes.add( PlayState.CALLBACK_TYPE_PLAYER_WALL_COLLISION );
        // angle: min: 25 -> velocity: 2000, max: 45 -> velocity: 0
        // http://stackoverflow.com/questions/5294955/how-to-scale-down-a-range-of-numbers-with-a-known-min-and-max-value
        var angle:Int = ( maxVelocity != null && velocity != null ) ? Math.round( 20 * ( maxVelocity.x - velocity.x ) / maxVelocity.x + 25 ) : 45;
        var poleStressVelocityBonus:Float = getPoleStress();
        FlxG.log( "" + Lib.getTimer() + " poleStressVelocityBonus: " + poleStressVelocityBonus );
        var rotatedVelocityVector:FlxPoint = FlxVelocity.velocityFromAngle( angle, Math.round( velocity.x / 2 + poleStressVelocityBonus ) );
        player.velocity.setxy( rotatedVelocityVector.x, -rotatedVelocityVector.y );
        
        rightHandJoint.active = false;
        groundJoint.anchor1.setxy( x + fragmentsTotal * fragmentLength * 0.9, FlxG.height - lane * PlayState.LANE_DISTANCE );
        groundJoint.active = true;
        leftHandJoint.body1 = player;
        leftHandJoint.anchor1.setxy( -2, -18 );
        
        clearPoleData();
    }
    
    public function createThrowedPhysicalPlayer():Void {
        if ( player != null ) {
            player.space = null;
            player = null;
            if ( leftHandJoint != null && leftHandJoint.active ) {
                leftHandJoint.active = false;
            }
            if ( rightHandJoint != null && rightHandJoint.active ) {
                rightHandJoint.active = false;
            }
        }
        FlxG.log( "" + Lib.getTimer() + " Creating throwed physical player" );
        compound.breakApart();
        player = new Body( BodyType.DYNAMIC );
        player.shapes.add( new Polygon( Polygon.rect( -WIDTH / 2, -HEIGHT / 2, WIDTH, HEIGHT )));
        player.mass = 75;
        player.position.setxy( x + WIDTH / 2, y + HEIGHT / 2 );
        player.space = space;
        player.group = collisionGroup;
        player.userData.playerLane = lane;
        player.userData.type = "player";
        player.cbTypes.add( PlayState.CALLBACK_TYPE_PLAYER_WALL_COLLISION );
        player.cbTypes.add( PlayState.CALLBACK_TYPE_PLAYER_GROUND_COLLISION );
        player.angularVel = Math.random() * 100 - 50;
        var angle:Int = Math.round( 180 - Math.random() * 75 );
        var rotatedVelocityVector:FlxPoint = FlxVelocity.velocityFromAngle( angle, 500 );
        player.velocity.setxy( rotatedVelocityVector.x, -rotatedVelocityVector.y );
        clearPoleData();
    }
    
    public function removeGroundCollisionCallbackType():Void {
        if ( player == null ) {
            return;
        }
        player.cbTypes.remove( PlayState.CALLBACK_TYPE_PLAYER_GROUND_COLLISION );
        disableGroundJoint();
    }
    
    public function removeWallCollisionCallbackType():Void {
        if ( player == null ) {
            return;
        }
        player.cbTypes.remove( PlayState.CALLBACK_TYPE_PLAYER_WALL_COLLISION );
    }
    
    public function disableGroundJoint():Void {
        if ( groundJoint == null ) {
            return;
        }
        groundJoint.active = false;
    }
    
    override public function draw():Void {
        if ( restarted ) {
            return;
        }
        if ( flash.visible ) {
            flash.draw();
        }
        shadow.draw();
        super.draw();
        for ( i in 0...poleFragmentSprites.length ) {
            var fragment:Body = poleFragments[i];
            var fragmentSprite:FlxSprite = poleFragmentSprites[i];
            fragmentSprite.x = 0;
            fragmentSprite.y = 0;
            fragmentSprite.angle = FlxMath.asDegrees( fragment.rotation );
            fragmentSprite.x = fragment.position.x - fragmentSprite.width / 2;
            fragmentSprite.y = fragment.position.y - fragmentSprite.height / 2;
            fragmentSprite.draw();
        }
    }
    
    override private function updateMotion():Void {
        if ( restarted ) {
            return;
        }
        super.updateMotion();
        cameraTarget.x = x + FlxG.width * 0.45;
        cameraTarget.y = y - FlxG.height / 8;
        shadow.x = x;
        shadow.alpha = ( 200 - ( Math.abs( shadow.y ) - Math.abs( y ) ) ) / 200;
        if ( player != null ) {
            if ( player.position.x > PlayState.FENCE_LOCATION_X - lane * PlayState.LANE_X_OFFSET ) {
                cast( FlxG.state, PlayState ).switchFence( lane );
            }
        }
    }
    
    public function readyToRestart():Void {
        if ( currentState == STATE_ELECTROCUTED ) {
            return;
        }
        FlxG.log( "" + Lib.getTimer() + " Changing state to STATE_READY_TO_RESTART" );
        currentState = STATE_READY_TO_RESTART;
    }
    
    private function setJointsMaxForce( timer:FlxTimer ):Void {
        for ( j in 0...poleJoints.length ) {
            var joint:Constraint = poleJoints[j];
            joint.maxForce = 70000;
            joint.breakUnderForce = true;
        }
    }
    
    public function getPoleStress():Float {
        var poleStress:Float = 0;
        for ( i in 0...poleFragments.length ) {
            var fragment:Body = poleFragments[i];
            if ( fragment.constraints.length == 0 ) {
                continue;
            }
            var joint:Constraint = fragment.constraints.at( 0 );
            poleStress += joint.bodyImpulse( fragment ).xy().length;
        }
        return poleStress;
    }
    
    private function debugPoleJointsStressValues():Void {
        var poleStress:Float = getPoleStress();
        if ( poleStress > maxPoleStress ) {
            maxPoleStress = poleStress;
        }
    }
    
    override public function update():Void {
        if ( restarted ) {
            return;
        }
        super.update();
        updateControls();
        if ( restarted ) {
            return;
        }
        if ( player == null ) {
            if ( leftHandJoint != null && leftHandJoint.active ) {
                leftHandJoint.anchor1.setxy( x + leftHandPosition.x, y + leftHandPosition.y );
            }
            if ( rightHandJoint != null && rightHandJoint.active ) {
                rightHandJoint.anchor1.setxy( x + rightHandPosition.x, y + rightHandPosition.y );
            }
            if ( !electrocuted ) {
                if ( velocity.x > 0 ) {
                    play( "run-slow" );
                } else {
                    play( "idle", true );
                }
            }
        }
        else {
            if ( !electrocuted ) {
                play( "idle", true );
            }
            if ( currentState != STATE_ELECTROCUTED ) {
                x = 0;
                y = 0;
                angle = FlxMath.asDegrees( player.rotation );
                x = player.position.x - width / 2;
                y = player.position.y - height / 2;
                if ( currentState == STATE_LOWERING_POLE && player.position.x > groundJoint.anchor1.x + fragmentsTotal * fragmentLength && groundJoint.active ) {
                    disableGroundJoint();
                    if ( leftHandJoint != null && leftHandJoint.active ) {
                        leftHandJoint.active = false;
                    }
                    readyToRestart();
                }
            }
        }
        if ( Math.abs( y - initialHeight ) > maxHeight ) {
            maxHeight = Math.abs( y - initialHeight );
            if ( maxHeight > PlayState.MAX_HEIGHT ) {
                PlayState.MAX_HEIGHT = maxHeight;
            }
        }
        debugPoleJointsStressValues();
    }
    
    public function electrocute():Void {
        electrocuted = true;
        FlxG.play( "zap" );
        play( "electrocuted" );
        velocity.make( 0, 0 );
        acceleration.make( 0, 0 );
        currentState = STATE_ELECTROCUTED;
        if ( leftHandJoint != null && leftHandJoint.active ) {
            leftHandJoint.active = false;
        }
        if ( rightHandJoint != null && rightHandJoint.active ) {
            rightHandJoint.active = false;
        }
        if ( player != null ) {
            player.space = null;
            player = null;
        }
        Actuate.timer( 1.0 ).onComplete( throwAway );
    }
    
    private function throwAway():Void {
        createThrowedPhysicalPlayer();
        currentState = STATE_READY_TO_RESTART;
    }
    
    override public function destroy():Void {
        FlxG.unwatch( this.velocity, "x" );
        FlxG.unwatch( this, "maxHeight" );
        FlxG.unwatch( this, "currentState" );
        FlxG.unwatch( this, "maxPoleStress" );
        flash.destroy();
        flash = null;
        shadow.destroy();
        shadow = null;
        currentState = null;
        compound.breakApart();
        compound.space = null;
        compound = null;
        collisionGroup.group = null;
        collisionGroup = null;
        for ( j in 0...poleJoints.length ) {
            var joint:Constraint = poleJoints[j];
            joint.space = null;
            joint.userData.player = null;
            space.listeners.remove( joint.userData.constraintListener );
            joint.userData.constraintListener = null;
        }
        leftHandJoint.space = null;
        leftHandJoint = null;
        rightHandJoint.space = null;
        rightHandJoint = null;
        groundJoint.space = null;
        groundJoint = null;
        cameraTarget.destroy();
        cameraTarget = null;
        for ( i in 0...poleFragmentSprites.length ) {
            var fragment:Body = poleFragments[i];
            while (!fragment.constraints.empty()) fragment.constraints.at(0).space = null;
            fragment.group = null;
            fragment.space = null;
            var fragmentSprite:FlxSprite = poleFragmentSprites[i];
            fragmentSprite.destroy();
        }
        poleFragments = [];
        poleFragmentSprites = [];
        poleJoints = [];
        if ( player != null ) {
            player.group = null;
            player.space = null;
            player = null;
        }
        space = null;
        super.destroy();
    }
}