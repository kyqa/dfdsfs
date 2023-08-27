local Services = {
    Storage = game:GetService("ReplicatedStorage"),
    Workspace = game:GetService("Workspace"),
    Players = game:GetService("Players"),
    Tween = game:GetService("TweenService"),
    UserInput = game:GetService("UserInputService")
}

local module = {
    Settings = {
        AssetsFolder = "",
        AwayInfo = nil,
        HomeInfo = nil,
        IsDay = true
    }
}

-----------------------------------------------------------------------
-- Script API Declarations
-----------------------------------------------------------------------
local getcustomasset = getsynasset or getcustomasset

-----------------------------------------------------------------------
-- Final
-----------------------------------------------------------------------
local FFValues = Services["Storage"].Values

-----------------------------------------------------------------------
-- Static
-----------------------------------------------------------------------

-----------------------------------------------------------------------
-- Functions
-----------------------------------------------------------------------
function FindNumbers(children, inner, stroke)
    for i,v in ipairs(children) do
        if (v:IsA("TextLabel")) then
            v.TextColor3 = inner
            v.TextStrokeColor3 = stroke
        elseif (#v:GetChildren() > 0) then
            FindNumbers(v:GetChildren(), inner, stroke)
        end
    end
end

function Helm(player, teamInfo, pos)
    task.spawn(function()
	print("Reached Helm")
        local uniform = player.Character:WaitForChild("Uniform")
    	uniform.Helmet.RightLogo.Decal.Texture = teamInfo["Colors"]["Jersey"][pos]["Logo"]
    	uniform.Helmet.LeftLogo.Decal.Texture = teamInfo["Colors"]["Jersey"][pos]["Logo"]
    end)
end

function set(player, teamInfo, pos)
    task.spawn(function()
	local uniform = player.Character:WaitForChild("Uniform")
	uniform.ShoulderPads.Front.Team.Text = string.upper(teamInfo["Name"])
        uniform.ShoulderPads.Color = Color3.fromHex(teamInfo["Colors"]["Jersey"][pos]["Jersey"])
        uniform.Shirt.Color = Color3.fromHex(teamInfo["Colors"]["Jersey"][pos]["Jersey"])
        uniform.LeftShortSleeve.Color = Color3.fromHex(teamInfo["Colors"]["Jersey"][pos]["Jersey"])
        uniform.RightShortSleeve.Color = Color3.fromHex(teamInfo["Colors"]["Jersey"][pos]["Jersey"])
        uniform.LeftPit.Color = Color3.fromHex(teamInfo["Colors"]["Jersey"][pos]["Jersey"])
        uniform.RightPit.Color = Color3.fromHex(teamInfo["Colors"]["Jersey"][pos]["Jersey"])
        uniform.LeftPants.Color = Color3.fromHex(teamInfo["Colors"]["Jersey"][pos]["Pants"])
        uniform.RightPants.Color = Color3.fromHex(teamInfo["Colors"]["Jersey"][pos]["Pants"])
        uniform.LeftGlove.Color = Color3.fromHex(teamInfo["Colors"]["Jersey"][pos]["Stripe"])
        uniform.LeftShoe.Color = Color3.fromHex(teamInfo["Colors"]["Jersey"][pos]["Stripe"])
        uniform.LeftSock.Color = Color3.fromHex(teamInfo["Colors"]["Jersey"][pos]["Stripe"])
        uniform.RightGlove.Color = Color3.fromHex(teamInfo["Colors"]["Jersey"][pos]["Stripe"])
        uniform.RightShoe.Color = Color3.fromHex(teamInfo["Colors"]["Jersey"][pos]["Stripe"])
        uniform.RightSock.Color = Color3.fromHex(teamInfo["Colors"]["Jersey"][pos]["Stripe"])
        FindNumbers(uniform:GetChildren(), Color3.fromHex(teamInfo["Colors"]["Jersey"][pos]["NumberInner"]), Color3.fromHex(teamInfo["Colors"]["Jersey"][pos]["NumberStroke"]))
    end)
end

function SetJersey(player, teamInfo, pos)
    pcall(function()
        if not player.Character then
            return
        end

        task.spawn(function()
            local uniform = player.Character:WaitForChild("Uniform")
            wait(0.5)

            if not uniform:FindFirstChild("Helmet") then
                return
            end

            -- Setting Helmet
            uniform.Helmet.Mesh.TextureId = teamInfo["Colors"]["Jersey"][pos]["HelmetTexture"]

            local logo = uniform.Helmet:FindFirstChild("RightLogo")

            if not logo then		
                set(player, teamInfo, pos)
            else
                Helm(player, teamInfo, pos)
                set(player, teamInfo, pos)
            end
        end)
    end)
end


function SetTime(time)
    --TODO (night/day)
end

function module:SetTeams(awayInfo, homeInfo)
    module.Settings.AwayInfo = awayInfo
    module.Settings.HomeInfo = homeInfo

    -- Setting Stadium Colors --
    print("[ENVIROMENT] Setting the Stadium's colors.")
    local Stadium = Services["Workspace"].Models.Stadium
    for i,v in ipairs(Stadium.Seats:GetChildren()) do
        v.Color = Color3.fromHex(module.Settings.HomeInfo.Colors.Normal.Main)
    end
    for i,v in ipairs(Stadium.PressSeats:GetChildren()) do
        v.Color = Color3.fromHex(module.Settings.HomeInfo.Colors.Normal.Light)
    end
    for i,v in ipairs(Stadium.Barrier.PrimaryPads:GetChildren()) do
        v.Color = Color3.fromHex(module.Settings.HomeInfo.Colors.Normal.Main)
    end
    for i,v in ipairs(Stadium.Barrier.SecondaryPads:GetChildren()) do
        v.Color = Color3.fromHex(module.Settings.HomeInfo.Colors.Normal.Light)
    end
    Services["Workspace"].Models.Uprights1.FGparts.Base.Color = Color3.fromHex(module.Settings.HomeInfo.Colors.Normal.Main)
    Services["Workspace"].Models.Uprights2.FGparts.Base.Color = Color3.fromHex(module.Settings.HomeInfo.Colors.Normal.Main)

    -- Setting Field --
    local Field = Services["Workspace"].Models.Field
    Field.Grass.Normal.Mid.SurfaceGui.ImageLabel.Image = "rbxassetid://14414169471"
    Field.Grass.Normal.Mid.SurfaceGui.ImageLabel.ScaleType = Enum.ScaleType.Fit

    if (Field.Grass.Endzone.One:FindFirstChild("SurfaceGui")) then
        print("[ENVIROMENT] Removing default Endzone Decal #1.")
        Field.Grass.Endzone.One.SurfaceGui:Destroy()
    end
    if (Field.Grass.Endzone.Two:FindFirstChild("SurfaceGui")) then
        print("[ENVIROMENT] Removing default Endzone Decal #2.")
        Field.Grass.Endzone.Two.SurfaceGui:Destroy()
    end

    if (module.Settings.HomeInfo.Colors.Endzone) then
        print("[ENVIROMENT] Setting Endzone Color #1.")
        Field.Grass.Endzone.One.Color = Color3.fromHex(module.Settings.HomeInfo.Colors.Endzone)
    end
    if (module.Settings.AwayInfo.Colors.Endzone) then
        print("[ENVIROMENT] Setting Endzone Color #2.")
        Field.Grass.Endzone.Two.Color = Color3.fromHex(module.Settings.HomeInfo.Colors.Endzone)
    end

    -- Setting Jerseys --
    for i,player in ipairs(Services["Players"]:GetPlayers()) do
        print("[ENVIROMENT] Set " .. player.Name .. "'s Jersey")
        if (player.Team.Name == FFValues.Home.Value.Name) then
            SetJersey(player,module.Settings["HomeInfo"],"Home")
        else
            SetJersey(player,module.Settings["AwayInfo"],"Away")
        end
    end
end


function module:SetTime(isDay)
    module.Settings.IsDay = isDay
end

FFValues.Away.Changed:Connect(function(team)
    if (team and team:IsA("Team")) then
        team.PlayerAdded:Connect(function(player)
            if (module.Settings["AwayInfo"]) then
                print("[ENVIROMENT] Set " .. player.Name .. "'s Jersey")
                SetJersey(player,module.Settings["AwayInfo"],"Away")
            end
        end)
    end
end)
FFValues.Home.Changed:Connect(function(team)
    if (team and team:IsA("Team")) then
        team.PlayerAdded:Connect(function(player)
            if (module.Settings["HomeInfo"]) then
                print("[ENVIROMENT] Set " .. player.Name .. "'s Jersey")
                SetJersey(player,module.Settings["HomeInfo"],"Home")
            end
        end)
    end
end)

Services["Players"].PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        print("[ENVIROMENT] Set " .. player.Name .. "'s Jersey")
        if (player.Team.Name == FFValues.Home.Value.Name) then
            SetJersey(player,module.Settings["HomeInfo"],"Home")
        else
            SetJersey(player,module.Settings["AwayInfo"],"Away")
        end
    end)
