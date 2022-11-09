function state3 = defineOutcomeState(taskStruct, numTrials, numOptions_1, doRareTrans, condState)
    
    % the state transitioned into from each action
    state3 = nan(numTrials, numOptions_1);
    % probability of state transitions raliability across conditions
    pTrans([taskStruct.STATE_LOW taskStruct.STATE_HIGH]) = [0.9 0.5];
    % will hold common/rare landing pad (columns) for each asteroid(rows)
    commonRarePlanet = nan(2,2);
    % track the transition condition for the current block of trials
    currentBlockType = nan;
    
    % loop through all trials
    for tI = 1 : numTrials
        if condState(tI) ~= currentBlockType
            % in a new conditional block type, resample common/rare planets
            commonRarePlanet(1,:) = randsample([1 2], 2, false);
            commonRarePlanet(2,:) = randsample([3 4], 2, false);
            % update the state transition for the current block
            currentBlockType = condState(tI);
        end
        
        % pull transition volatility for the current block
        pCommon = pTrans(condState(tI));
        
        % sample outcome state for each action as weighted by transition probability to the common/rare planets
        state3(tI, 1) = randsample(commonRarePlanet(1,:), 1, true, [pCommon 1-pCommon]);
        state3(tI, 2) = randsample(commonRarePlanet(2,:), 1, true, [pCommon 1-pCommon]);
    end % for each trial
    
    % swap outcome states on rare transitions
    state3( doRareTrans == 1, [1 2] ) = state3( doRareTrans == 1, [2 1] );
end