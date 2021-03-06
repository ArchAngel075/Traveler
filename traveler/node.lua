local folderOfThisFile = (...):match("(.-)[^%.]+$")
local class = require (folderOfThisFile .. "30log")

local NodeClass = class("Archis.Traveler.Node")

NodeClass.position_x = nil
NodeClass.position_y = nil
NodeClass.tags = nil
NodeClass.H,NodeClass.G,NodeClass.F = 0,0,0
NodeClass.G_Alpha = 0.5
NodeClass.InternalGCost = 0
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

function NodeClass:SetInternalG(cost)
  self.InternalGCost = cost
end

function NodeClass:GetInternalG()
  return self.InternalGCost
end

function NodeClass:AddTag(Tag,cost)
  self.tags[Tag] = cost or 0
end

function NodeClass:RemoveTag(Tag)
  self.tags[Tag] = nil 
end

function NodeClass:CompareTag(Tag)
  return self.tags[Tag]
end

function NodeClass:CalculateG(alpha,override_parent)
  alpha = alpha or self.G_Alpha
  alpha = (alpha)*2
  return 1 + alpha * (self:_CalculateG(override_parent) - 1)
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
  local internalCost = self.InternalGCost
  for k,v in pairs(self.tags) do
    internalCost = internalCost + v
  end
  local parent = override_parent or self.ParentNode or false
  if(parent) then
    if(class.isInstance(parent,self.Traveler.Node)) then
      local isCorner = self:IsNodeCorner(parent)
      if(isCorner) then
        return (parent:GetG()+(2*internalCost))
      else
        return (parent:GetG()+(1*internalCost))
      end
    else
      error("Invalid type for 'override_parent', expected " .. tostring(self.Traveler.Node) .. "| got " .. type(override_parent) .. ".")
    end
  else
    return internalCost
  end
end

return NodeClass