function trials = buildTrials_dynamic(taskStruct, numTrials)

    % list all trials
    trials.trialID = (1:numTrials)';
    
    
    % define dynamic condition 

    % min/max number of trials for a condition value
    minDuration_state = round(numTrials/6);
    maxDuration_state = round(numTrials/6);
    minDuration_reward = round(numTrials/6);
    maxDuration_reward = round(numTrials/6);
    % block types, and count indices for state transition condition
    transOrder = randsample([taskStruct.STATE_HIGH, taskStruct.STATE_LOW], 2);
    transDuration = randi([minDuration_state, maxDuration_state]);
    transCount = 0;
    trials.condState = nan(numTrials, 1);
    % for reward magnitude condition
    rewardOrder = randsample([taskStruct.REWARD_LOW, taskStruct.REWARD_HIGH], 2);
    rewardDuration = randi([minDuration_reward, maxDuration_reward]);
    rewardCount = 0;
    trials.condReward = nan(numTrials, 1);
    
    % loop through each trial
    for tI = 1 : numTrials
        transCount = transCount + 1;
        rewardCount = rewardCount + 1;

        % check to see if we should flip the state transition
        if transCount > transDuration
            % implement a condition switch
            transOrder = fliplr(transOrder);
            transDuration = randi([minDuration_state, maxDuration_state]);
            transCount = 0;
        end

        % check to see if we should flip the reward magnitude
        if rewardCount > rewardDuration
            % implement a condition switch
            rewardOrder = fliplr(rewardOrder);
            rewardDuration = randi([minDuration_reward, maxDuration_reward]);
            rewardCount = 0;
        end
        
        % store state transition, 
        trials.condState(tI) = transOrder(1);
        trials.condReward(tI) = rewardOrder(1);

        % generate random ship position (change range to [0 1] for js)
        trials.shipPos(tI,:) = randsample([1 2], 2);

    end % for each trial
    
    % offset the reward/state conditions
    trials.condReward = circshift(trials.condReward, round(maxDuration_state/2));
    
    
    % define aciton transitions
    trials.doRareTrans = defineActionTransition(numTrials, taskStruct.pTransRare);
    
    % define win/loss outcomes for each trial
    trials.rewPWin = defineRewardProbability(numTrials, taskStruct.numOutcomeStates, trials.doRareTrans);
    % convert mean reward probability into observations
    trials.rewBinary = (trials.rewPWin > rand(size(trials.rewPWin))) + 0;
    
    % define terminal state for each action according to transition probability and condition
    trials.state3 = defineOutcomeState(taskStruct, numTrials, taskStruct.numOptions_1, trials.doRareTrans, trials.condState);
    
    % define reward magnitude for each trial according to condition
    trials.rewMagnitude = defineRewardMagnitude(taskStruct, numTrials, trials.condReward);
    
    % convert to table
    trials = struct2table(trials);
end