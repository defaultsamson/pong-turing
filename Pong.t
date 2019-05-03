% TODO
% - Make the balls have the ability to collide with each other
% - Make moving up and down, left and right on the menu screen smoother
% - Add a way to pause the game
 
% Sets up the workspace
setscreen ("graphics:720;480, nobuttonbar, position:center;center, noecho, offscreenonly")
 
% Initializes all the procedures and their parameters
forward proc drawPlayScreen
forward proc drawNumber (x : int, y : int, number : int, anchor : int)
forward proc gameInput
forward proc updateBall (ballID : int)
forward proc resetBall (ballID : int, playerLastHitParam : int)
forward proc drawMenuScreen
forward proc menuInput
forward proc reset
forward proc drawMenuArrows (option : int)
forward proc drawControls (xCon : int, yCon : int)
forward proc drawBall (ballToDraw : int)
forward proc givePoint (playerToGiveTo : int)
forward proc updateAI
 
% Initializes menu constants and variables
const typeface := "Fixedsys"
const numberOfOptions := 5
 
var paddleSpeedOptions : array 1 .. 5 of int
paddleSpeedOptions (1) := 3
paddleSpeedOptions (2) := 6
paddleSpeedOptions (3) := 12
paddleSpeedOptions (4) := 24
paddleSpeedOptions (5) := 60
var paddleSpeedOptionsDefault := 2
var paddleSpeedOptionsSelected := paddleSpeedOptionsDefault
 
var paddlePixelHeightOptions : array 1 .. 6 of int
paddlePixelHeightOptions (1) := 30
paddlePixelHeightOptions (2) := 50
paddlePixelHeightOptions (3) := 80
paddlePixelHeightOptions (4) := 100
paddlePixelHeightOptions (5) := 120
paddlePixelHeightOptions (6) := 200
var paddlePixelHeightOptionsDefault := 3
var paddlePixelHeightOptionsSelected := paddlePixelHeightOptionsDefault
 
var numberOfBalls : array 1 .. 3 of int
numberOfBalls (1) := 1
numberOfBalls (2) := 2
numberOfBalls (3) := 3
var numberOfBallsDefault := 1
var numberOfBallsSelected := numberOfBallsDefault
 
var numberOfPlayers : array 1 .. 4 of int
numberOfPlayers (1) := 1
numberOfPlayers (2) := 2
numberOfPlayers (3) := 3
numberOfPlayers (4) := 4
var numberOfPlayersDefault := 2
var numberOfPlayersSelected := numberOfPlayersDefault
 
% Initializes menu variables
var optionSelected := 1
 
% Initializes game constants
const halfx := floor (maxx / 2)
const halfy := floor (maxy / 2)
const paddleCeiling := maxy - 14
const paddleFloor := 13
const paddleWallLeft := 134
const paddleWallRight := maxx - 134
const ballCeiling := maxy - 13
const ballFloor := 13
const paddlePixelWidth := 10
const halfPaddlePixelWidth := floor (paddlePixelWidth / 2)
const originalBallSpeed := 2
const ballPixelWidth := 10
const halfBallPixelWidth := floor (ballPixelWidth / 2)
var millisecondsBetweenTicks := 15
const ballChangeXDefault := 3
const ballChangeYDefault := 3
 
% Initializes game variables
var paddley : array 1..4 of int
paddley(1) := halfy - floor (paddlePixelHeightOptions (paddlePixelHeightOptionsSelected) / 2)
paddley(2) := halfy - floor (paddlePixelHeightOptions (paddlePixelHeightOptionsSelected) / 2)
paddley(3) := 10
paddley(4) := maxy - 10
 
var paddlex : array 1..4 of int
paddlex(1) := 30
paddlex(2) := maxx - 30
paddlex(3) := halfx - floor (paddlePixelHeightOptions (paddlePixelHeightOptionsSelected) / 2)
paddlex(4) := halfx - floor (paddlePixelHeightOptions (paddlePixelHeightOptionsSelected) / 2)
 
var ballTickCounter : array 1 .. 3 of int
ballTickCounter (1) := 0
ballTickCounter (2) := 0
ballTickCounter (3) := 0
 
var ballx : array 1 .. 3 of int
ballx (1) := 100
ballx (2) := 100
ballx (3) := 100
 
var bally : array 1 .. 3 of int
bally (1) := 200
bally (2) := 200
bally (3) := 200
 
var ballChangeX : array 1 .. 3 of int
ballChangeX (1) := 3
ballChangeX (2) := 3
ballChangeX (3) := 3
 
var ballChangeY : array 1 .. 3 of int
ballChangeY (1) := 3
ballChangeY (2) := 3
ballChangeY (3) := 3
 
var ballSpeed : array 1 .. 3 of int
ballSpeed (1) := 2
ballSpeed (2) := 2
ballSpeed (3) := 2
 
var timeBeforeLaunch : array 1 .. 3 of int
timeBeforeLaunch (1) := floor (2000 / millisecondsBetweenTicks)
timeBeforeLaunch (2) := floor (1000 / millisecondsBetweenTicks)
timeBeforeLaunch (3) := 0
 
