    function [task_MBMF_train, ioStruct] = run_SpaceMarket_train(subID, orderID, wPtr)
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
    task_MBMF_train = initTask();
    task_MBMF_train.subID = subID;
    task_MBMF_train.orderID = orderID;
    task_MBMF_train.outputFolder = outputFolder;
    task_MBMF_train.fileName = ['subID_' subID '_ordID_' orderID '_MBMF_train_' datestr(now, 'mm-dd-yyyy_HH-MM-SS')];
    
    % initialize the IO for the task
    ioStruct = initIO(wPtr);
    
    %% show task instrutions
    run_instructions(ioStruct, fullfile('.', 'images', 'instructions'), @buildInstRespMap)
    
    %% Run practice trials
    
    % number of trials in each pre-scan practice block (each trial is approx 7 seconds)
    numRuns = 1;
    numBlocks = 3;
    trialBlocks = cell(numBlocks,1); 
    % A pair of short blocks to get familiar with the game strucutre
    trialBlocks{1} = buildTrials_blocked(task_MBMF_train, 1, 15, task_MBMF_train.STATE_LOW, task_MBMF_train.REWARD_HIGH);
    % randomize across high/low reward and state volatility with reward conditioned on outcome state
    trialBlocks{2} = buildTrials_blocked(task_MBMF_train, 2, 20, task_MBMF_train.STATE_LOW, task_MBMF_train.REWARD_HIGH);
    trialBlocks{3} = buildTrials_blocked(task_MBMF_train, 3, 20, task_MBMF_train.STATE_HIGH, task_MBMF_train.REWARD_LOW);
    % randomize the order, flatten, and pull all trials into a single run
    blockToRandomize = [2 3];
    trialBlocks(blockToRandomize) = trialBlocks( randsample(blockToRandomize, 2) );
    task_MBMF_train.trials = vertcat(trialBlocks{:});
    task_MBMF_train.trials.runID = ones(size(task_MBMF_train.trials,1), 1);
    
    % jitters between events (response (ship animation), state 2 (station), state 3 (planet), ITI)
    jitters = ones(5,2);
    
    % add in event tracking and event jitters for each run of trials
    trialEvents = [];
    for rI = 1 : numRuns
        trialEvents = [trialEvents; defineEventTracking(sum(task_MBMF_train.trials.runID == rI), jitters)];
    end
    task_MBMF_train.trials = [task_MBMF_train.trials, trialEvents];
        
    % run though all practice trials
    runTrials = 1:size(task_MBMF_train.trials, 1);
    task_MBMF_train.startTime = GetSecs();
    task_MBMF_train = startSpaceMarketRun(task_MBMF_train, ioStruct, runTrials, Inf, false);
    task_MBMF_train.endTime = GetSecs();
    save(fullfile(task_MBMF_train.outputFolder, task_MBMF_train.fileName));
    
    % wait for user to initiate
    Screen(ioStruct.wPtr, 'Flip');
    Screen('TextSize', ioStruct.wPtr, 30); Screen('TextColor', ioStruct.wPtr, [255 255 255]); Screen('TextFont', ioStruct.wPtr, 'Helvetica');
    DrawFormattedText(ioStruct.wPtr, 'We''re done with practice.\n\n Please let the experimenter know that you''re done.', 'center', 'center');
    RestrictKeysForKbCheck( ioStruct.respKey_Quit );
    Screen(ioStruct.wPtr, 'Flip');
    KbWait(-3, 2);
    
    ListenChar(1); ShowCursor(); Screen('Close');
    
    % only the window if we weren't passed a shared window
    if isempty(wPtr)
        Screen('CloseAll');
    end
end