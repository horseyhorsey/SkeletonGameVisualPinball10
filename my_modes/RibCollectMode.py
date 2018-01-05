import procgame.game
from procgame.game import AdvancedMode

import pygame
from pygame.locals import *
from pygame.font import *

class RibCollectMode(procgame.game.AdvancedMode):
	"""
	Class for collecting the ribs.
	Left Gate and the ramp increments each side of the rib lamps.
	When switch is hit it calls sw_LGate or sw_Rampshot. Increments the count into players states.
	Invokes the local update_lamps to.......update the lamps.	
	"""
	def __init__(self, game):
		super(RibCollectMode, self).__init__(game=game, priority=4, mode_type=AdvancedMode.Game) # 2 is higher than BGM
		# stuff that gets done EXACTLY once.
		# happens when the "parent" Game creates this mode
		pass
	
	def mode_started(self):
		pass
	
	def mode_stopped(self): 
		pass

	def sw_LGate_active(self,sw):
		LRibCount = self.game.getPlayerState('LRibCount')
		LRibCount +=1
		if not LRibCount >=8:
			self.game.setPlayerState('LRibCount',LRibCount)
			self.game.displayText(str(LRibCount))
			self.update_lamps()
		
	def sw_RampShot_active(self,sw):
		RRibCount = self.game.getPlayerState('RRibCount')
		RRibCount +=1
		self.layer = self.game.animations['SkeleRamp']
		# Resetting the animations directly after it's called, seems to be fine.
		self.game.animations['SkeleRamp'].reset()
		if not RRibCount >=8:
			self.game.setPlayerState('RRibCount',RRibCount)
			self.game.displayText(str(RRibCount))
			self.update_lamps()

	def update_lamps(self):
		if self.game.getPlayerState('LRibCount')==1:
			self.game.lamps.LRib1.enable()
		if self.game.getPlayerState('LRibCount')==2:
			self.game.lamps.LRib2.enable()   
		if self.game.getPlayerState('LRibCount')==3:
			self.game.lamps.LRib3.enable() 
		if self.game.getPlayerState('LRibCount')==4:
			self.game.lamps.LRib4.enable() 
		if self.game.getPlayerState('LRibCount')==5:
			self.game.lamps.LRib5.enable() 
		if self.game.getPlayerState('LRibCount')==6:
			self.game.lamps.LRib6.enable() 
		if self.game.getPlayerState('LRibCount')==7:
			self.game.lamps.LRib7.enable() 

		if self.game.getPlayerState('RRibCount')==1:
			self.game.lamps.RRib1.enable()
		if self.game.getPlayerState('RRibCount')==2:
			self.game.lamps.RRib2.enable()   
		if self.game.getPlayerState('RRibCount')==3:
			self.game.lamps.RRib3.enable() 
		if self.game.getPlayerState('RRibCount')==4:
			self.game.lamps.RRib4.enable() 
		if self.game.getPlayerState('RRibCount')==5:
			self.game.lamps.RRib5.enable() 
		if self.game.getPlayerState('RRibCount')==6:
			self.game.lamps.RRib6.enable() 
		if self.game.getPlayerState('RRibCount')==7:
			self.game.lamps.RRib7.enable() 



