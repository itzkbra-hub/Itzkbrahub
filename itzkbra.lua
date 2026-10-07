-- =====================================================
-- itzkbra Hub | Velocidad + Fly + Noclip
-- Compatible con Delta Executor
-- =====================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ======================
-- CONFIGURACIÓN
-- ======================
local VELOCIDAD_MIN = 30
local VELOCIDAD_MAX = 500
local VELOCIDAD_NORMAL = 16

local FLY_SPEED = 50
local estadoVelocidad = VELOCIDAD_NORMAL
local volando = false
local noclipActivo = false
local bodyVelocity = nil
local bodyGyro = nil
local flyConnection = nil
local noclipConnection = nil

-- ======================
-- CREAR GUI
-- ======================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "itzkbraHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- ======================
-- ANIMACIÓN INTRODUCCIÓN
-- ======================
local introFrame = Instance.new("Frame")
introFrame.Size = UDim2.new(1, 0, 1, 0)
introFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
introFrame.BackgroundTransparency = 0.35
introFrame.Parent = screenGui

local introText = Instance.new("TextLabel")
introText.Size = UDim2.new(0, 320, 0, 70)
introText.Position = UDim2.new(0.5, -160, 0.5, -35)
introText.BackgroundTransparency = 1
introText.Text = "itzkbra"
introText.TextColor3 = Color3.fromRGB(0, 255, 150)
introText.TextScaled = true
introText.Font = Enum.Font.GothamBold
introText.TextTransparency = 1
introText.Parent = introFrame

local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
TweenService:Create(introText, tweenInfo, {TextTransparency = 0}):Play()
TweenService:Create(introText, tweenInfo, {Size = UDim2.new(0, 360, 0, 80)}):Play()

task.wait(1.5)

TweenService:Create(introText, TweenInfo.new(0.45), {TextTransparency = 1}):Play()
TweenService:Create(introFrame, TweenInfo.new(0.45), {BackgroundTransparency = 1}):Play()
task.wait(0.5)
introFrame:Destroy()

-- ======================
-- FUNCIÓN CREAR BOTÓN
-- ======================
local function crearBoton(texto, color, parent, orden)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 42)
	btn.BackgroundColor3 = color
	btn.Text = texto
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextScaled = true
	btn.Font = Enum.Font.GothamBold
	btn.LayoutOrder = orden or 1
	btn.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 10)
	c.Parent = btn
	return btn
end

-- ======================
-- BOTÓN FLOTANTE (Abrir/Cerrar Menú)
-- ======================
local btnFlotante = Instance.new("TextButton")
btnFlotante.Name = "BotonFlotante"
btnFlotante.Size = UDim2.new(0, 70, 0, 70)
btnFlotante.Position = UDim2.new(1, -85, 0.5, -35)
btnFlotante.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
btnFlotante.Text = "itzkbra"
btnFlotante.TextColor3 = Color3.fromRGB(255, 255, 255)
btnFlotante.TextScaled = true
btnFlotante.Font = Enum.Font.GothamBold
btnFlotante.Parent = screenGui

Instance.new("UICorner", btnFlotante).CornerRadius = UDim.new(1, 0)

local menuAbierto = true

-- ======================
-- MENÚ PRINCIPAL
-- ======================
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MenuPrincipal"
mainFrame.Size = UDim2.new(0, 270, 0, 310)
mainFrame.Position = UDim2.new(0.5, -135, 0.5, -155)
mainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)

local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1, 0, 0, 48)
titulo.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
titulo.Text = "itzkbra | Menú"
titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
titulo.TextScaled = true
titulo.Font = Enum.Font.GothamBold
titulo.Parent = mainFrame
Instance.new("UICorner", titulo).CornerRadius = UDim.new(0, 14)

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -20, 1, -60)
content.Position = UDim2.new(0, 10, 0, 55)
content.BackgroundTransparency = 1
content.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 9)
listLayout.Parent = content

local btnVelocidad = crearBoton("⚡ VELOCIDAD", Color3.fromRGB(0, 140, 255), content, 1)
local btnVolar     = crearBoton("🕊 VOLAR", Color3.fromRGB(160, 50, 255), content, 2)
local btnNoclip    = crearBoton("👻 NOCLIP: OFF", Color3.fromRGB(255, 140, 0), content, 3)
local btnCerrar    = crearBoton("❌ CERRAR MENÚ", Color3.fromRGB(180, 40, 40), content, 4)

-- ======================
-- PANEL VELOCIDAD
-- ======================
local panelVelocidad = Instance.new("Frame")
panelVelocidad.Size = UDim2.new(0, 270, 0, 280)
panelVelocidad.Position = UDim2.new(0.5, -135, 0.5, -140)
panelVelocidad.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
panelVelocidad.Visible = false
panelVelocidad.Parent = screenGui
Instance.new("UICorner", panelVelocidad).CornerRadius = UDim.new(0, 14)

