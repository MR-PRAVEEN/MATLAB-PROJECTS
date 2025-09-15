% Quarter Car Suspension System Simulation (Corrected)
% Praveen - Mechatronics Engineer Portfolio

clc; clear; close all;

% Vehicle parameters (Quarter Car Model)
ms = 300;       % Sprung mass (kg) -> car body supported per wheel
mu = 40;        % Unsprung mass (kg) -> wheel + suspension
ks = 15000;     % Suspension stiffness (N/m)
cs = 1000;      % Suspension damping (Ns/m)
kt = 200000;    % Tire stiffness (N/m)

% Simulation setup
tspan = [0 5];        % simulation time (s)
dt = 0.01;
time = 0:dt:5;        % for road profile

% Road input (bump profile)
road = zeros(size(time));
road(time>=1 & time<=1.2) = 0.05; % 5 cm bump between 1s and 1.2s

% Initial state [zs; zsdot; zu; zudot]
state0 = [0; 0; 0; 0];

% Run ODE
[t, x] = ode45(@(t, y) quarter_car(t, y, ms, mu, ks, cs, kt, road, time), tspan, state0);

% Extract results
zs = x(:,1); % sprung mass (body)
zu = x(:,3); % unsprung mass (wheel)

% Plot results
figure;
subplot(3,1,1);
plot(time, road, 'r', 'LineWidth', 2);
xlabel('Time (s)'); ylabel('Road (m)');
title('Road Input (Bump)');
grid on;

subplot(3,1,2);
plot(t, zs, 'b', 'LineWidth', 2);
xlabel('Time (s)'); ylabel('Body Displacement (m)');
title('Car Body Response');
grid on;

subplot(3,1,3);
plot(t, zu, 'k', 'LineWidth', 2);
xlabel('Time (s)'); ylabel('Wheel Displacement (m)');
title('Wheel Response');
grid on;

% --- Quarter car dynamics function ---
function dydt = quarter_car(t, y, ms, mu, ks, cs, kt, road, timeVec)
    zs = y(1); zsdot = y(2);
    zu = y(3); zudot = y(4);

    % Interpolate road input at current time
    zr = interp1(timeVec, road, t);

    % Forces
    F_spring = ks*(zu - zs);
    F_damper = cs*(zudot - zsdot);
    F_tire = kt*(zr - zu);

    % Equations of motion
    zsdotdot = (F_spring + F_damper)/ms;
    zudotdot = (F_tire - F_spring - F_damper)/mu;

    dydt = [zsdot; zsdotdot; zudot; zudotdot];
end
