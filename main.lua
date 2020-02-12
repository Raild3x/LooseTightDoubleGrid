local LTDG = require("Datastructures.LooseTightDoubleGrid");
local x = 0;

love.window.setMode(400, 400)
local grid = LTDG.new(20,20,20,20)

function love.draw()
    grid:Draw()
    x = x + 1
    love.graphics.print("Hello World!", 100, 100);
    love.graphics.rectangle("line", 200, x, 120, 100);
end
