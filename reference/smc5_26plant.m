function [sys,x0,str,ts,simStateCompliance] = smc5_26plant(t,x,u,flag)
%
% The following outlines the general structure of an S-function.
%
switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
    [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes;

  %%%%%%%%%%%%%%%
  % Derivatives %
  %%%%%%%%%%%%%%%
  case 1,
    sys=mdlDerivatives(t,x,u);
  %%%%%%%%%%%
  % Outputs %
  %%%%%%%%%%%
  case 3,
    sys=mdlOutputs(t,x,u);

  case {2,4,9}
    sys = [];


  %%%%%%%%%%%%%%%%%%%%
  % Unexpected flags %
  %%%%%%%%%%%%%%%%%%%%
  otherwise
    DAStudio.error('Simulink:blocks:unhandledFlag', num2str(flag));

end

% end sfuntmpl

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes

%
% call simsizes for a sizes structure, fill it in and convert it to a
% sizes array.
%
% Note that in this example, the values are hard coded.  This is not a
% recommended practice as the characteristics of the block are typically
% defined by the S-function parameters.
%
sizes = simsizes;

sizes.NumContStates  = 2;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 2;
sizes.NumInputs      = 3;%%1是控制量ut，2是p，3是状态观测器dp
sizes.DirFeedthrough = 0;
sizes.NumSampleTimes = 1;   % at least one sample time is needed

sys = simsizes(sizes);

%
% initialize the initial conditions
%
x0  = [0,0];

%
% str is always an empty matrix
%
str = [];

%
% initialize the array of sample times
%
ts  = [0 0];

% Specify the block simStateCompliance. The allowed values are:
%    'UnknownSimState', < The default setting; warn and assume DefaultSimState
%    'DefaultSimState', < Same sim state as a built-in block
%    'HasNoSimState',   < No sim state
%    'DisallowSimState' < Error out when saving or restoring the model sim state
simStateCompliance = 'UnknownSimState';

% end mdlInitializeSizes

%
%=============================================================================
% mdlDerivatives
% Return the derivatives for the continuous states.
%=============================================================================
%
function sys=mdlDerivatives(t,x,u)
 p = u(2) ;                   %%压力
% %  Cd = 0.61;                   %%流量系数
 w = 7.5e-3;                   %%面积梯度
 m = 0.1;                   %%阀芯质量
 Cd = 30;                   %%粘性阻尼系数，所以用这个系数来乘以
 A = -1.489e+08;
 B = 1.538e+05;
 Ki = 10;                   %%马达N/A

 Kf = p*2e-3;               %%  Kf = Cd*Cd*w*2*P*0.03584;
 gama = 5e6;
 ksp = 1e4;                %%弹簧弹性系数
 ut = u(1);                %%控制量Fsol
 dp= u(3);                 %%状态观测器测得的误差
 
 sys(1) = x(2);
 sys(2) =(1/m)*(ut-Cd*x(2)-ksp*x(1)-dp);  %65是弹簧预紧力，缺少摩擦力，还差了液动力

% end mdlDerivatives

%
%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================
%
function sys=mdlOutputs(t,x,u)

sys(1) = x(1);   %%位移
sys(2) = x(2);   %%速度

% end mdlOutputs

