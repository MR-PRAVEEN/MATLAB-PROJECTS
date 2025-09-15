clc; clear; close all;

% Define RPM range
rpm = linspace(3000, 13000, 500);
omega = rpm * 2 * pi / 60; % rad/s

%% Yamaha R3 (spec sheet accurate)
Ppeak_R3 = 31.0;        % kW (42 hp)
rpm_peakP_R3 = 10750;
Tpeak_R3 = 29.5;        % Nm
rpm_peakT_R3 = 9000;

sigma_R3 = 1800;
Torque_R3 = Tpeak_R3 * exp(-0.5*((rpm - rpm_peakT_R3)/sigma_R3).^2);
Power_R3 = Torque_R3 .* omega / 1000;

%% Aprilia RS457 (spec sheet accurate)
Ppeak_RS = 35.0;        % kW (47 hp)
rpm_peakP_RS = 9400;
Tpeak_RS = 43.5;        % Nm
rpm_peakT_RS = 6700;

sigma_RS = 2000;
Torque_RS = Tpeak_RS * exp(-0.5*((rpm - rpm_peakT_RS)/sigma_RS).^2);
Power_RS = Torque_RS .* omega / 1000;

%% Engine Republic 350 (max tuned concept)
Ppeak_ER = 52.0;        % kW (70 hp)
rpm_peakP_ER = 11000;
Tpeak_ER = 45.0;        % Nm
rpm_peakT_ER = 8500;

sigma_ER = 2200;
Torque_ER = Tpeak_ER * exp(-0.5*((rpm - rpm_peakT_ER)/sigma_ER).^2);
Power_ER = Torque_ER .* omega / 1000;

%% Plot Torque Curves
figure;
plot(rpm, Torque_R3, 'b-', 'LineWidth', 2); hold on;
plot(rpm, Torque_RS, 'r-', 'LineWidth', 2);
plot(rpm, Torque_ER, 'g-', 'LineWidth', 2);
xlabel('Engine Speed (RPM)');
ylabel('Torque (Nm)');
title('Torque Curves Comparison');
legend('Yamaha R3', 'Aprilia RS457', 'ER350 Concept');
grid on;

%% Plot Power Curves
figure;
plot(rpm, Power_R3, 'b-', 'LineWidth', 2); hold on;
plot(rpm, Power_RS, 'r-', 'LineWidth', 2);
plot(rpm, Power_ER, 'g-', 'LineWidth', 2);
xlabel('Engine Speed (RPM)');
ylabel('Power (kW)');
title('Power Curves Comparison');
legend('Yamaha R3', 'Aprilia RS457', 'ER350 Concept');
grid on;
