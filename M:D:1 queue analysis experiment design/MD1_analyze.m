% this is a script for analyze the relation of average queue length vs
% utilization. The data are imported from experiment log. Specifies the 
% section: average queue length and realized rou
%
% LAB 3, EL-GY 7353 Network Modeling. NYU Tandon school of Engineering
%==========================================================================
clc; clear all; close all;

%%%%%%%%%%%%%
%    MD1    %
%%%%%%%%%%%%%
%% load data
% GENI testbed data
% queue length
load('MD1.mat');
T_queue_L = MD1(:,1);
T_queue_L = reshape(T_queue_L,6,5);
T_mean_queue_L = T_queue_L(6,:);
T_queue_L = T_queue_L(1:5,:);

% rou
T_rou = MD1(:,2);
T_rou = reshape(T_rou,6,5);
T_mean_rou = T_rou(6,:);
T_rou = T_rou(1:5,:);

T_queue_var = sqrt(var(T_queue_L));
T_rou_var = var(T_rou);

%==========================================================================
% ns2 simulation data
% queue length
load('MD1.mat');
S_queue_L = MD1(:,3);
S_queue_L = reshape(S_queue_L,6,5);
S_mean_queue_L = S_queue_L(6,:);
S_queue_L = S_queue_L(1:5,:);

% rou
S_rou = MD1(:,4);
S_rou = reshape(S_rou,6,5);
S_mean_rou = S_rou(6,:);
S_rou = S_rou(1:5,:);

S_queue_var = sqrt(var(S_queue_L));
S_rou_var = var(S_rou);

%% plot testbed experiment result
figure(1);
errorbar(T_mean_rou,T_mean_queue_L,T_queue_var,'bo','Markersize',5.0);hold on;
reference = linspace(0.49,0.92,100);
rou_plot = spline(T_mean_rou,T_mean_rou,reference);
queue_plot = spline(T_mean_rou,T_mean_queue_L,rou_plot);
plot(rou_plot,queue_plot,'b-'); grid on;hold on;
title('M/D/1 Average queue length vs ¦Ñ');
xlabel('¦Ñ');
ylabel('Average queue length');

%% plot analytical result
rou_analytical = reference;
queue_analytical = rou_analytical./(1-rou_analytical).*(1-rou_analytical/2) - rou_analytical;
plot(rou_analytical,queue_analytical,'r-');

%% plot testbed experiment result
errorbar(S_mean_rou,S_mean_queue_L,S_queue_var,'go','Markersize',5.0);hold on;
rou_plot = spline(S_mean_rou,S_mean_rou,reference);
queue_plot = spline(S_mean_rou,S_mean_queue_L,rou_plot);
plot(rou_plot,queue_plot,'g-'); hold on;

legend('Testbed mean','Testbed Experiment','Analytical result','Simulation mean','Simulation Experiment');

%%

%%%%%%%%%%%%%
%    MD1    %
%%%%%%%%%%%%%
%% load data
% GENI testbed data
% queue length
load('MM1.mat');
MT_queue_L = MM1(:,1);
MT_queue_L = reshape(MT_queue_L,6,5);
MT_mean_queue_L = MT_queue_L(6,:);
MT_queue_L = MT_queue_L(1:5,:);

% rou
MT_rou = MM1(:,2);
MT_rou = reshape(MT_rou,6,5);
MT_mean_rou = MT_rou(6,:);
MT_rou = MT_rou(1:5,:);

MT_queue_var = sqrt(var(MT_queue_L));
MT_rou_var = var(MT_rou);

%% plot
% GENI testbed
figure(2);
errorbar(T_mean_rou,T_mean_queue_L,T_queue_var,'bo','Markersize',5.0);hold on;
reference = linspace(0.49,0.92,100);
rou_plot = spline(T_mean_rou,T_mean_rou,reference);
queue_plot = spline(T_mean_rou,T_mean_queue_L,rou_plot);
plot(rou_plot,queue_plot,'b-'); grid on;hold on;
title('M/D/1 vs M/M/1 average queue length');
xlabel('¦Ñ');
ylabel('Average queue length');

errorbar(MT_mean_rou,MT_mean_queue_L,MT_queue_var,'ro','Markersize',5.0);hold on;
Mrou_plot = spline(MT_mean_rou,MT_mean_rou,reference);
Mqueue_plot = spline(MT_mean_rou,MT_mean_queue_L,Mrou_plot);
plot(Mrou_plot,Mqueue_plot,'r-'); grid on;hold on;

% Analytical result
rou_analytical = reference;
queue_analytical = rou_analytical./(1-rou_analytical).*(1-rou_analytical/2) - rou_analytical;
plot(rou_analytical,queue_analytical,'g-');hold on;

Mrou_analytical = reference;
Mqueue_analytical = Mrou_analytical./(1-Mrou_analytical) - Mrou_analytical;
plot(Mrou_analytical,Mqueue_analytical,'m-');
legend('M/D/1 GENI testbed mean','M/D/1 GENI testbed','M/M/1 GENI testbed mean',...
        'M/M/1 GENI testbed','M/D/1 analytical result','M/M/1 analytical result');
