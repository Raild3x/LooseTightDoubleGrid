local function clamp(v,lower,upper)
    return math.min(upper,math.max(lower,v))
end

local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < w2 and
           x2 < w1 and
           y1 < h2 and
           y2 < h1
end

local Node = {}
Node.__index = Node

function Node.new(v,n)
    local self = setmetatable({
        value = v, -- stores an index to the loose cell
        next = n -- Points to next loose cell node in the tight cell
    }, Node)
    return self
end


local LooseCell = {};
LooseCell.__index = LooseCell;

function LooseCell.new(l,r,t,b)
    local x = (r-l)/2+l
    local y = (b-t)/2+t
    local self = setmetatable({
        head, -- LL of entities(node) in the loose cell
        
        x = x,
        y = y,
        -- bounding box extents from TR corner
        l = x,
        r = x,
        t = y,
        b = y 
    }, LooseCell)
    print(l,r,t,b)
    return self
end


function LooseCell:Intersects(x1,x2,y1,y2)
    return CheckCollision(self.l,self.t,self.r,self.b, x1,y1,x2,y2);
end

function LooseCell:Insert(entity)
    local container = Node.new(entity, self.head);
    self.head = container;
end

function LooseCell:UpdateExtents()
    local n = self.head
    local v = n.value
    local l,r,t,b = v:AABB();
    self.l = l;--self.x;
    self.r = r;--self.x;
    self.t = t;--self.y;
    self.b = b;--self.y;
    n = n.next;
    while n do
        local v = n.value
        local l,r,t,b = v:AABB();
        --print(l,self.l)
        self.l = math.min(l,self.l);
        self.r = math.max(r,self.r);
        self.t = math.min(t,self.t);
        self.b = math.max(b,self.b);
        n = n.next
    end
end

function LooseCell:Remove(entity)
    local n = self.head
    if entity == n.value then
        self.head = n.next
        self.l = self.x;
        self.r = self.x;
        self.t = self.y;
        self.b = self.y;
    else
        local nn = n.next
        while nn do
            if nn.value == entity then
                n.next = nn.next
                break
            end
            n = nn
            nn = nn.next
        end
    end
end





local TightCell = {}
TightCell.__index = TightCell

function TightCell.new(idx)
    local self = setmetatable({
        head = Node.new(idx) -- stores the index to the first loose cell node in the tight cell using an index SLL
    }, TightCell)
    return self
end


local LTDG = {}
LTDG.__index = LTDG

function LTDG.new(width, height, cellWidth, cellHeight)
    local TG = {}
    --local LN = {}
    local LG = {}
    for i = 1, height*width do
        TG[i] = TightCell.new(i);
        --LN[i] = Node.new();
        local l = (i-1)%width*cellWidth
        local b = ((math.floor((i-1)/height))%height)*cellHeight
        LG[i] = LooseCell.new(l, l+cellWidth, b, b+cellHeight);
        --if i%20==0 then print() end
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
            -- Tight Cells (static)
            love.graphics.setColor(255,255,255, .4);
            love.graphics.rectangle("line", x*self.cWidth, y*self.cHeight, self.cWidth, self.cHeight);
            -- Loose Cells
            --print((y)*self.tCols+x+1)
            local cell = self.LooseGrid[(y)*self.tCols+x+1]
            --love.graphics.setColor(0,0,255,1);
            if cell.head then
                love.graphics.setColor(255,0,0,1);
                cell:UpdateExtents()
            end
            local w = cell.r-cell.l;
            local h = cell.b-cell.t;
            love.graphics.rectangle("line", cell.l, cell.t, w, h);
        end
    end
end

function LTDG:Insert(entity)
    local cX = clamp(math.ceil(entity.x/self.cWidth), 1, self.tCols)
    local cY = clamp(math.ceil(entity.y/self.cHeight), 1, self.tRows)
    local index = (cY-1)*self.tCols + cX; -- double check this later
    if entity.lastCell ~= index then
        if entity.lastCell then
            self.LooseGrid[entity.lastCell]:Remove(entity)
        end
        -- insert element to cell at 'index' and expand the loose cell's AABoundingBox
        print(cX,cY,index)
        entity.lastCell = index
        self.LooseGrid[index]:Insert(entity);
    end
end

function LTDG:SearchTightGrid(x1,x2,y1,y2)
    local tx1 = clamp(math.ceil(x1/self.cWidth), 1, self.tCols);
    local tx2 = clamp(math.ceil(x2/self.cWidth), 1, self.tCols);
    local ty1 = clamp(math.ceil(y1/self.cHeight), 1, self.tRows);
    local ty2 = clamp(math.ceil(y2/self.cHeight), 1, self.tRows);

    for ty = ty1, ty2 do
        local trow = (ty-1)*self.tCols;
        for tx = tx1, tx2 do
            local tightCell = self.TightGrid[trow + tx];
        end
    end
end

function LTDG:SearchBox(search)
    local x1,x2,y1,y2 = search:AABB()
    local tx1 = clamp(math.ceil(x1/self.cWidth), 1, self.tCols);
    local tx2 = clamp(math.ceil(x2/self.cWidth), 1, self.tCols);
    local ty1 = clamp(math.ceil(y1/self.cHeight), 1, self.tRows);
    local ty2 = clamp(math.ceil(y2/self.cHeight), 1, self.tRows);

    local intersectingEntities = {};

    for ty = ty1, ty2 do
        local trow = (ty-1)*self.tCols;
        for tx = tx1, tx2 do
            local tightCell = self.TightGrid[trow + tx];

            love.graphics.setColor(255,255,255,1)

            local looseNode = tightCell.head;
            while looseNode do -- for each looseCell in tightCell
                love.graphics.setColor(0,0,255,1)
                local looseCell = self.LooseGrid[looseNode.value];
                if looseCell:Intersects(x1,x2,y1,y2) then -- if looseCell intersects search area
                    love.graphics.setColor(255,0,255,1)
                    local entity = looseCell.head;
                    while entity do -- for each entity in loose cell
                        if entity.value:IntersectsRadius(search) then --if entity.value:Intersects(x1,y1,x2,y2) then -- if entity intersects search area
                            table.insert(intersectingEntities, entity.value)-- add entity to query results
                        end
                        entity = entity.next;
                    end
                end
                looseNode = looseNode.next;
            end
            love.graphics.circle("fill", tx*self.cWidth-self.cWidth/2, ty*self.cWidth-self.cWidth/2, 4)
        end
    end
    return intersectingEntities;
end

return LTDG;