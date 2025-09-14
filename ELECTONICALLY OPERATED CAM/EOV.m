%% Electronically Driven Cam vs Conventional Cam Simulation
% This script compares the efficiency of electronically actuated valve timing 
% vs conventional fixed cam timing in a single-cylinder IC engine.

clc; clear; close all;

%% Engine and Valve Parameters
RPM = linspace(1000, 8000, 8); % Engine speeds (rpm)
conventional_valve_lift = [0 10 15 20 25 20 15 10]; % Fixed valve lift (mm) profile
electronic_valve_lift = conventional_valve_lift + [0 2 1 3 3 2 1 2]; % Adjusted for electronic actuation

conventional_opening = [10 15 20 25 25 20 15 10]; % Degrees of crank for opening
electronic_opening = conventional_opening + [2 1 3 3 3 2 1 2]; % Electronically adjusted

%% Simplified Volumetric Efficiency Model
% Volumetric efficiency increases when valve timing/lift matches engine speed
vol_eff_conventional = 0.7 + 0.1*(conventional_valve_lift/max(conventional_valve_lift)); 
vol_eff_electronic = 0.7 + 0.1*(electronic_valve_lift/max(electronic_valve_lift)); 

%% Torque Proxy Calculation (arbitrary units)
% Torque ~ Volumetric efficiency * valve lift
torque_conventional = vol_eff_conventional .* conventional_valve_lift;
torque_electronic = vol_eff_electronic .* electronic_valve_lift;

%% Plot 1: Valve Lift vs RPM
figure('Name','Valve Lift Comparison','NumberTitle','off');
plot(RPM, conventional_valve_lift,'-o','LineWidth',2,'MarkerSize',6); hold on;
plot(RPM, electronic_valve_lift,'-s','LineWidth',2,'MarkerSize',6);
xlabel('Engine RPM'); ylabel('Valve Lift (mm)');
title('Valve Lift Profile: Conventional vs Electronically Actuated Cam');
legend('Conventional Cam','Electronic Cam','Location','northwest');
grid on;

%% Plot 2: Volumetric Efficiency vs RPM
figure('Name','Volumetric Efficiency','NumberTitle','off');
plot(RPM, vol_eff_conventional,'-o','LineWidth',2,'MarkerSize',6); hold on;
plot(RPM, vol_eff_electronic,'-s','LineWidth',2,'MarkerSize',6);
xlabel('Engine RPM'); ylabel('Volumetric Efficiency');
title('Volumetric Efficiency Comparison');
legend('Conventional Cam','Electronic Cam','Location','northwest');
grid on;

%% Plot 3: Torque Proxy vs RPM
figure('Name','Torque Comparison','NumberTitle','off');
plot(RPM, torque_conventional,'-o','LineWidth',2,'MarkerSize',6); hold on;
plot(RPM, torque_electronic,'-s','LineWidth',2,'MarkerSize',6);
xlabel('Engine RPM'); ylabel('Torque Proxy (arbitrary units)');
title('Torque Proxy: Conventional vs Electronic Cam');
legend('Conventional Cam','Electronic Cam','Location','northwest');
grid on;

%% Optional: Save plots for GitHub
saveas(figure(1),'ValveLiftComparison.png');
saveas(figure(2),'VolumetricEfficiency.png');
saveas(figure(3),'TorqueComparison.png');
