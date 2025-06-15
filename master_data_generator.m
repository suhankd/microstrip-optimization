T = readtable("generatedValues.csv");

substrate = dielectric;
substrate.Name = 'FH4';
substrate.EpsilonR = 4.3;
substrate.LossTangent = 0.025;
substrate.Thickness = 1.6e-3;

mainPatchLength = 30e-3;
patchWidth = 60e-3;

feedLength = T.fl(1);
feedWidth = T.fw(1);

patchLength = feedLength + mainPatchLength;
y_offset = (patchLength - mainPatchLength) * 0.5;

l1 = T.l1(1);
l2 = T.l2(1);
w1 = T.w1(1);
w2 = T.w2(1);
radius = T.r(1);

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
    'Radius', 6e-3, ...
    'Center', [0, y_offset]);

fullPatch = mainPatch + feed - (cutoutULeft + cutoutURight + cutoutUTop) - cutoutCircle;

pcb = pcbStack;
pcb.BoardShape = gnd;
pcb.BoardThickness = substrate.Thickness;
pcb.Layers = {fullPatch, substrate, gnd};
pcb.FeedLocations = [0, -patchLength / 2 + 1e-3, 1, 3];
pcb.Conductor = metal('Copper');

figure;
show(pcb);

% S11
freq = linspace(15e9, 20e9, 75);
s = sparameters(pcb, freq);
s11 = 20 * log10(abs(rfparam(s, 1, 1)));

% Calculating area made by the y(x) = -10 - s11 using the trapezoidal rule.
curve = -10 - s11;
area = trapz(freq / 1e9, curve);

fprintf("Area under curve (in dB.GHz) : %.4f\n", area);
