function trials = buildTrials_blocked(taskStruct, blockID, numTrials, condState, condReward)

    % list all trials
    trials.trialID = (1:numTrials)';
    trials.blockID = zeros(numTrials, 1) + blockID;
    
    % define state and reward conditions
    trials.condState = zeros(numTrials, 1) + condState;
    trials.condReward = zeros(numTrials, 1) + condReward;
    
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
    
    % define ship starting position
    for tI = 1:numTrials
        trials.shipPos(tI,:) = randsample([1 2], 2);
    end
    
    % convert to table
    trials = struct2table(trials);
end