var initialDelayBeforeLaunch := 0
 
% Tells the ball who the player was who got the last hit, thus who deserves the point
var playerLastHit : array 1 .. 3 of int
playerLastHit (1) := 0
playerLastHit (2) := 0
playerLastHit (3) := 0
 
var points1 := 0
var points2 := 0
var points3 := 0
var points4 := 0
var inGame := false
 
var aiAimpoint := 0
 
% The main gameloop
loop
    millisecondsBetweenTicks := 15
 
    if inGame = true then
 
	gameInput
 
	% Invokes the AI if there's only one player
	if numberOfPlayers (numberOfPlayersSelected) = 1 then
	    updateAI
	end if
 
	if initialDelayBeforeLaunch > floor (2000 / millisecondsBetweenTicks) then
	    % Computes each ball individually
	    for counter : 1 .. (numberOfBalls (numberOfBallsSelected))
 
		ballTickCounter (counter) += 1
 
		% Pauses each ball at the beginning of each launch
		if timeBeforeLaunch (counter) < floor (2000 / millisecondsBetweenTicks) then
		    timeBeforeLaunch (counter) += 1
		else
		    updateBall (counter)
		end if
 
		% Makes ball speed up after 20 seconds
		if ballTickCounter (counter) > floor (20000 / millisecondsBetweenTicks) then
		    ballSpeed (counter) := originalBallSpeed + 1
		else
		    ballSpeed (counter) := originalBallSpeed
		end if
	    end for
	else
	    initialDelayBeforeLaunch += 1
	end if
 
	drawPlayScreen
    end if
 
    % This is put in a different if statement to stop the game from drawing the play screen for one more frame before exiting to the menu
    if inGame = false then
	menuInput
 
	drawMenuScreen
 
    end if
 
    % Caps the framerate
    delay (millisecondsBetweenTicks)
 
    % Updates the frame
    View.Update
end loop
 
% Updates the AI to move towards the closest ball
body proc updateAI
 
    % The default ID of the closest ball, set to 1 for games with only 1 ball where it doesn't need to test for closest ball
    var firstBallID := 1
 
    %time = speed/dis
   
    % Finds the ID of the fastest ball for the AI to go for
    if numberOfBalls (numberOfBallsSelected) > 1 then
	for counter : 1 .. (numberOfBalls (numberOfBallsSelected))
	    % Chooses the ball that will arrive first, but ignores any beyond the halfway line so that the AI is remotely beatable
	    if (-ballChangeX (counter) / ballx (counter)) > (-ballChangeX (firstBallID) / ballx (firstBallID)) and ballChangeX (counter) < 0 and ballx (counter) < halfx then
		firstBallID := counter
	    end if
	end for
    end if
   
    var ballRange := maxy - ballFloor
    
    var target := halfy
    
    % If the targeted ball is not going away and is not beyond the halfway line
    if ballChangeX (firstBallID) < 0 and ballx (firstBallID) < halfx then
	% b = -mx + y , predicts where the ball is going to go through
	target := floor (-(ballChangeY (firstBallID) / ballChangeX(firstBallID) * (ballx (firstBallID) + paddlex(1))) + bally (firstBallID))
    end if
    
    /*
    % If the targeted ball is not going away and is not beyond the halfway line
    if ballChangeX (firstBallID) < 0 and ballx (firstBallID) < halfx then
	% b = -mx + y , predicts where the ball is going to go through
	target := floor (-(ballChangeY (firstBallID) / ballChangeX(firstBallID) * (ballx (firstBallID) + paddlex(1))) + bally (firstBallID))
	
	% Predicts the y point where it will actually come into contact with the paddle
	loop
	    if target > ballRange * 2 then
		target := target - ballRange;
	    elsif target < -ballRange then
		target := target + ballRange;
	    end if
	
	    target := -target
	    
	    % If it doesn't exit, then invert the target on the y axis
	    if target >= ballFloor and target <= ballCeiling then
		exit
	    end if
	end loop
    end if*/
   
    % Makes the AI move upwards if the nearest ball is above it
    if paddley(1) + floor (paddlePixelHeightOptions (paddlePixelHeightOptionsSelected) / 2) < target + aiAimpoint and ((paddley(1) + paddlePixelHeightOptions (paddlePixelHeightOptionsSelected)) < paddleCeiling) then
	paddley(1) += paddleSpeedOptions (paddleSpeedOptionsSelected)
    end if
   
    % Makes the AI move downwards if the nearest ball is below it
    if paddley(1) + floor (paddlePixelHeightOptions (paddlePixelHeightOptionsSelected) / 2) > target + aiAimpoint and ((paddley(1)) > paddleFloor) then
	paddley(1) -= paddleSpeedOptions (paddleSpeedOptionsSelected)
    end if
end updateAI
 
