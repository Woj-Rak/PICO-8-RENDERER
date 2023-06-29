pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
-- PICO-8 SOFTWARE RENDERER
-- BY WOJTEK RAK
#include lights.lua
#include utils.lua
#include mouse.lua
#include camera.lua
#include vectors.lua
#include draw.lua
#include math.lua
#include mesh.lua
#include matrix.lua

-- TODO:
-- next version:
-- different trifill function?
-- texture loading?
    -- removed a lot of the texture related code so all of that will need another look
-- if not textures then use solid colors that can be changed at run time?
-- shading implemenation something along the lines of pico-cad

debug = false
-- 0 = no rotation
-- 1 = y axis rotation
-- 2 = x axis rotation
-- 3 = x and y rotation
rotation_mode = 0 

-- main
function _init()
    mouse.init()
    cam = camera()
    cam.position.y = 5
    cam.position.z -= 8 
    cam.pitch = 0.5 

    -- projection matrix
    fov = 120
    znear = 0.1
    zfar = 100
    proj_matrix = mat_perspective(fov, 1, znear, zfar)

    main_light = light()
    main_light.direction.z = 1
end

function _update()
    -- check for file loads
    if (stat(120) and not load_pending) then
        load_pending = true
    end

    -- input
    if (load_pending) then
        if btnp(⬇️) then
            load_menu_option += 1
        end
        if btnp(⬆️) then
            load_menu_option -= 1
        end

        if load_menu_option > 2 then load_menu_option = 1 end
        if load_menu_option < 1 then load_menu_option = 2 end

        if (btnp(🅾️)) then
            if (load_menu_option == 1) then
                load_mesh()
            elseif (load_menu_option == 2) then
                abort_load()
            end
        end
        return
    end

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
    -- auto rotate toggle
    if btnp(⬇️) and btn(🅾️) then
        rotation_mode += 1
        if rotation_mode > 3 then rotation_mode = 0 end
    end
    -- add cube mesh
    if btnp(🅾️) and #meshes == 0 then
        load_cube_mesh()
    end
    -- toggle debug mode
    if btnp(❎) and btn(🅾️) then 
        debug = not debug
    end
    if btn(❎) and not debug and #meshes > 0 then
        showing_controls = true
    else
        showing_controls = false
    end
    -- mouse input
    mouse.update()

    -- camera movement
    if #meshes > 0 then
        camera_movement(cam)
    end

    -- gfx process
    triangles_to_render = {}

    for m=1, #meshes do
        cur_mesh = meshes[m]

        if rotation_mode == 1 or rotation_mode == 3 then
            cur_mesh.rotation.x += 0.01
        end

        if rotation_mode == 2 or rotation_mode == 3 then 
            cur_mesh.rotation.y += 0.01
        end

        -- view matrix
        local target = cam_lookat_target(cam)
        local view_matrix = mat_look_at(cam.position, target)
        -- translation scale rotation matrices
        local scale_matrix = mat_scale(cur_mesh.scale.x, cur_mesh.scale.y, cur_mesh.scale.z)
        local translation_matrix = mat_translation(cur_mesh.translation.x, cur_mesh.translation.y, cur_mesh.translation.z)
        local rot_matrix_x = mat_rot_x(cur_mesh.rotation.x)
        local rot_matrix_y = mat_rot_y(cur_mesh.rotation.y)

        for f=1, #cur_mesh.faces do
            local cull = false
            cur_face = cur_mesh.faces[f]

            local face_vertices = {cur_mesh.vertices[tonum(cur_face.a)], cur_mesh.vertices[tonum(cur_face.b)], cur_mesh.vertices[tonum(cur_face.c)]}

            local projected_triangle = {}
            local transformed_vertices = {}

            for i=1, 3 do
                cull = false
                local transformed_vertex = vec4_from_vec(vec_copy(face_vertices[i]))

                -- removed scale and z axis rotation for performance
                -- world matrix
                world_matrix = mat_identity() 
                world_matrix = mat4_mul_mat4(rot_matrix_x, world_matrix)
                world_matrix = mat4_mul_mat4(rot_matrix_y, world_matrix)
                world_matrix = mat4_mul_mat4(translation_matrix, world_matrix)
                -- multiple world matrix by the original vector
                transformed_vertex = mat4_mul_vec(world_matrix, transformed_vertex)

                -- transform to camera space
                transformed_vertex = mat4_mul_vec(view_matrix, transformed_vertex)

                add(transformed_vertices, transformed_vertex)
            end
            
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

            -- backface culling
            if(backface_culling) then
                if (dot_normal_cam < 0) then
                    cull = true
                end
            end

            -- average depth
            local avg_depth = (transformed_vertices[1].z + transformed_vertices[2].z + transformed_vertices[3].z) / 3

            -- shading
            local light_intensity = -vec_dot(n, main_light.direction)
            if light_intensity > 1 then 
                light_intensity = 1
            elseif light_intensity < 0 then
                light_intensity = 0
            end

            -- if face is not culled project it and add triangles to render
            if (not cull) then
                for i=1, 3 do
                    projected_point = mat4_mul_vec_project(proj_matrix, transformed_vertices[i])
                    -- fix the orientation
                    projected_point.y *= -1

                    -- scale into view
                    projected_point.x *= (127/2) 
                    projected_point.y *= (127/2) 
                    
                    -- translate to the middle of the screen
                    projected_point.x += (127/2)
                    projected_point.y += (127/2)

                    projected_triangle[i] = projected_point
                end

                projected_triangle.c = light_intensity
                projected_triangle.avg_depth = avg_depth

                add(triangles_to_render, projected_triangle)
            end
        end
    end

    -- sort the triangles to render by their average depth    
    if (backface_culling and #meshes < 2) then return end

    for i=1,#triangles_to_render do
        for j=1,#triangles_to_render do
            if triangles_to_render[i].avg_depth > triangles_to_render[j].avg_depth then
                local tmp = triangles_to_render[i]
                triangles_to_render[i] = triangles_to_render[j]
                triangles_to_render[j] = tmp
            end
        end
    end
end 

function _draw()
    cls(12)

    if load_in_progress then return end

    if (#meshes == 0) then
        oprint("drag an .obj model here", 16, 50, 0, 7)
        oprint("or press 🅾️ to load a cube", 10, 58, 0, 7)
    end

    -- rendering
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
            local new_color

            -- play around with these thresholds
            if cur_triangle.c > .6 then
                new_color = 7 
            elseif cur_triangle.c > .35 then
                new_color = 6
            else
                new_color = 5
            end

            draw_triangle_filled(cur_triangle[1].x,cur_triangle[1].y,cur_triangle[1].z,cur_triangle[1].w,
                                 cur_triangle[2].x,cur_triangle[2].y,cur_triangle[2].z,cur_triangle[2].w,
                                 cur_triangle[3].x,cur_triangle[3].y,cur_triangle[3].z,cur_triangle[3].w,
                                 new_color)
        end

        -- draw wireframe triangle
        if (drawing_mode == 1 or drawing_mode == 2 or drawing_mode == 4) then
            draw_triangle(cur_triangle[1].x, cur_triangle[1].y, cur_triangle[2].x, cur_triangle[2].y, cur_triangle[3].x, cur_triangle[3].y, 11)
        end
    end

    -- mouse draw
    mouse.draw()

    if (showing_controls) then
        show_controls()
    end

    -- file loading
    if load_pending then
        draw_load_msg()
        return
    end

    -- debug output
    if (debug) then
        color(7)
        print_sys_info()
        print_mesh_info()
    end
end

__gfx__
00010000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00171000017171710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00177100117777710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00177710717777710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00177771177777710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00177771011777110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00177110001777100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00011710000111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
