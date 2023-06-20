function mat_identity()
    return {
        {1, 0, 0, 0},
        {0, 1, 0, 0},
        {0, 0, 1, 0},
        {0, 0, 0, 1}
    }
end

function mat_scale(sx, sy, sz)
    local m = mat_identity()

    m[1][1] = sx
    m[2][2] = sy
    m[3][3] = sz

    return m
end

function mat_translation(tx, ty, tz)
    local m = mat_identity()

    m[1][4] = tx
    m[2][4] = ty
    m[3][4] = tz

    return m
end

function mat_rot_x(a)
    local m = mat_identity()

    local c = bettercos(a)
    local s = bettersin(a)

    m[2][2] = c
    m[2][3] = -s 
    m[3][2] = s
    m[3][3] = c 

    return m
end

function mat_rot_y(a)
    local m = mat_identity()

    local c = bettercos(a)
    local s = bettersin(a)

    m[1][1] = c 
    m[1][3] = s 
    m[3][1] = -s
    m[3][3] = c

    return m
end

function mat_rot_z(a)
    local m = mat_identity()

    local c = bettercos(a)
    local s = bettersin(a)

    m[1][1] = c
    m[1][2] = -s
    m[2][1] = s
    m[2][2] = c

    return m
end

function mat_perspective(fov, aspect, znear, zfar)
    local m = {
        {0,0,0,0},
        {0,0,0,0},
        {0,0,0,0},
        {0,0,0,0}
    }

    m[1][1] = aspect * (1/bettertan(fov/2))
    m[2][2] = 1 / bettertan(fov/2)
    m[3][3] = zfar / (zfar - znear)
    m[3][4] = (-zfar * znear) / (zfar - znear)
    m[4][3] = 1

    return m
end

function mat4_mul_vec(m, v)
    local result = vec4(
        m[1][1] * v.x + m[1][2] * v.y + m[1][3] * v.z + m[1][4] * v.w,
        m[2][1] * v.x + m[2][2] * v.y + m[2][3] * v.z + m[2][4] * v.w,
        m[3][1] * v.x + m[3][2] * v.y + m[3][3] * v.z + m[3][4] * v.w,
        m[4][1] * v.x + m[4][2] * v.y + m[4][3] * v.z + m[4][4] * v.w
    )

    return result
end

function mat4_mul_mat4(a, b)
    local mr = mat_identity()

    for i=1, 4 do
        for j=1, 4 do
            mr[i][j] = a[i][1] * b[1][j] + a[i][2] * b[2][j] + a[i][3] * b[3][j] + a[i][4] * b[4][j]
        end
    end

    return mr
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
        {x.x, x.y, x.z, -vec_dot(x, cam_pos)},
        {y.x, y.y, y.z, -vec_dot(y, cam_pos)},
        {z.x, z.y, z.z, -vec_dot(z, cam_pos)},
        {  0,   0,   0,                1}
    }

    return view_mat
end