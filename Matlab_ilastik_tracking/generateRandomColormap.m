
function generateRandomColormap(num)

cmap = 0.2 + 0.8*rand(500,3);
cmap(1,:) = [0 0 0];

csvwrite('C:\Users\Skotheim Lab\Desktop\Matlab-Scripts\Matlab_ilastik_tracking\cmap.csv', cmap)

end