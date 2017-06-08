clc; clear all; close all;
load udp.mat;
udp_time_difference = VarName2 - VarName1;
udp_time_difference = 1000 * udp_time_difference;
time_axis = linspace(0,60,3994);
figure(1);
plot(time_axis, udp_time_difference);
title('queuing delay of UDP');
xlabel('time / sec');ylabel('delay / msec');
