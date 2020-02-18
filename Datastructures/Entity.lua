local Vector2 = require("Datastructures.Vector2");

local Entity = {};
Entity.__index = Entity;

function Entity.new(x,y,width,height)
    local self = setmetatable({
        pos = Vector2.New(x,y),
        velocity = Vector2.New(0,0),
        width = width,
        height = height,
        rotation = 0,
        intersecting = false,
        lastCell
    }, Entity);
    return self;
end

function Entity:Draw()
    if self.intersecting then
        love.graphics.setColor(0,200,255);
    else
        love.graphics.setColor(50,255,0);
    end
    love.graphics.circle("line",self.pos.x,self.pos.y,self.width/2);
    self.intersecting = false
end

function Entity:Move(dx,dy)
    self.velocity.x = dx;
    self.velocity.y = dy;
end

function Entity:IntersectsRadius(entity)
    if self == entity then return false end
    if Vector2.Magnitude(entity.pos-self.pos) <= self.width/2+entity.width/2 then
        self.intersecting = true;
        entity.intersecting = true;
        return true
    end
end

function Entity:AABB()
    local w = self.width/2
    local h = self.height/2
    return self.pos.x-w,self.pos.x+w,self.pos.y-h,self.pos.y+h;
end

return Entity;