% Draws the controls legend
body proc drawControls
    var controlsFont := Font.New (typeface + ":22:bold")
    var xConCenter := xCon + floor (Font.Width ("CONTROLS", controlsFont) / 2)
    var xConRight := xCon + Font.Width ("CONTROLS", controlsFont)
 
    % Draws player 1's controls
    Font.Draw ("CONTROLS", xCon - 5, yCon + 4, Font.New (typeface + ":20:bold"), white)
 
    Font.Draw ("P1", xCon, yCon - 26, Font.New (typeface + ":20:underline"), white)
    Font.Draw ("w", xCon + 5, yCon - 52, Font.New (typeface + ":20:bold"), white)
    Font.Draw ("s", xCon + 6, yCon - 74, Font.New (typeface + ":20:bold"), white)
 
    % Draws player 2's controls
    Font.Draw ("P2", xConRight - 42, yCon - 26, Font.New (typeface + ":20:underline"), white)
    Font.Draw ("up", xConRight - 42, yCon - 52, Font.New (typeface + ":20:bold"), white)
    Font.Draw ("down", xConRight - 74, yCon - 78, Font.New (typeface + ":20:bold"), white)
 
    Font.Draw ("P3", xCon, yCon - 110, Font.New (typeface + ":20:underline"), white)
    Font.Draw ("<", xCon - 8, yCon - 138, Font.New (typeface + ":20:bold"), white)
    Font.Draw (">", xCon + 23, yCon - 138, Font.New (typeface + ":20:bold"), white)
 
    Font.Draw ("P4", xConRight - 42, yCon - 110, Font.New (typeface + ":20:underline"), white)
    Font.Draw ("c", xConRight - 46, yCon - 136, Font.New (typeface + ":20:bold"), white)
    Font.Draw ("v", xConRight - 22, yCon - 136, Font.New (typeface + ":20:bold"), white)
 
end drawControls
 
% Draws the screen
body proc drawPlayScreen
 
    % Draws the background and frame
    drawfillbox (0, 0, maxx, maxy, black)
    drawfillbox (0, maxy - 10, maxx, maxy, white)
    drawfillbox (0, 0, maxx, 10, white)
 
    % Draws lines in the middle of the in game screen
    for counter : 1 .. 10
	drawfillbox (halfx - 4, maxy - ((counter - 1) * 50), halfx + 4, maxy - 30 - ((counter - 1) * 50), white)
    end for
 
    % Draws the scores for however many players there are
    if numberOfPlayers (numberOfPlayersSelected) > 3 then
	drawNumber (halfx - 15, halfy + 8, points1, 3)
	drawNumber (halfx + 15, halfy + 8, points2, 1)
	drawfillbox (halfx - 4, maxy - 250, halfx + 4, maxy - 30 - 250, black)
	drawNumber (halfx, halfy - 50 + 8, points3, 2)
	drawfillbox (halfx - 4, maxy - 150, halfx + 4, maxy - 30 - 150, black)
	drawNumber (halfx, halfy + 50 + 8, points4, 2)
    else
	drawNumber (halfx - 15, maxy - 80, points1, 3)
	drawNumber (halfx + 15, maxy - 80, points2, 1)
 
	if numberOfPlayers (numberOfPlayersSelected) > 2 then
	    drawfillbox (halfx - 4, maxy - 100, halfx + 4, maxy - 30 - 100, black)
	    drawNumber (halfx, maxy - 130, points3, 2)
	end if
    end if
 
    % Draws 2 paddles from the bottom and keeps the x coord at the front face of the paddles
    drawfillbox (paddlex(1) - paddlePixelWidth, paddley(1), paddlex(1), paddley(1) + paddlePixelHeightOptions (paddlePixelHeightOptionsSelected), white)
    drawfillbox (paddlex(2), paddley(2), paddlex(2) + paddlePixelWidth, paddley(2) + paddlePixelHeightOptions (paddlePixelHeightOptionsSelected), white)
 
    % Draws the third and fourth paddles from the front face of the paddles
    if numberOfPlayers (numberOfPlayersSelected) > 2 then
	drawfillbox (paddleWallLeft, 0, paddleWallRight, 10, black)
	drawfillbox (paddlex(3), paddley(3) - paddlePixelWidth, paddlex(3) + paddlePixelHeightOptions (paddlePixelHeightOptionsSelected), paddley(3), white)
 
	if numberOfPlayers (numberOfPlayersSelected) > 3 then
	    drawfillbox (paddleWallLeft, maxy - 10, paddleWallRight, maxy, black)
	    drawfillbox (paddlex(4), paddley(4), paddlex(4) + paddlePixelHeightOptions (paddlePixelHeightOptionsSelected), paddley(4) + paddlePixelWidth, white)
	end if
    end if
 
    % Draws the balls
    for counter : 1 .. (numberOfBalls (numberOfBallsSelected))
	drawBall (counter)
    end for
end drawPlayScreen
 
