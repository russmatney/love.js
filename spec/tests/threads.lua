local Threads = {}
Threads.__index = Threads
function create()
  local threadCode = [[
  -- Receive values sent via thread:start
  local min, max = ...
  
  for i = min, max do
      -- The Channel is used to handle communication between our main thread and
      -- this thread. On each iteration of the loop will push a message to it which
      -- we can then pop / receive in the main thread.
      love.thread.getChannel( 'info' ):push( i )
  end
  ]]
  
  local thread -- Our thread object.
  local timer  -- A timer used to animate our circle.

  thread = love.thread.newThread( threadCode )
  thread:start( 99, 1000 )

  local test = {
    timer = timer,
    thread = thread
  }
  setmetatable(test, Threads)
  return test
end

function Threads:update(dt)
  self.timer = self.timer and self.timer + dt or 0
 
  -- Make sure no errors occured.
  local error = self.thread:getError()
  assert( not error, error )
end

function Threads:draw()
  -- Get the info channel and pop the next message from it.
  local info = love.thread.getChannel( 'info' ):pop()
  if info then
      love.graphics.print( info, 10, 10 )
  end

  -- We smoothly animate a circle to show that the thread isn't blocking our main thread.
  love.graphics.circle( 'line', 100 + math.sin( self.timer ) * 20, 100 + math.cos( self.timer ) * 20, 20 )
end

function Threads:cleanup()
end

return create
