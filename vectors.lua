-- every vector will be a vec4
function vec(x, y, z, w)
    return {x=x or 0, y=y or 0, z=z or 0, w=w or 0}
end

function vec_copy(v)
    return vec(v.x, v.y, v.z, v.w)
end

function vec_len(v)
    return sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
end

function vec_add(a, b)
    return vec(a.x + b.x, a.y + b.y + a.z + b.z)
end

function vec_sub(a, b)
    return vec(a.x - b.x, a.y - b.y, a.z - b.z)
end

function vec_mul(v, f)
    return vec(v.x * f, v.y * f, v.z * f)
end

function vec_div(v, f)
    return vec(v.x / f, v.y / f, v.z / f)
end

function vec_dot(a, b)
    return (a.x * b.x) + (a.y * b.y) + (a.z * b.z)
end

function vec_cross(a, b)
    return vec(
        a.y * b.z - a.z * b.y,
        a.z * b.x - a.x * b.z,
        a.x * b.y - a.y * b.x
    )
end

function vec_normalize(v)
    local length = vec_len(v)

    if length == 0 then return v end

    v.x /= length
    v.y /= length
    v.z /= length
end

-- directions
v_up = vec(0, 1, 0)
v_down = vec(0, -1, 0)
v_left = vec(-1, 0, 0)
v_right = vec(1, 0, 0)