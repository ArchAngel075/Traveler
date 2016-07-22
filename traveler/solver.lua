local folderOfThisFile = (...):match("(.-)[^%.]+$")
local class = require (folderOfThisFile .. "30log")
local mlib = require (folderOfThisFile .. "mlib")

local SolverClass = class("Archis.Traveler.Solver")

SolverClass.Traveler = nil
SolverClass.World = nil
SolverClass.Start = nil
SolverClass.End = nil
SolverClass.tags = nil
SolverClass.heuristicGridMovementType = "basic-cardinal"
SolverClass.openList = nil
SolverClass.closedList = nil
SolverClass.lowest_f_cost_node = nil
SolverClass.Rule = "all_false_extras"
--[[ Rule
"any" : Node must contain at-least one of the Solver tags
"all_ignore_extras" : Node must contain all tags the Solver contains, extra tags the node contains are ignored.
"all_false_extras" : Node must contain all tags the Solver contains and no extras else results to non traversable.
--]]

--[[ heuristicGridMovementType
  basic-cardinal : up, down, left, right
  advanced-cardinal : up, down, left, right, (diagonals) ...
  free : any angle/direction
--]]

function SolverClass:init(Traveler,World,Start,End,Tag)
  self.Traveler = Traveler
  self.World = World
  self.Solver = self
  self.openList = {}
  self.closedList = {}
  self.tags = {}
  for k_x,v_x in pairs(World.Nodes) do
    for k_y,v_y in pairs(v_x) do
      v_y.Solver = self
    end
  end
  self.Start = Start
  self.End = End
  SolverClass.tags = Tag
end

function SolverClass:SetG_Alpha(alpha)
  local alpha = alpha or 0.5
  --clamp
  if(alpha < 0) then alpha = 0 end
  if(alpha > 1) then alpha = 1 end
  for k_x,v_x in pairs(self.World.Nodes) do
    for k_node,node in pairs(v_x) do
      node.G_alpha = alpha
    end
  end
end

function SolverClass:AddTag(Tag)
  self.tags[Tag] = true
end

function SolverClass:RemoveTag(Tag)
  self.tags[Tag] = nil
end

function SolverClass:GetPath()
  local node = self.World:GetNodeAt(self.End[1],self.End[2])
  local path = {}
  while(node ~= self.World:GetNodeAt(self.Start[1],self.Start[2])) do
    if(node.ParentNode) then
      table.insert(path,node)
      node = node.ParentNode
    end
  end
  table.insert(path,self.World:GetNodeAt(self.Start[1],self.Start[2]))
  return path
end

function SolverClass:GetHeuristic(NodeA,NodeB)
  local D = 1
  local D2 = 2
  assert(class.isInstance(NodeA,self.Traveler.Node),"variable #1 is incorrect class type, expected " .. tostring(self.Traveler.Node) .. " got " .. tostring(NodeA))
  assert(class.isInstance(NodeB,self.Traveler.Node),"variable #2 is incorrect class type, expected " .. tostring(self.Traveler.Node) .. " got " .. tostring(NodeB))
  local dx = math.abs(NodeA.position_x - NodeB.position_x)
  local dy = math.abs(NodeA.position_y - NodeB.position_y)
  if(self.heuristicGridMovementType == "basic-cardinal") then
    return D * (dx + dy)
  elseif(self.heuristicGridMovementType == "advanced-cardinal") then
    return D * (dx + dy) + (D2 - 2 * D) * math.min(dx, dy)
  elseif(self.heuristicGridMovementType == "free") then
    return D * math.sqrt(dx * dx + dy * dy)
  end
end

