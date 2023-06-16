function camera()
    return {
        position = vec(),
        direction = vec(0, 0, 1),
        velocity = vec(),
        yaw = 0,
        pitch = 0,
        move_speed = 0.01,
        scroll_speed = 0.1
    }
end

function cam_lookat_target(c)
    local target = vec(0, 0, 1)

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
    -- keyboard
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
        c.position.x -= c.move_speed
    end
    -- right
    if btn(1) then
        c.position.x += c.move_speed
    end

    -- mouse
    if mouse.button == 1 then
        -- pitch 
        if mouse.y < mouse.last_y then
            c.pitch -= mouse.move_sens 
        end
        if mouse.y > mouse.last_y then
            c.pitch += mouse.move_sens 
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

    --printh(dump(c.position))
end