-- wget -f 'https://raw.githubusercontent.com/Pozitrone/Base-Control/master/AroLib.lua' /home/arolib.lua

-- import these functions using
-- arolib = require("arolib")

-- run using
-- arolib.function()

---------------------------------------

-- Imports

local sides = require("sides")
local colors = require("colors")
local event = require("event")

-- Colors
clrRed = 0xFF0000
clrBlue = 0x0000FF
clrGreen = 0x0FF00
clrWhite = 0xFFFFFF
clrBlack = 0x000000
clrYellow = 0xFFFF00
clrOrange = 0xFFAA00

-- Functions

function tempBar(temp,x,y,maxtemp,gpu)
--    local gpu = require("component").gpu
    local bg = gpu.getBackground();
    tempStage = math.floor(temp/(maxtemp/40));
    for i = 0, tempStage, 1 do
        if tempStage >= 0 then
            gpu.setBackground(0xFF0000)
        elseif tempStage >= 5 then
            gpu.setBackground(0xFF2400)
        elseif tempStage >= 10 then
            gpu.setBackground(0xFF4900)
        elseif tempStage >= 15 then
            gpu.setBackground(0xFF6D00)
        elseif tempStage >= 20 then
            gpu.setBackground(0xCC9200)
        elseif tempStage >= 25 then
            gpu.setBackground(0xCCB600)
        elseif tempStage >= 30 then
            gpu.setBackground(0xCCDB00)
        elseif tempStage >= 35 then
            gpu.setBackground(0xCCFF00)
        else
            gpu.setBackground(0x00FF00)
        end
        gpu.fill(x,y+40-i,20,1," ")
    end
    gpu.setBackground(bg)
end

-- Library

local arolib = {}

function arolib.help()
    print("tps(): number - calculates TPS")
    print("farmsControl(): void - outputs redstone in the front if TPS > 15")
    print("colortps(tps: number): void - prints out tps in a color")
    print("draconicCore(): void - constant status of Draconic storage core")
    print("reset(): void - resets the resolution")
    print("extremeReactorStats(): void - controls for extremeReactors")
    print("help() - shows this list")
end


function arolib.tps() -- TPS function by Nex4rius
    if not pcall(
        function()
            local function time()
                local f = io.open("/tmp/TPS","w")
                f:write("Woof!")
                f:close()
                return(require("filesystem").lastModified("/tmp/TPS"))
            end

            local realTimeOld = time()
            os.sleep(1)
            ticks = 20000 / (time() - realTimeOld)
            if ticks > 20 then
                return 20
            else
                return ticks
            end
        end
    ) then
        print("An Error ocurred. Your harddrive might not have enough capacity.")
    end
end


function arolib.farmsControl() -- Outputs redstone from the back, when tps > 15, else stops the signal. Checks every 10 seconds.
    if not pcall(
        function()
            while true do
                local tps = tps()
                if tps > 15 then
                    print("TPS status nominal, farms running.")
                    colortps(tps)
                    require("component").redstone.setOutput(sides.back, 15)
                else
                    print("TPS are too low, farm are not running!")
                    colortps(tps)
                    require("component").redstone.setOutput(sides.back, 0)
                end
                os.sleep(10)
            end
        end
    ) then
        print("An Error occured. Check, if a redstone card is present.")
    end
end


function arolib.colortps() -- Prints out TPS in according color
    if not pcall(
        function()
            tps = arolib.tps()
            if tps > 15 then
                require("component").gpu.setForeground(clrGreen)
            elseif tps > 5 then
                require("component").gpu.setForeground(clrOrange)
            else
                require("component").gpu.setForeground(clrRed)
            end
            print(tps)
            require("component").gpu.setForeground(clrWhite)
        end
    ) then
        print("An error occured.")
    end
end


function arolib.draconicCore()
    if not pcall(
        function()
            local core = require("component").draconic_rf_storage
            print("use arolib.reset(), or reboot, to reset the Resolution back.");
            os.sleep(4)
            require("component").gpu.setResolution(40,7);
            require("term").clear()
            while true do
                print("Energy stored: ")
                print(core.getEnergyStored())
                print("Maximum energy: ")
                print(core.getMaxEnergyStored())
                print("Transfering: ")
                local rate = core.getTransferPerTick()
                if rate > 0 then 
                    require("component").gpu.setForeground(clrGreen)
                else
                    require("component").gpu.setForeground(clrRed)
                end
                print(rate)
                require("component").gpu.setForeground(clrWhite)
                os.sleep(1)
            end
        end
    ) then
        print("An error occured. Please, make sure a draconic energy storage core is connected.")
    end
end

function arolib.reset()
    if not pcall(
        function()
            require("component").gpu.setResolution(160,50);
            require("term").clear()
        end
    ) then
        print("An error occured.")
    end
end

function arolib.extremeReactorStats()
    local term = require("term")
    local gpu = require("component").gpu
    local reactor = require("component").br_reactor

    

    term.clear()
    
    gpu.setBackground(0xD2D2D2)

    gpu.fill(3,1,74,3," ") --reactor name
    gpu.fill(87,1,74,3," ") --reactor type

    gpu.fill(7,5,46,3," ") --Temperatures

    --gpu.fill(7,9,20,40," ") --Core temp bar
    --gpu.fill(33,9,20,40," ") --Casing temp bar

    gpu.fill(60,36,40,13," ") --battery main
    gpu.fill(100,41,2,3," ") --battery bit

    --button
    gpu.fill(108,36,44,13," ") --button
    --end button

    --Core temperature
    local coreTemp = reactor.getFuelTemperature()
    tempBar(coreTemp,7,9,2000,gpu)

    local casingTemp = reactor.getCasingTemperature()
    tempBar(casingTemp,33,9,2000,gpu)
    os.sleep(10)
end


return arolib
        