If Table1.ShowDT = false then
    Scoretext.Visible = false
End If

Sub Table1_KeyDown(ByVal keycode)

	If keycode = PlungerKey Then
		Plunger.PullBack
		PlaySound "plungerpull",0,1,0.25,0.25
	End If

	If keycode = LeftFlipperKey Then
		LeftFlipper.RotateToEnd
		PlaySound "fx_flipperup", 0, .67, -0.05, 0.05
	End If
    
	If keycode = RightFlipperKey Then
		RightFlipper.RotateToEnd
		PlaySound "fx_flipperup", 0, .67, 0.05, 0.05
	End If
    
	If keycode = LeftTiltKey Then
		Nudge 90, 2
	End If
    
	If keycode = RightTiltKey Then
		Nudge 270, 2
	End If
    
	If keycode = CenterTiltKey Then
		Nudge 0, 2
	End If
    
End Sub

Sub Table1_KeyUp(ByVal keycode)

	If keycode = PlungerKey Then
		Plunger.Fire
		PlaySound "plunger",0,1,0.25,0.25
	End If
    
	If keycode = LeftFlipperKey Then
		LeftFlipper.RotateToStart
		PlaySound "fx_flipperdown", 0, 1, -0.05, 0.05
	End If
    
	If keycode = RightFlipperKey Then
		RightFlipper.RotateToStart
		PlaySound "fx_flipperdown", 0, 1, 0.05, 0.05
	End If

End Sub

Sub Drain_Hit()
	PlaySound "drain",0,1,0,0.25
	Drain.DestroyBall
	BIP = BIP - 1
	If BIP = 0 then
		'Plunger.CreateBall
		BallRelease.CreateBall
		BallRelease.Kick 90, 8
		PlaySound "ballrelease",0,1,0,0.25
		BIP = BIP + 1
	End If
End Sub

Dim BIP
BIP = 0

Sub Plunger_Init()
	PlaySound "ballrelease",0,0.5,0.5,0.25
	'Plunger.CreateBall
	BallRelease.CreateBall
	BallRelease.Kick 90, 8
	BIP = BIP +1
End Sub

Sub Gate_Hit
	Kicker1.Kick 190, 10
End Sub

Sub Bumper1_Hit
	PlaySound "fx_bumper4"
	B1L1.State = 1:B1L2. State = 1
	Me.TimerEnabled = 1
End Sub

Sub Bumper1_Timer
	B1L1.State = 0:B1L2. State = 0
	Me.Timerenabled = 0
End Sub

Sub Bumper2_Hit
	PlaySound "fx_bumper4"
	B2L1.State = 1:B2L2. State = 1
	Me.TimerEnabled = 1
End Sub

Sub Bumper2_Timer
	B2L1.State = 0:B2L2. State = 0
	Me.Timerenabled = 0
End Sub	

Sub Bumper3_Hit
	PlaySound "fx_bumper4"
	B3L1.State = 1:B3L2. State = 1
	Me.TimerEnabled = 1
End Sub

Sub Bumper3_Timer
	B3L1.State = 0:B3L2. State = 0
	Me.Timerenabled = 0
End Sub

Sub Bumper4_Hit
	PlaySound "fx_bumper4"
	B4L1.State = 1:B4L2. State = 1
	Me.TimerEnabled = 1
End Sub

Sub Bumper4_Timer
	B4L1.State = 0:B4L2. State = 0
	Me.Timerenabled = 0
End Sub

Sub Bumper5_Hit
	PlaySound "fx_bumper4"
	B5L1.State = 1:B5L2. State = 1
	Me.TimerEnabled = 1
End Sub

Sub Bumper5_Timer
	B5L1.State = 0:B5L2. State = 0
	Me.Timerenabled = 0
End Sub

Sub sw9_Hit
	If L9.State = 1 then 
		L9.State  = 0
	else 
		L9.State = 1
	end if
End Sub

Sub sw8_Hit
	If L8.State = 1 then 
		L8.State  = 0
	else 
		L8.State = 1
	end if
End Sub

