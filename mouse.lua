mouse_x_offset = 2

mouse = {
    -- mouse position
    x,y,last_x,last_y,
    -- mouse sensitivity
    move_sens = 0.05,
    -- button
    button,
    -- scrl
    scroll,
    -- init mouse input
    init = function()
      poke(0x5f2d, 1)
    end,
    --mouse cursor draw function
    draw = function()
        if mouse.button == 1 then
            spr(1, mouse.x+mouse_x_offset, mouse.y)
        else
            spr(0, mouse.x+mouse_x_offset, mouse.y)
        end
    end,
    -- return int:button [0..4]
    -- 0 .. no button
    -- 1 .. left
    -- 2 .. right
    -- 4 .. middle
    get_button = function()
        mouse.button=stat(34)
    end,
    -- return int:direction
    -- 0 .. no scroll
    -- 1 .. up scroll
    -- -1 .. down scroll
    wheel = function()
        mouse.scroll=stat(36)
    end,
    -- return int:x, int:y, onscreen:bool
    update = function()
        mouse.last_x, mouse.last_y = mouse.x, mouse.y
        mouse.x,mouse.y = stat(32)-1,stat(33)-1
        mouse.get_button()
        mouse.wheel()
    end,
}