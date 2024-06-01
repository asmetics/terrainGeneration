local totalNodes = 10000
local startPosition = Vector3.new(0, 0, 0)
local nodeDistance = 10
local positions
RenderSize = 100
Resolution = 100
local Frequency = nil
local Amplitude = nil
local Resoloution = nil

function newValues()
	Frequency = math.random(5, 10)
	Amplitude = math.random(3, 6)
	Resoloution = math.random(60, 120)
end

newValues()

local folder = Instance.new("Folder")
folder.Parent = game.Workspace
folder.Name = "Nodes"

function spiral(X, Y)
	local x, y = 0, 0
	local dx, dy = 0, -1
	local positions = {}

	for i = 1, (math.max(X, Y))^2 do
		if (-X/2 < x and x <= X/2) and (-Y/2 < y and y <= Y/2) then
			table.insert(positions, Vector3.new(x * nodeDistance, startPosition.Y + math.random(-2, 2), y * nodeDistance))
		end
		if x == y or (x < 0 and x == -y) or (x > 0 and x == 1 - y) then
			dx, dy = -dy, dx
		end
		x, y = x + dx, y + dy
	end

	return positions
end

local function GetHeight(x :number, z :number): number -- Creates Our Function
	local noiseHeight = math.noise( -- Math.Noise
		x / Resoloution * Frequency, -- The First Value Is X Divided And Multiplied
		z / Resoloution * Frequency -- The Second is Z but the same as X
	)
	noiseHeight = math.clamp(noiseHeight, -.5, .5) + .5
	return noiseHeight -- Returns The 'Noise' Height / Value
end


function new()
	local currentNodes = 0
	local _max = 100
	local max = _max
	for x = 0, RenderSize do
		for z = 0, RenderSize do
			local cell = Instance.new("Part")
			
			if max - 1 == 0 then
				game["Run Service"].Heartbeat:Wait()
				max = max - 1
			else
				max = _max
			end
			
			cell.Anchored = true
			cell.Parent = folder
			cell.Size = Vector3.new(10, 50, 10)
			cell.Color = Color3.fromRGB(62, 106, 35)
			cell.Material = Enum.Material.Grass

			local newPosition = Vector3.new(startPosition.X + math.floor(x * cell.Size.X), startPosition.Y + math.floor(GetHeight(x, z) * Amplitude) * Amplitude, startPosition.Z + math.floor(z * cell.Size.X))
			cell.Position = newPosition
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
	newValues()
end)
