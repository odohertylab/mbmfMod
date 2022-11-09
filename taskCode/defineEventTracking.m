function tracking = defineEventTracking(numTrials, jitters)
    % to store task events as the unfold
    outcome1 = nan(numTrials, 1);
    outcome2 = nan(numTrials, 1);
    outcomeBin = nan(numTrials, 1);
    outcomeMag = nan(numTrials, 1);
    resp1 = nan(numTrials, 1);
    RT1 = nan(numTrials, 1);
    RT2 = nan(numTrials, 1);
    
    % to store event times
    tStart = nan(numTrials, 1);
    tState1On = nan(numTrials, 1);
    tResp1 = nan(numTrials, 1);
    tResp2 = nan(numTrials, 1);
    tState2On = nan(numTrials, 1);
    tState3On = nan(numTrials, 1);
    tFbOn = nan(numTrials, 1);
    
    % set up intertrial jitters
    %
    % time between 1st stage response and display of 2nd state
    jitterResp1 = linspace(jitters(1,1), jitters(1,2), numTrials)';
    jitterResp1 = jitterResp1(randperm(length(jitterResp1)));
    % time jitter between showing station and station moving
    jitterState2 = linspace(jitters(2,1), jitters(2,2), numTrials)';
    jitterState2 = jitterState2(randperm(length(jitterState2)));
    % time between station and display of planet
    jitterTrans = linspace(jitters(3,1), jitters(3,2), numTrials)';
    jitterTrans = jitterTrans(randperm(length(jitterTrans)));
    % time between second response and outcome feedback
    jitterFb = linspace(jitters(4,1), jitters(4,2), numTrials)';
    jitterFb = jitterFb(randperm(length(jitterFb)));
    % time between trials
    jitterITI = linspace(jitters(5,1), jitters(5,2), numTrials)';
    jitterITI = jitterITI(randperm(length(jitterITI)));
    
    tracking = table(outcome1, outcome2, outcomeBin, outcomeMag, resp1, RT1, RT2, ...
        tStart, tState1On, tResp1, tState2On, tResp2, tState3On, tFbOn,...
        jitterResp1, jitterState2, jitterTrans, jitterFb, jitterITI);
end