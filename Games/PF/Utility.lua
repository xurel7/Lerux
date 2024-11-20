local module = {}
local US = UserSettings()

local GetService = cloneref or function(...) return ... end

local Players = GetService(game:GetService("Players")) :: Players
local Teams = GetService(game:GetService("Teams")) :: Teams
local Lighting = GetService(game:GetService("Lighting"))
local UserGameSettings = GetService(US:GetService("UserGameSettings"))
local Workspace = GetService(game:GetService("Workspace"))
local TweenService = GetService(game:GetService("TweenService"))


local LocalPlayer = Players.LocalPlayer
local TweenInfo1 = TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local Bodyparts = {
  ["Head"] = "rbxassetid://6179256256",
  ["Torso"] = "rbxassetid://4049240078"
}

function module.getMouseSens()
  return UserGameSettings.MouseSensitivity + 0.1 or 0.3 -- slight padding to prevent jittering on 0 smoothing
end

function module.getLightingVal(properties: {string}): {[string]: any}
  local Values = {}
  local MapLighting = Lighting:FindFirstChild("MapLighting")
  if not MapLighting then
    return
  end
  for i, v in ipairs(properties) do
    Values[v] = MapLighting[v].Value
  end
  return Values
end

function module.getPlrArms(): {Model}
  local Camera = Workspace.CurrentCamera
  local Arms = {}
  for i, v in ipairs(Camera:GetChildren()) do
    if not v:IsA("Model") or not v:FindFirstChild("Arm") then
      continue
    end
    table.insert(Arms, v)
    if #Arms == 2 then
      break
    end
  end
  return Arms
end

function module.getPlrGun(): Model
  local Camera = Workspace.CurrentCamera
  for i, v in ipairs(Camera:GetChildren()) do
    if not v:IsA("Model") or v:FindFirstChild("Arm") then
      continue
    end
    return v
  end
end

function module.new(inst: Instance, properties): Instance
  local instance = Instance.new(inst)
  for i, v in pairs(properties) do
    instance[i] = v
  end

  return instance
end

function module.plrAllied(Character: Model): boolean
  if not Character then
    return true
  end
  local HF = Character:FindFirstChildOfClass("Folder")
  local H = HF and HF:FindFirstChildOfClass("MeshPart")
  if not HF then
    return true
  end
  if H.BrickColor == BrickColor.new("Black") then
    return Teams.Phantoms == LocalPlayer.Team
  end
  return Teams.Ghosts == LocalPlayer.Team
end

function module.getBodypart(Character: Model, Bodypart: string): BasePart
  local Target = Bodyparts[Bodypart] or Bodyparts["Head"]
  for _, Part in ipairs(Character:GetChildren()) do
    local SpecialMesh = Part:FindFirstChildOfClass("SpecialMesh")
    if not SpecialMesh then
        continue
    end
    if SpecialMesh.MeshId == Target then
        return Part
    end
  end
end

function module.addESPtoModel(tbl: {[string]: any})
  local isAlly = module.plrAllied(tbl["Adornee"])
  if tbl["Parent"]:FindFirstChild(tbl["Adornee"].Name) or isAlly then
    return
  end
  local components = {}
  if tbl["ChamsEnabled"] then
    local hl = module.new("Highlight",{
        Parent = tbl["Parent"],
        Adornee = tbl["Adornee"],
        FillColor = tbl["FillColor"],
        OutlineColor = tbl["OutlineColor"],
        FillTransparency = tbl["FillTransparency"],
        OutlineTransparency = tbl["OutlineTransparency"],
        Enabled = true,
        Name = tbl["Adornee"].Name
    })
    table.insert(components,hl)
  end
  if tbl["IndicatorEnabled"] then
    local bg = module.new("BillboardGui",{
      Parent = tbl["Parent"],
      Adornee = tbl["Adornee"],
      AlwaysOnTop = true,
      LightInfluence = 0,
      Size = UDim2.new(1,0,1,0),
      StudsOffset = Vector3.new(0,3.2,0),
      Name = tbl["Adornee"].Name
    })
    local f = module.new("Frame",{
      Parent = bg,
      AnchorPoint = Vector2.new(0.5,0.5),
      Size = UDim2.new(1,0,1,0),
      BackgroundColor3 = tbl["IndicatorColor"],
      BackgroundTransparency = tbl["IndicatorTransparency"],
      BorderSizePixel = 0
    })
    module.new("UICorner",{
      Parent = f,
      CornerRadius = UDim.new(100,0)
    })
    table.insert(components,bg)
  end

  tbl["Adornee"].Destroying:Once(function()
    for i, v in ipairs(components) do
      v:Destroy()
    end
  end)
