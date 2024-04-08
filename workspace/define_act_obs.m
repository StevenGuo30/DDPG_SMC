import rl.util.*;
import rl.layer.*;
import rl.option.*;
import rl.agent.*;
import rl.representation.*;
import rl.representation.actor.*;


actionSize = [3 1];
actionInfo = rlNumericSpec(actionSize, 'LowerLimit', 0, 'UpperLimit', 10000); % 假设行动在[0,1]范围内
actionInfo.Name="parameters";
actionInfo.Description = "c_1,k,epsi";


inputSize = [2 1]; % 根据您的环境观察空间来调整
observationInfo = rlNumericSpec(inputSize,...
        LowerLimit=[-inf -inf]',...
        UpperLimit=[ inf  inf]');
observationInfo.Name = 'observations';
observationInfo.Description = "ts,x_sum";

% 定义actor以及actor-critic的网络
% 定义网络层
layers = [
    featureInputLayer(inputSize(1),'Normalization','none','Name','input')
    fullyConnectedLayer(256, 'Name', 'fc_1')
    reluLayer('Name', 'relu_1')
    fullyConnectedLayer(256, 'Name', 'fc_2')
    reluLayer('Name', 'relu_2')
    fullyConnectedLayer(actionSize(1), 'Name', 'fc_output') % 最后的全连接层
    reluLayer('Name', 'output_relu') % 添加一个ReLU层作为输出层
];
net = dlnetwork(layers);
actor = rlContinuousDeterministicActor(net,observationInfo,actionInfo);

agent_second_order = rlDDPGAgent(observationInfo,actionInfo);