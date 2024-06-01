local totalNodes = 10000
local currentNodes = 0

local startPosition = Vector3.new(0,0,0)
local nodeDistance = 20

local folder = Instance.new("Folder")
folder.Parent = game.Workspace
folder.Name = "Nodes"

local raycastParams = RaycastParams.new()
raycastParams.RespectCanCollide = true

local function polarToCartesian(radius, angle)
	return Vector3.new(radius * math.cos(angle), 0, radius * math.sin(angle))
end

function new()
	local lastNodePosition = startPosition
	local angleIncrement = 2 * math.pi / 50 
	local angle = 10
	local radius = nodeDistance

	for currentNodes = 0, totalNodes, 1 do
		currentNodes = currentNodes + 1
		radius = totalNodes - currentNodes 
		local newpart = Instance.new("Part")
		newpart.Parent = folder
		newpart.Size = Vector3.new(0.5, 0.5, 0.5)
		newpart.Material = Enum.Material.Neon
		newpart.Anchored = true

		local offset = polarToCartesian(radius, angle)
		newpart.Position = startPosition + offset + Vector3.new(0 + math.random(-radius / 3, radius / 3), lastNodePosition.Y + math.random(-2, 2), 0 + math.random(-radius / 3, radius / 3))

		if game.Workspace:Raycast(newpart.Position, Vector3.new(0, 1000, 0), raycastParams) or game.Workspace:Raycast(newpart.Position, Vector3.new(0, -1000, 0), raycastParams) then
			newpart:Destroy()
			currentNodes = currentNodes - 1
		else
			lastNodePosition = newpart.Position
			angle = angle + angleIncrement
			radius = radius + nodeDistance / (2 * math.pi)
		end
	end
end

game.ReplicatedStorage:WaitForChild("new").OnServerEvent:Connect(function()
	if game.Workspace:FindFirstChild("Nodes") then
		for i, v in pairs(game.Workspace:FindFirstChild("Nodes"):GetChildren()) do
			v:Destroy()
		end
	end
	new()
end)
