local LTDG = require("Datastructures.LooseTightDoubleGrid");
local Entity = require("Datastructures.Entity");

local x = 0;

local windowWidth = 800
local nodesPerLine = 10
love.window.setMode(windowWidth, windowWidth)
local grid = LTDG.new(nodesPerLine,nodesPerLine,windowWidth/nodesPerLine,windowWidth/nodesPerLine)

local plr = Entity.new(88, 94, 20, 20)
grid:Insert(plr);
local boids = {plr}
for i = 2, 5000 do
    local d = math.floor(math.random()*100+1)
    local b = Entity.new(math.floor(math.random()*800), math.floor(math.random()*800), d, d);
    print(b.x,b.y,d)
    table.insert(boids, b);
    grid:Insert(b);
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
    
    if love.keyboard.isDown('w') then
        plr:Move(0,-1);
    end
    if love.keyboard.isDown('a') then
        plr:Move(-1,0);
    end
    if love.keyboard.isDown('s') then
        plr:Move(0,1);
    end
    if love.keyboard.isDown('d') then
        plr:Move(1,0);
    end
    grid:Insert(plr);
    plr:Draw();

    local intersections = grid:SearchBox(plr);

    for i = 2, #boids do
        boids[i]:Move(math.random()*2-1,math.random()*2-1)
        grid:Insert(boids[i]);
        grid:SearchBox(boids[i]);
        boids[i]:Draw();
    end
    grid:Draw();
end
