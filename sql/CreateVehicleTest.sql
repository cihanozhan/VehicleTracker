--select geography::STGeomFromText('POINT(150.1885986328125 -34.569906380856345)', 4326) 
USE [VehicleTrackerDB] 

go 

EXEC CreateVehicle 
  '54B030F0-6B22-49B8-9ED2-177E5B0D9001', 
  '7E0750EA-D913-407C-B349-1BBFE23FBFB5', 
  '202', 
  '150.1885986328125', 
  '-34.569906380856345' 