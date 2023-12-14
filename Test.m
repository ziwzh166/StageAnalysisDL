%% simulate some step looking signals with guassian noise plus the decreasing trend

% Step length
LenthData = 1e5;
% x axis
x = 1:LenthData;
% y axis
y = zeros(1,LenthData);
% random step index
Random_step_idx = randi(LenthData,1,LenthData/1e3);
% random index for adding spikes
Random_spike_idx = randi(LenthData,1,LenthData/1e4);
% initial step value
num = 10;
y(1:Random_step_idx(1)) = num;
i = 1;

while i <=LenthData
    y(i) = num + randn(1,1);
    % add random stage
    if ismember(i,Random_step_idx)
        num = num  - abs(randn(1,1));
        y(i) = num;
    end
    % add random spikes(not well simulated)
    if ismember(i,Random_spike_idx)
        % 5 numbers for simulating a spike
        for j = i:i+5-1
            y(j) = y(j-1) + 2*randn(1,1); 
        end
         i = i + 5;
    else
        i = i + 1;
    end
end

y_denoised = wdenoise(y,5);
% plot
figure;
plot(x,y,'DisplayName','Simulated');
hold on;
plot(x,y_denoised,'DisplayName','Denoised');
xlabel('x')
ylabel('y')
legend show




