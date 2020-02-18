local LTDG = require("Datastructures.LooseTightDoubleGrid");
local Entity = require("Datastructures.Entity");

local x = 0;

local windowWidth = 800
local nodesPerLine = 10
love.window.setMode(windowWidth, windowWidth)
local grid = LTDG.new(nodesPerLine,nodesPerLine,windowWidth/nodesPerLine,windowWidth/nodesPerLine)

local size = 45
local plr = Entity.new(88, 94, size, size)
grid:Insert(plr);
local boids = {plr}
for i = 2, 2000 do
    local d = math.floor(math.random()*20+1); -- diameter
    local b = Entity.new(math.floor(math.random()*(windowWidth-100)+50), math.floor(math.random()*(windowWidth-100)+50), d, d);
    print(b.x,b.y,d)
    table.insert(boids, b);
    grid:Insert(b);
end


local function resolveCollision(e, intersections)
    for i = 1, #intersections do
        local e2 = intersections[i];
        local dir = (e.pos-e2.pos):Normalize()/5
        --[[local midPoint = e2.pos+(dir/2);
        e2.pos = midPoint+((e2.pos-midPoint):Normalize()*(e2.width/2));
        e.pos = midPoint+((e.pos-midPoint):Normalize()*(e.width/2));]]
        e2.pos:Add(dir*-1);
        e.pos:Add(dir);
    end
end

function love.mousepressed(x, y, button, istouch)
    if button == 1 then -- Versions prior to 0.10.0 use the MouseConstant 'l'
        local cId = grid:GetCol(x)+(grid:GetRow(y)-1)*grid.tCols;
        local tCell = grid.TightGrid[cId];
        local n = tCell.head
        print("Checking Cell: "..cId)
        while n do
            print(n.value..", ")
            n = n.next
        end
    end
 end


function love.draw()
    local x,y = 0,0
    if love.keyboard.isDown('w') then
        y = -1
    end
    if love.keyboard.isDown('a') then
        x = -1
    end
    if love.keyboard.isDown('s') then
        y = 1
    end
    if love.keyboard.isDown('d') then
        x = 1
    end
    plr:Move(x,y);
    plr.pos:Add(plr.velocity);
    grid:Insert(plr);
    
    local intersections = grid:SearchBox(plr);
    resolveCollision(plr,intersections);
    plr:Draw();

    for i = 2, #boids do
        local b = boids[i];
        --b:Move(math.random()*2-1,math.random()*2-1)
        --b.pos:Add(b.velocity);
        grid:Insert(b);
        local intersections = grid:SearchBox(b);
        resolveCollision(b,intersections);
        b:Draw();
    end
    grid:Draw();
end
