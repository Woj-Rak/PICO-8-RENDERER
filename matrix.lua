function mat_identity()
    return {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
    }
end

function mat_scale(sx, sy, sz)
    local m = mat_identity()

    m[1] = sx
    m[6] = sy
    m[11] = sz

    return m
end

function mat_translation(tx, ty, tz)
    local m = mat_identity()

    m[4] = tx
    m[8] = ty
    m[12] = tz

    return m
end

function mat_rot_x(a)
    local m = mat_identity()

    local c = bettercos(a)
    local s = bettersin(a)

    m[6] = c
    m[7] = -s 
    m[10] = s
    m[11] = c 

    return m
end

function mat_rot_y(a)
    local m = mat_identity()

    local c = bettercos(a)
    local s = bettersin(a)

    m[1] = c 
    m[3] = s 
    m[9] = -s
    m[11] = c

    return m
end

function mat_rot_z(a)
    local m = mat_identity()

    local c = bettercos(a)
    local s = bettersin(a)

    m[1] = c
    m[2] = -s
    m[5] = s
    m[6] = c

    return m
end

function mat_perspective(fov, aspect, znear, zfar)
    local m = {
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0
    }

    m[1] = aspect * (1/bettertan(fov/2))
    m[6] = 1 / bettertan(fov/2)
    m[11] = zfar / (zfar - znear)
    m[12] = (-zfar * znear) / (zfar - znear)
    m[15] = 1

    return m
end

function mat4_mul_vec(m, v)
    local result = vec4(
        m[1]  * v.x + m[2]  * v.y + m[3]  * v.z + m[4]  * v.w,
        m[5]  * v.x + m[6]  * v.y + m[7]  * v.z + m[8]  * v.w,
        m[9]  * v.x + m[10] * v.y + m[11] * v.z + m[12] * v.w,
        m[13] * v.x + m[14] * v.y + m[15] * v.z + m[16] * v.w
    )

    return result
end

function mat4_mul_mat4(a, b)
    return {
        a[1]  * b[1] + a[2]  * b[5] + a[3]  * b[9]  + a[4]  * b[13],
        a[1]  * b[2] + a[2]  * b[6] + a[3]  * b[10] + a[4]  * b[14],
        a[1]  * b[3] + a[2]  * b[7] + a[3]  * b[11] + a[4]  * b[15],
        a[1]  * b[4] + a[2]  * b[8] + a[3]  * b[12] + a[4]  * b[16],
        a[5]  * b[1] + a[6]  * b[5] + a[7]  * b[9]  + a[8]  * b[13],
        a[5]  * b[2] + a[6]  * b[6] + a[7]  * b[10] + a[8]  * b[14],
        a[5]  * b[3] + a[6]  * b[7] + a[7]  * b[11] + a[8]  * b[15],
        a[5]  * b[4] + a[6]  * b[8] + a[7]  * b[12] + a[8]  * b[16],
        a[9]  * b[1] + a[6]  * b[5] + a[11] * b[9]  + a[12] * b[13],
        a[9]  * b[2] + a[10] * b[6] + a[11] * b[10] + a[12] * b[14],
        a[9]  * b[3] + a[10] * b[7] + a[11] * b[11] + a[12] * b[15],
        a[9]  * b[4] + a[10] * b[8] + a[11] * b[12] + a[12] * b[16],
        a[13] * b[1] + a[14] * b[5] + a[15] * b[9]  + a[16] * b[13],
        a[13] * b[2] + a[14] * b[6] + a[15] * b[10] + a[16] * b[14],
        a[13] * b[3] + a[14] * b[7] + a[15] * b[11] + a[16] * b[15],
        a[13] * b[4] + a[14] * b[8] + a[15] * b[12] + a[16] * b[16]
    }
end

function mat4_mul_vec_project(m, v)
    local result = mat4_mul_vec(m, v)

    if result.w != 0 then
        result.x /= result.w
        result.y /= result.w
        result.z /= result.w
    end

    return result
end

function mat_look_at(cam_pos, target)
    local z = vec_sub(target, cam_pos)
    vec_normalize(z)
    local x = vec_cross(v_up, z)
    vec_normalize(x)
    local y = vec_cross(z, x)

    local view_mat = {
        x.x, x.y, x.z, -vec_dot(x, cam_pos),
        y.x, y.y, y.z, -vec_dot(y, cam_pos),
        z.x, z.y, z.z, -vec_dot(z, cam_pos),
          0,   0,   0,                    1;
    }

    return view_mat
end