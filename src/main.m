% Referece: https://www.mathworks.com/help/parallel-computing/mandelbrot-set.html

maxIterations = 500;
gridSize = 1000;
xlim = [-0.748766713922161, -0.748766707771757];
ylim = [ 0.123640844894862,  0.123640851045266];
CUDA_COMPUTE = false;

% Setup
if  gpuDeviceCount("available") >= 1
    x = gpuArray.linspace( xlim(1), xlim(2), gridSize );
    y = gpuArray.linspace( ylim(1), ylim(2), gridSize );
    [xGrid,yGrid] = meshgrid( x, y );
else
    x = linspace( xlim(1), xlim(2), gridSize );
    y = linspace( ylim(1), ylim(2), gridSize );
    [xGrid,yGrid] = meshgrid( x, y );
    z0 = xGrid + 1i*yGrid;
    count = ones( size(z0) );   
end

% Calculate
if  gpuDeviceCount("available") >= 1
    count = arrayfun( @pctdemo_processMandelbrotElement, xGrid, yGrid, maxIterations );
else
    z = z0;
    parfor n = 0:maxIterations
        z = z.*z + z0;
        inside = abs( z )<=2;
        count = count + inside;
    end
    count = log( count );
end

% Show
fig = gcf;
fig.Position = [200 200 600 600];
imagesc( x, y, count );
colormap( [jet();flipud( jet() );0 0 0] );
axis off