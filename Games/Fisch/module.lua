game.Loaded:Wait()

local cloneser = cloneref or function(...) return ... end

local Players = cloneser(game:GetService("Players")) :: Players
local GuiService = cloneser(game:GetService("GuiService")) :: GuiService
local VirtualInputManager = cloneser(game:GetService("VirtualInputManager")) :: VirtualInputManager
local ReplicatedStorage = cloneser(game:GetService("ReplicatedStorage")) :: ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local ReelEnd = ReplicatedStorage:WaitForChild("events",10) and
  ReplicatedStorage.events:WaitForChild("reelfinished",10)

local Rod

local Character = LocalPlayer.Character

LocalPlayer.CharacterAdded:Connect(function(c)
  Character = c
end)

Character.ChildAdded:Connect(function(child)
  if child:IsA("Tool") and child.Name:lower():find("rod") then
    Rod = child
  end
end)

Character.ChildRemoved:Connect(function(child)
  if child == Rod then
      Rod = nil
      GuiService.SelectedObject = nil
  end
end)

if Character then
  for i, v in ipairs(Character:GetChildren()) do
    if v:IsA("Tool") and v.Name:lower():find("rod") then
      Rod = v
      break
    end
  end
end

local module = {}

local function Click(Button: ImageButton) -- this function is a little retarded :heartbreak: just incase user keeps trying to type in chat theres a bunch of debug to keep going
    while Button and Button.Visible do
        repeat task.wait()
            GuiService.SelectedObject = Button
        until GuiService.SelectedObject == Button
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
        task.delay(0.5,function()
            if Button.Visible then
                Button.Visible = false
                task.wait()
                Button.Visible = true
            end
        end)
        Button:GetPropertyChangedSignal("Visible"):Wait()
        GuiService.SelectedObject = nil
        for i = 1, 2 do
            task.wait()
        end
    end
end

function module.reel(reelui: PlayerGui, method: string)
  local Bar = reelui:WaitForChild("bar",10)
  local PlayerBar = Bar and
    Bar:WaitForChild("playerbar",10)
  local fish = Bar and
    Bar:WaitForChild("fish",10)

  PlayerBar:GetPropertyChangedSignal("Position"):Wait()
  if method:lower() ~= "legit" then
    ReelEnd:FireServer(100,true)
    return
  end
  repeat task.wait()
    PlayerBar.Position = fish.Position
  until not reelui
end

function module.getRod()
  return Rod
end

function module.shake(shakeui: PlayerGui)
  local Safezone = shakeui:WaitForChild("safezone",10)
  if not Safezone then
    return
  end
  Safezone.ChildAdded:Connect(function(Child)
    if Child.Name == "button" then
      Click(Child)
    end
  end)
  if Safezone:FindFirstChild("button") then
    Click(Safezone.button)
  end
end

return module
