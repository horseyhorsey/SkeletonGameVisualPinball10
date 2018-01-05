####
## Example of a blank mode

import procgame.game
from procgame.game import AdvancedMode

import pygame
from pygame.locals import *
from pygame.font import *

class ExBlankMode(procgame.game.AdvancedMode):
  """
  Example Mode
  """
  def __init__(self, game):
    super(ExBlankMode, self).__init__(game=game, priority=2, mode_type=AdvancedMode.Game) # 2 is higher than BGM
    # stuff that gets done EXACTLY once.
    # happens when the "parent" Game creates this mode
    pass
  
  def mode_started(self):
    print("My mode started")
    #self.game.displayText("hit the flashing target for bonus")
  
  def mode_stopped(self): 
    print("My mode ended")
    # do cleanup of the mode here. 



