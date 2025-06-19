T = readtable("generatedValues.csv");

substrate = dielectric;
substrate.Name = 'R5';
substrate.EpsilonR = 2.2;
substrate.LossTangent = 0.0009;
substrate.Thickness = 2.5e-3;

scale = 0.2;  % scaling from ~3.5 GHz to 17.5 GHz

mainPatchLength = 30e-3 * scale;
patchWidth = 60e-3 * scale;

feedLength = T.fl(8) * scale;
feedWidth = T.fw(8) * scale;

patchLength = feedLength + mainPatchLength;
y_offset = (patchLength - mainPatchLength) * 0.5;

l1 = T.l1(8) * scale;
l2 = T.l2(8) * scale;
w1 = T.w1(8) * scale;
w2 = T.w2(8) * scale;
radius = T.r(8) * scale;

gnd = antenna.Rectangle( ...
    'Length', patchWidth, ...
    'Width', patchLength, ...
    'Center', [0, 0]);

mainPatch = antenna.Rectangle( ...
    'Length', patchWidth, ...
    'Width', mainPatchLength, ...z
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
pcb.FeedLocations = [0, -patchLength / 2 + 1e-3 * scale + y_offset, 1, 3];
pcb.FeedDiameter = 1.5e-3 * scale;
pcb.Conductor = metal('Copper');

figure;
show(pcb);

% S11
freq = linspace(17e9, 24e9, 75);
s = sparameters(pcb, freq);
s11 = 20 * log10(abs(rfparam(s, 1, 1)));

figure;
plot(freq/1e9, s11, 'LineWidth', 2);
xlabel('Frequency (GHz)');
ylabel('|S_{11}| (dB)');
title('S_{11} vs Frequency');
grid on;

% Calculating area under curve y(x) = max(0, -10 - s11)
curve = max(0, -10 - s11);
area = trapz(freq / 1e9, curve);

fprintf("Area under curve (in dB·GHz) : %.4f\n", area);
