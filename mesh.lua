-- table to store all loaded meshes
meshes = {}

-- mesh loading variables
load_pending = false
load_in_progress = false
-- 1 = y
-- 2 = n
load_menu_option = 1 


-- mesh object definition
function mesh()
    return {
        vertices = {},
        faces = {},
        rotation = vec(0, 0, 0),
        scale = vec(1, 1, 1),
        translation = vec(0, 0, 0)
    }
end

-- hardcoded cube mesh for debugging
cube_vertices = {
    { x = -1, y = -1, z = -1 },
	{ x = -1, y =  1, z = -1 }, 
	{ x =  1, y =  1, z = -1 }, 
	{ x =  1, y = -1, z = -1 }, 
	{ x =  1, y =  1, z =  1 }, 
	{ x =  1, y = -1, z =  1 }, 
	{ x = -1, y =  1, z =  1 }, 
	{ x = -1, y = -1, z =  1 }
}

cube_faces = {
    -- front
    { a = 1, b = 2, c = 3},
    { a = 1, b = 3, c = 4},
    -- right
    { a = 4, b = 3, c = 5},
    { a = 4, b = 5, c = 6},
    -- back
    { a = 6, b = 5, c = 7},
    { a = 6, b = 7, c = 8},
    -- left
    { a = 8, b = 7, c = 2},
    { a = 8, b = 2, c = 1},
    -- top
    { a = 2, b = 7, c = 5},
    { a = 2, b = 5, c = 3},
    -- bottom
    { a = 6, b = 8, c = 1},
    { a = 6, b = 1, c = 4}
}

-- function to load mesh data into a mesh object
function load_cube_mesh()
    local mesh = mesh()

    -- TODO: replace with actual mesh loading
    mesh.vertices = cube_vertices
    mesh.faces = cube_faces

    add(meshes, mesh)
end

-- TODO: figure out how to do this better. I dont' really understand how to clear it out without just reading it all
function abort_load()
    repeat
        size = serial(0x800, 0x4300, 0x1000)
    until(size == 0)

    load_pending = false
    load_in_progress = false
end

function load_mesh()
    load_pending = false
    load_in_progress = true

    local file_contents=""
    local new_mesh = mesh()

    repeat
        size = serial(0x800, 0x4300, 0x1000)
        for i=0,size do 
            b = peek(0x4300 + i)
            file_contents = file_contents..chr(b)
        end
    until(size == 0)

    file_contents = split(file_contents, "\n", false)

    for i=1,#file_contents do
        local line_type = split(file_contents[i], " ")
        line_type = line_type[1]
        -- vertex data
        if (line_type=="v") then
            local cur_vertex = split(file_contents[i], " ")
            add(new_mesh.vertices, vec(cur_vertex[2],cur_vertex[3],cur_vertex[4]))
        end
        -- face data
        -- ignores texture and normal data right now
        if (line_type=="f") then
            local new_face = {}
            local cur_face = split(file_contents[i], " ")

            for i=2,4 do 
                local cur_point = split(cur_face[i], "/")
                add(new_face, cur_point[1]) 
            end

            add(new_mesh.faces, {a = new_face[1], b = new_face[2], c = new_face[3]})
        end
    end

    -- TODO: give user control over this
    new_mesh.translation.z = 5 * #meshes

    add(meshes, new_mesh)
    load_in_progress = false
end

function draw_load_msg()
    -- bg
    rectfill(20, 40, 107, 80, 0)
    rect(21, 41, 106, 79, 7)
    -- msg
    print("import detected!", 32, 46, 7)
    print("load mesh?", 44, 53, 7)
    -- selector
    -- yes
    if load_menu_option == 1 then
        rectfill(55, 62, 67, 68, 8)
    -- no
    elseif load_menu_option == 2 then
        rectfill(55, 69, 67, 75, 8)
    end
    -- options
    print("yes", 56, 63, 7)
    print("no", 58, 70, 7)
end