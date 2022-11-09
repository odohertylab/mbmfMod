function [] = run_instructions(ioStruct, instructPath, responseMapFunction)
    % load task instruction images
    instrFiles = dir(fullfile(instructPath, '*.png'));
    ioStruct.instructions = nan(length(instrFiles),1);
    for iI = 1 : length(ioStruct.instructions)
        ioStruct.instructions(iI) = Screen('MakeTexture', ioStruct.wPtr, imread(fullfile(instrFiles(iI).folder, instrFiles(iI).name )));
    end
    
    % build the response map for each insturction slide
    [backKeys, nextKeys] = responseMapFunction(ioStruct, length(ioStruct.instructions));
    
    % initialize the instruction display
    instructionWidth = 960 * 1.5;
    instructionHeight = 540 * 1.5;
    leftX = ioStruct.centerX - round((instructionWidth/2));
    topY = ioStruct.centerY - round((instructionHeight/2));
    ioStruct.instructionRect = [leftX, topY, leftX+instructionWidth, topY+instructionHeight];
    
    % list of instructions to show
    instructions = 1:size(ioStruct.instructions);
    % init the current instruction
    currentInst = 1;

    % loop until done signal
    doneInst = false;
    while ~doneInst
        % show instructions
        Screen('DrawTexture', ioStruct.wPtr, ioStruct.instructions(currentInst), [], ioStruct.instructionRect );
        Screen(ioStruct.wPtr, 'Flip');
        
        % wait for navigation input
        RestrictKeysForKbCheck( [backKeys{currentInst}, nextKeys{currentInst} ] );
        [~, keyCode] = KbWait(-3, 2);

        % update the current instructin according to key press
        respKey = find(keyCode, 1, 'last');
        if ismember( respKey, nextKeys{currentInst} ) && currentInst == instructions(end)
            doneInst = true;
        elseif ismember( respKey, backKeys{currentInst} )
            % move back
            currentInst = max(1, currentInst-1);
        elseif ismember( respKey, nextKeys{currentInst} )
            % move forward
            currentInst = min(length(instructions), currentInst+1);
        end
    end
    
    RestrictKeysForKbCheck([]);
end