

-- Cette ligne permet d'afficher des traces dans la console pendant l'éxécution
io.stdout:setvbuf('no')

-- Empèche Love de filtrer les contours des images quand elles sont redimentionnées
-- Indispensable pour du pixel art
love.graphics.setDefaultFilter("nearest", "nearest")

-- Cette ligne permet de déboguer pas à pas dans ZeroBraneStudio
if arg[#arg] == "-debug" then require("mobdebug").start() end


------------------------------------------------------
--=                     REQUIRE                    =--
------------------------------------------------------
Tile = require("modules/Tile")
Map = require("modules/Map")
Perso = require("modules/Perso")
Camera = require("modules/Camera")
require("modules/Gradient")
tScreen = require("modules/Titlescreen")
mainMenu = require("modules/Mainmenu")
Level = require("modules/Level")
levelSelect = require("modules/LevelSelect")
lunar = require("modules/Lunar")
pause = require("modules/Pause")
Ease = require("modules/Ease")

------------------------------------------------------
--=                TABLE & VAR                     =--
------------------------------------------------------


tiles_ground = {}
objects = {}
tile_set = {}
map = {}
perso = {}
draw_list = {}

map_start = {x = 0, y = 0}



backgroundColor = gradient {   -- degradé de couleur pour l'arrière plan
    direction = 'horizontal';
	{203, 219, 215};
    {145, 170, 180};
}
 
currentScene = "TITLESCREEN" -- permet de changer la scene
------------------------------------------------------
--=                     LOAD                       =--
------------------------------------------------------

function love.load()
  Font = love.graphics.newFont("images/font/Pixeled.ttf", 18)
  width = love.graphics.getWidth()
  height = love.graphics.getHeight()
  
  lunar:load()
  mainMenu:load()
  levelSelect:load()
  loadLevel()
  pause:load()
  plouf = love.audio.newSource("musics/plouf1.ogg", "static")
  move_grass = love.audio.newSource("musics/move-grass.ogg", "static")
  move_grass:setPitch(1.5)
  move_stone = love.audio.newSource("musics/move-stone.ogg", "static")
  move_stone:setPitch(1)
  move_ice = love.audio.newSource("musics/move-ice.ogg", "static")
  move_ice:setPitch(1)
  move_box = love.audio.newSource("musics/push.ogg", "static")
  move_box:setPitch(1)
  move_box:setVolume(0.5)
  perso_fall = love.audio.newSource("musics/fall.ogg", "static")
  perso_fall:setPitch(1)
end

------------------------------------------------------
--=                     UPDATE                     =--
------------------------------------------------------

function love.update(dt)
	if currentScene == "MAINGAME" then
 
    lunar:update(dt)
    
    perso.update(dt)
    local nb_hole = 0
    local falled_obj = false
    for i = 1, #objects do
      if (i < 1 or i > #objects) then break end
      objects[i].update(map_start)
      if (not objects[i].moving and objects[i].falled) then
        objects[i].exist = false
        table.remove(objects, i)
        i = i-1
      end
    end
    
    for i = 1, #tiles_ground do
      tiles_ground[i].update(map_start)
      if (tiles_ground[i].line == 3 and tiles_ground[i].column == 5) then
      end
      if (not tiles_ground[i].inhole.exist and tiles_ground[i].object_inhole) then
        tiles_ground[i].object_inhole = false
        tiles_ground[i].inhole = {exist = false}
      end
    end
    
    if (not perso.falled) then
    
      middle_cam = {}
      middle_cam.x = camera.pos.x+width/2
      middle_cam.y = camera.pos.y+height/2
      local d = distance(middle_cam, {x = perso.pos.x+Tile.tile_width*1.5, y = perso.pos.y+Tile.tile_height*1.5})
      if d>150 then
        local tmp_pos = {}
        tmp_pos.x = perso.pos.x-width/2+perso.image:getWidth()+28
        tmp_pos.y = perso.pos.y-height/2+perso.image:getHeight()+15
        camera.setMoving(tmp_pos)
      end
    end
    if (not perso.moving and perso.falled) then
      loadLevel()
    end
    
    camera.update()
    
    updateDrawList()

	end  
	  
end

------------------------------------------------------
--=                     DRAW                       =--
------------------------------------------------------
function love.draw()
	love.graphics.setFont(Font)
	if currentScene == "TITLESCREEN" then
		tScreen:draw()
  elseif currentScene == "MAINMENU" then
	  drawinrect(backgroundColor, 0, 0, love.graphics.getWidth(), love.graphics.getHeight())    
    mainMenu:draw()
  elseif currentScene == "LEVELSELECT" then
    drawinrect(backgroundColor, 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    levelSelect:draw()
  elseif currentScene == "MAINGAME" then
    
    love.graphics.setColor(255,255, 255, 255)
      drawinrect(backgroundColor, 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
        love.graphics.push()
        
        love.graphics.translate(-camera.pos.x, -camera.pos.y)
        
        for i = 1, #draw_list do
          if (draw_list[i].name == nil) then
            love.graphics.draw(draw_list[i].image, draw_list[i].pos.x-draw_list[i].image:getWidth(), draw_list[i].pos.y-draw_list[i].image:getHeight()-Tile.tile_height*2, 0 , Tile.scale.x, Tile.scale.y)
          elseif (draw_list[i].name == "perso")then
            
            if (perso.scale_sign == 1) then 
            
            love.graphics.draw(draw_list[i].image, draw_list[i].pos.x, draw_list[i].pos.y, 0, Tile.scale.x, Tile.scale.y)
            else 
              love.graphics.draw(draw_list[i].image, draw_list[i].pos.x, draw_list[i].pos.y, 0, -Tile.scale.x, Tile.scale.y, draw_list[i].image:getWidth())
            end
          else
            love.graphics.draw(draw_list[i].image, draw_list[i].pos.x, draw_list[i].pos.y, 0, Tile.scale.x, Tile.scale.y)
          end
          if (draw_list[i].id == 6) then
            pos = {}
            pos.x = draw_list[i].pos.x
            pos.y = draw_list[i].pos.y
          end
        end
        
        love.graphics.rectangle("fill", 550, 683-15, 50, 50)

        love.graphics.pop()
        
        if (lunar_mode) then
          love.graphics.draw(lunar_ship.image, lunar_ship.pos.x, lunar_ship.pos.y, math.rad(lunar_ship.r), Tile.scale.x, Tile.scale.y, lunar_ship.image:getWidth(), lunar_ship.image:getHeight()/2)
          if (lunar_ship.fire_on) then
            love.graphics.draw(lunar_ship.fire, lunar_ship.pos.x, lunar_ship.pos.y, math.rad(lunar_ship.r), Tile.scale.x, Tile.scale.y, lunar_ship.fire:getWidth()-5, lunar_ship.fire:getHeight()/2)
          end

       

        end
    --AFFICHAGE DE L'ECRAN PAUSE
    pause:draw()
     --DEBUG
        love.graphics.print(tostring(pause.enable) , 0, 10)
      end
     
     
   
    
  
end


------------------------------------------------------
--=                     CONTROLLER                 =--
------------------------------------------------------

function love.keypressed(key)
  if (perso.falled)then return false end
	if currentScene  == "TITLESCREEN" then	
		tScreen:controller(key)
	elseif currentScene == "MAINMENU" then
    mainMenu:controller(key)
  elseif currentScene == "LEVELSELECT" then
    levelSelect:controller(key)
    Level.index_level = levelSelect:getVal()
	elseif currentScene == "MAINGAME" then  -- IN GAME CONTROLL
    pause:ingame(key)
    if pause.enable == false then
    local box_moving = false
    for i = 1, #objects do
      if ((objects[i].id == 6 or objects[i].id == 7) and objects[i].moving and not objects[i].falled) then
        box_moving = true
      end
    end 
    
    if (not perso.moving and not box_moving)then
      local under_button = false
      local prec_pos = {line = perso.line, column = perso.column}
      if map.map_objects[perso.line][perso.column] == 8 or map.map_objects[perso.line][perso.column] == 10 then
        under_button = true
      end
      
      if key == "up" then
        local wanted_nextpos = {line = perso.line+1, column = perso.column}
        move_perso(wanted_nextpos, perso.up)
      elseif key == "down" then
        local wanted_nextpos = {line = perso.line-1, column = perso.column}
        move_perso(wanted_nextpos, perso.down)
      elseif key == "right" then
        local wanted_nextpos = {line = perso.line, column = perso.column-1}
        move_perso(wanted_nextpos, perso.right)
      elseif key == "left" then
        local wanted_nextpos = {line = perso.line, column = perso.column+1}
        move_perso(wanted_nextpos, perso.left)
      end
      
      if (perso.falled or not inScreen(perso.line, perso.column)) then
        return false
      end
      
      if (lunar_mode)then return false end
      
      if prec_pos.line ~= perso.line or prec_pos.column ~= perso.column then
        if under_button then
          for i = 1, #objects do
            if objects[i].line == prec_pos.line and objects[i].column == prec_pos.column then
              objects[i].id = objects[i].id+1
              Level.current_level.nb_buttons_succed = Level.current_level.nb_buttons_succed-1
              map.map_objects[prec_pos.line][prec_pos.column] = objects[i].id
              objects[i].image = tile_set[objects[i].id].image
              break
            end
          end
        end
      end
      if map.map_objects[perso.line][perso.column] == 9 or map.map_objects[perso.line][perso.column] == 11 then
        for i = 1, #objects do
          if objects[i].line == perso.line and objects[i].column == perso.column then
            if (objects[i].id == 9 or objects[i].id == 11) then
              objects[i].id = objects[i].id-1
              Level.current_level.nb_buttons_succed = Level.current_level.nb_buttons_succed+1
              map.map_objects[perso.line][perso.column] = objects[i].id
              objects[i].image = tile_set[objects[i].id].image
            end
            break
             
          end
        end
      end
      
      if (Level.current_level.nb_buttons_succed == Level.current_level.nb_buttons) then
        Level.current_level.gate.image = Level.current_level.gate.images.open
      else
        Level.current_level.gate.image = Level.current_level.gate.images.close
      end
    end
    
    if (Level.current_level.nb_buttons_succed == Level.current_level.nb_buttons and 
        (perso.line == Level.current_level.gate.line and perso.column == Level.current_level.gate.column)
      ) then
      
      lunar_mode = true
    end
    
    for i = 1, #objects do
      if (not objects[i].falled) then
        if ((objects[i].id == 6 or objects[i].id == 7) and map.map_set[objects[i].line][objects[i].column] == 5) then
          map.map_objects[objects[i].line][objects[i].column] = 0
          objects[i].fall()
          for j = 1, #tiles_ground do
            if tiles_ground[j].line == objects[i].line and tiles_ground[j].column == objects[i].column then
              tiles_ground[j].object_inhole = true
              tiles_ground[j].inhole = objects[i]
              tiles_ground[j].inhole.exist = true
              break
            end
          end
        end
      end
    end
  end -- pause enable false

  if pause.enable then pause:controller(key) end

  end  -- end level select 
end --end keypressed

function love.keyreleased(key)
end

function distance(a, b)
  x = b.x-a.x
  y = b.y-a.y
  return math.sqrt( (x*x)+(y*y) )
end

function inScreen(pLine, pColumn)
  return (pLine<=map.nb_tile_height and 
    pLine>=1 and
    pColumn<=map.nb_tile_width and
    pColumn>=1)
end

function canPass(nextPos, id)
  if (lunar_mode)then return false end
  if (
    nextPos.line<=map.nb_tile_height and 
    nextPos.line>=1 and
    nextPos.column<=map.nb_tile_width and
    nextPos.column>=1
    ) then
    
    if (Tile.isPerso(id) and map.map_set[nextPos.line][nextPos.column] == 3) then
      return false
    end
    
    if ( not(
      (
        (Level.current_level.nb_buttons_succed ~= Level.current_level.nb_buttons) 
        and (
          nextPos.line == Level.current_level.gate.line and
          nextPos.column == Level.current_level.gate.column
        )
      )
      or (
        nextPos.line == Level.current_level.gate.line and
          (
          nextPos.column == Level.current_level.gate.column-1 or
          nextPos.column == Level.current_level.gate.column+1
          )
        )
      )) then
      return true
    end
  end
  return false
end


------------------------------------------------------
--=                     LOAD LEVEL                 =--
------------------------------------------------------

function loadLevel()
  tiles_ground = {}
  objects = {}
  tile_set = {}

  map = {}
  perso = {}
  
  Level.current_level.gate.image = Level.current_level.gate.images.close
  Level.current_level.nb_buttons_succed = 0
    
  local scale_x = 4
  local scale_y = scale_x
  
  Tile.init(tile_set, Tile)  -- chargement de toutes les images  
  Tile.setScale(scale_x, scale_y)
  
  map = Map.newMap(Level.current_level.set, Level.current_level.objects, tile_set)
  
  Perso.map = map
  
  for i = 1, map.nb_tile_height do
    for j = 1, map.nb_tile_width do
      if (map.map_set[i][j] ~= 0) then
        tiles_ground[#tiles_ground+1] = Tile.newTile(i, j, {x = 0, y = 0}, tile_set[map.map_set[i][j]])
      end
      if (map.map_objects[i][j] ~= 0) then
        objects[#objects+1] = Tile.newTile(i, j, {x = 0, y = 0}, tile_set[map.map_objects[i][j]])
      end
    end
  end
  
  map.pos_start = Tile.initTiles(map.map_set, tiles_ground, map.nb_tile_width, map.nb_tile_height, {width = Tile.tile_width*Tile.scale.x, height = 16*Tile.scale.y})
  map_start.x = map.pos_start.x+(Tile.tile_width*0.5*Tile.scale.x)
  map_start.y = map.pos_start.y+(Tile.tile_height*Tile.scale.y)
  
  map.pos_start = map_start
  
  for i = 1, #tiles_ground do
    tiles_ground[i].update(map_start)
  end
  
  
  
  perso = Perso.newPerso(map_start, Level.current_level.pStart.line, Level.current_level.pStart.column, {up = "images/hero/hero_frontr.png", down ="images/hero/hero_backr.png"}, Tile, map.pos_start)

  
  Tile.initObjects(objects, map.nb_tile_width, map.nb_tile_height, Perso.TabPos2Pos, map.map_objects, map.pos_start)
  
  camera = Camera.newCamera()
  
  camera.pos.x = perso.pos.x-width/2+perso.image:getWidth()+28
  camera.pos.y = perso.pos.y-height/2+perso.image:getHeight()+15
  
  Level.current_level.gate.pos = Perso.TabPos2Pos(Level.current_level.gate.line, Level.current_level.gate.column, Tile.tile_width, Tile.tile_height, map.pos_start)
  Level.current_level.gate.pos.x = Level.current_level.gate.pos.x-Level.current_level.gate.image:getWidth()-Tile.tile_width+10
  Level.current_level.gate.pos.y = Level.current_level.gate.pos.y-Level.current_level.gate.image:getHeight()-Tile.tile_height*2-20
  
  if map.map_objects[perso.line][perso.column] == 9 or map.map_objects[perso.line][perso.column] == 11 then
end

pos = Perso.TabPos2Pos(1, 1, Tile.tile_width, Tile.tile_height, {x = 534, y = 672})
end

function updateDrawList() 
  draw_list = {}
  for i = 1, #tiles_ground do
    draw_list[#draw_list+1] = {}
    draw_list[#draw_list] = tiles_ground[i]
  end
  draw_list[#draw_list+1] = {}
  draw_list[#draw_list] = tiles_ground[i]
  
  draw_list[#draw_list+1] = {}
  draw_list[#draw_list] = perso
  
  draw_list[#draw_list+1] = {}
  draw_list[#draw_list] = Level.current_level.gate
  
  for i = 1, #objects do
    if (objects[i].under ~= nil) then
      draw_list[#draw_list+1] = {}
      draw_list[#draw_list] = objects[i].under
    end
    draw_list[#draw_list+1] = {}
    draw_list[#draw_list] = objects[i]
  end
  
  if (#draw_list>1) then
    table.sort( draw_list, 
      function (a, b)
        
        if (a.name == nil) then
          return false
        end
        if (b.name == nil) then
          return true
        end
        
        base = a.z>b.z
        
        return base
        
      end
    )
  end
  
  
end


function move_perso(wanted_nextpos, fctMove)
  local CanPass = canPass(wanted_nextpos, perso.id)
  if (CanPass) then
    if (map.map_objects[wanted_nextpos.line][wanted_nextpos.column] == 6 or map.map_objects[wanted_nextpos.line][wanted_nextpos.column] == 7) then
      CanPass = canPass({line = (wanted_nextpos.line-perso.line)*2+perso.line, column = (wanted_nextpos.column-perso.column)*2+perso.column}, 6)
    end
  end
  local type_fall = ""
  if (shouldFall(wanted_nextpos.line, wanted_nextpos.column, type_fall)) then
    fallPerso(wanted_nextpos)
    return false
  end
  
  if (CanPass) then
    local diff_c = 0
    local diff_l = 0
    glass_under = map.map_set[wanted_nextpos.line][wanted_nextpos.column] == 4
    diff_c = perso.column
    diff_l = perso.line
    fctMove(map, objects, Level.current_level)
    diff_c = perso.column-diff_c
    diff_l = perso.line-diff_l
    wanted_nextpos.line = wanted_nextpos.line+diff_l
    wanted_nextpos.column = wanted_nextpos.column+diff_c
    CanPass = canPass({line = wanted_nextpos.line, column = wanted_nextpos.column}, perso.id)
    if (CanPass) then
      if (map.map_objects[wanted_nextpos.line][wanted_nextpos.column] == 6 or map.map_objects[wanted_nextpos.line][wanted_nextpos.column] == 7) then
        CanPass = canPass({line = (wanted_nextpos.line-perso.line)*2+perso.line, column = (wanted_nextpos.column-perso.column)*2+perso.column}, 6)
      end
    end
    
    while (CanPass and glass_under) do
      local type_fall = ""
      if (shouldFall(wanted_nextpos.line, wanted_nextpos.column, type_fall)) then
        fallPerso(wanted_nextpos)
        return false
      end
      if (map.map_set[wanted_nextpos.line][wanted_nextpos.column] == 4) then
        diff_c = perso.column
        diff_l = perso.line
        fctMove(map, objects, Level.current_level)
        diff_c = perso.column-diff_c
        diff_l = perso.line-diff_l
        wanted_nextpos.line = wanted_nextpos.line+diff_l
        wanted_nextpos.column = wanted_nextpos.column+diff_c
        if (Level.current_level.nb_buttons_succed == Level.current_level.nb_buttons and 
            (perso.line == Level.current_level.gate.line and perso.column == Level.current_level.gate.column)
          ) then
          
          lunar_mode = true
          return false
        end
      end
      if (diff_c == 0 and diff_l == 0)then 
        break 
      end
            
      CanPass = canPass({line = wanted_nextpos.line, column = wanted_nextpos.column}, perso.id)
      if (not CanPass )then
      end
      if (CanPass) then
        if (map.map_objects[wanted_nextpos.line][wanted_nextpos.column] == 6 or map.map_objects[perso.line][wanted_nextpos.column] == 7) then
          CanPass = canPass({line = (wanted_nextpos.line-perso.line)*2+perso.line, column = (wanted_nextpos.column-perso.column)*2+perso.column}, 6)
        end
      end
      if CanPass then
        if (map.map_set[wanted_nextpos.line][wanted_nextpos.column] ~= 4) then
          fctMove(map, objects, Level.current_level)
          CanPass = false
          break
        end
      end      
    end
    local type_fall = ""
    if (glass_under and shouldFall(wanted_nextpos.line, wanted_nextpos.column, type_fall)) then
      fallPerso(wanted_nextpos)
      return false
    end
  end
end

function shouldFall(line, column, type_fall)
  if (not inScreen(line, column)) then
    type_fall = "border"
    return true
  elseif (map.map_set[line][column] == 0 or map.map_set[line][column] == 5) then 
    if (map.map_set[line][column] == 5)then type_fall = "hole" end
    return true
  end
  return false
end

function fallPerso(wanted_nextpos)
  perso.column = wanted_nextpos.column
  perso.line = wanted_nextpos.line
  perso.fall(type_fall)
  for i = 1, #tiles_ground do
    if (tiles_ground[i].line == wanted_nextpos.line and tiles_ground[i].column == wanted_nextpos.column) then
      tiles_ground[i].object_inhole = true
      tiles_ground[i].inhole = perso
      
      tiles_ground[i].inhole.exist = true
    end
  end
end