end)

Services["Workspace"].DescendantAdded:Connect(function(model)
    if (model:IsA("Model")) then
        if (model.Name == "Kicker" or model.Name == "Punter") then
            if (model:WaitForChild("Humanoid")) then
                if (FFValues.PossessionTag.Value == FFValues.Home.Value.Name) then
                    if (model.Name == "Kicker") then
                        SetJersey({Character = model},module.Settings["AwayInfo"],"Away")
                    else
                        SetJersey({Character = model},module.Settings["HomeInfo"],"Away")
                    end
                else
                    if (model.Name == "Kicker") then
                        SetJersey({Character = model},module.Settings["HomeInfo"],"Home")
                    else
                        SetJersey({Character = model},module.Settings["AwayInfo"],"Home")
                    end
                end
                print("[ENVIROMENT] Set " .. model.Name .. "'s Jersey")
                return
            end
        end

        if (FFValues.StatusTag.Value == "REPLAY") then
            local player
            for i,v in ipairs(Services["Players"]:GetPlayers()) do
                if (v.Name == model.Name) then
                    player = v
                end
            end

            if (player) then
                print("[ENVIROMENT] Set " .. player.Name .. "'s Replay Jersey")
                if (player.Team.Name == FFValues.Home.Value.Name) then
                    SetJersey({Character = model},module.Settings["HomeInfo"],"Home")
                else
                    SetJersey({Character = model},module.Settings["AwayInfo"],"Away")
                end
            end
        end
    end
end)

for i,player in ipairs(Services["Players"]:GetPlayers()) do
    player.CharacterAdded:Connect(function(character)
        print("[ENVIROMENT] Set " .. player.Name .. "'s Jersey")
        if (player.Team.Name == FFValues.Home.Value.Name) then
            SetJersey(player,module.Settings["HomeInfo"],"Home")
        else
            SetJersey(player,module.Settings["AwayInfo"],"Away")
        end
    end)
end

game.StarterGui:SetCore("SendNotification", {Title = "enzo8000", Text = "Success, Jersey Script Loaded!", Duration = 4,})
return module
