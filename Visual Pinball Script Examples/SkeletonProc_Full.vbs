Option Explicit
Randomize
Dim b2sOn:b2sOn = False
Dim B2SController
Const cGameName="SkeletonProc"
Const UseSolenoids = 1

' Standard Sounds
Const SSolenoidOn="Solenoid"
Const SSolenoidOff=""
Const SFlipperOn=""
Const SFlipperOff=""
Const SCoin="Coin"
'Constant switch names
Const swOuthole = 18
Const swTilt = 14
Const swSlamTilt = 21

Dim bsTrough, bsSauce, bump1, bump2, bump3

LoadVPM "WPC.VBS", 3.55
Sub LoadVPM(VBSfile, VBSver)
    On Error Resume Next
    If ScriptEngineMajorVersion<5 Then MsgBox "VB Script Engine 5.0 or higher required"
    ExecuteGlobal GetTextFile(VBSfile)
    If Err Then MsgBox "Unable to open " & VBSfile & ". Ensure that it is in the same folder as this table. " & vbNewLine & Err.Description
    Set Controller=CreateObject("VPROC.Controller")
    If Err Then MsgBox "Can't Load VPROC Controller." & vbNewLine & Err.Description    
    If VPinMAMEDriverVer<VBSver Or Err Then MsgBox VBSFile & " ver " & VBSver & " or higher required."
    On Error Goto 0
  If b2sOn = True Then
    Set B2SController=CreateObject("B2S.Server")
      B2SController.B2SName=("SkeletonProc")
      B2SController.Run
  End If
End Sub

Sub Table1_Init
  With Controller
       .GameName=cGameName
       If Err Then MsgBox "Can't start Game" & cGameName & vbNewLine & Err.Description : Exit Sub
       .SplashInfoLine="Skeleton Proc" & vbNewLine & ""
       .HandleKeyboard=0
       .ShowTitle=0
       .ShowDMDOnly=1
       .ShowFrame=0
       .HandleMechanics=0
       '.Hidden=1
       '.SetDisplayPosition 1600, 1600, GetPlayerHWnd
       On Error Resume Next
       .Run GetPlayerHWnd
       If Err Then MsgBox Err.Description
    End With 
    On Error Goto 0

    vpmCreateEvents AllSwitches
    ' Nudging
    vpmNudge.TiltSwitch=swTilt
    vpmNudge.Sensitivity=3
    vpmNudge.TiltObj=Array(bump1, bump2, bump3, LeftSlingshot, RightSlingshot)
 
  ' Trough
    Set bsTrough=New cvpmBallStack
    bsTrough.InitSw 0,15,16,17,swOuthole,0,0,0
    bsTrough.InitKick BallRelease, 80, 6
    bsTrough.InitEntrySnd "drain", "Solenoid"
    bsTrough.InitExitSnd "ballrel", "Solenoid"
	ScoreText.text= "Trough cnt: " & bsTrough.Balls
    bsTrough.Balls=3

    ' Middle Saucer
     Set bsSauce=New cvpmBallStack
     bsSauce.InitSaucer kicker1, 24, 190, 10
     bsSauce.InitExitSnd "solenoidleft", "Solenoid"
     bsSauce.KickAngleVar=1
     bsSauce.KickForceVar=4
   
  ' Main Timer init
      PinMAMETimer.Interval=PinMAMEInterval
      PinMAMETimer.Enabled=1
      'Leds.Enabled=1
	
End Sub

Sub Table1_Paused:Controller.Pause=True:End Sub
Sub Table1_unPaused:Controller.Pause=False:End Sub
Sub Table1_Exit:Controller.Stop:End Sub

'Add the drain to a timer of 300ms, just works better this way
Sub Drain_Hit()
	Drain.TimerEnabled=True
End Sub

Sub Drain_Timer
	Drain.TimerEnabled=False
	bsTrough.AddBall Me
	Playsound "drainhit"	
End Sub

Sub BallReleaseGate_Hit
	ScoreText.text= "Trough cnt: " & bsTrough.Balls
End Sub

' Mode Kicker
SUb kicker1_Hit
    bsSauce.AddBall 0
End Sub

