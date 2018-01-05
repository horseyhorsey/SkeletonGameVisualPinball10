####
## Example of a blank mode

import procgame.game
from procgame.game import AdvancedMode

import pygame
from pygame.locals import *
from pygame.font import *

class MultiBallMode(procgame.game.AdvancedMode):
  """
  This mode is always running. To get more balls hit the center saucer
  """
  def __init__(self, game):
    super(MultiBallMode, self).__init__(game=game, priority=5, mode_type=AdvancedMode.Game) # 2 is higher than BGM
    # stuff that gets done EXACTLY once.
    # happens when the "parent" Game creates this mode
    pass
  
  def mode_started(self):
    print("My mode started")
    #self.game.displayText("hit the flashing target for bonus")
  
  def mode_stopped(self): 
    print("My mode ended")
    # do cleanup of the mode here. 

#Eject a ball from the trough is the center saucer is made
#If max balls on playfield then just kick it back
  def sw_saucer_active(self, sw):
	if not self.game.trough.num_balls() ==0:
		self.game.coils.trough.pulse()
	else:
		self.game.coils.saucer.pulse()

#Kick the ball from the saucer when the entry gate is hit
#Add different music depending how many balls is play
  def sw_RGate_active(self,sw):
	if self.game.switches.saucer.is_active():
		#Kick ball from saucer
		self.game.coils.saucer.pulse()		

		#TextLayer.set_text("Multiball")
		if self.game.trough.num_balls()==1:
			self.game.sound.play_music('TwoBall',-1)
			self.game.displayText("TwoBall",'SkeleMulti',None,None,False,1.5,True)			
		elif self.game.trough.num_balls()==0:
			self.game.sound.play_music('ThreeBall',-1)
			self.game.displayText("ThreeBall",'SkeleMulti',None,None,False,1.5,True)



