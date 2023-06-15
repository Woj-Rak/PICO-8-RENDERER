function camera()
    return {
        position = vec(),
        direction = vec(0, 0, 1),
        velocity = vec(),
        yaw = 0,
        pitch = 0
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