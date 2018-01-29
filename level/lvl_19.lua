local lvl = {}

--[[    TILES & OBJECT NUMBER   

grass             -- 1
stone             -- 2
water             -- 3
ice               -- 4
hole              -- 5
box wood          -- 6
box stone         -- 7
button stone off  -- 9
button wood off   -- 11 ]]


lvl.set = {
  { 1, 1, 1, 1, 1, 1, 1, 1, 0},
  { 1, 1, 1, 1, 1, 1, 1, 1, 0},
  { 1, 0, 0, 1, 0, 0, 1, 1, 0},
  { 1, 0, 0, 1, 0, 0, 1, 1, 0},
  { 1, 1, 1, 1, 1, 0, 1, 1, 1},
  { 1, 1, 1, 1, 1, 0, 0, 0, 0},
  { 0, 3, 3, 0, 0, 0, 0, 0, 0},
  { 0, 1, 1, 0, 0, 0, 0, 0, 0}
}


lvl.objects = {
  { 0, 0, 0, 0, 0, 0, 0, 0, 0},
  { 0, 7, 0, 0, 0, 0, 6, 0, 0},
  { 0, 0, 0, 0, 0, 0, 6, 0, 0},
  { 0, 0, 0, 0, 0, 0, 0, 0, 0},
  { 0, 0, 0, 0, 0, 0, 0, 0, 0},
  { 0, 0, 0, 7, 0, 0, 0, 0, 0},
  { 0, 0, 0, 0, 0, 0, 0, 0, 0},
  { 0, 9, 9, 0, 0, 0, 0, 0, 0}
  
}

lvl.pStart = {line = 4, column = 8}

lvl.move = {gold = 10, silver = 15, wood = 25 }

lvl.gate = {}
lvl.gate.line = 5
lvl.gate.column = 8

lvl.gate.pos = {x = 0, y = 0}

lvl.gate.images = {}
lvl.gate.images.open = love.graphics.newImage("images/gate_0.png")
lvl.gate.images.close = love.graphics.newImage("images/gate_1.png")
lvl.gate.image = lvl.gate.images.close

lvl.nb_buttons = 0

for n, o in pairs(lvl.objects) do
  for n2, o2 in pairs(o) do
    if (o2 >= 8 and o2 <= 11) then
      lvl.nb_buttons = lvl.nb_buttons+1
    end
  end
end

lvl.nb_buttons_succed = 0

return lvl