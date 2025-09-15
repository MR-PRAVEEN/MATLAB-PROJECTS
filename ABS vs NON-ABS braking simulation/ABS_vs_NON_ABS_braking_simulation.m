% ABS vs Non-ABS Braking Simulation
% Praveen - Mechatronics Engineer Portfolio

clc; clear; close all;

% Vehicle parameters
m = 1500;          % vehicle mass (kg)
R = 0.3;           % wheel radius (m)
Iz = 1.8;          % wheel inertia (kg*m^2)
g = 9.81;          % gravity (m/s^2)
mu_max = 0.9;      % peak road friction coefficient
V0 = 30;           % initial speed (m/s) ~ 108 km/h
brake_force = 6000; % braking force (N)

% Simulation parameters
dt = 0.001;         % time step
t_end = 5;          % simulation time
time = 0:dt:t_end;

% Initialize variables
v = V0 * ones(size(time));  % vehicle speed
w = (V0/R) * ones(size(time)); % wheel angular velocity
slip = zeros(size(time));
a = zeros(size(time));

% ABS control variables
abs_active = true;
lambda_opt = 0.15;   % optimal slip ratio ~ 15%
Kp = 2000;           % ABS proportional gain

% Loop simulation
for i = 1:length(time)-1
    % Slip ratio
    slip(i) = max(0, (v(i) - w(i)*R) / max(v(i),0.1));
    
    if abs_active
        % ABS controller: adjust brake torque based on slip
        mu = mu_max * (slip(i)/(lambda_opt)) * exp(1 - slip(i)/lambda_opt);
        Tb = min(Kp*(slip(i)-lambda_opt), brake_force*R);
    else
        % Non-ABS braking: constant brake torque
        mu = mu_max;
        Tb = brake_force*R;
    end
    
    % Forces
    F_brake = mu * m * g;
    a(i) = -F_brake/m;
    
    % Vehicle dynamics update
    v(i+1) = v(i) + a(i)*dt;
    v(i+1) = max(v(i+1),0);
    
    % Wheel dynamics update
    Tw = Tb;
    alpha = (Tw - F_brake*R)/Iz;
    w(i+1) = w(i) + alpha*dt;
    w(i+1) = max(w(i+1),0);
end

% Slip final
slip(end) = (v(end) - w(end)*R) / max(v(end),0.1);

% Plot results
figure;
subplot(3,1,1);
plot(time, v, 'b', 'LineWidth', 2);
xlabel('Time (s)'); ylabel('Vehicle Speed (m/s)');
title('Vehicle Speed vs Time');
grid on;

subplot(3,1,2);
plot(time, slip*100, 'r', 'LineWidth', 2);
xlabel('Time (s)'); ylabel('Slip Ratio (%)');
title('Slip Ratio vs Time');
grid on;

subplot(3,1,3);
plot(time, a, 'k', 'LineWidth', 2);
xlabel('Time (s)'); ylabel('Deceleration (m/s^2)');
title('Vehicle Deceleration vs Time');
grid on;
