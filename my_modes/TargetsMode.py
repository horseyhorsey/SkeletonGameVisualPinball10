import procgame.game
from procgame.game import AdvancedMode

import pygame
from pygame.locals import *
from pygame.font import *

class TargetsMode(procgame.game.AdvancedMode):
	"""
	Hit left and right targets to complete banks.
	Using the sample games target helper because it's a very nice way + being lazy. :)
	"""
	def __init__(self, game):
		super(TargetsMode, self).__init__(game=game, priority=3, mode_type=AdvancedMode.Game) # 2 is higher than BGM
		# stuff that gets done EXACTLY once.
		# happens when the "parent" Game creates this mode
		pass
	
	def mode_started(self):
		pass
	
	def mode_stopped(self): 
		pass

	def sw_Ltarget1_active(self, sw):
		return self.leftTargetHitHelper(0)        

	def sw_Ltarget2_active(self, sw):
		return self.leftTargetHitHelper(1)        

	def sw_Ltarget3_active(self, sw):
		return self.leftTargetHitHelper(2)

	def leftTargetHitHelper(self, targetNum):
		vals = self.game.getPlayerState('leftTargets')
		vals[targetNum] = True
		if(False in vals):
			self.game.setPlayerState('leftTargets',vals)
			self.game.score(5000)
			self.update_lamps()
			self.game.sound.play('target')
		else:
			self.game.setPlayerState('leftTargets',vals)            
			self.game.score(50000)
			self.game.sound.play('target_bank')
			self.game.displayText("LEFT TARGETS COMPLETE!", 'explosion')
			self.game.setPlayerState('leftTargets',[False]*3)
			self.update_lamps()
		return procgame.game.SwitchContinue    

	def sw_Rtarget1_active(self, sw):
		return self.rightTargetHitHelper(0)        

	def sw_Rtarget2_active(self, sw):
		return self.rightTargetHitHelper(1)        

	def sw_Rtarget3_active(self, sw):
		return self.rightTargetHitHelper(2)

	def rightTargetHitHelper(self, targetNum):
		vals = self.game.getPlayerState('rightTargets')
		vals[targetNum] = True
		if(False in vals):
			self.game.setPlayerState('rightTargets',vals)
			self.game.score(5000)
			self.update_lamps()
			self.game.sound.play('target')
		else:
			self.game.setPlayerState('rightTargets',vals)            
			self.game.score(50000)
			self.game.sound.play('target_bank')
			self.game.displayText("RIGHT TARGETS COMPLETE!", 'explosion')
			self.game.setPlayerState('rightTargets',[False]*3)
			self.update_lamps()
		return procgame.game.SwitchContinue  		

	def update_lamps(self):
		leftTargetStates = self.game.getPlayerState('leftTargets')
		rightTargetStates = self.game.getPlayerState('rightTargets')

		for target,lamp in zip(leftTargetStates,self.game.leftTargetLamps):
			if(target):
				lamp.enable()
			else:
				lamp.disable()

		for target,lamp in zip(rightTargetStates,self.game.rightTargetLamps):
			if(target):
				lamp.enable()
			else:
				lamp.disable() 



