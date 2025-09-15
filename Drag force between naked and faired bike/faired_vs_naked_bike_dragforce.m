%% Motorcycle Aerodynamics: Faired vs Naked
% Praveen - Mechatronics Engineer Portfolio
% Compares drag, required power, and top speed for faired vs naked motorcycles.

clc; clear; close all;

%% Constants & shared parameters
rho = 1.20;           % air density (kg/m^3) ~ sea-level, mild weather
g   = 9.81;           % gravity (m/s^2)
Crr = 0.015;          % rolling resistance coefficient (street tire on asphalt)
m   = 200;            % mass bike + rider (kg)
eta_drivetrain = 0.90;% drivetrain efficiency (engine->wheel)
Rwheel = 0.33;        % effective wheel radius (m) ~ 17" wheel + tire

% Gearing (primary * top gear * final drive)
primary = 1.90;
gear6   = 0.96;
final   = 2.80;
overall = primary * gear6 * final;  % overall ratio in top gear

% Engine power curve (crank), simple bell-shaped ~ 650cc class
Pmax = 55e3;          % peak engine power (W) ~ 55 kW
rpm_peak = 9000;      % peak power rpm
rpm_idle = 1500;      % idle rpm
rpm_red  = 10500;     % redline

% Speed vector
v = linspace(0.1, 80, 800); % m/s (0.1 to 288 km/h)

%% Bike configurations (CdA = Cd * Area)
% Reasonable ballpark values
cfg(1).name = 'Naked';
cfg(1).CdA  = 0.70;   % m^2  (upright posture, turbulent)
cfg(1).color= [0 0.45 0.74];

cfg(2).name = 'Faired';
cfg(2).CdA  = 0.45;   % m^2  (sports fairing + tuck)
cfg(2).color= [0.85 0.33 0.10];

% Preallocate
for k = 1:numel(cfg)
    % Forces
    Fd = 0.5 * rho * cfg(k).CdA .* v.^2;  % aerodynamic drag
    Fr = Crr * m * g * ones(size(v));     % rolling resistance
    Ftot = Fd + Fr;                        % total resistive force

    % Power required at wheel
    P_req = Ftot .* v;                     % W

    % Map speed -> engine RPM in top gear
    % wheel_omega = v / Rwheel; engine_rpm = wheel_omega * overall * 60/(2*pi)
    rpm = (v / Rwheel) * overall * 60 / (2*pi);

    % Engine power curve (crank) ~ Gaussian around peak, with low-rpm ramp
    sigma = 0.35 * rpm_peak;
    P_eng = Pmax .* exp(-((rpm - rpm_peak).^2) / (2*sigma^2));
    % fade to zero outside idle-redline window
    P_eng(rpm < rpm_idle) = 0;
    P_eng(rpm > rpm_red)  = P_eng(rpm > rpm_red) .* ...
                            max(0, 1 - (rpm(rpm>rpm_red)-rpm_red)/(rpm_red*0.1));

    % Available wheel power
    P_wheel = P_eng * eta_drivetrain;

    % Top speed = highest v where wheel power >= required power
    feasible = P_wheel >= P_req;
    if any(feasible)
        idx = find(feasible, 1, 'last');
        cfg(k).Vtop = v(idx);                  % m/s
        cfg(k).P_at_top = P_req(idx)/1000;     % kW
        cfg(k).RPM_top  = rpm(idx);
    else
        cfg(k).Vtop = NaN; cfg(k).P_at_top = NaN; cfg(k).RPM_top = NaN;
    end

    % Store for plotting
    cfg(k).v     = v;
    cfg(k).Fd    = Fd;
    cfg(k).Fr    = Fr;
    cfg(k).Ftot  = Ftot;
    cfg(k).P_req = P_req/1000;  % kW
    cfg(k).P_w   = P_wheel/1000;% kW
    cfg(k).rpm   = rpm;
end

%% --------- Plots ---------
% 1) Forces vs Speed
figure('Name','Forces vs Speed','NumberTitle','off');
for k = 1:numel(cfg)
    plot(cfg(k).v*3.6, cfg(k).Fd, '-', 'LineWidth', 2, 'Color', cfg(k).color); hold on;
