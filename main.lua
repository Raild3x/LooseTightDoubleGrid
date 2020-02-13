local LTDG = require("Datastructures.LooseTightDoubleGrid");
local Entity = require("Datastructures.Entity");

local x = 0;

local windowWidth = 800
local nodesPerLine = 8
love.window.setMode(windowWidth, windowWidth)
local grid = LTDG.new(nodesPerLine,nodesPerLine,windowWidth/nodesPerLine,windowWidth/nodesPerLine)

local plr = Entity.new(88, 94, 20, 20)
grid:Insert(plr);
local boids = {plr}
for i = 2, 50 do
    local d = math.floor(math.random()*100+1)
    local b = Entity.new(math.floor(math.random()*800), math.floor(math.random()*800), d, d);
    print(b.x,b.y,d)
    table.insert(boids, b);
    grid:Insert(b);
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
        boids[i]:Draw();
    end
    grid:Draw();
end
