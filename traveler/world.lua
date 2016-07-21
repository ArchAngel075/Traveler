local folderOfThisFile = (...):match("(.-)[^%.]+$")
local class = require (folderOfThisFile .. "30log")

local WorldClass = class("Archis.Traveler.World")

WorldClass.Nodes = nil
WorldClass.size_x = nil
WorldClass.size_y = nil
WorldClass.Traveler = nil

function WorldClass:init(Traveler,xSize, ySize)
  self.Traveler = Traveler
  self.size_x, self.size_y = xSize, ySize
  WorldClass.Nodes = {}
  for xindex = 1,xSize do
    WorldClass.Nodes[xindex] = {}
    for yindex = 1,ySize do
      WorldClass.Nodes[xindex][yindex] = Traveler:newNode(xindex,yindex)
    end
  end
end

function WorldClass:GetNodeAt(x,y)
  if(self.Nodes[x] and self.Nodes[x][y]) then
    return self.Nodes[x][y]
  else
    return false
  end
end

return WorldClass