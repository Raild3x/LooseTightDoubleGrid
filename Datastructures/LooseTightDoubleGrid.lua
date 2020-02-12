local function clamp(v,lower,upper)
    return math.min(upper,math.max(lower,v))
end


local LooseCell = {}
LooseCell.__index = LooseCell

function LooseCell.new()
    local self = setmetatable({
        head, -- LL of entities(node) in the loose cell
        l,r,t,b -- bounding box extents from TR corner
    }, LooseCell)
    return self
end

function LooseCell:Insert(entity)

end


local Node = {}
Node.__index = Node

function Node.new()
    local self = setmetatable({
        next, -- Points to next loose cell node in the tight cell
        value -- stores an index to the loose cell
    }, Node)
    return self
end


local TightCell = {}
TightCell.__index = TightCell

function TightCell.new()
    local self = setmetatable({
        head -- stores the index to the first loose cell node in the tight cell using an index SLL
    }, TightCell)
    return self
end


local LTDG = {}
LTDG.__index = LTDG

function LTDG.new(height,width,cellWidth,cellHeight)
    local TG = {}
    --local LN = {}
    local LG = {}
    for i = 1, height*width do
        TG[i] = TightCell.new();
        --LN[i] = Node.new();
        LG[i] = LooseCell.new();
    end

    local self = setmetatable({
        TightGrid = TG,
        LooseGrid = LG,
        tCols = width,
        tRows = height,
        cWidth = cellWidth,
        cHeight = cellHeight
    }, LTDG);

    return self
end

function LTDG:Draw()
    for y = 0, self.tRows-1 do
        for x = 0, self.tCols-1 do
            love.graphics.rectangle("line", x*self.cWidth, y*self.cHeight, self.cWidth, self.cHeight);
        end
    end
end

function LTDG:Insert(entity)
    local cX = clamp(math.floor(entity.x/self.cWidth), 1, self.tCols)
    local cY = clamp(math.floor(entity.y/self.cHeight), 1, self.tRows)
    local index = cY*self.tRows + cX; -- double check this later
    -- insert element to cell at 'index' and expand the loose cell's AABoundingBox
    self.LooseGrid[index]:Insert(entity);
end

function LTDG:SearchBox(x1,y1,x2,y2)
    local tx1 = clamp(math.floor(x1/self.cWidth), 1, self.tCols);
    local tx2 = clamp(math.floor(x2/self.cWidth), 1, self.tCols);
    local ty1 = clamp(math.floor(y1/self.cHeight), 1, self.tRows);
    local ty2 = clamp(math.floor(y2/self.cHeight), 1, self.tRows);

    local intersectingEntities = {};

    for ty = ty1, ty2 do
        local trow = ty*self.tCols;
        for tx = tx1, tx2 do
            local tightCell = self.TightGrid[trow + tx];
            local looseNode = tightCell.head;
            while looseNode do -- for each looseCell in tightCell
                local looseCell = self.LooseGrid[looseNode.value];
                if looseCell:Intersects(x1,y1,x2,y2) then -- if looseCell intersects search area
                    local entity = looseCell.head;
                    while entity do -- for each entity in loose cell
                        if entity:Intersects(x1,y1,x2,y2) then
                            table.insert(intersectingEntities, entity.value)-- add entity to query results
                        end
                        entity = entity.next;
                    end
                end
                looseCell = looseCell.next;
            end
        end
    end
    return intersectingEntities;
end

return LTDG;