local tituloVel = Instance.new("TextLabel")
tituloVel.Size = UDim2.new(1, 0, 0, 45)
tituloVel.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
tituloVel.Text = "Velocidad de Caminar"
tituloVel.TextColor3 = Color3.fromRGB(255, 255, 255)
tituloVel.TextScaled = true
tituloVel.Font = Enum.Font.GothamBold
tituloVel.Parent = panelVelocidad
Instance.new("UICorner", tituloVel).CornerRadius = UDim.new(0, 14)

local contentVel = Instance.new("Frame")
contentVel.Size = UDim2.new(1, -20, 1, -55)
contentVel.Position = UDim2.new(0, 10, 0, 55)
contentVel.BackgroundTransparency = 1
contentVel.Parent = panelVelocidad

local layoutVel = Instance.new("UIListLayout")
layoutVel.Padding = UDim.new(0, 9)
layoutVel.Parent = contentVel

local labelInfoVel = Instance.new("TextLabel")
labelInfoVel.Size = UDim2.new(1, 0, 0, 28)
labelInfoVel.BackgroundTransparency = 1
labelInfoVel.Text = "Escribe un número (30 - 500)"
labelInfoVel.TextColor3 = Color3.fromRGB(200, 200, 200)
labelInfoVel.TextScaled = true
labelInfoVel.Font = Enum.Font.Gotham
labelInfoVel.LayoutOrder = 1
labelInfoVel.Parent = contentVel

local textBoxVel = Instance.new("TextBox")
textBoxVel.Size = UDim2.new(1, 0, 0, 42)
textBoxVel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
textBoxVel.Text = "50"
textBoxVel.PlaceholderText = "Ej: 120"
textBoxVel.TextColor3 = Color3.fromRGB(255, 255, 255)
textBoxVel.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
textBoxVel.TextScaled = true
textBoxVel.Font = Enum.Font.GothamBold
textBoxVel.ClearTextOnFocus = false
textBoxVel.LayoutOrder = 2
textBoxVel.Parent = contentVel
Instance.new("UICorner", textBoxVel).CornerRadius = UDim.new(0, 10)

local btnAplicarVel = crearBoton("APLICAR VELOCIDAD", Color3.fromRGB(0, 180, 100), contentVel, 3)
local btnNormal     = crearBoton("VELOCIDAD NORMAL (16)", Color3.fromRGB(80, 80, 80), contentVel, 4)
local btnVolverVel  = crearBoton("← VOLVER", Color3.fromRGB(60, 60, 60), contentVel, 5)

-- ======================
-- PANEL VOLAR
-- ======================
local panelVolar = Instance.new("Frame")
panelVolar.Size = UDim2.new(0, 270, 0, 320)
panelVolar.Position = UDim2.new(0.5, -135, 0.5, -160)
panelVolar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
panelVolar.Visible = false
panelVolar.Parent = screenGui
Instance.new("UICorner", panelVolar).CornerRadius = UDim.new(0, 14)

local tituloFly = Instance.new("TextLabel")
tituloFly.Size = UDim2.new(1, 0, 0, 45)
tituloFly.BackgroundColor3 = Color3.fromRGB(160, 50, 255)
tituloFly.Text = "Control de Vuelo"
tituloFly.TextColor3 = Color3.fromRGB(255, 255, 255)
tituloFly.TextScaled = true
tituloFly.Font = Enum.Font.GothamBold
tituloFly.Parent = panelVolar
Instance.new("UICorner", tituloFly).CornerRadius = UDim.new(0, 14)

local contentFly = Instance.new("Frame")
contentFly.Size = UDim2.new(1, -20, 1, -55)
contentFly.Position = UDim2.new(0, 10, 0, 55)
contentFly.BackgroundTransparency = 1
contentFly.Parent = panelVolar

local layoutFly = Instance.new("UIListLayout")
layoutFly.Padding = UDim.new(0, 9)
layoutFly.Parent = contentFly

local btnToggleFly = crearBoton("ACTIVAR VUELO", Color3.fromRGB(0, 180, 100), contentFly, 1)

local labelInfoFly = Instance.new("TextLabel")
labelInfoFly.Size = UDim2.new(1, 0, 0, 28)
labelInfoFly.BackgroundTransparency = 1
labelInfoFly.Text = "Velocidad de vuelo (30 - 500)"
labelInfoFly.TextColor3 = Color3.fromRGB(200, 200, 200)
labelInfoFly.TextScaled = true
labelInfoFly.Font = Enum.Font.Gotham
labelInfoFly.LayoutOrder = 2
labelInfoFly.Parent = contentFly

local textBoxFly = Instance.new("TextBox")
textBoxFly.Size = UDim2.new(1, 0, 0, 42)
textBoxFly.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
textBoxFly.Text = "50"
textBoxFly.PlaceholderText = "Ej: 100"
textBoxFly.TextColor3 = Color3.fromRGB(255, 255, 255)
textBoxFly.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
textBoxFly.TextScaled = true
textBoxFly.Font = Enum.Font.GothamBold
textBoxFly.ClearTextOnFocus = false
textBoxFly.LayoutOrder = 3
textBoxFly.Parent = contentFly
Instance.new("UICorner", textBoxFly).CornerRadius = UDim.new(0, 10)

