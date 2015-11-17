  function TP = makeTragetPool
  Target_IMG_DIR = 'Sloan/';
    D_Target = dir([Target_IMG_DIR filesep '*.bmp']);
    
    for i=1:length(D_Target)
        % original image
        TP(i).im = imread([Target_IMG_DIR D_Target(i).name]);
        
        name = D_Target(i).name;
        TP(i).targLet = name(1);
        TP(i).fName = name;
    end