Sub sw7_Hit
	If L7.State = 1 then 
		L7.State  = 0
	else 
		L7.State = 1
	end if
End Sub

Sub sw6_Hit
	If L6.State = 1 then 
		L6.State  = 0
	else 
		L6.State = 1
	end if
End Sub


'****Targets
Sub sw1_Hit
	If L1.State = 1 then 
		L1.State  = 0
	else 
		L1.State = 1
	end if
	sw1p.transx = -10
	Me.TimerEnabled = 1
End Sub

Sub sw1_Timer
	sw1p.transx = 0
	Me.TimerEnabled = 0
End Sub

Sub sw2_Hit
	If L2.State = 1 then 
		L2.State  = 0
	else 
		L2.State = 1
	end if
	sw2p.transx = -10
	Me.TimerEnabled = 1
End Sub

Sub sw2_Timer
	sw2p.transx = 0
	Me.TimerEnabled = 0
End Sub

Sub sw3_Hit
	If L3.State = 1 then 
		L3.State  = 0
	else 
		L3.State = 1
	end if
	sw3p.transx = -10
	Me.TimerEnabled = 1
End Sub

Sub sw3_Timer
	sw3p.transx = 0
	Me.TimerEnabled = 0
End Sub

Sub sw11_Hit
	If L11.State = 1 then 
		L11.State  = 0
	else 
		L11.State = 1
	end if
	sw11p.transx = -10
	Me.TimerEnabled = 1
End Sub

Sub sw11_Timer
	sw11p.transx = 0
	Me.TimerEnabled = 0
End Sub

Sub sw12_Hit
	If L12.State = 1 then 
		L12.State  = 0
	else 
		L12.State = 1
	end if
	sw12p.transx = -10
	Me.TimerEnabled = 1
End Sub

Sub sw12_Timer
	sw12p.transx = 0
	Me.TimerEnabled = 0
End Sub

Sub sw13_Hit
	If L13.State = 1 then 
		L13.State  = 0
	else 
		L13.State = 1
	end if
	sw13p.transx = -10
	Me.TimerEnabled = 1
End Sub

Sub sw13_Timer
	sw13p.transx = 0
	Me.TimerEnabled = 0
End Sub


Sub Kicker1_Hit
	PlaySound "kicker_enter_center", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
	'Plunger.CreateBall
	PlaySound "ballrelease",0,0.5,0.5,0.25
	BallRelease.CreateBall
	BallRelease.Kick 90, 8
	BIP = BIP +1
End Sub

Sub Kicker1_UnHit
	PlaySound "popper_ball",0,.75,0,0.25
End Sub

'*****GI Lights On
dim xx

For each xx in GI:xx.State = 1: Next

'**********Sling Shot Animations
' Rstep and Lstep  are the variables that increment the animation
'****************
Dim RStep, Lstep

Sub RightSlingShot_Slingshot
    PlaySound "left_slingshot", 0, 1, 0.05, 0.05
    RSling.Visible = 0
    RSling1.Visible = 1
    sling1.TransZ = -20
    RStep = 0
    RightSlingShot.TimerEnabled = 1
	gi1.State = 0:Gi2.State = 0
End Sub

Sub RightSlingShot_Timer
    Select Case RStep
        Case 3:RSLing1.Visible = 0:RSLing2.Visible = 1:sling1.TransZ = -10
        Case 4:RSLing2.Visible = 0:RSLing.Visible = 1:sling1.TransZ = 0:RightSlingShot.TimerEnabled = 0:gi1.State = 1:Gi2.State = 1
    End Select
    RStep = RStep + 1
End Sub

Sub LeftSlingShot_Slingshot
    PlaySound "right_slingshot",0,1,-0.05,0.05
    LSling.Visible = 0
    LSling1.Visible = 1
    sling2.TransZ = -20
    LStep = 0
    LeftSlingShot.TimerEnabled = 1
	gi3.State = 0:Gi4.State = 0
End Sub

