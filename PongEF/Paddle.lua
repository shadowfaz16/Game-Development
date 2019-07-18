Paddle = Class{}

--[[
    The `init` function on our class is called just once, when the object
    is first created. Used to set up all variables in the class and get it
    ready for use.
    Our Paddle should take an X and a Y, for positioning, as well as a width
    and height for its dimensions.
    `self` is a reference to *this* object, whichever object is
    instantiated at the time this function is called. Different objects can
    have their own x, y, width, and height values, thus serving as containers
    for data. 
]]
function Paddle:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dy = 0
end

function Paddle:update(dt)
    -- add negative paddle speed to current Y scaled by deltaTime
    -- math.max returns the greater of two values; 0 and player Y
    -- will ensure we don't go above it
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    -- add positive paddle speed to current Y scaled by deltaTime
    -- math.min returns the lesser of two values; bottom of the egde minus paddle height
    -- and player Y will ensure we don't go below it
    else
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    end
end

--[[
    To be called by our main function in `love.draw`, ideally. Uses
    LÖVE2D's `rectangle` function, which takes in a draw mode as the first
    argument as well as the position and dimensions for the rectangle. To
    change the color, one must call `love.graphics.setColor`. As of the
    newest version of LÖVE2D, you can even draw rounded rectangles!
]]
function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end