-- table to store all loaded meshes
meshes = {}

-- mesh object definition
function mesh()
    mesh = {
        vertices = {},
        faces = {},
        rotation = vec(0, 0, 0),
        scale = vec(1, 1, 1),
        translation = vec(0, 0, 0)
    }
    return mesh
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
	{ x = -1, y = -1, z =  1 }, 
}

cube_faces = {
    -- front
    { a = 1, b = 2, c = 3, a_uv = { 0, 1 }, b_uv = { 0, 0 }, c_uv = { 1, 0 }, color = 8 },
    { a = 1, b = 3, c = 4, a_uv = { 0, 1 }, b_uv = { 1, 0 }, c_uv = { 1, 1 }, color = 8 },
    -- right
    { a = 4, b = 3, c = 5, a_uv = { 0, 1 }, b_uv = { 0, 0 }, c_uv = { 1, 0 }, color = 8 },
    { a = 4, b = 5, c = 6, a_uv = { 0, 1 }, b_uv = { 1, 0 }, c_uv = { 1, 1 }, color = 8 },
    -- back
    { a = 6, b = 5, c = 7, a_uv = { 0, 1 }, b_uv = { 0, 0 }, c_uv = { 1, 0 }, color = 8 },
    { a = 6, b = 7, c = 8, a_uv = { 0, 1 }, b_uv = { 1, 0 }, c_uv = { 1, 1 }, color = 8 },
    -- left
    { a = 8, b = 7, c = 2, a_uv = { 0, 1 }, b_uv = { 0, 0 }, c_uv = { 1, 0 }, color = 8 },
    { a = 8, b = 2, c = 1, a_uv = { 0, 1 }, b_uv = { 1, 0 }, c_uv = { 1, 1 }, color = 8 },
    -- top
    { a = 2, b = 7, c = 5, a_uv = { 0, 1 }, b_uv = { 0, 0 }, c_uv = { 1, 0 }, color = 8 },
    { a = 2, b = 5, c = 3, a_uv = { 0, 1 }, b_uv = { 1, 0 }, c_uv = { 1, 1 }, color = 8 },
    -- bottom
    { a = 6, b = 8, c = 1, a_uv = { 0, 1 }, b_uv = { 0, 0 }, c_uv = { 1, 0 }, color = 8 },
    { a = 6, b = 1, c = 4, a_uv = { 0, 1 }, b_uv = { 1, 0 }, c_uv = { 1, 1 }, color = 8 }
}

-- function to load mesh data into a mesh object
function load_mesh()
    mesh = mesh()

    -- TODO: replace with actual mesh loading
    mesh.vertices = cube_vertices
    mesh.faces = cube_faces

    add(meshes, mesh)
end