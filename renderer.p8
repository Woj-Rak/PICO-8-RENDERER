pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
-- PICO-8 SOFTWARE RENDERER
-- BY WOJTEK RAK
#include utils.lua
#include camera.lua
#include vectors.lua
#include draw.lua
#include math.lua
#include mesh.lua
#include matrix.lua

-- TODO:
-- move the mesh loading to the drag and drop (file_test.p8 has the examples)
-- matrices 
-- camera movement
    -- mouse
-- some sort of a lighting implementation
-- fix z-buffer functionality (a maybe depending on the point below)
-- look into filled triangle performance (it's extremely bad right now with the cube mesh)
    -- + try scan line with rectfill?
    -- + remove the zbuffer stuff :(
-- texture loading

debug = false

-- main
function _init()
    -- initialize the z buffer
    clear_z_buffer()

    cam = camera()
    -- TODO: this shouldn't have to be the case
    -- having a 1 in the .z is vital to having anything shop up on the screen
    cam.position = vec(0, 0, 1)

    -- projection matrix
    fov = 120
    znear = 0.1
    zfar = 100
    proj_matrix = mat_perspective(fov, 1, znear, zfar)

    -- 
    load_cube_mesh()
end

-- old, hopefully to be removed
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
    if btnp(➡️) and btn(🅾️) then
        drawing_mode += 1 
        if drawing_mode > max_draw_mode then drawing_mode = 1 end
    end
    if btnp(⬅️) and btn(🅾️) then
        drawing_mode -= 1
        if drawing_mode < 1 then drawing_mode = max_draw_mode end
    end
    -- backface culling toggle 
    if btnp(⬆️) and btn(🅾️) then
        backface_culling = not backface_culling
    end
    -- toggle debug mode
    if btnp(❎) and btn(🅾️) then
        debug = not debug
    end

    -- gfx process
    triangles_to_render = {}

    for m=1, #meshes do
        cur_mesh = meshes[m]

        --cur_mesh.rotation.x += 0.01
        --cur_mesh.rotation.y += 0.1
        --cur_mesh.rotation.z += 0.5

        -- initial offset for the camera
        cur_mesh.translation.x += 0.01
        cur_mesh.translation.y += 0.01 
        cur_mesh.translation.z += 0.01 

        --cam.position.x += 1 
        --cam.position.y += 1
        --cam.position.z += 1

        -- view matrix
        local target = cam_lookat_target(cam)
        local view_matrix = mat_look_at(cam.position, target)
        -- translation scale rotation matrices
        local scale_matrix = mat_scale(cur_mesh.scale.x, cur_mesh.scale.y, cur_mesh.scale.z)
        local translation_matrix = mat_translation(cur_mesh.translation.x, cur_mesh.translation.y, cur_mesh.translation.z)
        local rot_matrix_x = mat_rot_x(cur_mesh.rotation.x)
        local rot_matrix_y = mat_rot_y(cur_mesh.rotation.y)
        local rot_matrix_z = mat_rot_z(cur_mesh.rotation.z)

        for f=1, #cur_mesh.faces do
            local cull = false
            cur_face = cur_mesh.faces[f]         

            local face_vertices = {vec(), vec(), vec()}

            face_vertices[1] = cur_mesh.vertices[cur_face.a]
            face_vertices[2] = cur_mesh.vertices[cur_face.b]
            face_vertices[3] = cur_mesh.vertices[cur_face.c]

            local projected_triangle = {}
            local transformed_vertices = {}

            for i=1, 3 do
                cull = false
                local transformed_vertex = vec_copy(face_vertices[i])

                -- world matrix
                world_matrix = mat_identity() 
                --world_matrix = mat4_mul_mat4(scale_matrix, world_matrix)
                world_matrix = mat4_mul_mat4(rot_matrix_x, world_matrix)
                --world_matrix = mat4_mul_mat4(rot_matrix_y, world_matrix)
                --world_matrix = mat4_mul_mat4(rot_matrix_z, world_matrix)
                world_matrix = mat4_mul_mat4(translation_matrix, world_matrix)

                -- multiple world matrix by the original vector
                transformed_vertex = mat4_mul_vec(world_matrix, transformed_vertex)

                -- transform to camera space
                transformed_vertex = mat4_mul_vec(view_matrix, transformed_vertex)

                -- TODO: shouldn't need this
                transformed_vertex.z -= 5

                add(transformed_vertices, transformed_vertex)
            end

            -- backface culling
            if(backface_culling) then
                local vec_a = vec_copy(transformed_vertices[1])
                local vec_b = vec_copy(transformed_vertices[2])
                local vec_c = vec_copy(transformed_vertices[3])

                local vec_ab = vec_sub(vec_b, vec_a)
                local vec_ac = vec_sub(vec_c, vec_a)
                vec_normalize(vec_ab)
                vec_normalize(vec_ac)

                local n = vec_cross(vec_ab, vec_ac)
                vec_normalize(n)

                local origin = vec(0, 0, 0)
                local cam_ray = vec_sub(origin, vec_a)

                local dot_normal_cam = vec_dot(n, cam_ray)

                if (dot_normal_cam < 0) then
                    cull = true
                end
            end

            -- if face is not culled project it and add triangles to render
            if (not cull) then
                for i=1, 3 do
                    projected_point = mat4_mul_vec_project(proj_matrix, transformed_vertices[i])

                    -- scale into view
                    projected_point.x *= (127/2) 
                    projected_point.y *= (127/2) 
                    
                    -- translate to the middle of the screen
                    projected_point.x += (127/2)
                    projected_point.y += (127/2)

                    projected_triangle[i] = projected_point
                end
                    
                add(triangles_to_render, projected_triangle)
            end
        end
    end
end 

function _draw()
    cls(12)

    for t=1, #triangles_to_render do
        local cur_triangle = triangles_to_render[t]

        if (drawing_mode == 1 or drawing_mode==4 or drawing_mode == 5) then
            -- draw the vertices
            circfill(cur_triangle[1].x, cur_triangle[1].y, 2, 8)
            circfill(cur_triangle[2].x, cur_triangle[2].y, 2, 8)
            circfill(cur_triangle[3].x, cur_triangle[3].y, 2, 8)
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
        color(7)
        print_sys_info()
        print_mesh_info()
    end

    -- clear the z_buffer at the end of every frame
    clear_z_buffer()
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
