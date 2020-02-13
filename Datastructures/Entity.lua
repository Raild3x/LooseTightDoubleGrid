local Entity = {};
Entity.__index = Entity;

function Entity.new(x,y,width,height)
    local self = setmetatable({
        x = x,
        y = y,
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
        love.graphics.setColor(0,255,255);
    else
        love.graphics.setColor(0,255,0);
    end
    love.graphics.circle("line",self.x,self.y,self.width/2);
    self.intersecting = false
end

function Entity:Move(dx,dy)
    self.x = self.x+dx;
    self.y = self.y+dy;
end

function Entity:IntersectsRadius(entity)
    if math.sqrt((entity.x-self.x)^2+(entity.y-self.y)^2) <= self.width/2+entity.width/2 then
        self.intersecting = true;
        entity.intersecting = true;
        return true
    end
end

function Entity:AABB()
    local w = self.width/2
    local h = self.height/2
    return self.x-w,self.x+w,self.y-h,self.y+h;
end

return Entity;