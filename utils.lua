peak_cpu_useage = 0

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
   if ((stat(1)*100) > peak_cpu_useage) peak_cpu_useage = (stat(1)*100)
   print("fps:"..stat(7))
   print("cpu:"..(stat(1)*100).."% ("..peak_cpu_useage.."% peak)")
   print("memory:"..stat(0).." kb")
end

function print_mesh_info()
   local vert_count = 0
   local face_count = 0

   for m=1,#meshes do
      vert_count += #meshes[m].vertices
      face_count += #meshes[m].faces
   end

   print("tris:"..#triangles_to_render)
   print("verts:"..vert_count)
   print("faces:"..face_count)
   print("BFC:"..(backface_culling and 'ON' or 'OFF').."(⬆️+🅾️)", 0, 117)
   print("AUTO-ROTATE:"..(auto_rotate and 'ON' or 'OFF').."(⬇️+🅾️)", 0, 123)
end

function oprint(t,x,y,c1,c2)
	for i=0,2 do
	 for j=0,2 do
	  if not(i==1 and j==1) then
	   print(t,x+i,y+j,c1)
	  end
	 end
	end
	print(t,x+1,y+1,c2)
end