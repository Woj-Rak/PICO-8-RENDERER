backface_culling = true

-- drawing modes
-- 1 = vertices + wireframe
-- 2 = wireframe
-- 3 = solid color
-- 4 = solid color + wireframe 
-- 5 = vertices only

drawing_mode = 1
max_draw_mode = 5 


function draw_triangle(x0, y0, x1, y1, x2, y2, c)
    line(x0, y0, x1, y1, c)
    line(x1, y1, x2, y2, c)
    line(x2, y2, x0, y0, c)
end

function barycentric(a, b, c, p)
    local v0 = vec_sub(b,a)
    local v1 = vec_sub(c,a)
    local v2 = vec_sub(p,a)

    local d00 = vec_dot(v0, v0)
    local d01 = vec_dot(v0, v1)
    local d11 = vec_dot(v1, v1)
    local d20 = vec_dot(v2, v0)
    local d21 = vec_dot(v2, v1)
    local denom = d00 * d11 - d01 * d01

    local v = (d11 * d20 - d01 * d21) / denom
    local w = (d00 * d21 - d01 * d20) / denom
    local u = 1 - v - w
    return vec(v, w, u)
end

function draw_triangle_pixel(x, y, c, point_a, point_b, point_c)
    local p = vec(x, y)

    local weights = barycentric(point_a, point_b, point_c, p)

    local interpolated_reciprocal_w = 0

    -- interpolate value of 1/w for the current pixel
    interpolated_reciprocal_w = (1 / point_a.w) * weights.x + (1 / point_b.w) * weights.y + (1 / point_c.w) * weights.z
    interpolated_reciprocal_w = 1 - interpolated_reciprocal_w

    -- draw the pixel
    pset(x, y, c)
end

function draw_triangle_filled(x0, y0, z0, w0, x1, y1, z1, w1, x2, y2, z2, w2, c)
    -- dumb and lazy sort
    if (y0 > y1) then
        y0, y1 = y1, y0
        x0, x1 = x1, x0 
        z0, z1 = z1, z0
        w0, w1 = w1, w0
    end

    if (y1 > y2) then
        y1, y2 = y2, y1
        x1, x2 = x2, x1
        z1, z2 = z2, z1
        w1, w2 = w2, w1
    end

    if (y0 > y1) then
        y0, y1 = y1, y0
        x0, x1 = x1, x0 
        z0, z1 = z1, z0
        w0, w1 = w1, w0
    end

    -- Vector points out of the passed in values
    local point_a = vec(x0, y0, z0, w0)
    local point_b = vec(x1, y1, z1, w1)
    local point_c = vec(x2, y2, z2, w2)

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

            for x=x_start, x_end do
                draw_triangle_pixel(flr(x), flr(y), c, point_a, point_b, point_c)
            end
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

            for x=x_start,x_end do
                draw_triangle_pixel(flr(x), flr(y), c, point_a, point_b, point_c)
            end
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