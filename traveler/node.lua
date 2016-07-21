local folderOfThisFile = (...):match("(.-)[^%.]+$")
local class = require (folderOfThisFile .. "30log")

local NodeClass = class("Archis.Traveler.Node")

NodeClass.position_x = nil
NodeClass.position_y = nil
NodeClass.tags = nil
NodeClass.H,NodeClass.G,NodeClass.F = 0,0,0
--G is measured in Units
NodeClass.ParentNode = nil
NodeClass.Traveler = nil
NodeClass.Solver = nil
NodeClass.neighbors = nil

function NodeClass:init(Traveler,xPos, yPos)
  self.tags = {}
  self.Traveler = Traveler
  self.position_x, self.position_y = xPos, yPos
  self.neighbors = {}
end

function NodeClass:AddNeighbor(Node)
  assert(class.isInstance(Node,self.Traveler.Node),"variable #1 is incorrect class type, expected " .. tostring(self.Traveler.Node) .. " got " .. tostring(Node))
  self.neighbors[#self.neighbors+1] = Node
end

function NodeClass:AddTag(Tag)
  self.tags[Tag] = true
end

function NodeClass:RemoveTag(Tag)
  self.tags[Tag] = false 
end

function NodeClass:CompareTag(Tag)
  return self.tags[Tag]
end

function NodeClass:CalculateG(alpha,override_parent)
  alpha = alpha or 1
  alpha = alpha
  return 10 + alpha * (self:_CalculateG(override_parent) - 10)
end

function NodeClass:GetG()
  self.G = self:CalculateG()
  return self.G 
end

function NodeClass:IsNodeCorner(NodeB)
  for k,v in pairs(self.Traveler.diagonal) do
    local x,y = self.position_x + v[1],self.position_y + v[2]
    local node = self.Solver.World:GetNodeAt(x,y)
    if(node and node == v) then
      return true
    end
  end
  return false
end

function NodeClass:GetF()
  local H = self:GetH()
  return self:GetG() + H
end

function NodeClass:GetH()
  self.H = self.Solver:GetHeuristic(self , self.Solver.World:GetNodeAt(self.Solver.End[1],self.Solver.End[2]))
  return self.H
end

function NodeClass:_CalculateG(override_parent)
  local parent = override_parent or self.ParentNode or false
  if(parent) then
    if(class.isInstance(parent,self.Traveler.Node)) then
      local isCorner = self:IsNodeCorner(parent)
      if(isCorner) then
        return (parent:GetG()+14)
      else
        return (parent:GetG()+10)
      end
    else
      error("Invalid type for 'override_parent', expected " .. tostring(self.Traveler.Node) .. "| got " .. type(override_parent) .. ".")
    end
  else
    return 10
  end
end

return NodeClass