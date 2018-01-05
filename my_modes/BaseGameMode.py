import procgame.game
from procgame.game import AdvancedMode
import logging

class BaseGameMode(procgame.game.AdvancedMode):
	"""
	A mode that runs whenever the GAME is in progress.
	(notice the super() function call specifies type .Game)
	- it is automatically added when a game starts
		(mode_started will be called once per game)
	- it is automatically removed when a game ends
		(mode_stopped will be called once per game)

	NOTE: a second player does not cause a second game
		(confusing, no doubt).  When a new player is
		added, an evt_player_added will fire.  When
		a new ball starts, that's a good time to ensure
		our data comes from that player and sync up
		lamps via a call to update_lamps.  Read on...
	"""

	def __init__(self, game):
		""" 
		The __init__ function is called automatically whenever an instance 
		of this object is created --e.g., whenever the code:
				something = new BaseGameMode() 
		is executed, this __init__ function is called
		"""

		# a call to 'super' call's the parent object's __init__ method
		# in this case, it calls the procgame.game.Mode's init()
		super(BaseGameMode, self).__init__(game=game, priority=5, mode_type=AdvancedMode.Game)

		# You might be used to storing data, right in the mode, like as follows:
		# self.multiplier = 0
		# self.standupSwitchL = False
		# self.standupSwitchC = False
		# self.standupSwitchR = False
		# self.idle_balls = 0
		# self.leftTargets = [False, False, False, False, False]
		# self.kickbackEnabled = False
		# but these are properties of the PLAYER not the mode, so we
		# store them there, instead, when the player is added to the game!

	def evt_player_added(self, player):
		player.setState('leftTargets', [False, False, False])
		player.setState('rightTargets', [False, False, False])
		player.setState('topLanes',[False,False,False,False])
		player.setState('LRibCount',0)
		player.setState('RRibCount',0)


	def evt_ball_starting(self):
		self.game.sound.fadeout_music()
		self.game.sound.play_music('base-music-bgm',-1)

	def sw_shooter_inactive_for_250ms(self, sw):
		# ball saver syntax has changed.  We no longer need to supply a callback
		# method instead, evt_ball_saved() will be called if a ball is saved.
		# to enable it, use this 
		# (defaults are 1 ball, save time length is based on service mode setting)

		self.game.enable_ball_saver()		

	def evt_ball_saved(self):
		""" this event is fired to notify us that a ball has been saved
		"""
		self.game.log("BaseGameMode: BALL SAVED from Trough callback")
		self.game.sound.play('ball_saved')
		self.game.displayText('Ball Saved!')		
		# Do NOT tell the trough to launch balls!  It's handled automatically!
		# self.game.trough.launch_balls(1)

	def mode_started(self):
		"""
		the mode_started method is called whenever this mode is added
		to the mode queue; this might happen multiple times per game,
		depending on how the Game itself adds/removes it.  B/C this is 
		an advancedMode, we know when it will be added/removed.
		"""
		pass

	def mode_stopped(self): 
		"""
		the mode_stopped method is called whenever this mode is removed
		from the mode queue; this might happen multiple times per game,
		depending on how the Game itself adds/removes it
		"""
		pass

	def update_lamps(self):
		""" 
		update_lamps is a very important method -- you use it to set the lamps
		to reflect the current state of the internal mode progress variables.
		This function is called after a lampshow is played so that the state
		variables are correct after the lampshow is done.  It's also used other
		times.

		Notice that progress is stored in the player object, so check with:
			self.game.getPlayerState(key)
		which is a wrapper around:
			self.game.get_current_player().getState(key)
		"""

	""" The following are the event handlers for events broadcast by SkeletonGame.  
		handling these events lets your mode give custom feedback to the player
		(lamps, dmd, sound, etc)
	"""
	pass

	def evt_ball_ending(self, (shoot_again, last_ball)):
		""" this is the handler for the evt_ball_ending event.  It shows    
			the player information about the specific event.  You can optionally
			return a number, which is the number of seconds that you are requesting
			to delay the commitment of the event.  For example, if I wanted to show
			a message for 5 seconds before the ball actually ended (and bonus mode
			began), I would return 5.  Returning 0 (or None) would indicate no delay.
		"""
		self.game.log("base game mode trough changed notification ('ball_ending - again=%s, last=%s')" % (shoot_again,last_ball))
		self.layer = self.game.animations['SkeleEnd']
		self.game.animations['SkeleEnd'].reset()
		# stop any music as appropriate
		# self.game.sound.fadeout_music()
		self.game.sound.play('ball_drain')
		self.game.sound.play_music('endBall')		
		#self.game.displayText('BGM Ball Ended!')
		return 1.0

	def evt_game_ending(self):
		self.game.log("base game mode game changed notification ('game_ending')")

		self.game.displayText("GAME ENDED", 'gameover')

		# Do NOT call game_ended any more!!!!!
		# not now or later!

		return 2


	"""
	this is an example of a timed switch handler
		 sw_      : indicates a switch handler
		 outhole  : the name of the switch
		 active   : the state (could be inactive, open, closed)
		 for_200ms: how long that the switch must be detected
								in this state before this handler is called

	in this case, if the controller sees this switch closed
	for 200ms, then this function is called; waiting 200ms
	will wait for long enough for the ball to settle in the
	slot before responding
	"""
	def sw_outhole_active(self,sw):
		self.game.coils.outhole.pulse()

	def sw_outlaneL_active(self, sw):
		return procgame.game.SwitchContinue    

	def sw_slingL_active(self, sw):
		self.game.score(100)
		self.game.sound.play('sling')
		return procgame.game.SwitchContinue

	def sw_slingR_active(self, sw):
		self.game.score(100)
		self.game.sound.play('sling')
		return procgame.game.SwitchContinue

	def sw_bumperOne_active(self,sw):
		self.game.score(443)
		return procgame.game.SwitchStop

	def sw_bumper2_active(self,sw):
		self.game.score(443)
		return procgame.game.SwitchStop

	def sw_bumper3_active(self,sw):
		self.game.score(443)
		return procgame.game.SwitchStop

	def sw_bumper4_active(self,sw):
		self.game.score(443)
		return procgame.game.SwitchStop

	def sw_bumper5_active(self,sw):
		self.game.score(443)
		return procgame.game.SwitchStop