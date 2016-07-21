--[[
  'Traveler' Pathfinder for LUA LOVE
  @Author : ArchAngel075 | Jaco Kotzé
  License = DO WHAT YOU WANT*
    *But please kind append original @author to any modified versions.
    
  Source and reference : 
  http://www.policyalmanac.org/games/aStarTutorial.htm
    -The general algorithm
    
  http://theory.stanford.edu/~amitp/GameProgramming/Heuristics.html
    -H;G and F calculation improvements for heuristics
--]]
local folderOfThisFile = (...):match("(.-)[^%.]+$")
local class = require (folderOfThisFile .. "traveler.30log")
local Traveler = class("Archis.Traveler.Traveler")
local instance = Traveler() --singleton class that helps manage all of Traveler library functions

Traveler.Node = require(folderOfThisFile .. "traveler.node")
Traveler.World = require(folderOfThisFile .. "traveler.world")
Traveler.Solver = require(folderOfThisFile .. "traveler.solver")

Traveler.adjacent = {
    {1,0},
    {-1,0},
    {0,1},
    {0,-1},
}

Traveler.diagonal = {
    {1,1},
    {1,-1},
    {-1,1},
    {-1,-1},
}

Traveler.adjacent_and_diagonal = {
    {1,1},
    {1,-1},
    {-1,1},
    {-1,-1},
    
    {1,0},
    {-1,0},
    {0,1},
    {0,-1},
}

function Traveler.new() 
  error('Cannot instantiate the core Traveler class') 
end
function Traveler.init() end

function Traveler.extend() 
  error('Cannot extend the core Traveler class')
end

function Traveler:getInstance()
  return instance
end

function Traveler:getInstance()
  return instance
end

function Traveler:newWorld(xSize,ySize)
  return self.World:new(self,xSize,ySize)
end

function Traveler:newNode(x,y)
  return self.Node:new(self,x,y)
end

function Traveler:newSolver(World,Start,End,optional_tags)
  return self.Solver:new(self,World,Start,End,optional_tags)
end

function Traveler.DoesTableContain(tbl,itm)
  for k,v in pairs(tbl) do
    if (v == itm) then 
      return true 
    end
  end
  return false
end

return instance

