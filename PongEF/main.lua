
push = require 'push'

Class = require 'class'

require 'Paddle'

require 'Ball'


WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- multiplied later by dt
PADDLE_SPEED = 200

--[[
    Runs when the game first starts up, only once; used to initialize the game. ]]
function love.load()
	love.graphics.setDefaultFilter('nearest', 'nearest')

-- Set the title of our application window
	love.window.setTitle('Pong')

-- "seed" the RNG so that calls to random are always random
-- use the current time, since that will vary on startup every time
	math.randomseed(os.time())

--create retro text object smallfont size 8 , use it on any text
	smallFont = love.graphics.newFont('font.ttf', 8)
							   	   --path, size
--bigger font for score and winner
	scoreFont = love.graphics.newFont('font.ttf', 32)
	largeFont = love.graphics.newFont('font.ttf', 16)
--set LÖVE2D active font to smallfont object
	love.graphics.setFont(smallFont)

-- set up sound effects so we can call them later
	sounds = {
		['paddle_hit1'] = love.audio.newSource('sounds/paddle_hit1.wav', 'static'),
		['paddle_hit2'] = love.audio.newSource('sounds/paddle_hit2.wav', 'static'),
		['score'] = love.audio.newSource('sounds/score.wav', 'static'),
		['wall_hit'] = love.audio.newSource('sounds/bounce.wav', 'static')
	}

 
  --Tables are {} like dictionaries in Python but with =
	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
		fullscreen = false,
		resizable = true,
		vsync = true
		})
	--initialize score variables, render on creen & keep track of winner
	player1Score = 0
	player2Score = 0

	-- either going to be 1 or 2. whoever gets scored on gets to serve
	servingPlayer = 1

	--paddle objects created
	player1 = Paddle(10, 30, 5, 20)
	player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    -- position and size variables for our ball when play starts
    -- class includes ball movement and speed
	ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    -- create gamestate for start of game
    -- (used for beginning, menus, main game, high score list, etc.)
    -- we will use this to determine behavior during render and update
    gameState = 'start'
end

function love.resize(w, h)
	push:resize(w, h)
end

--[[
    Runs every frame, with "dt" passed in, our delta in seconds 
    since the last frame, which LÖVE2D supplies us.
]]
function love.update(dt)
	if gameState == 'serve' then
		-- before switching to play, initiate ball velocity based
		-- on player who scored
		ball.dy = math.random(-50, 50)
		if servingPlayer == 1 then
			ball.dx = math.random(140, 200)
		else 
			ball.dx = -math.random(140, 200)
		end

	elseif gameState == 'play' then
		-- detect ball collision with paddles, reverse dx if true and
		-- increas it. 
		if ball:collides(player1) then
			ball.dx = -ball.dx * 1.05
			ball.x = player1.x + 5
			-- keep velocity the same direction, but randomize it
			if ball.dy < 0 then
				ball.dy = -math.random(10, 150)
			else
				ball.dy = math.random(10, 150)
			end

			sounds['paddle_hit1']:play()
		end

		if ball:collides(player2) then
			ball.dx = -ball.dx * 1.05
			ball.x = player2.x - 4
			-- keep velocity the same direction, but randomize it
			if ball.dy < 0 then
			ball.dy = -math.random(10, 150)
			else
			ball.dy = math.random(10, 150)
			end

			sounds['paddle_hit2']:play()
		end

		-- detect upper and lower screen boundary collision, make it bounce
		if ball.y <0 then
			ball.y = 0
			ball.dy = -ball.dy
			sounds['wall_hit']:play()
		end
		-- -4 to account for ball's size
		if ball.y > VIRTUAL_HEIGHT - 4 then
			ball.y = VIRTUAL_HEIGHT -4
			ball.dy = -ball.dy
			sounds['wall_hit']:play()
		end

		if ball.x < 0 then
			servingPlayer = 1
			player2Score = player2Score + 1
			sounds['score']:play()

			if player2Score == 10 then
				winningplayer = 2
				gameState = 'done'
			else
				gameState = 'serve'
				ball:reset()
			end
		end

		if ball.x > VIRTUAL_WIDTH then
			servingPlayer = 2
			player1Score = player1Score + 1
			sounds['score']:play()

			if player1Score == 10 then
				winningplayer = 1
				gameState = 'done'
			else
				gameState = 'serve'
				ball:reset()
			end
		end
	end
	-- Player 1 movement (Y axis is positive down, negative up)
	-- isDown = currently pressing the key
	if love.keyboard.isDown('w') then
		player1.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown('s') then
		player1.dy = PADDLE_SPEED
	elseif love.keyboard.isDown('z') then
		player1.y = ball.y
	else
		player1.dy = 0
	end

	-- Player 2 movement (Y axis is positive down, negative up)
	if love.keyboard.isDown('up') then
	-- add negative paddle speed to current Y scaled by deltaTime
		player2.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown('down') then
	-- add positive paddle speed to current Y scaled by deltaTime
		player2.dy = PADDLE_SPEED
	else
		player2.dy = 0
	end

    -- update our ball based on its DX and DY only if we're in play state;
    -- scale the velocity by dt so movement is framerate-independent
	if gameState == 'play' then
		ball:update(dt)
	end

	player1:update(dt)
	player2:update(dt)
