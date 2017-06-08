clc; clear all; close all;
load tcp_rwnd.mat;
time_axis = linspace(0,60,9132);
plot (time_axis, VarName3);
title('Rwnd');
xlabel('time /sec'); ylabel('window size KB');