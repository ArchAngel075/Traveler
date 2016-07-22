if arg[#arg] == "-debug" then require("mobdebug").start() end
local traveler = require("traveler")
local MyWorld = traveler:newWorld(8,6)
local MySolver = traveler:newSolver(MyWorld,{3,3},{7,3})
local offset_x = 0
local offset_y = 0
local scale_x = 1
local scale_y = 1

function love.load()
  MySolver:AddTag("grass")
  MySolver:AddTag("air")
  ConstructNeighbors()
  
  MyWorld:GetNodeAt(5,1):AddTag("dirt")
  MyWorld:GetNodeAt(5,2):AddTag("dirt")
  MyWorld:GetNodeAt(5,3):AddTag("dirt")
  MyWorld:GetNodeAt(5,4):SetInternalG(20)
  MyWorld:GetNodeAt(5,5):AddTag("dirt")
  --MyWorld:GetNodeAt(5,6):AddTag("dirt")
  
  MySolver:SetupSolver()
end

function love.update(dt)  
  if(love.keyboard.isDown("space")) then
    MySolver:Step()
  end
  if(love.keyboard.isDown"w") then
    offset_y = offset_y - 32*dt
  end
  if(love.keyboard.isDown"s") then
    offset_y = offset_y + 32*dt
  end
  if(love.keyboard.isDown"a") then
    offset_x = offset_x - 32*dt
  end
  if(love.keyboard.isDown"d") then
    offset_x = offset_x + 32*dt
  end
  if(love.keyboard.isDown"q") then
    scale_x = scale_x + 0.25*dt
    scale_y = scale_y + 0.25*dt
  end
  if(love.keyboard.isDown"e") then
    scale_x = scale_x - 0.25*dt
    scale_y = scale_y - 0.25*dt
  end
end

function love.draw()
  MySolver:debugDraw(offset_x,offset_y,scale_x,scale_y)
end

function love.keypressed(key)
  
end

function ConstructNeighbors()
  for x = 1,MyWorld.size_x,1 do
    for y = 1,MyWorld.size_y,1 do
      local node = MyWorld:GetNodeAt(x,y)
      node:AddTag("grass")
      node:AddTag("air")
      for k,v in pairs(traveler.adjacent) do
        local neighbor = MyWorld:GetNodeAt(x+v[1],y+v[2])
        if(neighbor) then
          node:AddNeighbor(neighbor)
        end
      end
    end
  end
  --MyWorld:GetNodeAt(5,6):AddNeighbor(MyWorld:GetNodeAt(7,3))
end