end

-- does not work if kept pressed 
function love.keypressed(key)
	--keys can be accessed by string name
	if key == 'escape' then
		love.event.quit() --function LÖVE gives us to terminate
	
    -- if we press enter during the start state of the game, we'll go into play mode
    -- during play mode, the ball will move in a random direction
	elseif key == 'enter' or key == 'return' or key == 'space' then
		if gameState == 'start' then
			gameState = 'serve'
		elseif gameState == 'serve' then
			gameState = 'play'
		elseif gameState == 'done' then
			gameState = 'serve'
			ball:reset()

			player1Score = 0
			player2Score = 0

			if winningplayer == 1 then
				servingPlayer = 2
			else 
				servingPlayer = 1
			end
		end
	end
end




-- function love.graphics.draw(text, x, y, [width], [align])
function love.draw()
	--render in virtual resolution
	push:apply('start')

	-- love.graphics.clear(r, g, b, a)
			--255 means completely opaque , no transparency
	love.graphics.clear(40/255, 45/255, 52/255, 255/255)

	love.graphics.setFont(smallFont)

	displayScore()
	love.graphics.setFont(smallFont)

	if gameState == 'start' then
		love.graphics.setFont(smallFont)
		love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
		love.graphics.printf('Press Enter to Begin!', 0, 20, VIRTUAL_WIDTH, 'center')
	elseif gameState == 'serve' then
		love.graphics.setFont(smallFont)
		love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!",
			0, 10, VIRTUAL_WIDTH, 'center')
		love.graphics.printf('Press Enter to Serve!', 0, 20, VIRTUAL_WIDTH, 'center')
	elseif gameState == 'play' then
		love.graphics.printf('Good Luck!', 0, 20, VIRTUAL_WIDTH, 'center')
	elseif gameState == 'done' then
		love.graphics.setFont(largeFont)
       	 love.graphics.printf('Player ' .. tostring(winningplayer) .. ' wins!', 
    		 0, 10, VIRTUAL_WIDTH, 'center')
       	 love.graphics.setFont(smallFont)
      	 love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end
	-- render paddles using their Class's render method
	player1:render()
	player2:render()
	-- render ball using ts Class's render method
	ball:render()
		--love.graphics.rectangle(mode, x, y, width, height)
	displayFPS()
-- end rendering at virtual resolution
	push:apply('end')
end

--Renders current Frames Per Second FPS
function displayFPS() 
		--simple FPS display across all states
	love.graphics.setFont(smallFont)
	-- set color RGBA quadruple (red, green, blue, opaque level)
	love.graphics.setColor(0, 255, 0 ,255)
	-- love.timer.getFPS() returns current FPS, easy to monitor by printing it
	-- use .. to concatinate using tostriing()		   -- top left edge screen
	love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function displayScore()
	love.graphics.setFont(scoreFont)
	love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, 
		VIRTUAL_HEIGHT / 3)
	love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, 
		VIRTUAL_HEIGHT / 3)
end