function rewMagnitude = defineRewardMagnitude(taskStruct, numTrials, condReward)
    % reward magnitude observed for each trial
    rewMagnitude = nan(numTrials, 1);
    
    % define high reward magnitude variance trials
    isCondTrial = condReward == taskStruct.REWARD_HIGH;
    rewMagnitude( isCondTrial ) = unifrnd(0.3, 1.0, sum(isCondTrial), 1);
    
    % define low reward magnitude and low variance trials
    isCondTrial = condReward == taskStruct.REWARD_LOW;
    rewMagnitude( isCondTrial ) = unifrnd(0.10, 0.19, sum(isCondTrial), 1);

end