% Updates the ball position and direction (ballID : int)
body proc updateBall
 
    % Moves ball in opposite y direction upon impact of the default ceiling
    if numberOfPlayers (numberOfPlayersSelected) < 4 and (bally (ballID) + halfBallPixelWidth) > ballCeiling and ballChangeY (ballID) > 0 then
	ballChangeY (ballID) := -ballChangeY (ballID)
    % Only rebound off of side walls when there's 4 players    
    elsif numberOfPlayers (numberOfPlayersSelected) > 3  and (bally (ballID) + halfBallPixelWidth) > ballCeiling and (ballx (ballID) - halfBallPixelWidth < paddleWallLeft or ballx (ballID) + halfBallPixelWidth > paddleWallRight) and ballChangeY (ballID) > 0 then
	ballChangeY (ballID) := -ballChangeY (ballID)
    end if
 
    % Moves ball in opposite y direction upon impact of the default floor
    if numberOfPlayers (numberOfPlayersSelected) < 3 and (bally (ballID) - halfBallPixelWidth) < ballFloor and ballChangeY (ballID) < 0 then
	ballChangeY (ballID) := -ballChangeY (ballID)
    % Only rebound off of side walls when there's 3 players    
    elsif numberOfPlayers (numberOfPlayersSelected) > 2 and (bally (ballID) - halfBallPixelWidth) < ballFloor and (ballx (ballID) - halfBallPixelWidth < paddleWallLeft or ballx (ballID) + halfBallPixelWidth > paddleWallRight) and ballChangeY (ballID) < 0 then
	ballChangeY (ballID) := -ballChangeY (ballID)
    end if
 
    % Updates the ball direction upon impact of paddle 1
    if (ballx (ballID) - halfBallPixelWidth) < paddlex(1) and bally (ballID) + halfBallPixelWidth > paddley(1) and bally (ballID) - halfBallPixelWidth < paddley(1) +
	    paddlePixelHeightOptions (paddlePixelHeightOptionsSelected) and ballChangeX (ballID) < 0 then
 
	var ballPosFromMiddleOfPaddle := (bally (ballID) - paddley(1)) - floor (paddlePixelHeightOptions (paddlePixelHeightOptionsSelected) / 2)
 
	var slope : real := ballPosFromMiddleOfPaddle / (paddlePixelHeightOptions (paddlePixelHeightOptionsSelected) / 2)
 
	ballChangeY (ballID) := floor (slope * (ballChangeXDefault + ballChangeYDefault))
 
	% Compensates for adding or subtracting to get the X value depending on whether Y is positive or negative
	if ballChangeY (ballID) < 0 then
	    ballChangeX (ballID) := (ballChangeXDefault + ballChangeYDefault) + ballChangeY (ballID)
	else
	    ballChangeX (ballID) := (ballChangeXDefault + ballChangeYDefault) - ballChangeY (ballID)
	end if
 
	% Stops the ball from going straight up and getting stuck in that position
	if ballChangeX (ballID) = 0 then
	    ballChangeX (ballID) += 1
	    ballChangeY (ballID) -= 1
	end if
 
	% Lets the ball know that player 1 got the last hit
	playerLastHit (ballID) := 1
       
	% Creates a new aimpoint for the AI so that it doesn't hit the ball in the same direction each time
	aiAimpoint := Rand.Int(-floor(paddlePixelHeightOptions (paddlePixelHeightOptionsSelected) / 2), floor(paddlePixelHeightOptions (paddlePixelHeightOptionsSelected) / 2))
    end if
 
    % Updates the ball direction upon impact of paddle 2
    if (ballx (ballID) + halfBallPixelWidth) > paddlex(2) and bally (ballID) + halfBallPixelWidth > paddley(2) and bally (ballID) - halfBallPixelWidth < paddley(2) +
	    paddlePixelHeightOptions (paddlePixelHeightOptionsSelected) and ballChangeX (ballID) > 0 then
 
	var ballPosFromMiddleOfPaddle := (bally (ballID) - paddley(2)) - floor (paddlePixelHeightOptions (paddlePixelHeightOptionsSelected) / 2)
 
	var slope : real := ballPosFromMiddleOfPaddle / (paddlePixelHeightOptions (paddlePixelHeightOptionsSelected) / 2)
 
	ballChangeY (ballID) := floor (slope * (ballChangeXDefault + ballChangeYDefault))
 
	% Compensates for adding or subtracting to get the X value depending on whether Y is positive or negative
	if ballChangeY (ballID) < 0 then
	    ballChangeX (ballID) := - (ballChangeXDefault + ballChangeYDefault) - ballChangeY (ballID)
	else
	    ballChangeX (ballID) := - (ballChangeXDefault + ballChangeYDefault) + ballChangeY (ballID)
	end if
 
	% Stops the ball from going straight up and getting stuck in that position
	if ballChangeX (ballID) = 0 then
	    ballChangeX (ballID) -= 1
	    ballChangeY (ballID) -= 1
	end if
 
	% Lets the ball know that player 2 got the last hit
	playerLastHit (ballID) := 2
       
	% Creates a new aimpoint for the AI so that it doesn't hit the ball in the same direction each time
	aiAimpoint := Rand.Int(-floor(paddlePixelHeightOptions (paddlePixelHeightOptionsSelected) / 2), floor(paddlePixelHeightOptions (paddlePixelHeightOptionsSelected) / 2))
    end if
 
    % Updates the ball direction upon impact of paddle 3
    if (bally (ballID) - halfBallPixelWidth) < paddley(3) and ballx (ballID) + halfBallPixelWidth > paddlex(3) and ballx (ballID) - halfBallPixelWidth < paddlex(3) +
	    paddlePixelHeightOptions (paddlePixelHeightOptionsSelected) and ballChangeY (ballID) < 0 then
 
	var ballPosFromMiddleOfPaddle := (ballx (ballID) - paddlex(3)) - floor (paddlePixelHeightOptions (paddlePixelHeightOptionsSelected) / 2)
 
	var slope : real := ballPosFromMiddleOfPaddle / (paddlePixelHeightOptions (paddlePixelHeightOptionsSelected) / 2)
 
	ballChangeX (ballID) := floor (slope * (ballChangeXDefault + ballChangeYDefault))
 
	% Compensates for adding or subtracting to get the Y value depending on whether X is positive or negative
	if ballChangeX (ballID) < 0 then
	    ballChangeY (ballID) := (ballChangeXDefault + ballChangeYDefault) + ballChangeX (ballID)
	else
	    ballChangeY (ballID) := (ballChangeXDefault + ballChangeYDefault) - ballChangeX (ballID)
	end if
 
	% Stops the ball from going straight sideways and getting stuck in that position
	if ballChangeY (ballID) = 0 then
	    ballChangeY (ballID) += 1
	    ballChangeX (ballID) -= 1
	end if
 
	% Lets the ball know that player 3 got the last hit
	playerLastHit (ballID) := 3
       
	% Creates a new aimpoint for the AI so that it doesn't hit the ball in the same direction each time
	aiAimpoint := Rand.Int(-floor(paddlePixelHeightOptions (paddlePixelHeightOptionsSelected) / 2), floor(paddlePixelHeightOptions (paddlePixelHeightOptionsSelected) / 2))
    end if
 
    % Updates the ball direction upon impact of paddle 4
    if (bally (ballID) + halfBallPixelWidth) > paddley(4) and ballx (ballID) + halfBallPixelWidth > paddlex(4) and ballx (ballID) - halfBallPixelWidth < paddlex(4) +
	    paddlePixelHeightOptions (paddlePixelHeightOptionsSelected) and ballChangeY (ballID) > 0 then
 
	var ballPosFromMiddleOfPaddle := (ballx (ballID) - paddlex(4)) - floor (paddlePixelHeightOptions (paddlePixelHeightOptionsSelected) / 2)
 
	var slope : real := ballPosFromMiddleOfPaddle / (paddlePixelHeightOptions (paddlePixelHeightOptionsSelected) / 2)
 
	ballChangeX (ballID) := floor (slope * (ballChangeXDefault + ballChangeYDefault))
 
	% Compensates for adding or subtracting to get the Y value depending on whether X is positive or negative
	if ballChangeX (ballID) < 0 then
	    ballChangeY (ballID) := - (ballChangeXDefault + ballChangeYDefault) - ballChangeX (ballID)
	else
	    ballChangeY (ballID) := - (ballChangeXDefault + ballChangeYDefault) + ballChangeX (ballID)
	end if
 
	% Stops the ball from going straight sideways and getting stuck in that position
	if ballChangeY (ballID) = 0 then
	    ballChangeY (ballID) -= 1
	    ballChangeX (ballID) += 1
	end if
 
	% Lets the ball know that player 4 got the last hit
	playerLastHit (ballID) := 4
       
	% Creates a new aimpoint for the AI so that it doesn't hit the ball in the same direction each time
	aiAimpoint := Rand.Int(-floor(paddlePixelHeightOptions (paddlePixelHeightOptionsSelected) / 2), floor(paddlePixelHeightOptions (paddlePixelHeightOptionsSelected) / 2))
    end if
 
    % Relaunches the ball and update scores if the ball falls behind the left paddle
    if ballx (ballID) - halfBallPixelWidth < paddlex(1) - 15 or ballx (ballID) + halfBallPixelWidth > paddlex(2) + 15 or bally (ballID) - halfBallPixelWidth < paddley(3) - 15 or bally (ballID) +
	    halfBallPixelWidth > paddley(4) + 15 then
	givePoint (playerLastHit (ballID))
	resetBall (ballID, playerLastHit (ballID))
    end if
 
    % Updates the ball position based on its' speed and direction
    ballx (ballID) += (ballChangeX (ballID) * ballSpeed (ballID))
    bally (ballID) += (ballChangeY (ballID) * ballSpeed (ballID))
