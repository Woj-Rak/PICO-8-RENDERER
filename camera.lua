function camera()
    return {
        position = vec(),
        direction = vec(0, 0, 1),
        velocity = vec(),
        yaw = 0,
        pitch = 0,
        move_speed = 0.1,
        scroll_speed = 1
    }
end

function cam_lookat_target(c)
    local target = vec4(0, 0, 1)

    local cam_yaw_rot = mat_rot_y(c.yaw)
    local cam_pitch_rot = mat_rot_x(c.pitch)

    -- rot matrix
    local camera_rotation = mat_identity()
    camera_rotation = mat4_mul_mat4(cam_pitch_rot, camera_rotation)
    camera_rotation = mat4_mul_mat4(cam_yaw_rot, camera_rotation)

    -- update direction
    c.direction = mat4_mul_vec(camera_rotation, target)

    target = vec_add(c.position, c.direction)

    return target
end

function camera_movement(c)
    -- mouse
    if mouse.button == 1 then
        -- pitch 
        if mouse.y < mouse.last_y then
            c.pitch += mouse.move_sens 
        end
        if mouse.y > mouse.last_y then
            c.pitch -= mouse.move_sens 
        end
        -- yaw
        if mouse.x < mouse.last_x then
            c.yaw += mouse.move_sens
        end
        if mouse.x > mouse.last_x then
            c.yaw -= mouse.move_sens
        end
    end

    if mouse.scroll == 1 then
        c.position.y -= c.scroll_speed
    end
    if mouse.scroll == -1 then
        c.position.y += c.scroll_speed
    end

    if debug then return end
    -- keyboard
    -- if modifier key is held down leave early
    if btn(4) then return end
    -- forward
    if btn(2) then
        c.velocity = vec_mul(c.direction, c.move_speed)
        c.position = vec_add(c.position, c.velocity)
    end
    -- back
    if btn(3) then
        c.velocity = vec_mul(c.direction, c.move_speed)
        c.position = vec_sub(c.position, c.velocity)
    end
    -- left
    if btn(0) then
        local strafe = vec_cross(c.direction, v_up)
        c.velocity = vec_mul(strafe, c.move_speed)
        c.position = vec_add(c.position, c.velocity)
    end
    -- right
    if btn(1) then
        local strafe = vec_cross(c.direction, v_up)
        c.velocity = vec_mul(strafe, c.move_speed)
        c.position = vec_sub(c.position, c.velocity)
    end
end