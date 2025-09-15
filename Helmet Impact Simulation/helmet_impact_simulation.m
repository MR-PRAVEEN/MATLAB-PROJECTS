% Smart Helmet Impact Simulation (Mass-Spring-Damper Model)
% Praveen - Mechatronics Engineer Portfolio

clc; clear; close all;

% Parameters (approximate values)
m_head = 5;         % Mass of head (kg)
k_helmet = 8000;    % Helmet stiffness (N/m)
c_helmet = 300;     % Helmet damping (Ns/m)
h_drop = 1.5;       % Drop height (m)

% Initial conditions
v0 = sqrt(2*9.81*h_drop); % Impact velocity (m/s)
state0 = [0; -v0];        % [displacement; velocity]

% Simulation time
tspan = [0 0.05];  % short impact duration

% Run ODE
[t, x] = ode45(@(t, y) helmet_dynamics(t, y, m_head, k_helmet, c_helmet), tspan, state0);

% Extract displacement & velocity
disp = x(:,1);
vel = x(:,2);
acc = [diff(vel)./diff(t); 0];  % approximate acceleration

% Force experienced by head
F = m_head * acc;

% Plot results
figure;

subplot(3,1,1);
plot(t, disp*1000, 'b', 'LineWidth', 2);
xlabel('Time (s)'); ylabel('Displacement (mm)');
title('Helmet Compression during Impact');
grid on;

subplot(3,1,2);
plot(t, vel, 'r', 'LineWidth', 2);
xlabel('Time (s)'); ylabel('Velocity (m/s)');
title('Head Velocity during Impact');
grid on;

subplot(3,1,3);
plot(t, F/1000, 'k', 'LineWidth', 2);
xlabel('Time (s)'); ylabel('Force (kN)');
title('Impact Force on Head');
grid on;

% --- Helmet Dynamics Function ---
function dydt = helmet_dynamics(~, y, m, k, c)
    disp = y(1); vel = y(2);
    acc = -(k*disp + c*vel)/m; % Spring-damper system
    dydt = [vel; acc];
end
