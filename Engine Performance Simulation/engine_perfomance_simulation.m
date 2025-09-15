% Engine Performance Simulation for a Single-Cylinder Engine
% Praveen - Mechatronics Engineer Portfolio

clc; clear; close all;

% Engine Parameters
bore = 0.085;          % m
stroke = 0.088;        % m
CR = 10;               % Compression Ratio
rpm = 1000:500:10000;  % Engine speed range

% Derived parameters
Vd = (pi/4)*bore^2*stroke;    % Displacement volume (m^3)
Vc = Vd/(CR-1);               % Clearance volume (m^3)

% Assumptions
eff_vol = 0.85;                % Volumetric efficiency
air_density = 1.184;           % kg/m^3
AFR = 14.7;                    % Air-Fuel ratio
LHV = 44e6;                    % Fuel calorific value (J/kg)
mech_eff = 0.9;                % Mechanical efficiency

% Initialize results
torque = zeros(size(rpm));
power = zeros(size(rpm));

for i=1:length(rpm)
    N = rpm(i)/60;  % rev/s
    ma = eff_vol * air_density * Vd * N;   % Air mass flow rate
    mf = ma / AFR;                         % Fuel mass flow rate
    Qin = mf * LHV;                        % Energy input per second
    P_ind = Qin * 0.35;                    % Indicated Power (35% efficiency)
    P_brake = P_ind * mech_eff;            % Brake Power
    power(i) = P_brake/1000;               % kW
    torque(i) = (P_brake) / (2*pi*N);      % Nm
end

% Plotting
figure;
subplot(2,1,1)
plot(rpm, torque, 'LineWidth', 2);
xlabel('Engine Speed (RPM)');
ylabel('Torque (Nm)');
title('Torque vs RPM');
grid on;

subplot(2,1,2)
plot(rpm, power, 'r', 'LineWidth', 2);
xlabel('Engine Speed (RPM)');
ylabel('Power (kW)');
title('Power vs RPM');
grid on;