end updateBall
 
% Gives points to the player number
body proc givePoint
    if playerToGiveTo = 1 then
	points1 += 1
    elsif playerToGiveTo = 2 then
	points2 += 1
    elsif playerToGiveTo = 3 then
	points3 += 1
    elsif playerToGiveTo = 4 then
	points4 += 1
    end if
end givePoint
 
% Relaunches a ball playerLastHit
body proc resetBall
 
    % Resests timers for ball launches
    timeBeforeLaunch (ballID) := 0
    ballTickCounter (ballID) := 0
 
    % Launches ball from right to left
    if playerLastHitParam = 1 then
	ballx (ballID) := maxx - 100
	bally (ballID) := halfy
	ballChangeX (ballID) := - (ballChangeXDefault + ballChangeYDefault) + 1
	ballChangeY (ballID) := 0
 
    % Launches ball from left to right
    elsif playerLastHitParam = 2 then
	ballx (ballID) := 100
	bally (ballID) := halfy
	ballChangeX (ballID) := (ballChangeXDefault + ballChangeYDefault) - 1
	ballChangeY (ballID) := 0
 
    % Launches ball from top to bottom
    elsif playerLastHitParam = 3 then
	ballx (ballID) := halfx
	bally (ballID) := maxy - 100
	ballChangeX (ballID) := 0
	ballChangeY (ballID) := - (ballChangeXDefault + ballChangeYDefault) + 1
 
    % Launches ball from bottom to top
    elsif playerLastHitParam = 4 then
	ballx (ballID) := halfx
	bally (ballID) := 100
	ballChangeX (ballID) := 0
	ballChangeY (ballID) := (ballChangeXDefault + ballChangeYDefault) - 1
       
    % Launches ball from random side    
    else
	resetBall (ballID, Rand.Int(1, 2))
    end if
 
    % Resets hit tracker
    playerLastHit (ballID) := 0
