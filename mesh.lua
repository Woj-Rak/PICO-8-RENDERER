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
    { a = 1, b = 2, c = 3, color = 8 },
    { a = 1, b = 3, c = 4, color = 8 },
    -- right
    { a = 4, b = 3, c = 5, color = 8 },
    { a = 4, b = 5, c = 6, color = 8 },
    -- back
    { a = 6, b = 5, c = 7, color = 8 },
    { a = 6, b = 7, c = 8, color = 8 },
    -- left
    { a = 8, b = 7, c = 2, color = 8 },
    { a = 8, b = 2, c = 1, color = 8 },
    -- top
    { a = 2, b = 7, c = 5, color = 8 },
    { a = 2, b = 5, c = 3, color = 8 },
    -- bottom
    { a = 6, b = 8, c = 1, color = 8 },
    { a = 6, b = 1, c = 4, color = 8 }
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
end

function draw_load_msg()
    -- bg
    rectfill(20, 40, 107, 80, 0)
    rect(21, 41, 106, 79, 7)
    -- msg
    print("import detected!", 32, 46, 7)
    print("load mesh?", 44, 53, 7)
    -- selector
    if load_menu_option == 1 then
        rectfill(55, 62, 67, 68, 8)
    elseif load_menu_option == 2 then
        rectfill(55, 69, 67, 75, 8)
    end
    -- options
    print("yes", 56, 63, 7)
    print("no", 58, 70, 7)
end