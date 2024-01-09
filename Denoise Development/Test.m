
%% Simulate data
[x,y,Random_step_idx,Random_spike_idx] = simData(1e5);
y_denoised = Apply_NLF(y,40,20,10);
%% set a height thresold and length threshold for step
step_thresold = 0.4;
Step_length = 20;
stepIni = y_denoised(Random_step_idx-Step_length);
StepEnd = y_denoised(Random_step_idx+Step_length);
StepLen = x(Random_step_idx+Step_length) - x(Random_step_idx-Step_length);
step =abs(StepEnd - stepIni);
step_idx = find(step>step_thresold);
step_idx = step_idx(StepLen(step_idx)>Step_length);
Random_step_idx_filtered = Random_step_idx(step_idx);
%% 
%% Plot data and the index of step and spike
figure;
t = tiledlayout(2,1)
ax(1) = nexttile;
plot(x,y)
hold on;
plot(x(Random_step_idx_filtered),y(Random_step_idx_filtered),'*','DisplayName','step')
ax(2) = nexttile;
plot(x,y_denoised)
hold on;
plot(x(Random_step_idx_filtered),y_denoised(Random_step_idx_filtered),'*','DisplayName','step')
linkaxes(ax,'x')
xlabel(t,'x')
ylabel(t,'y')
legend show
%% Check prime of Denoise signal with diff
ydiff = diff(y_denoised);
figure;
tiledlayout(2,1)
ax(1) = nexttile;
% plot(x(1:end-1),diff(y))
hold on;
plot(x(1:end-1),ydiff,'*','DisplayName','step')
plot(x(Random_step_idx_filtered),ydiff(Random_step_idx_filtered),'*','DisplayName','step')
ax(2) = nexttile;
plot(x,y)
hold on;
plot(x,y_denoised)
plot(x(Random_step_idx_filtered),y_denoised(Random_step_idx_filtered),'|','MarkerSize',20,'DisplayName','step','LineWidth',5)
linkaxes(ax,'x')
%% Prepare the training set
%Length of the stride
StrideLen = 1;
%Number of clips
NumClip = 1 + floor((length(y) - Step_length) / StrideLen);
X = zeros(Step_length,NumClip);
y_Class = zeros(1,NumClip);
for i = 1:NumClip
    try
        X(:,i) = y_denoised(i*StrideLen:i*StrideLen+Step_length-1);
    catch
        X(:,i) = y_denoised(i*StrideLen:end);
    end
    if ismember(i*StrideLen,Random_step_idx_filtered-Step_length/2)
        y_Class(i) = 1;
    end
end
%% Train the model
% SVM model
SVMModel = fitcsvm(X',y_Class,'KernelFunction','rbf','Standardize',true,'ClassNames',[0,1]);
%% 
% LSTM model
layers = [ ...
    sequenceInputLayer(Step_length)
    lstmLayer(100,'OutputMode','sequence')
    fullyConnectedLayer(2)
    tanhLayer
    regressionLayer];
options = trainingOptions('adam', ...
    'MaxEpochs',100, ...
    'GradientThreshold',1, ...
    'InitialLearnRate',0.01, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',50, ...
    'LearnRateDropFactor',0.2, ...
    'Verbose',0, ...
    'Plots','training-progress');
y_0 = y_Class == 0;
y_train = [y_Class;y_0];
X_norm = normalize(X);
LSTMModel = trainNetwork(X_norm,y_train,layers,options);


%% Test the model
y_pred_SVM = predict(SVMModel,X');
y_pred_LSTM = predict(LSTMModel,X);
y_pred_LSTM(y_pred_LSTM < 0.5) = 0;
y_pred_LSTM(y_pred_LSTM >= 0.5) = 1;
%% plot the confusion matrix
figure;
y_SVM0 = y_pred_SVM == 0;
plotconfusion(y_train,[y_pred_SVM';y_SVM0'])
figure;
plotconfusion(y_train,y_pred_LSTM)
%% Plot on the graph
figure;
tiledlayout(2,1)
ax(1) = nexttile;
plot(x,y)
hold on;
plot(x(Random_step_idx_filtered),y(Random_step_idx_filtered),'*','DisplayName','step')
for i = 1:length(y_pred_SVM)
    if y_pred_SVM(i) == 1
        idx = i*StrideLen:i*StrideLen+Step_length-1;
        fprintf('step idx: %d\n',idx(1))
        plot(X,y(i*StrideLen:i*StrideLen+Step_length-1),'|')
    end
end
legend show
ax(2) = nexttile;
plot(x,y)
hold on;
plot(x(Random_step_idx_filtered),y_denoised(Random_step_idx_filtered),'*','DisplayName','step')
for i = 1:length(y_pred_LSTM)
    if y_pred_LSTM(i) == 1
        plot(x(i*StrideLen:i*StrideLen+Step_length-1),y_denoised(i*StrideLen:i*StrideLen+Step_length-1),'r')
    end
end
linkaxes(ax,'x')


%% function section
function [x,y,Random_step_idx,Random_spike_idx] = simData(LenthData)
% Simulate data
if nargin == 0
    % default length of data
    LenthData = 1e5;
end
% x axis
x = 1:LenthData;
% y axis
y = zeros(1,LenthData);
% random step idx
Random_step_idx = randi([1,LenthData],1,100);
% random spike idx
Random_spike_idx = randi([1,LenthData],1,100);
num = 10;

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
end



