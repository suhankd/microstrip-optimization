substrate = dielectric;
substrate.Name = 'FH4';
substrate.EpsilonR = 4.3;
substrate.LossTangent = 0.025;
substrate.Thickness = 1.6e-3;

patchLength = 50e-3;
patchWidth = 60e-3;

mainPatchLength = 30e-3;

y_offset = (patchLength - mainPatchLength) * 0.5;

gnd = antenna.Rectangle('Length', patchWidth, ...
                       'Width', patchLength, ...
                       'Center', [0,0]);

mainPatch = antenna.Rectangle('Length', patchWidth, ...
                             'Width', mainPatchLength, ...
                             'Center', [0, y_offset]);

feedWidth = 3e-3;
feedLength = 20e-3;

feed = antenna.Rectangle('Length', feedWidth, ...
                         'Width', feedLength, ...
                         'Center', [0,(-patchLength * 0.5) + (feedLength * 0.5)]);

l1 = 18e-3;
l3 = 18e-3;
w1 = 2e-3;
w3 = 2e-3;

l2 = 2e-3;
w2 = 38e-3;

cutoutULeft = antenna.Rectangle('Length', w1, ...
                                'Width', l1, ...
                                'Center', [w1 - w2/2, y_offset]);  % left side

cutoutURight = antenna.Rectangle('Length', w3, ...
                                 'Width', l3, ...
                                 'Center', [-w3 + w2/2, y_offset]);   % right side

cutoutUTop = antenna.Rectangle('Length', w2, ...
                               'Width', l2, ...
                               'Center', [0, y_offset + l1/2]);  % top bar


cutoutCircle = antenna.Circle('Radius', 6e-3, ...
                              'Center', [0, y_offset]);

fullPatch = mainPatch + feed - (cutoutULeft + cutoutURight + cutoutUTop) - cutoutCircle;

pcb = pcbStack;
pcb.BoardShape = gnd;
pcb.BoardThickness = substrate.Thickness;
pcb.Layers = {fullPatch, substrate, gnd};
pcb.FeedLocations = [0, -patchLength/2 + 1e-3, 1, 3];
pcb.Conductor = metal('Copper');

figure;
show(pcb);

freq = linspace(15e9, 20e9, 75);

s = sparameters(pcb, freq);

s11 = 20 * log10(abs(rfparam(s, 1, 1)));

curve = -10 - s11;
area = trapz(freq/1e9, curve);

fprintf("Area under curve (in dB.GHz) : %.4f\n", area);

figure;
plot(freq/1e9, s11, 'LineWidth', 2);
xlabel('Frequency (GHz)');
ylabel('|S_{11}| (dB)');
title('S_{11} vs Frequency');
grid on;

% pattern(pcb, freq, 0, 0:1:360);

% freq = linspace(15e9, 20e9, 200);
% maxGain = zeros(size(freq)); %Allocate

% for i = 1:length(freq)
% 
%     gainPattern = pattern(pcb, freq(i), 0:5:180, 0:5:360);
% 
%     maxGain(i) = max(gainPattern(:)); % Store the maximum gain for the current frequency
% end

% figure;
% plot(freq/1e9, maxGain, 'LineWidth', 2);
% xlabel('Frequency (GHz)');
% ylabel('Max Gain (dBi)');
% title('Maximum Gain vs Frequency');
% grid on;

