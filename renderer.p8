pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
-- PICO-8 SOFTWARE RENDERER
-- BY WOJTEK RAK
#include utils.lua
#include vectors.lua
#include draw.lua
#include mesh.lua

--TODO:
-- add backface culling
-- define some direction vectors
-- fix z-buffer functionality
-- look into filled triangle performance (it's extremely bad right now with the cube mesh)
debug = false 

fov = 800
camera_pos = vec(0, 0, -50)

-- main
function _init()
    -- initialize the z buffer
    clear_z_buffer()

    -- 
    load_mesh()
end


function project(v) 
    return vec(
        (fov*v.x) / v.z,
        (fov*v.y) / v.z,
        0
    )
end

function _update()
    -- input
    -- change rendering modes
    if btnp(➡️) then
        drawing_mode += 1 
        if drawing_mode > max_draw_mode then drawing_mode = 1 end
    end
    if btnp(⬅️) then
        drawing_mode -= 1
        if drawing_mode < 0 then drawing_mode = max_draw_mode end
    end
    -- toggle debug mode
    if btnp(❎) then
        debug = not debug
    end

    -- gfx process
    triangles_to_render = {}

    for m=1, #meshes do
        cur_mesh = meshes[m]

        cur_mesh.rotation.x += 0.01
        cur_mesh.rotation.y += 0.01
        cur_mesh.rotation.z += 0.01

        for f=1, #cur_mesh.faces do
            cur_face = cur_mesh.faces[f]         

            local face_vertices = {vec(), vec(), vec()}

            face_vertices[1] = cur_mesh.vertices[cur_face.a]
            face_vertices[2] = cur_mesh.vertices[cur_face.b]
            face_vertices[3] = cur_mesh.vertices[cur_face.c]

            local projected_triangle = {}

            for i=1, 3 do
                local transformed_vertex = vec_copy(face_vertices[i])

                -- apply rotations
                transformed_vertex = v_rot_x(transformed_vertex, cur_mesh.rotation.x)
                transformed_vertex = v_rot_y(transformed_vertex, cur_mesh.rotation.y)
                transformed_vertex = v_rot_z(transformed_vertex, cur_mesh.rotation.z)

                -- apply the camera offset
                transformed_vertex.z -= camera_pos.z

                projected_point = project(transformed_vertex)

                projected_point.x += (127/2)
                projected_point.y += (127/2)

                projected_triangle[i] = projected_point
            end
            
            add(triangles_to_render, projected_triangle)
        end
    end
end 

function _draw()
    cls(12)
    --draw_triangle_filled(10, 10, 0, 0, 100, 10, 0, 0, 50, 100, 4)

    for t=1, #triangles_to_render do
        local cur_triangle = triangles_to_render[t]

        if (drawing_mode == 1 or drawing_mode==4) then
            -- draw the vertices
            rectfill(cur_triangle[1].x, cur_triangle[1].y, cur_triangle[1].x+1, cur_triangle[1].y+1, 8)
            rectfill(cur_triangle[2].x, cur_triangle[2].y, cur_triangle[2].x+1, cur_triangle[2].y+1, 8)
            rectfill(cur_triangle[3].x, cur_triangle[3].y, cur_triangle[3].x+1, cur_triangle[3].y+1, 8)
        end
        
        -- draw solid triangle
        if (drawing_mode == 3 or drawing_mode == 4) then
            draw_triangle_filled(cur_triangle[1].x,cur_triangle[1].y,cur_triangle[1].z,cur_triangle[1].w,
                                 cur_triangle[2].x,cur_triangle[2].y,cur_triangle[2].z,cur_triangle[2].w,
                                 cur_triangle[3].x,cur_triangle[3].y,cur_triangle[3].z,cur_triangle[3].w,
                                 8)
        end

        -- draw wireframe triangle
        if (drawing_mode == 1 or drawing_mode == 2 or drawing_mode == 4) then
            draw_triangle(cur_triangle[1].x, cur_triangle[1].y, cur_triangle[2].x, cur_triangle[2].y, cur_triangle[3].x, cur_triangle[3].y, 11)
        end

    end

    -- debug output
    if (debug) then
        print_sys_info()
        print_mesh_info()
    end

    -- clear the z_buffer at the end of every frame
    clear_z_buffer()
end

__gfx__
00000000677777760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000656006560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700666006660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000550000550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700666006660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000756006570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000776006770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
