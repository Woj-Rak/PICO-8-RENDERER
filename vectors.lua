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
    v.x /= length
    v.y /= length
    v.z /= length
end

function v_rot_x(v,a) return vec(v.x, v.y * cos(a) - v.z * sin(a), v.y * sin(a) + v.z * cos(a)) end
function v_rot_y(v,a) return vec(v.x * cos(a) - v.z * sin(a), v.y, v.x * sin(a) + v.z * cos(a)) end
function v_rot_z(v,a) return vec(v.x * cos(a) - v.y * sin(a), v.x * sin(a) + v.y * cos(a), v.z) end