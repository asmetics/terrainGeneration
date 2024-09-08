local startPosition = Vector3.new(0, 20, 0)
local nodeDistance = 5
local positions
local RenderSize = 350
local Frequency, Amplitude, Resolution, heightBias

local placingTable = {}
local placePer = 750

local seed = tick()
math.randomseed(seed)

local waterHeight = nil

function newValues()
	Frequency = math.random(5,7)
	Amplitude = 40
	Resolution = math.random(200,400)
	heightBias = 400
	seed = tick() + math.random(-92873987, 92873987)
	math.randomseed(seed)
end

newValues()

local folder = Instance.new("Folder")
folder.Parent = game.Workspace
folder.Name = "Nodes"

local function FBMNoise(x: number, z: number, octaves: number): number
	local total = 0
	local frequency = Frequency
	local amplitude = Amplitude
	local maxValue = 0

	for i = 1, octaves do
		total = total + math.noise(x * frequency, z * frequency, seed) * amplitude
		maxValue = maxValue + amplitude
		frequency = frequency * 2
		amplitude = amplitude * 0.5
	end

	return total / maxValue
end

local globalHeightOffset = math.random(-40, 40)

local function GetHeight(x: number, z: number): number
	local noiseValue = FBMNoise(x / Resolution, z / Resolution, 5)
	local height = noiseValue * Amplitude
	local regionalBias = math.noise(x / 1000, z / 1000, seed) * heightBias
	height = height + regionalBias + globalHeightOffset
	return height
end

local function SmoothHeight(x: number, z: number): number
	local h1 = GetHeight(x, z)
	local h2 = GetHeight(x + 1, z)
	local h3 = GetHeight(x - 1, z)
	local h4 = GetHeight(x, z + 1)
	local h5 = GetHeight(x, z - 1)
	return (h1 + h2 + h3 + h4 + h5) / 5
end

local function GetMaterial(block, height: number)
	if height < -50 then
		block.Material = Enum.Material.Plastic
		block.Transparency = 0.5
		block.CanCollide = false
		block.Color = Color3.fromRGB(49, 176, 255)
		return nil
	elseif height < 50 then
		return Enum.Material.Grass, Color3.fromRGB(math.random(67, 72), math.random(104, 110), math.random(46, 49))
	elseif height < 60 then
		return Enum.Material.Rock, Color3.fromRGB(math.random(124, 130), math.random(109, 117), math.random(100, 115))
	else
		return Enum.Material.Snow, Color3.fromRGB(math.random(250, 255), math.random(245, 250), math.random(245, 250))
	end
end

function new()
	local currentNodes = 0

	for x = 0, RenderSize do
		for z = 0, RenderSize do
			local height = SmoothHeight(x, z)
			local cell = Instance.new("Part")

			cell.Size = Vector3.new(5, 15, 5)
			cell.Anchored = true

			local material, color = GetMaterial(cell, height)
			if material and color then
				cell.Color = color
				cell.Material = material
			end

			local newPosition = Vector3.new(
				startPosition.X + math.floor(x * cell.Size.X),
				startPosition.Y + height + math.random(0, 5) / 10,
				startPosition.Z + math.floor(z * cell.Size.X)
			)

			if material and color then
				cell.Position = newPosition
			else
				if waterHeight == nil then
					waterHeight = newPosition.Y
				end
				cell.Position = Vector3.new(newPosition.X, waterHeight, newPosition.Z)
			end

			table.insert(placingTable, cell)

			if #placingTable >= placePer then
				for i, v in pairs(placingTable) do
					v.Parent = folder
				end
				placingTable = {}
				game["Run Service"].Heartbeat:Wait()
			end
		end
	end
end

game.ReplicatedStorage:WaitForChild("new").OnServerEvent:Connect(function()
	if game.Workspace:FindFirstChild("Nodes") then
		for i, v in pairs(game.Workspace:FindFirstChild("Nodes"):GetChildren()) do
			v:Destroy()
		end
	end
	newValues()
	new()
end)