function SolverClass:SetupSolver()
  local start = self.Start
  start = self.World.Nodes[start[1]][start[2]]
  for k,v in pairs(start.neighbors) do
    if(self:IsNodePathable(v)) then
      v.ParentNode = start
      self.openList[#self.openList+1] = v
    end
  end
  self.closedList[#self.closedList+1] = start
end

function SolverClass:Step()
  if(self.completed) then
    return self.completed
  end
  local function Sort(a,b)
    local f_a = a:GetF()
    local f_b = b:GetF()
    return (f_a < f_b)
  end
  table.sort(self.openList,Sort)
  
  self.lowest_f_cost_node = self.openList[1]
  lowest_f_cost_node = self.lowest_f_cost_node
  
  for k,v in pairs(lowest_f_cost_node.neighbors) do
    if (self:IsNodePathable(v) and not self.Traveler.DoesTableContain(self.closedList,v)) then
      if(not self.Traveler.DoesTableContain(self.openList,v)) then
        v.ParentNode = lowest_f_cost_node
        self.openList[#self.openList+1] = v
      else
        if(v:CalculateG(nil,lowest_f_cost_node) < v:CalculateG()) then
          v.ParentNode = lowest_f_cost_node
        end
      end
    end
  end
  table.remove(self.openList,1)
  self.closedList[#self.closedList+1] = lowest_f_cost_node
  self.completed = self.Traveler.DoesTableContain(self.closedList,self.World:GetNodeAt(self.End[1],self.End[2]))
  return self.completed
end

function SolverClass:IsNodePathable(Node)
  assert(class.isInstance(Node,self.Traveler.Node),"variable #1 is incorrect class type, expected " .. tostring(self.Traveler.Node) .. " got " .. tostring(Node))
  
  local function CountTable(Tbl)
    local i = 0
    local str = ""
    for k,v in pairs(Tbl) do
      i = i + 1
      str = str .. ", " .. k .. ":" .. tostring(v)
    end
    return i,str
  end
  
  if (self.Rule == "any") then
    for k_tag,tag in pairs(self.tags) do
      if(Node.tags[k_tag] == true) then
        return true
      end
    end
  elseif (self.Rule == "all_ignore_extras") then
    for k_tag,tag in pairs(self.tags) do
      if(not Node.tags[k_tag] or Node.tags[k_tag] == false) then
        return false
      end
    end
  elseif (self.Rule == "all_false_extras") then
    if(CountTable(self.tags) == CountTable(Node.tags)) then
      for k_tag,tag in pairs(self.tags) do
        if(not Node.tags[k_tag] or Node.tags[k_tag] == false) then
          return false
        end
      end
    else
      return false
    end
  end
  return true
end


function SolverClass:debugDraw(offsetx,offsety,scalex,scaley)
  local offsetx = offsetx or 0
  local offsety = offsety or 0
  local scalex = scalex or 1
  local scaley = scalex or 1
  love.graphics.push()
  love.graphics.translate(offsetx,offsety)
  love.graphics.scale(scalex,scaley)
  local nodeSize = 32
  local nodeSize2 = nodeSize/2
  love.graphics.setColor(255,255,255,255)
  local path = false
  if(self.completed) then
    path = self:GetPath()
  end
  
  local function trimDecimals(stringNumber)
    local stringNumber = tostring(stringNumber)
    local dot = string.find(stringNumber,".")
    if(dot) then
      stringNumber = string.sub(stringNumber,0,dot+3)
    end
    return stringNumber
  end
  
  local function addCircle(list,mode,r,segments,color)
    table.insert(list,{mode,r,segments,color})
  end
  
  local function sortCircles(a,b)
    return (a[2] > b[2])
  end
  
  local function DrawCircle(x,y,circle)
    love.graphics.setColor(circle[4][1],circle[4][2],circle[4][3],circle[4][4])
    love.graphics.circle(circle[1],x * nodeSize -(nodeSize/2) + x*3,y * nodeSize -(nodeSize/2) + y*3, circle[2],circle[3])
  end
  
  for k_x,v_x in pairs(self.World.Nodes) do
    for k_node,node in pairs(v_x) do
      local circles = {}
      love.graphics.setColor(255,255,255,255)
      if(self:IsNodePathable(node)) then
        addCircle(circles,"line",nodeSize2*1.03,8,{255/2.5,255,255/2.5,255})
        addCircle(circles,"line",nodeSize2*0.97,8,{255/2.5,255,255/2.5,255})
      else
        addCircle(circles,"line",nodeSize2*1.03,8,{255,255/2.5,255/2.5,255})
        addCircle(circles,"line",nodeSize2*0.97,8,{255,255/2.5,255/2.5,255})
      end
      
      
      if(self.Traveler.DoesTableContain(self.openList,node)) then
        addCircle(circles,"line",nodeSize2*0.6,8,{0,255,0,255})
      elseif(self.Traveler.DoesTableContain(self.closedList,node)) then
        addCircle(circles,"line",nodeSize2*0.6,8,{255,0,0,255})
      end
      if(self.lowest_f_cost_node ~= nil) then
        if(node == self.lowest_f_cost_node) then
          addCircle(circles,"fill",nodeSize2*0.4,8,{0,255,255,255})
        end
        if(self.Traveler.DoesTableContain(self.lowest_f_cost_node.neighbors,node)) then
          addCircle(circles,"line",nodeSize2*0.85,8,{255,255,0,255})
        end
      end
      if(node == self.World.Nodes[self.Start[1]][self.Start[2]]) then
        addCircle(circles,"line",nodeSize2*0.9,8,{0,255,255/2,255})
        addCircle(circles,"line",nodeSize2*0.95,8,{0,255,255/2,255})
      elseif(node == self.World.Nodes[self.End[1]][self.End[2]]) then
        addCircle(circles,"line",nodeSize2*0.9,8,{255,255/2,0,255})
        addCircle(circles,"line",nodeSize2*0.95,8,{255,255/2,0,255})
      end
      if(path and self.Traveler.DoesTableContain(path,node)) then
        addCircle(circles,"line",nodeSize2*0.75,8,{255,20,147,255})
        addCircle(circles,"line",nodeSize2*0.7,8,{255,20,147,255})
      end
      table.sort(circles,sortCircles)
      for k_circle,v_circle in pairs(circles) do
        DrawCircle(node.position_x,node.position_y,v_circle)
      end
    end
  end
  love.graphics.setColor(255,0,255,255*0.85)
  for k_x,v_x in pairs(self.World.Nodes) do
    for k_node,node in pairs(v_x) do
      if(node.ParentNode) then
        
        love.graphics.line(node.ParentNode.position_x * nodeSize -(nodeSize/2) + node.ParentNode.position_x*3,node.ParentNode.position_y * nodeSize -(nodeSize/2)+ node.ParentNode.position_y*3, node.position_x * nodeSize -(nodeSize/2) + node.position_x*3,node.position_y * nodeSize -(nodeSize/2) + node.position_y*3)
        
        love.graphics.circle("line",node.position_x * nodeSize -(nodeSize/2) + node.position_x*3,node.position_y * nodeSize -(nodeSize/2) + node.position_y*3, 4,8)
      end
    end
  end
  love.graphics.setColor(255,255,255,255)
  for k_x,v_x in pairs(self.World.Nodes) do
    for k_node,node in pairs(v_x) do
      local tc = {node.position_x * nodeSize -(nodeSize/2) + node.position_x*3, node.position_y * nodeSize -(nodeSize/2) + node.position_y*3 - 2.5}
      local G = "G" .. trimDecimals(node:GetG())
      local H = "H" .. trimDecimals(node:GetH())
      local F = "F" .. trimDecimals(node:GetF())
      love.graphics.print(F,tc[1] - (#F)*2.5+2, tc[2] - 10,0,0.55,0.55)
      love.graphics.print(G,tc[1] - (#G)*2.5, tc[2],0,0.55,0.55)
      love.graphics.print(H,tc[1] - (#H)*2.5, tc[2] + 7,0,0.55,0.55)
    end
  end
  love.graphics.pop()
end


return SolverClass