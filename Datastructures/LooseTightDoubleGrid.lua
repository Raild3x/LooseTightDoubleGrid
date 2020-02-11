local function clamp(v,lower,upper)
    return math.min(upper,math.max(lower,v))
end


local LooseCell = {}
LooseCell.__index = LooseCell

function LooseCell.new()
    local self = setmetatable({
        head,
        l,r,t,b
    }, LooseCell)
    return self
end


local TightCell = {}
TightCell.__index = TightCell

function TightCell.new()
    local self = setmetatable({

    }, TightCell)
    return self
end

local LTDG = {}
LTDG.__index = LTDG

function LTDG.new(height,width)
    local self = setmetatable({
        TightGrid = {}
        tCols = width,
        tRows = height
    }, LooseCell)
    return self
end

function LTDG:SearchBox(x1,y1,x2,y2,w,h)
    tx1 = clamp(math.floor(x1))
end