Sub LeftSlingShot_Timer
    Select Case LStep
        Case 3:LSLing1.Visible = 0:LSLing2.Visible = 1:sling2.TransZ = -10
        Case 4:LSLing2.Visible = 0:LSLing.Visible = 1:sling2.TransZ = 0:LeftSlingShot.TimerEnabled = 0:gi3.State = 1:Gi4.State = 1
    End Select
    LStep = LStep + 1
End Sub



' *********************************************************************
'                      Supporting Ball & Sound Functions
' *********************************************************************

Function Vol(ball) ' Calculates the Volume of the sound based on the ball speed
    Vol = Csng(BallVel(ball) ^2 / 2000)
End Function

Function Vol2(ball1, ball2) ' Calculates the Volume of the sound based on the speed of two balls
    Vol2 = (Vol(ball1) + Vol(ball2) ) / 2
End Function

Function Pan(ball) ' Calculates the pan for a ball based on the X position on the table. "table1" is the name of the table
    Dim tmp
    tmp = ball.x * 2 / table1.width-1
    If tmp> 0 Then
        Pan = Csng(tmp ^10)
    Else
        Pan = Csng(-((- tmp) ^10) )
    End If
End Function

Function Pitch(ball) ' Calculates the pitch of the sound based on the ball speed
    Pitch = BallVel(ball) * 20
End Function

Function BallVel(ball) 'Calculates the ball speed
    BallVel = INT(SQR((ball.VelX ^2) + (ball.VelY ^2) ) )
End Function

'*****************************************
'    JP's VP10 Collision & Rolling Sounds
'*****************************************

Const tnob = 8 ' total number of balls
ReDim rolling(tnob)
ReDim collision(tnob)
Initcollision

Sub Initcollision
    Dim i
    For i = 0 to tnob
        collision(i) = -1
        rolling(i) = False
    Next
End Sub

Sub CollisionTimer_Timer()
    Dim BOT, B, B1, B2, dx, dy, dz, distance, radii
    BOT = GetBalls

    ' rolling
	
	For B = UBound(BOT) +1 to tnob
        rolling(b) = False
        StopSound("fx_ballrolling" & b)
	Next

    If UBound(BOT) = -1 Then Exit Sub

    For B = 0 to UBound(BOT)
        If BallVel(BOT(b) ) > 1 AND BOT(b).z < 30 Then
            rolling(b) = True
            PlaySound("fx_ballrolling" & b), -1, Vol(BOT(b) ), Pan(BOT(b) ), 0, Pitch(BOT(b) ), 1, 0
        Else
            If rolling(b) = True Then
                StopSound("fx_ballrolling" & b)
                rolling(b) = False
            End If
        End If
    Next

    'collision

    If UBound(BOT) < 1 Then Exit Sub

    For B1 = 0 to UBound(BOT)
        For B2 = B1 + 1 to UBound(BOT)
            dz = INT(ABS((BOT(b1).z - BOT(b2).z) ) )
            radii = BOT(b1).radius + BOT(b2).radius
			If dz <= radii Then

            dx = INT(ABS((BOT(b1).x - BOT(b2).x) ) )
            dy = INT(ABS((BOT(b1).y - BOT(b2).y) ) )
            distance = INT(SQR(dx ^2 + dy ^2) )

            If distance <= radii AND (collision(b1) = -1 OR collision(b2) = -1) Then
                collision(b1) = b2
                collision(b2) = b1
                PlaySound("fx_collide"), 0, Vol2(BOT(b1), BOT(b2)), Pan(BOT(b1)), 0, Pitch(BOT(b1)), 0, 0
            Else
                If distance > (radii + 10)  Then
                    If collision(b1) = b2 Then collision(b1) = -1
                    If collision(b2) = b1 Then collision(b2) = -1
                End If
            End If
			End If
        Next
    Next
End Sub


'************************************
' What you need to add to your table
'************************************

' a timer called CollisionTimer. With a fast interval, like from 1 to 10
' one collision sound, in this script is called fx_collide
' as many sound files as max number of balls, with names ending with 0, 1, 2, 3, etc
' for ex. as used in this script: fx_ballrolling0, fx_ballrolling1, fx_ballrolling2, fx_ballrolling3, etc


