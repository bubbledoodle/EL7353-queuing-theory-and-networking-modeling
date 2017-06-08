load tcp_BIF.mat;
%time_axis = VarName1 - 46.8336 .* ones(32101,1);
time_array = linspace(0,60,32101);
plot(time_array,VarName2/1000);
title('BIF on server link');
xlabel('time / sec');ylabel('rate /Mbps')