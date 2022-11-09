
function [task_MBMF_fMRI, ioStruct] = run_SpaceMarket_beh(subID, orderID, wPtr)
    % graft in task run information
    if nargin < 1, subID = input('Participant number :\n','s'); end
    if nargin < 2, orderID = input('Task ordering:\n','s'); end
    if nargin < 3, wPtr = []; end
    
    % path to where data will be saved
    outputFolder = fullfile('..', 'data');
    if exist(outputFolder, 'dir') == 0
        % folder does not exist - create it
        mkdir( outputFolder );
    end
    
    % initialize task variables
    task_MBMF_fMRI = initTask();
    task_MBMF_fMRI.subID = subID;
    task_MBMF_fMRI.orderID = orderID;
    task_MBMF_fMRI.outputFolder = outputFolder;
    task_MBMF_fMRI.fileName = ['subID_' subID '_sesID_' orderID '_MBMF_fMRI_' datestr(now, 'mm-dd-yyyy_HH-MM-SS')];
    
    % initialize the IO for the task
    ioStruct = initIO(wPtr);
    
                    %movie = Screen('CreateMovie', ioStruct.wPtr, 'mbmfEx.mov', ioStruct.wPtrRect(3), ioStruct.wPtrRect(4), 30, ':CodecSettings=Videoquality=0.8 Profile=2');

    
    %% run main task
    
    % define task trials
    numRuns = 2;
    % each run takes approximately 10 second
    numBlockTrials = 77*numRuns;
    % build a set of trials to cross all blocks
    trials = buildTrials_dynamic(task_MBMF_fMRI, numBlockTrials);
    % parcel trials into required number of runs
    trials.runID = repelem(1:numRuns, numBlockTrials/numRuns)';
    
    % jitters between events (response (ship animation), state 2 (station), state 3 (planet), ITI)
    jitters = ones(5,2);
    
    % add in event tracking and event jitters for each run of trials
    trialEvents = [];
    for rI = 1 : numRuns
        trialEvents = [trialEvents; defineEventTracking(sum(trials.runID == rI), jitters)];
    end
    task_MBMF_fMRI.trials = [trials, trialEvents];
    
    % pass through each run
    for rI = unique(task_MBMF_fMRI.trials.runID)'
        % initiate prep-wait
        Screen(ioStruct.wPtr, 'Flip');
        
        % extract the trials for this run
        runTrials = find(task_MBMF_fMRI.trials.runID == rI);
        % run the block of trials
        task_MBMF_fMRI = startSpaceMarketRun(task_MBMF_fMRI, ioStruct, runTrials, Inf, false);
        % store finish time and save the data
        task_MBMF_fMRI.tRunEnd(rI) = GetSecs();
        % save data to file
        save(fullfile(task_MBMF_fMRI.outputFolder, task_MBMF_fMRI.fileName));
    end
    
    % accumulate the total number of points earned
    totalPoints = round(nansum(task_MBMF_fMRI.trials.outcomeMag));
    % finish game
    Screen(ioStruct.wPtr, 'Flip');
    % show inter-block information
    Screen('TextSize', ioStruct.wPtr, 30); Screen('TextColor', ioStruct.wPtr, [255 255 255]); Screen('TextFont', ioStruct.wPtr, 'Helvetica');
    DrawFormattedText(ioStruct.wPtr, ['You''re done.\n\n You earned a total of ' num2str(totalPoints) ' points.\n\n Please remain still, and the experimenter will be with you shortly.'], 'center', 'center');
    Screen(ioStruct.wPtr, 'Flip');
    RestrictKeysForKbCheck( KbName('space'));
    KbWait([],2);

                        %Screen('FinalizeMovie', movie);
    
    RestrictKeysForKbCheck( [] );
    ListenChar(1); ShowCursor(); Screen('Close');
    % only the window if we weren't passed a shared window
    if isempty(wPtr)
        Screen('CloseAll');
    end
end