T = readtable("generatedValues.csv");

substrate = dielectric;
substrate.Name = 'R5';
substrate.EpsilonR = 2.2;
substrate.LossTangent = 0.001;
substrate.Thickness = 1.6e-3;

f_target = 17.5e9;
scale = 1 / 4.94;  % ≈ 0.202

mainPatchLength = 30e-3 * scale;
patchWidth = 60e-3 * scale;

n = 50;
area_vector = zeros(n, 1);

for i = 1 : n

    feedLength = T.fl(i) * scale;
    feedWidth = T.fw(i) * scale;

    l1 = T.l1(i) * scale;
    l2 = T.l2(i) * scale;
    w1 = T.w1(i) * scale;
    w2 = T.w2(i) * scale;

    radius = T.r(i) * scale;

    patchLength = feedLength + mainPatchLength;
    y_offset = (patchLength - mainPatchLength) * 0.5;

    gnd = antenna.Rectangle( ...
        'Length', patchWidth, ...
        'Width', patchLength, ...
        'Center', [0, 0]);
    
    mainPatch = antenna.Rectangle( ...
        'Length', patchWidth, ...
        'Width', mainPatchLength, ...
        'Center', [0, y_offset]);
    
    feed = antenna.Rectangle( ...
        'Length', feedWidth, ...
        'Width', feedLength, ...
        'Center', [0, (-patchLength * 0.5) + (feedLength * 0.5)]);

    cutoutULeft = antenna.Rectangle( ...
        'Length', w1, ...
        'Width', l1, ...
        'Center', [w1 - l2 / 2, y_offset]);

    cutoutURight = antenna.Rectangle( ...
        'Length', w1, ...
        'Width', l1, ...
        'Center', [-w1 + l2 / 2, y_offset]);

    cutoutUTop = antenna.Rectangle( ...
        'Length', l2, ...
        'Width', w2, ...
        'Center', [0, y_offset + l1 / 2]);

    cutoutCircle = antenna.Circle( ...
        'Radius', radius, ...
        'Center', [0, y_offset]);

    fullPatch = mainPatch + feed - (cutoutULeft + cutoutURight + cutoutUTop) - cutoutCircle;

    pcb = pcbStack;
    pcb.BoardShape = gnd;
    pcb.BoardThickness = substrate.Thickness;
    pcb.Layers = {fullPatch, substrate, gnd};
    pcb.FeedLocations = [0, -patchLength / 2 + 1e-3 * scale, 1, 3];
    pcb.Conductor = metal('Copper');
        
    freq = linspace(15e9, 20e9, 75);
    s = sparameters(pcb, freq);
    s11 = 20 * log10(abs(rfparam(s, 1, 1)));
    
    curve = max(0, -10 - s11);
    
    plot(freq / 1e9, s11, 'LineWidth', 2);
    xlabel('Frequency (GHz)');
    ylabel('S11');
    title(sprintf('S11 vs Frequency (sample %d)', i));
    grid on;

    area = trapz(freq / 1e9, curve);
    
    fprintf("Sample %d — Area under curve (in dB·GHz): %.4f\n", i, area);
    
    area_vector(i) = area;

end

writematrix(area_vector, 'area_1to50_scaled.csv');
