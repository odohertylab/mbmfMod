function ioStruct = initIO(wPtr)
    % hide input to prevent participant from over-writing into the script
    %HideCursor(); 
    ListenChar(2);
    Screen('Preference', 'SkipSyncTests', 1);
    KbName('UnifyKeyNames');
%     Screen('Preference', 'ConserveVRAM', 64); % for use on Linux system
    
    % set up the screen
    ioStruct = struct();
    ioStruct.bgColor = [0 0 0];
    ioStruct.textColor = [200 200 200];
    if isempty(wPtr)
        debugRect = [0,0,1000,800];
        fullRect = [];
        allScreens = Screen('Screens');
        [ioStruct.wPtr, ioStruct.wPtrRect] = Screen('OpenWindow', allScreens(end-1), ioStruct.bgColor, fullRect);
    else
        % use the already open window
        ioStruct.wPtr = wPtr;
        ioStruct.wPtrRect = Screen('Rect', ioStruct.wPtr);
    end
    
    ioStruct.centerX = round(ioStruct.wPtrRect(3)/2);
    ioStruct.centerY = round(ioStruct.wPtrRect(4)/2);
    
    if ioStruct.wPtrRect(3)*9/16 ~= ioStruct.wPtrRect(4)            %if screen is not wide screen
        tmp = ioStruct.wPtrRect;
        ioStruct.wPtrRect(2) = ceil(tmp(4)/2 - (tmp(3)*9/16)/2);    %make screen rect 16:9
        ioStruct.wPtrRect(4) = ceil(tmp(4)/2 + (tmp(3)*9/16)/2);
    end
    
    % activate for alpha blending
    Screen('BlendFunction', ioStruct.wPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    % Measure the vertical refresh rate of the monitor
    ioStruct.centerX = round(ioStruct.wPtrRect(3)/2);
    ioStruct.centerY = round(ioStruct.wPtrRect(4)/2);
    
    % show loading prompt
    Screen('TextFont', ioStruct.wPtr, 'Courier');
    % show the loading screen
    Screen('TextSize', ioStruct.wPtr, 45);
    Screen('TextColor', ioStruct.wPtr, ioStruct.textColor);
    DrawFormattedText(ioStruct.wPtr, 'Loading...', 'center', 'center', [], 70, false, false, 1.1);
    Screen(ioStruct.wPtr, 'Flip');
    
    % stimulus durations
    ioStruct.SLOW = -1;
    ioStruct.MAX_RT = 2;
    ioStruct.MAX_RT2 = 1.5;
    ioStruct.BREAK_ITI = 5*60;
    ioStruct.BREAK_DURATION = 15;
    ioStruct.CHOICE_FB_DURATION = 1;
    ioStruct.REW_BIN_DURATION = 0;
    ioStruct.REW_DURATION = 1.5;
    ioStruct.BLOCK_START_WAIT = 3;
    ioStruct.BLOCK_END_WAIT = 4;
    
    %device id 
    ioStruct.devID = -3;    %merged inputs from all usb devices
    
    % response keys
    ioStruct.LEFT = 1;
    ioStruct.RIGHT = 2;
    ioStruct.respKey_1 = [ KbName('F'),  KbName('1'), KbName('1!') ];
    ioStruct.respKey_2 = [ KbName('J'),  KbName('4'), KbName('4$') ];
    ioStruct.respKey_3 = [ KbName('space'),  KbName('3'), KbName('3#') ];
    
    % task control keys
    ioStruct.respKey_Quit = KbName('Q');
    ioStruct.respKeyName_Quit = 'Q';
    ioStruct.respKey_Proceed = KbName('P');
    ioStruct.respKeyName_Proceed = 'P';
    
    % pulse signal
    ioStruct.pulseKey = [ KbName('5') KbName('5%') ];
    
    
    %%%%%%%%%%%%%%%%%
    %
    % current state, centered
    width = 400; height = 400;
    rect = [0, 0, width, height];
    leftX = ioStruct.centerX - round(width/2);
    topY = ioStruct.centerY - round(height/2);
    ioStruct.rectState = rect + [leftX, topY, leftX, topY];
    
    % station below for planet presentation
    width = 200; height = 200;
    rect = [0, 0, width, height];
    leftX = ioStruct.centerX - round(width/2);
    topY = ioStruct.rectState(4) - 75;
    ioStruct.rectState2(ioStruct.RIGHT,:) = rect + [leftX, topY, leftX, topY]; 
    
    % 1st stage choice option rects (ships)
    width = 400; height = 400; gap = 30;
    rect = [0, 0, width, height];
    % define left ship
    leftX = ioStruct.centerX - gap - width;
    topY = ioStruct.centerY - round(height/2);
    ioStruct.rectShip(ioStruct.LEFT,:) = rect + [leftX, topY, leftX, topY];
    % define the right ship
    leftX = ioStruct.centerX + gap;
    topY = ioStruct.centerY - round(height/2);
    ioStruct.rectShip(ioStruct.RIGHT,:) = rect + [leftX, topY, leftX, topY];
    
    
    % reward outcome rect
%     width = round(175*0.7); height = round(240*0.7);
%     rect = [0, 0, width, height];
%     leftX = ioStruct.centerX - round(width/2);
%     topY = ioStruct.rectState(2) - round(240*0.7);
%     ioStruct.rectReward = rect + [leftX, topY, leftX, topY];
    width = 150; height = 150;
    rect = [0, 0, width, height];
    leftX = ioStruct.centerX - round(width/2);
    topY = ioStruct.centerY - round(height/2);
    ioStruct.rectReward = rect + [leftX, topY, leftX, topY];
    

    % load the terminal state stimuli (planets)
    for currI = 1:4
        imageDir = fullfile('.', 'images');
        [img, ~, alpha] = imread(fullfile(imageDir, ['planet' num2str(currI) '.png']));
        img(:,:,4) = alpha;
        ioStruct.imgState(currI) = Screen('MakeTexture', ioStruct.wPtr, img);
    end
    
    % the middle state (stations)
    for currI = 1:2
        [img, ~, alpha] = imread(fullfile(imageDir, ['station' num2str(currI) '.png']));
        img(:,:,4) = alpha;
        ioStruct.imgStation(currI) = Screen('MakeTexture', ioStruct.wPtr, img);
    end
    
    % spaceships
    [img, ~, alpha] = imread(fullfile(imageDir, 'blueShip.png'));
    img(:,:,4) = alpha;
    ioStruct.spaceShip(1) = Screen('MakeTexture', ioStruct.wPtr, img);
    [img, ~, alpha] = imread(fullfile(imageDir, 'yellowShip.png'));
    img(:,:,4) = alpha;
    ioStruct.spaceShip(2) = Screen('MakeTexture', ioStruct.wPtr, img);
    % ships prepped for takeoff
    [img, ~, alpha] = imread(fullfile(imageDir, 'blueShip_takeOff.png'));
    img(:,:,4) = alpha;
    ioStruct.spaceShipSelect(1) = Screen('MakeTexture', ioStruct.wPtr, img);
    [img, ~, alpha] = imread(fullfile(imageDir, 'yellowShip_takeOff.png'));
    img(:,:,4) = alpha;
    ioStruct.spaceShipSelect(2) = Screen('MakeTexture', ioStruct.wPtr, img);

end