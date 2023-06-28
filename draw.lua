backface_culling = true

-- drawing modes
-- 1 = vertices + wireframe
-- 2 = wireframe
-- 3 = solid color
-- 4 = solid color + wireframe 
-- 5 = vertices only

drawing_mode = 3
max_draw_mode = 5 


function draw_triangle(x0, y0, x1, y1, x2, y2, c)
    line(x0, y0, x1, y1, c)
    line(x1, y1, x2, y2, c)
    line(x2, y2, x0, y0, c)
end

function draw_triangle_filled(x0, y0, z0, w0, x1, y1, z1, w1, x2, y2, z2, w2, c)
    -- dumb and lazy sort
    if (y0 > y1) then
        y0, y1 = y1, y0
        x0, x1 = x1, x0 
    end

    if (y1 > y2) then
        y1, y2 = y2, y1
        x1, x2 = x2, x1
    end

    if (y0 > y1) then
        y0, y1 = y1, y0
        x0, x1 = x1, x0 
    end

    -- bottom flat triangle
    local inv_slope_1 = 0 
    local inv_slope_2 = 0

    if (y1-y0 != 0) then
        inv_slope_1 = (x1-x0) / abs(y1-y0)
    end
    
    if (y2-y0 != 0) then
        inv_slope_2 = (x2-x0) / abs(y2-y0)  
    end

    if (y1-y0 != 0) then
        for y=y0, y1 do
            local x_start = x1 + (y-y1) * inv_slope_1
            local x_end = x0 + (y-y0) * inv_slope_2

            if (x_end < x_start) then
                x_start, x_end = x_end, x_start
            end

            rectfill(x_start, y, x_end, y, c)
        end
    end
    
    -- top flat triangle
    inv_slope_1 = 0
    inv_slope_2 = 0

    if (y2-y1 != 0) then
        inv_slope_1 = (x2-x1) / abs(y2-y1)
    end

    if (y2-y0 != 0) then
        inv_slope_2 = (x2-x0) / abs(y2-y0)
    end

    if (y2-y1 != 0) then
        for y=y1, y2 do 
            local x_start = x1 + (y-y1) * inv_slope_1
            local x_end = x0 + (y-y0) * inv_slope_2

            if (x_end < x_start) then
                x_start, x_end = x_end, x_start
            end

            rectfill(x_start, y, x_end, y, c)
        end
    end
end

-- draws a bg grid for debugging purposes
function draw_grid(w, h, c)
    for y=0, 127 do
        for x=0, 127 do
            if (x%w==0 or y%h==0) then
                pset(x,y,c)
            end
        end
    end
end

function draw_dotted_grid(w, h, c)
    for y=0, 127, h do
        for x=0, 127, w do
            pset(x,y,c)
        end
    end
end