end resetBall
 
% Draws a number (used to draw the score)
body proc drawNumber
    var font := Font.New (typeface + ":40")
    var offsetX := x
    var width := Font.Width (intstr (number), font)
 
    % If it anchors to the right of the number then it will offset the x to the width of the text
    if anchor = 3 then
	offsetX -= width
 
	% If it anchors to the middle of the number then it will offset the x to half the width of the text
    elsif anchor = 2 then
	offsetX -= floor (width / 2)
    end if
 
    % Fixes a bug where when score is 0 it will get drawn too far to the right
    if number = 0 and anchor = 1 then
	offsetX -= 6
    elsif number = 0 and anchor = 2 then
	offsetX -= 3
    end if
 
    % Draws the final number
    Font.Draw (intstr (number), offsetX, y, font, white)
end drawNumber
 
% Detects when players presses the key for in-game
body proc gameInput
    var chars : array char of boolean
    Input.KeyDown (chars)
 
    % On pressing the up arrow, makes sure that user is not pushing into the ceiling, then moves paddle 1 up
    if (chars (KEY_UP_ARROW)) and ((paddley(2) + paddlePixelHeightOptions (paddlePixelHeightOptionsSelected)) < paddleCeiling) then
	paddley(2) += paddleSpeedOptions (paddleSpeedOptionsSelected)
    end if
 
    % On pressing the down arrow, makes sure that user is not pushing into the floor, then moves paddle 1 down
    if (chars (KEY_DOWN_ARROW)) and ((paddley(2)) > paddleFloor) then
	paddley(2) -= paddleSpeedOptions (paddleSpeedOptionsSelected)
    end if
 
    % Adds more paddle controls the more players there are
    if numberOfPlayers (numberOfPlayersSelected) > 1 then
 
	% On pressing W, makes sure that user is not pushing into the ceiling, then moves paddle 2 up
	if (chars ('w')) and ((paddley(1) + paddlePixelHeightOptions (paddlePixelHeightOptionsSelected)) < paddleCeiling) then
	    paddley(1) += paddleSpeedOptions (paddleSpeedOptionsSelected)
	end if
 
	% On pressing S, makes sure that user is not pushing into the loor, then moves paddle 2 down
	if (chars ('s')) and ((paddley(1)) > paddleFloor) then
	    paddley(1) -= paddleSpeedOptions (paddleSpeedOptionsSelected)
	end if
 
	if numberOfPlayers (numberOfPlayersSelected) > 2 then
 
	    if (chars (',')) and ((paddlex(3)) > paddleWallLeft) then
		paddlex(3) -= paddleSpeedOptions (paddleSpeedOptionsSelected)
	    end if
 
	    if (chars ('.')) and ((paddlex(3) + paddlePixelHeightOptions (paddlePixelHeightOptionsSelected)) < paddleWallRight) then
		paddlex(3) += paddleSpeedOptions (paddleSpeedOptionsSelected)
	    end if
 
	    if numberOfPlayers (numberOfPlayersSelected) > 3 then
 
		if (chars ('c')) and ((paddlex(4)) > paddleWallLeft) then
		    paddlex(4) -= paddleSpeedOptions (paddleSpeedOptionsSelected)
		end if
 
		if (chars ('v')) and ((paddlex(4) + paddlePixelHeightOptions (paddlePixelHeightOptionsSelected)) < paddleWallRight) then
		    paddlex(4) += paddleSpeedOptions (paddleSpeedOptionsSelected)
		end if
	    end if
	end if
    end if
 
    % On pressing R, resets the game
    if (chars ('r')) then
	reset
    end if
 
    % on pressing the escape key, exits back to the title screen
    if chars (KEY_ESC) then
	inGame := false
	reset
    end if