'******************************************
' Explanation of the rolling sound routine
'******************************************

' sounds are played based on the ball speed and position

' the routine checks first for deleted balls and stops the rolling sound.

' The For loop goes through all the balls on the table and checks for the ball speed and 
' if the ball is on the table (height lower than 30) then then it plays the sound
' otherwise the sound is stopped, like when the ball has stopped or is on a ramp or flying.

' The sound is played using the VOL, PAN and PITCH functions, so the volume and pitch of the sound
' will change according to the ball speed, and the PAN function will change the stereo position according
' to the position of the ball on the table.


'**************************************
' Explanation of the collision routine
'**************************************

' The Double For loop: This is a double cycle used to check the collision between a ball and the other ones.
' If you look at the parameters of both cycles, you’ll notice they are designed to avoid checking 
' collision twice. For example, I will never check collision between ball 2 and ball 1, 
' because I already checked collision between ball 1 and 2. So, if we have 4 balls, 
' the collision checks will be: ball 1 with 2, 1 with 3, 1 with 4, 2 with 3, 2 with 4 and 3 with 4.

' Sum first the radius of both balls, and if the height between them is higher then do not calculate anything more,
' since the balls are on different heights so they can't collide.

' The next 3 lines calculates distance between xth and yth balls with the Pytagorean theorem,

' The first "If": Checking if the distance between the two balls is less than the sum of the radius of both balls, 
' and both balls are not already colliding.

' Why are we checking if balls are already in collision? 
' Because we do not want the sound repeting when two balls are resting closed to each other.

' Set the collision property of both balls to True, and we assign the number of the ball colliding

' Play the collide sound of your choice using the VOL, PAN and PITCH functions

' Last lines: If the distance between 2 balls is more than the radius of a ball,
' then there is no collision and then set the collision property of the ball to False (-1).


Sub Pins_Hit (idx)
	PlaySound "pinhit_low", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0
End Sub

Sub Targets_Hit (idx)
	PlaySound "target", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0
End Sub

Sub Metals_Thin_Hit (idx)
	PlaySound "metalhit_thin", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
End Sub

Sub Metals_Medium_Hit (idx)
	PlaySound "metalhit_medium", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
End Sub

Sub Metals2_Hit (idx)
	PlaySound "metalhit2", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
End Sub

Sub Gates_Hit (idx)
	PlaySound "gate4", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
End Sub

Sub Spinner_Spin
	PlaySound "fx_spinner",0,.25,0,0.25
End Sub

Sub Rubbers_Hit(idx)
 	dim finalspeed
  	finalspeed=SQR(activeball.velx * activeball.velx + activeball.vely * activeball.vely)
 	If finalspeed > 20 then 
		PlaySound "fx_rubber2", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
	End if
	If finalspeed >= 6 AND finalspeed <= 20 then
 		RandomSoundRubber()
 	End If
End Sub

Sub Posts_Hit(idx)
 	dim finalspeed
  	finalspeed=SQR(activeball.velx * activeball.velx + activeball.vely * activeball.vely)
 	If finalspeed > 16 then 
		PlaySound "fx_rubber2", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
	End if
	If finalspeed >= 6 AND finalspeed <= 16 then
 		RandomSoundRubber()
 	End If
End Sub

Sub RandomSoundRubber()
	Select Case Int(Rnd*3)+1
		Case 1 : PlaySound "rubber_hit_1", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
		Case 2 : PlaySound "rubber_hit_2", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
		Case 3 : PlaySound "rubber_hit_3", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
	End Select
End Sub

Sub LeftFlipper_Collide(parm)
 	RandomSoundFlipper()
End Sub

Sub RightFlipper_Collide(parm)
 	RandomSoundFlipper()
End Sub

Sub RandomSoundFlipper()
	Select Case Int(Rnd*3)+1
		Case 1 : PlaySound "flip_hit_1", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
		Case 2 : PlaySound "flip_hit_2", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
		Case 3 : PlaySound "flip_hit_3", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
	End Select
End Sub
