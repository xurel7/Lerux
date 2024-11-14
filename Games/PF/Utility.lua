local module = {}

local GetService = cloneref or function(...) return ... end

local Players = GetService(game:GetService("Players")) :: Players
local Teams = GetService(game:GetService("Teams")) :: Teams

local LocalPlayer = Players.LocalPlayer

local Bodyparts = {
  ["Head"] = "rbxassetid://6179256256",
  ["Torso"] = "rbxassetid://4049240078"
}

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
    if Part:IsA("SpecialMesh") and Part.MeshId == Target then
      return Part
    end
  end
end

return module
