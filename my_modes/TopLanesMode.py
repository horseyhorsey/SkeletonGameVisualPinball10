####
## Example of a blank mode

import procgame.game
from procgame.game import AdvancedMode

import pygame
from pygame.locals import *
from pygame.font import *

class TopLanesMode(procgame.game.AdvancedMode):
  """
  Example Mode
  """
  def __init__(self, game):
    super(TopLanesMode, self).__init__(game=game, priority=3, mode_type=AdvancedMode.Game) # 2 is higher than BGM
    # stuff that gets done EXACTLY once.
    # happens when the "parent" Game creates this mode
    pass
  
  def mode_started(self):
    print("My mode started")
    #self.game.displayText("hit the flashing target for bonus")
  
  def mode_stopped(self): 
    print("My mode ended")
    # do cleanup of the mode here. 

  def sw_TopLane1_active(self,sw):
	return self.TopLaneHelper(0)

  def sw_TopLane2_active(self,sw):
	return self.TopLaneHelper(1)

  def sw_TopLane3_active(self,sw):
	return self.TopLaneHelper(2)

  def sw_TopLane4_active(self,sw):
	return self.TopLaneHelper(3)

  def TopLaneHelper(self, targetNum):
		vals = self.game.getPlayerState('topLanes')
		vals[targetNum] = True
		if(False in vals):
			self.game.setPlayerState('topLanes',vals)
			self.game.score(5000)			
			self.game.sound.play('target')
		else:
			self.game.setPlayerState('topLanes',vals)            
			self.game.score(25000)
			self.game.sound.play('target_bank')
			self.game.displayText("TOP LANES COMPLETE!", 'explosion')
			self.game.setPlayerState('topLanes',[False]*4)

		self.update_lamps()
		
		return procgame.game.SwitchContinue 

  def update_lamps(self):
		topLaneStates = self.game.getPlayerState('topLanes')

		for lane,lamp in zip(topLaneStates,self.game.toplanes):
			if(lane):
				lamp.enable()
			else:
				lamp.disable()


