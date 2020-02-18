local LTDG = require("Datastructures.LooseTightDoubleGrid");
local Entity = require("Datastructures.Entity");

local x = 0;

local windowWidth = 800
local nodesPerLine = 40
love.window.setMode(windowWidth, windowWidth)
local grid = LTDG.new(nodesPerLine,nodesPerLine,windowWidth/nodesPerLine,windowWidth/nodesPerLine)

local size = 40
local plr = Entity.new(88, 94, size, size)
grid:Insert(plr);
local boids = {plr}
for i = 2, 5000 do
    local d = math.floor(math.random()*15+1); -- diameter
    local b = Entity.new(math.floor(math.random()*(windowWidth-200)+100), math.floor(math.random()*(windowWidth-200)+100), d, d);
    print(b.x,b.y,d)
    table.insert(boids, b);
    grid:Insert(b);
end


local function resolveCollision(e, intersections)
    for i = 1, #intersections do
        local e2 = intersections[i];
        local dir = (e2.pos-e.pos);
        local overlap = (e2.width/2+e.width/2) - dir:Magnitude() + 1/2;
        dir = dir:Normalize();
        e2.pos:Add(dir*(overlap/2));
        e.pos:Sub(dir*(overlap/2));
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


local frames = 0
local T = os.clock();
function love.draw()
    -- FPS Counter
    frames = frames + 1
    if T + 1 <= os.clock() then
        print("FPS:",frames)
        T = T+1
        frames = 0;
    end

    -- User Input manager
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

    -- manage static objects
    for i = 2, #boids do
        local b = boids[i];
        --b:Move(math.random()*2-1,math.random()*2-1)
        --b.pos:Add(b.velocity);
        
        local intersections = grid:SearchBox(b);
        if #intersections > 0 then
            --print("Resolving:",i)
            resolveCollision(b,intersections);
            grid:Insert(b);
            
        end
        b:Draw();
    end
    grid:Draw();
end
