package;

import org.flixel.FlxG;

/**
 * @author Adrian K. <goshki@gmail.com>
 */
class TimeUtil {
    public static function timecodeToSeconds( timecode:String ):Int {
        var timecodeFragments:Array<String> = timecode.split( ":" );
        return Std.parseInt( timecodeFragments[0] ) * 3600 + Std.parseInt( timecodeFragments[1] ) * 60 + Std.parseInt( timecodeFragments[2] );
    }
    
    public static function floatSecondsToTimecode( seconds:Float ):String {
        var milliseconds:String = StringTools.rpad( "" + Math.floor( ( seconds - Math.floor( seconds ) ) * 1000 ), "0", 3 ).substring( 0, 3 );
        return secondsToTimecode( Math.floor( seconds ) ) + "." + milliseconds;
    }

    public static function secondsToTimecode( seconds:Int ):String {
        var minutes:Int = Math.floor( seconds / 60 );
        var remainingSeconds:Int = seconds % 60;
        var remainingMinutes:Int = minutes % 60;
        var hours:Int = Math.floor( minutes / 60 );
        var floatSeconds:Int = Math.floor( ( remainingSeconds - Math.floor( remainingSeconds ) ) * 100 );
        remainingSeconds = Math.floor( remainingSeconds );
        if ( getTwoDigits( hours ) == "00" ) {
            return getTwoDigits( remainingMinutes ) + ":" + getTwoDigits( remainingSeconds );
        }
        return getTwoDigits( hours ) + ":" + getTwoDigits( remainingMinutes ) + ":" + getTwoDigits( remainingSeconds );
    }

    private static function getTwoDigits( number:Int ):String {
        if ( number < 10 ) {
            return "0" + number;
        }
        return "" + number;
    }
}