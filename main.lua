if arg[#arg] == "-debug" then require("mobdebug").start() end
local mlib = require ("traveler.mlib")
local traveler = require("traveler")
local MyWorld = traveler:newWorld(8,6)
local MySolver = traveler:newSolver(MyWorld,{3,3},{7,3})

function love.load()
  MySolver:AddTag("grass")
  MySolver:AddTag("air")
  ConstructNeighbors()
  
  
  MyWorld:GetNodeAt(5,2):RemoveTag("grass")
  MyWorld:GetNodeAt(5,3):AddTag("dirt")
  MyWorld:GetNodeAt(5,4):AddTag("dirt")
  
  MySolver:SetupSolver()
end

function love.update(dt)  
  
end

function love.draw()
  MySolver:debugDraw()
end

function love.keypressed(key)
  MySolver:Step()
end

function ConstructNeighbors()
  for x = 1,MyWorld.size_x,1 do
    for y = 1,MyWorld.size_y,1 do
      local node = MyWorld:GetNodeAt(x,y)
      node:AddTag("grass")
      node:AddTag("air")
      for k,v in pairs(traveler.adjacent_and_diagonal) do
        local neighbor = MyWorld:GetNodeAt(x+v[1],y+v[2])
        if(neighbor) then
          node:AddNeighbor(neighbor)
        end
      end
    end
  end
end