end gameInput
 
 
% Resets the in game values
body proc reset
    paddley(1) := halfy - floor (paddlePixelHeightOptions (paddlePixelHeightOptionsSelected) / 2)
    paddley(2) := halfy - floor (paddlePixelHeightOptions (paddlePixelHeightOptionsSelected) / 2)
    paddlex(3) := halfx - floor (paddlePixelHeightOptions (paddlePixelHeightOptionsSelected) / 2)
    paddlex(4) := halfx - floor (paddlePixelHeightOptions (paddlePixelHeightOptionsSelected) / 2)
 
    for counter : 1 .. numberOfBalls (numberOfBallsSelected)
	resetBall (counter, 0)
    end for
 
    timeBeforeLaunch (1) := floor (2000 / millisecondsBetweenTicks)
    timeBeforeLaunch (2) := floor (1000 / millisecondsBetweenTicks)
    timeBeforeLaunch (3) := 0
    initialDelayBeforeLaunch := 0
 
    points1 := 0
    points2 := 0
    points3 := 0
    points4 := 0
   
    aiAimpoint := Rand.Int(-floor(paddlePixelHeightOptions (paddlePixelHeightOptionsSelected) / 2), floor(paddlePixelHeightOptions (paddlePixelHeightOptionsSelected) / 2))
end reset
 
% Draws the given ball
body proc drawBall
    % Draws the ball fromthe center
    var halfBallPixelWidth := floor (ballPixelWidth / 2)
    drawfillbox (ballx (ballToDraw) - halfBallPixelWidth, bally (ballToDraw) - halfBallPixelWidth, ballx (ballToDraw) + halfBallPixelWidth, bally (ballToDraw) + halfBallPixelWidth, white)
end drawBall
 
%Draws the menu screen
body proc drawMenuScreen
 
    % Draws the background and frame
    drawfillbox (0, 0, maxx, maxy, black)
    drawfillbox (0, maxy - 10, maxx, maxy, white)
    drawfillbox (0, 0, maxx, 10, white)
 
    % Draws main text
    Font.Draw ("PONG", halfx - 200, 320, Font.New (typeface + ":121:bold"), white)
    Font.Draw ("CODED BY SAMSON CLOSE", halfx - 198, 300, Font.New (typeface + ":8:bold"), white)
    Font.Draw ("PLAY GAME", halfx - 198, 260, Font.New (typeface + ":32:bold"), white)
    Font.Draw ("PADDLE SPEED", halfx - 198, 220, Font.New (typeface + ":32:bold"), white)
    Font.Draw ("PADDLE SIZE", halfx - 198, 180, Font.New (typeface + ":32:bold"), white)
    Font.Draw ("NUMBER OF BALLS", halfx - 198, 140, Font.New (typeface + ":32:bold"), white)
    Font.Draw ("NUMBER OF PLAYERS", halfx - 198, 100, Font.New (typeface + ":32:bold"), white)
 
    % Draws Controls
    drawControls (halfx + 180, maxy - 60)
 
    % Draws all the option values with the font
    var font := Font.New (typeface + ":22:bold")
 
    var width1 := Font.Width (intstr (paddleSpeedOptions (paddleSpeedOptionsSelected)), font)
    Font.Draw (intstr (paddleSpeedOptions (paddleSpeedOptionsSelected)), (halfx - 240) - floor (width1 / 2), 223, font, white)
 
    var width2 := Font.Width (intstr (paddlePixelHeightOptions (paddlePixelHeightOptionsSelected)), font)
    Font.Draw (intstr (paddlePixelHeightOptions (paddlePixelHeightOptionsSelected)), (halfx - 240) - floor (width2 / 2), 183, font, white)
 
    var width3 := Font.Width (intstr (numberOfBalls (numberOfBallsSelected)), font)
    Font.Draw (intstr (numberOfBalls (numberOfBallsSelected)), (halfx - 240) - floor (width3 / 2), 143, font, white)
 
    var width4 := Font.Width (intstr (numberOfPlayers (numberOfPlayersSelected)), font)
    Font.Draw (intstr (numberOfPlayers (numberOfPlayersSelected)), (halfx - 240) - floor (width4 / 2), 103, font, white)
 
    % Draws the option boxes
    drawMenuArrows (optionSelected)
 
end drawMenuScreen
 
