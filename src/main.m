% Jag P - 2nd try 


% Referece: https://www.mathworks.com/help/parallel-computing/mandelbrot-set.html

% Load settings from JSON file
settings = jsondecode(fileread('settings.json'));

% Loop through each setting and render the Mandelbrot set
for i = 1:length(settings.settings)
    maxIterations = settings.settings(i).maxIterations;
    gridSize = settings.settings(i).gridSize;
    xlim = settings.settings(i).xlim;
    ylim = settings.settings(i).ylim;
    colorMap = settings.settings(i).colorMap;

    % Setup
    if gpuDeviceCount("available") >= 1
        x = gpuArray.linspace(xlim(1), xlim(2), gridSize);
        y = gpuArray.linspace(ylim(1), ylim(2), gridSize);
        [xGrid, yGrid] = meshgrid(x, y);
    else
        x = linspace(xlim(1), xlim(2), gridSize);
        y = linspace(ylim(1), ylim(2), gridSize);
        [xGrid, yGrid] = meshgrid(x, y);
        z0 = xGrid + 1i * yGrid;
        count = ones(size(z0));
    end

    % Calculate
    if gpuDeviceCount("available") >= 1
        count = arrayfun(@pctdemo_processMandelbrotElement, xGrid, yGrid, maxIterations);
    else
        z = z0;
        for n = 0:maxIterations
            z = z.*z + z0;
            inside = abs(z) <= 2;
            count = count + inside;
        end
        count = log(count);
    end

    % Show
    fig = gcf;
    fig.Position = [200 200 600 600];
    imagesc(x, y, count);
    colormap(colorMap);
    axis off;
end
