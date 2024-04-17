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
actionlayers = [
    featureInputLayer(inputSize(1),'Normalization','none','Name','input')
    fullyConnectedLayer(256, 'Name', 'fc_1')
    reluLayer('Name', 'relu_1')
    fullyConnectedLayer(256, 'Name', 'fc_2')
    reluLayer('Name', 'relu_2')
    fullyConnectedLayer(actionSize(1), 'Name', 'fc_output') % 最后的全连接层
    % reluLayer('Name', 'output_relu') % 添加一个ReLU层作为输出层
];
net_actor = dlnetwork(actionlayers);
actor = rlContinuousDeterministicActor(net_actor,observationInfo,actionInfo);

% 定义critic网络层，注意我们使用的是actionSize和inputSize来定义相应的输入层大小
criticStatePathLayers = [
    featureInputLayer(inputSize(1),'Normalization','none','Name','state')
    fullyConnectedLayer(256, 'Name', 'fc_state')
    reluLayer('Name', 'relu_state')
];

criticActionPathLayers = [
    featureInputLayer(actionSize(1),'Normalization','none','Name','action')
    fullyConnectedLayer(256, 'Name', 'fc_action')
    reluLayer('Name','relu_action')
];

criticCommonPathLayers = [
    additionLayer(2,'Name','add')
    reluLayer('Name','relu_add')
    fullyConnectedLayer(256, 'Name', 'fc_common')
    reluLayer('Name', 'relu_common')
    fullyConnectedLayer(1, 'Name', 'fc_output') % 输出是Q值，所以没有激活层
];

% 构建层图
criticNetwork = layerGraph();
criticNetwork = addLayers(criticNetwork, criticStatePathLayers);
criticNetwork = addLayers(criticNetwork, criticActionPathLayers);
criticNetwork = addLayers(criticNetwork, criticCommonPathLayers);

% 连接层
criticNetwork = connectLayers(criticNetwork,'relu_state','add/in1');
criticNetwork = connectLayers(criticNetwork,'relu_action','add/in2');

% 转换为dlnetwork
net_critic = dlnetwork(criticNetwork);

% 创建critic表示
critic = rlQValueFunction(net_critic,observationInfo,actionInfo);

%定义学习率
optOpts = rlOptimizerOptions(LearnRate=1e-01);

% 使用actor和critic创建agent
agentOptions = rlDDPGAgentOptions(...
    SampleTime=0.5,...
    ActorOptimizerOptions=optOpts,...
    CriticOptimizerOptions=optOpts,...
    TargetSmoothFactor=1e-3,...
    DiscountFactor=0.99,...
    MiniBatchSize=64,...
    ExperienceBufferLength=1e6); 

agent_second_order_change_obs = rlDDPGAgent(actor,critic,agentOptions);