end

--[[
how to properly use function (incase i forget)

module.addESPtoModel({
  ["IndicatorEnabled"] = boolean,
  ["ChamsEnabled"] = boolean,
  ["Parent"] = Folder,
  ["Adornee"] = Model,
  ["FillColor"] = Color3,
  ["OutlineColor"] = Color3,
  ["IndicatorColor"] = Color3,
  ["FillTransparency"] = number,
  ["OutlineTransparency"] = number,
  ["IndicatorTransparency"] = number
})
]]

function module.updateESP(tbl: {string: any})
  for i, v in ipairs(tbl["Parent"]:GetChildren()) do
    if v:IsA("Highlight") then
      v.FillColor = tbl["FillColor"]
      v.FillTransparency = tbl["FillTransparency"]
      v.OutlineColor = tbl["OutlineColor"]
      v.OutlineTransparency = tbl["OutlineTransparency"]
    end
    if v:IsA("BillboardGui") then
      local indicator = v:GetChildren()[1]
      if not indicator then
        continue
      end
      indicator.BackgroundColor3 = tbl["IndicatorColor"]
      indicator.BackgroundTransparency = tbl["IndicatorTransparency"]
    end
  end
end

--[[
module.updateESP({
  ["Parent"]  = Folder,
  ["FillColor"] = Color3,
  ["OutlineColor"] = Color3,
  ["IndicatorColor"] = Color3,
  ["FillTransparency"] = number,
  ["OutlineTransparency"] = number,
  ["IndicatorTransparency"] = number,
})
]]

function module.targetPlr(tbl: {string: any})
  local Fill = tbl["FOV"]:GetChildren()[1]
  local Outline = Fill.UIStroke
  local Indicator
  for i, v in ipairs(tbl["Folder"]:GetChildren()) do
    if v.Name == tbl["Target"].Name and v:IsA("BillboardGui") then
      Indicator = v
      break
    end
  end
  if not Indicator then
      return
  end
  if tbl["Targeted"] then
    TweenService:Create(Fill, TweenInfo1, { BackgroundColor3 = Color3.fromRGB(255, 138, 138) }):Play()
    TweenService:Create(Outline, TweenInfo1, { Color = Color3.fromRGB(255, 138, 138) }):Play()
    if Indicator then
      TweenService:Create(Indicator:GetChildren()[1], TweenInfo1, { BackgroundColor3 = Color3.fromRGB(255, 138, 138) }):Play()
    end
    return
  end
  TweenService:Create(Fill, TweenInfo1, { BackgroundColor3 = tbl["FOVColor"] }):Play()
  TweenService:Create(Outline, TweenInfo1, { Color = tbl["FOVColor"] }):Play()
  if Indicator then
    TweenService:Create(Indicator:GetChildren()[1], TweenInfo1, { BackgroundColor3 = tbl["IndicatorColor"] }):Play()
  end
end

--[[
module.targetPlr({
  ["FOV"] = ScreenGui,
  ["Target"] = Model,
  ["Folder"] = Folder,
  ["Targeted"] = boolean,
  ["IndicatorColor"] = Color3,
  ["FOVColor"] = Color3
})
]]

return module
