package pl.vigeo.polevaultage;

import nape.space.Space;

import nme.Lib;

import org.flixel.FlxSprite;
import org.flixel.FlxState;

/**
 * @author Adrian K. <goshki@gmail.com>
 */
class Pole extends FlxSprite {
    private var player:Player;
    private var state:FlxState;
    private var space:Space;
    
    public function new( player:Player, state:FlxState, space:Space ) {
		super();
        this.player = player;
        this.state = state;
        this.space = space;
    }
}