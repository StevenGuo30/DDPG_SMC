actionInfo = rlNumericSpec([3,1]);%输出的action是三个参数c_1,k,epsi
actionInfo.Name="parameters";
actionInfo.Description = "c_1,k,epsi";

observationInfo = rlNumericSpec([2 1],...
    LowerLimit=[-inf -inf]',...
    UpperLimit=[ inf  inf]');
observationInfo.Name = "observations";
observationInfo.Description = "ts,x_sum";

% 定义actor以及actor-critic的网络
actor = rlContinuousDeterministicActor(net,observationInfo,actionInfo);

agent_second_order = rlDDPGAgent(observationInfo,actionInfo);