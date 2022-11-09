function taskStruct = startSpaceMarketRun(taskStruct, ioStruct, currentRunTrials, breakITI, isFMRI)
    
    % initialize the start time to facilitate a break;
    lastBreak = GetSecs();

    % loop through all trials
    for tI = 1 : length(currentRunTrials)
        trialID = currentRunTrials(tI);
        disp(['Trial: ' num2str(tI) ' of ' num2str(length(currentRunTrials))]);
        
        % run the trial
        taskStruct.trials(trialID,:) = showTrial(ioStruct, taskStruct.trials(trialID,:));
        % save data and clean up
        save(fullfile(taskStruct.outputFolder, taskStruct.fileName), 'taskStruct', 'ioStruct');
        
        % should we pad the ITI with response time remainder
        if isFMRI && length(currentRunTrials) > tI
            adjustITI = (ioStruct.MAX_RT - taskStruct.trials.RT1(trialID));
            taskStruct.trials.jitterITI(currentRunTrials(tI+1)) = taskStruct.trials.jitterITI(currentRunTrials(tI+1)) + adjustITI;
        end
            
        % check to see if we need to offer a break
        if GetSecs() > (lastBreak + breakITI)
            lastBreak = showBreak(taskStruct, ioStruct);
        end
    end % for each trial
end

function tBreakEnd = showBreak(taskStruct, ioStruct)
    % offer a break
    numPoints = nansum(taskStruct.trials.outcomeMag);
    Screen(ioStruct.wPtr, 'Flip');
    % wait for the scanner to send the initial pulse signal
    Screen('TextSize', ioStruct.wPtr, 30); Screen('TextColor', ioStruct.wPtr, [255 255 255]); Screen('TextFont', ioStruct.wPtr, 'Helvetica');
    DrawFormattedText(ioStruct.wPtr, ['Time for a short break.\n\n You''ve earned a total of ' num2str(numPoints) ' so far.\n\n Press the spacebar when you''re ready to continue'], 'center', 'center');
    RestrictKeysForKbCheck( KbName('space') );
    Screen(ioStruct.wPtr, 'Flip');
    tBreakEnd = KbWait(-3, 2);
    RestrictKeysForKbCheck([]);
end