'**********
' Keys
'**********
 Sub Table1_KeyDown(ByVal Keycode)
  If keycode = PlungerKey Then Plunger.Pullback
  If keycode=RightFlipperKey Then Controller.Switch(11)=1:Exit Sub:End If
  If keycode=LeftFlipperKey Then Controller.Switch(12)=1:Exit Sub:End If
  ' start button
  If KeyName(KeyCode)="1" Then Controller.Switch(13)=1
  If keycode = LeftTiltKey Then Nudge 90, 10
  If keycode = RightTiltKey Then Nudge 270, 10
  If keycode = CenterTiltKey Then Nudge 0, 10

  If vpmKeyDown(keycode) Then Exit Sub
 End Sub

 Sub Table1_KeyUp(ByVal Keycode)
    If keycode = PlungerKey Then Plunger.Fire
    If keycode=RightFlipperKey Then Controller.Switch(11)=0:Exit Sub:End If
    If keycode=LeftFlipperKey Then Controller.Switch(12)=0:Exit Sub:End If
  ' start button
  If KeyName(KeyCode)="1" Then Controller.Switch(13)=0

    If vpmKeyUp(keycode) Then Exit Sub
 End Sub
'******************************
' LAMPS & GI
'******************************
Const UseLamps     = True
vpmMapLights AllLamps
Set LampCallback    = GetRef("UpdateMultipleLamps")
Sub UpdateMultipleLamps : End Sub
Set GICallback    = GetRef("UpdateGI")
Sub UpdateGI(giNo, stat)
  Select Case giNo
    Case 0 GI_low(abs(stat))
    Case 1 GI_up(abs(stat))
    Case 2 GI_mid(abs(stat))
  End Select
End Sub

'Control of GI instensitys
Dim slider, xx
slider = (100 - Table1.nightday)/2
for each xx in GILow: xx.intensity = xx.intensity + slider: next
for each xx in GIMid: xx.intensity = xx.intensity + slider: next
for each xx in GITop: xx.intensity = xx.intensity + slider: next

Sub SolGI(enabled)
End Sub

Dim lamp
Sub GI_low(enabled)
     For each lamp in GILow
    lamp.State= enabled
   Next
End Sub

Sub GI_up(enabled)
    For each lamp in GITop
    lamp.State=enabled
   Next
End Sub

Sub GI_mid(enabled)
     For each lamp in GIMid
    lamp.State=enabled
   Next
End Sub
'*********
' Switches
'*********
'**********Sling Shot Animations
' Rstep and Lstep  are the variables that increment the animation
'****************
Dim RStep, Lstep
Sub RightSlingShot_Slingshot
    vpmTimer.PulseSw 46
    PlaySound "slingshotright", 0, 1, 0.05, 0.05
    RSling.Visible = 0
    RSling1.Visible = 1
    sling1.TransZ = -20
    RStep = 0
    RightSlingShot.TimerEnabled = 1
End Sub
Sub RightSlingShot_Timer
    Select Case RStep
        Case 3:RSLing1.Visible = 0:RSLing2.Visible = 1:sling1.TransZ = -10
        Case 4:RSLing2.Visible = 0:RSLing.Visible = 1:sling1.TransZ = 0:RightSlingShot.TimerEnabled = 0
    End Select
    RStep = RStep + 1
End Sub
Sub LeftSlingShot_Slingshot
    vpmTimer.PulseSw 47
    PlaySound "slingshotright",0,1,-0.05,0.05
    LSling.Visible = 0
    LSling1.Visible = 1
    sling2.TransZ = -20
    LStep = 0
    LeftSlingShot.TimerEnabled = 1
End Sub
Sub LeftSlingShot_Timer
    Select Case LStep
        Case 3:LSLing1.Visible = 0:LSLing2.Visible = 1:sling2.TransZ = -10
        Case 4:LSLing2.Visible = 0:LSLing.Visible = 1:sling2.TransZ = 0:LeftSlingShot.TimerEnabled = 0
    End Select
    LStep = LStep + 1
End Sub


 '*********
 'Solenoids Callback
 '*********
 SolCallback(sLRFlipper)="SolFlipper RightFlipper,Nothing,"
 SolCallback(sLLFlipper)="SolFlipper LeftFlipper,Nothing,"
 SolCallback(1)="bsSauce.SolOut"
 'SolCallback(2)="bsTrough.SolOut"
 SolCallback(3)="bsTrough.SolIn"
 SolCallback(4)="bsTrough.SolOut"

 
' *********************************************************************
'                      Supporting Ball & Sound Functions
' *********************************************************************

Function Vol(ball) ' Calculates the Volume of the sound based on the ball speed
    Vol = Csng(BallVel(ball) ^2 / 200)
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
        If BallVel(BOT(b) ) > 1 AND BOT(b).z < 130 Then
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
' If you look at the parameters of both cycles, youll notice they are designed to avoid checking 
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

Sub RampLeftEnd_Hit
  PlaySound "ball drop ramp"
End Sub

Sub RampRightEnd_Hit
  PlaySound "ball drop ramp"
End Sub

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
  PlaySound "gate", 0, Vol(ActiveBall), Pan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
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