end
plot(v*3.6, cfg(1).Fr, '--', 'LineWidth', 1.5, 'Color', [0.3 0.3 0.3]); % same Fr for both
xlabel('Speed (km/h)'); ylabel('Force (N)');
title('Aerodynamic Drag and Rolling Resistance vs Speed');
legend({'Drag - Naked','Drag - Faired','Rolling Resistance'}, 'Location','northwest');
grid on;
saveas(gcf, 'Aero_Forces_vs_Speed.png');

% 2) Power Required vs Available Power
figure('Name','Power vs Speed','NumberTitle','off');
for k = 1:numel(cfg)
    plot(cfg(k).v*3.6, cfg(k).P_req, '-', 'LineWidth', 2, 'Color', cfg(k).color); hold on;
end
% Available power is same bike engine; show once (or show both—they’re identical)
plot(cfg(1).v*3.6, cfg(1).P_w, 'k-', 'LineWidth', 2);
xlabel('Speed (km/h)'); ylabel('Power (kW)');
title('Power Required (Drag+Rolling) vs Available Wheel Power');
legend({'Req - Naked','Req - Faired','Available Wheel Power'}, 'Location','northwest');
grid on;
saveas(gcf, 'Power_Required_vs_Available.png');

% Mark top speeds
for k = 1:numel(cfg)
    if ~isnan(cfg(k).Vtop)
        hold on;
        plot(cfg(k).Vtop*3.6, cfg(k).P_at_top, 'o', 'MarkerSize', 8, ...
             'MarkerFaceColor', cfg(k).color, 'MarkerEdgeColor', 'k');
        text(cfg(k).Vtop*3.6, cfg(k).P_at_top, ...
            sprintf('  %s Top ~ %.0f km/h', cfg(k).name, cfg(k).Vtop*3.6), ...
            'VerticalAlignment','bottom');
    end
end

% 3) RPM vs Speed (top gear)
figure('Name','Engine RPM vs Speed (Top Gear)','NumberTitle','off');
plot(cfg(1).v*3.6, cfg(1).rpm, 'LineWidth', 2); hold on;
yline(rpm_peak, '--', 'Peak Power RPM'); yline(rpm_red, '--', 'Redline');
xlabel('Speed (km/h)'); ylabel('Engine Speed (RPM)');
title('Engine RPM vs Speed (Top Gear)');
grid on;
saveas(gcf, 'RPM_vs_Speed.png');

%% --------- Optional: CdA Sweep (rider posture) ---------
% See how top speed changes if the rider tucks in (CdA decreases)
CdA_values = linspace(0.40, 0.80, 9);  % from deep tuck to upright naked
Vtops = nan(size(CdA_values));
for i = 1:numel(CdA_values)
    Fd_i = 0.5 * rho * CdA_values(i) .* v.^2;
    Fr_i = Crr * m * g;
    P_req_i = (Fd_i + Fr_i).*v;     % W
    feasible_i = (cfg(1).P_w*1000) >= P_req_i; % same engine
    if any(feasible_i)
        Vtops(i) = v(find(feasible_i,1,'last'))*3.6; % km/h
    end
end
figure('Name','Top Speed vs CdA','NumberTitle','off');
plot(CdA_values, Vtops, '-o', 'LineWidth', 2);
xlabel('CdA (m^2)'); ylabel('Top Speed (km/h)');
title('Effect of Rider/Fairing (CdA) on Top Speed');
grid on;
saveas(gcf, 'TopSpeed_vs_CdA.png');

%% --------- Console summary ---------
fprintf('--- Summary (same engine & gearing) ---\n');
for k = 1:numel(cfg)
    if ~isnan(cfg(k).Vtop)
        fprintf('%s: Top speed ~ %.1f km/h @ ~%.0f rpm (Power req ~ %.1f kW)\n', ...
            cfg(k).name, cfg(k).Vtop*3.6, cfg(k).RPM_top, cfg(k).P_at_top);
    else
        fprintf('%s: Top speed not reachable within speed range.\n', cfg(k).name);
    end
end