local btnAplicarFly = crearBoton("APLICAR VELOCIDAD VUELO", Color3.fromRGB(0, 140, 255), contentFly, 4)
local btnVolverFly  = crearBoton("← VOLVER", Color3.fromRGB(60, 60, 60), contentFly, 5)

-- ======================
-- FUNCIONES
-- ======================
local function aplicarVelocidadCaminar(valor)
	local num = tonumber(valor)
	if not num then return end
	num = math.clamp(num, VELOCIDAD_MIN, VELOCIDAD_MAX)

	local char = player.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = num
			estadoVelocidad = num
			textBoxVel.Text = tostring(num)
		end
	end
end

local function detenerVuelo()
	volando = false
	if flyConnection then
		flyConnection:Disconnect()
		flyConnection = nil
	end
	if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
	if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end

	local char = player.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.PlatformStand = false
		end
	end

	btnToggleFly.Text = "ACTIVAR VUELO"
	btnToggleFly.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
end

local function iniciarVuelo()
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end

	volando = true
	hum.PlatformStand = true

	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.zero
	bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	bodyVelocity.Parent = root

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	bodyGyro.P = 3000
	bodyGyro.Parent = root

	btnToggleFly.Text = "DESACTIVAR VUELO"
	btnToggleFly.BackgroundColor3 = Color3.fromRGB(200, 50, 50)

	flyConnection = RunService.RenderStepped:Connect(function()
		if not volando or not root or not bodyVelocity or not hum then return end

		local cam = workspace.CurrentCamera
		local moveDir = hum.MoveDirection

		if moveDir.Magnitude > 0.05 then
			local velocity = (cam.CFrame.LookVector * moveDir.Z + cam.CFrame.RightVector * moveDir.X) * FLY_SPEED
			bodyVelocity.Velocity = velocity
		else
			bodyVelocity.Velocity = Vector3.zero
		end

		bodyGyro.CFrame = cam.CFrame
	end)
end

-- NOCLIP
local function activarNoclip()
	noclipActivo = true
	btnNoclip.Text = "👻 NOCLIP: ON"
	btnNoclip.BackgroundColor3 = Color3.fromRGB(0, 200, 80)

	noclipConnection = RunService.Stepped:Connect(function()
		local char = player.Character
		if char then
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end)
end

local function desactivarNoclip()
	noclipActivo = false
	btnNoclip.Text = "👻 NOCLIP: OFF"
	btnNoclip.BackgroundColor3 = Color3.fromRGB(255, 140, 0)

	if noclipConnection then
		noclipConnection:Disconnect()
		noclipConnection = nil
	end

	local char = player.Character
	if char then
		for _, part in pairs(char:GetDescendants()) do
			if part:IsA("BasePart") and part.Name \~= "HumanoidRootPart" then
				part.CanCollide = true
			end
		end
	end
end

-- ======================
-- CONEXIONES
-- ======================

btnFlotante.MouseButton1Click:Connect(function()
	menuAbierto = not menuAbierto
	mainFrame.Visible = menuAbierto
	panelVelocidad.Visible = false
	panelVolar.Visible = false

	if menuAbierto then
		btnFlotante.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
	else
		btnFlotante.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	end
end)

btnVelocidad.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	panelVelocidad.Visible = true
end)

btnVolar.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	panelVolar.Visible = true
end)

btnNoclip.MouseButton1Click:Connect(function()
	if noclipActivo then
		desactivarNoclip()
	else
		activarNoclip()
	end
end)

btnCerrar.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	menuAbierto = false
	btnFlotante.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
end)

btnVolverVel.MouseButton1Click:Connect(function()
	panelVelocidad.Visible = false
	mainFrame.Visible = true
	menuAbierto = true
end)

btnVolverFly.MouseButton1Click:Connect(function()
	panelVolar.Visible = false
	mainFrame.Visible = true
	menuAbierto = true
end)

btnAplicarVel.MouseButton1Click:Connect(function()
	aplicarVelocidadCaminar(textBoxVel.Text)
end)

btnNormal.MouseButton1Click:Connect(function()
	local char = player.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = VELOCIDAD_NORMAL
			estadoVelocidad = VELOCIDAD_NORMAL
			textBoxVel.Text = tostring(VELOCIDAD_NORMAL)
		end
	end
end)

btnToggleFly.MouseButton1Click:Connect(function()
	if volando then
		detenerVuelo()
	else
		iniciarVuelo()
	end
end)

btnAplicarFly.MouseButton1Click:Connect(function()
	local num = tonumber(textBoxFly.Text)
	if num then
		FLY_SPEED = math.clamp(num, VELOCIDAD_MIN, VELOCIDAD_MAX)
		textBoxFly.Text = tostring(FLY_SPEED)
	end
end)

player.CharacterAdded:Connect(function(char)
	task.wait(0.5)
	local hum = char:WaitForChild("Humanoid", 5)
	if hum then
		hum.WalkSpeed = estadoVelocidad
	end
	if volando then detenerVuelo() end
	if noclipActivo then
		desactivarNoclip()
		task.wait(0.3)
		activarNoclip()
	end
end)

print("✅ itzkbra Hub cargado correctamente")
