--[[
    Pong Remake
    -- Ball Class --
    Represents a ball which will bounce back and forth between paddles
    and walls until it passes a left or right boundary of the screen,
    scoring a point for the opponent.
]]

Ball = Class{}

function Ball:init(x, y, width, height)
	self.x = x
	self.y = y
	self.width = width
	self.height = height

    -- these variables are for keeping track of our velocity on both the
    -- X and Y axis, since the ball can move in two dimensions
	 self.dy = math.random(2) == 1 and -100 or 100
	 self.dx = math.random(2) == 1 and math.random(-80, -100) or math.random(80, 100)
end

function Ball:collides(paddle)
	-- check to see if paddles' inside side is farther from the center than
	-- ball's edges
	if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
		return false
	end
	-- check to see if paddles' height is higher than the ball's edges
	if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
		return false
	end
	-- if both aren't true, it means there is collision
	return true
end

--Places the ball in the middle of the screen, with an initial 
--random velocity on both axes.
function Ball:reset()
	 self.x = VIRTUAL_WIDTH / 2 - 2
	 self.y = VIRTUAL_HEIGHT / 2 - 2
	 self.dy = math.random(2) == 1 and -100 or 100
	 self.dx = math.random(-50, 50)
end
--Applies velocity to position, scaled by deltaTime.
function Ball:update(dt)
	self.x = self.x + self.dx * dt
	self.y = self.y + self.dy * dt
end

function Ball:render()
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end