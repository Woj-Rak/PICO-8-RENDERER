-- used to output the contents of anything and everything
function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function print_sys_info()
   print("fps:"..stat(7).."fps")
   print("cpu:"..(stat(1)*100).."%")
   print("memory:"..stat(0).." kb")
end

function print_mesh_info()
   local vert_count = 0

   for m=1,#meshes do
      vert_count += #meshes[m].vertices
   end

   print("tris:"..#triangles_to_render)
   print("verts:"..vert_count)
   print("backface cull:"..(backface_culling and 'true' or 'false'), 0, 123)
end