% Draws the arrows beside each option in in the main menu
body proc drawMenuArrows
 
    % The space from the center of the option value to the arrow
    var xSpacing := 0
    var yPos := 0
 
    % Tells whether to draw the left and right arrows or not
    var drawLeft := false
    var drawRight := false
 
    % Sets the positioning, spacing, and arrows to draw for each option
    if option = 1 then
	xSpacing := 22
	yPos := 272
	drawRight := true
 
    elsif option = 2 then
 
	xSpacing := 22
	yPos := 232
 
	if paddleSpeedOptionsSelected < upper (paddleSpeedOptions) then
	    drawRight := true
	end if
 
	if paddleSpeedOptionsSelected > 1 then
	    drawLeft := true
	end if
 
    elsif option = 3 then
 
	xSpacing := 30
	yPos := 192
 
	if paddlePixelHeightOptionsSelected < upper (paddlePixelHeightOptions) then
	    drawRight := true
	end if
 
	if paddlePixelHeightOptionsSelected > 1 then
	    drawLeft := true
	end if
 
    elsif option = 4 then
 
	xSpacing := 22
	yPos := 152
 
	if numberOfBallsSelected < upper (numberOfBalls) then
	    drawRight := true
	end if
 
	if numberOfBallsSelected > 1 then
	    drawLeft := true
	end if
 
    elsif option = 5 then
 
	xSpacing := 22
	yPos := 112
 
	if numberOfPlayersSelected < upper (numberOfPlayers) then
	    drawRight := true
	end if
 
	if numberOfPlayersSelected > 1 then
	    drawLeft := true
	end if
    end if
 
    % Draws the right arrow
    if drawRight = true then
	Draw.Line ((halfx - 240) + xSpacing, yPos - 8, (halfx - 240) + xSpacing, yPos + 8, white)
	Draw.Line ((halfx - 240) + xSpacing, yPos + 8, (halfx - 240) + xSpacing + 8, yPos, white)
	Draw.Line ((halfx - 240) + xSpacing + 8, yPos, (halfx - 240) + xSpacing, yPos - 8, white)
	Draw.Fill ((halfx - 240) + xSpacing + 1, yPos, white, white)
    end if
 
    % Draws the left arrow
    if drawLeft = true then
	Draw.Line ((halfx - 240) - xSpacing, yPos - 8, (halfx - 240) - xSpacing, yPos + 8, white)
	Draw.Line ((halfx - 240) - xSpacing, yPos + 8, (halfx - 240) - xSpacing - 8, yPos, white)
	Draw.Line ((halfx - 240) - xSpacing - 8, yPos, (halfx - 240) - xSpacing, yPos - 8, white)
	Draw.Fill ((halfx - 240) - xSpacing - 1, yPos, white, white)
    end if
end drawMenuArrows
 
% Detects when players hit a key on the menu screen
body proc menuInput
    var chars : array char of boolean
    Input.KeyDown (chars)
 
    % When up arrow is pressed, moves selected option up
    if chars (KEY_UP_ARROW) and optionSelected > 1 then
	millisecondsBetweenTicks := 60
	optionSelected -= 1
    end if
 
    % When down arrow is pressed, moves selected option down
    if chars (KEY_DOWN_ARROW) and optionSelected < numberOfOptions then
	millisecondsBetweenTicks := 60
	optionSelected += 1
    end if
 
    % When left arrow is pressed, moves to the lower preset of the selected option
    if chars (KEY_LEFT_ARROW) then
	millisecondsBetweenTicks := 80
	if (optionSelected = 2) and (paddleSpeedOptionsSelected > 1) then
	    paddleSpeedOptionsSelected -= 1
	elsif (optionSelected = 3) and (paddlePixelHeightOptionsSelected > 1) then
	    paddlePixelHeightOptionsSelected -= 1
	elsif (optionSelected = 4) and (numberOfBallsSelected > 1) then
	    numberOfBallsSelected -= 1
	elsif (optionSelected = 5) and (numberOfPlayersSelected > 1) then
	    numberOfPlayersSelected -= 1
	end if
    end if
 
    % When right arrow is pressed, moves to the lower preset of the selected option
    if chars (KEY_RIGHT_ARROW) then
	millisecondsBetweenTicks := 80
	if (optionSelected = 2) and (paddleSpeedOptionsSelected < upper (paddleSpeedOptions)) then
	    paddleSpeedOptionsSelected += 1
	elsif (optionSelected = 3) and (paddlePixelHeightOptionsSelected < upper (paddlePixelHeightOptions)) then
	    paddlePixelHeightOptionsSelected += 1
	elsif (optionSelected = 4) and (numberOfBallsSelected < upper (numberOfBalls)) then
	    numberOfBallsSelected += 1
	elsif (optionSelected = 5) and (numberOfPlayersSelected < upper (numberOfPlayers)) then
	    numberOfPlayersSelected += 1
	end if
    end if
 
    % When enter key is pressed, either starts the game or sets the selected option to its' default value
    if chars (KEY_ENTER) then
	if optionSelected = 1 then
	    inGame := true
	    reset
 
	elsif optionSelected = 2 then
	    paddleSpeedOptionsSelected := paddleSpeedOptionsDefault
	elsif optionSelected = 3 then
	    paddlePixelHeightOptionsSelected := paddlePixelHeightOptionsDefault
	elsif optionSelected = 4 then
	    numberOfBallsSelected := numberOfBallsDefault
	elsif optionSelected = 4 then
	    numberOfPlayersSelected := numberOfPlayersDefault
	end if
    end if
end menuInput
