% September, 2010 by MYK 
Target_IMG_DIR = 'Sloan/';
D_Target = dir([Target_IMG_DIR filesep '*.bmp']);

for i=1:length(D_Target)
    
    imT = imread([Target_IMG_DIR D_Target(i).name]);
    
    for r = 1:size(imT, 1)
        for c = 1:size(imT, 2)
        
            if imT(r,c) == 0
               
               imT(r,c) = 128;
            elseif imT(r,c) == 255
                
               imT(r,c) = 0;
               
            end
        
        end
        
    
    end

    imwrite(imT, [Target_IMG_DIR D_Target(i).name]);
    
end

%%
Target_IMG_DIR = 'Flanker E/';
D_Target = dir([Target_IMG_DIR filesep '*.jpg']);

for i=1:length(D_Target)
    
    imT = imread([Target_IMG_DIR D_Target(i).name]);
    bg = ones(size(imT,1), size(imT,2))*128;
    
    imMask = imT./255;
    
    newT = double(imMask).*bg;
   

    imwrite(uint8(newT), [Target_IMG_DIR D_Target(i).name]);
    
end



%%


Target_IMG_DIR = 'Sloan/';
D_Target = dir([Target_IMG_DIR filesep '*.jpg']);

for i=1:length(D_Target)
    
    imT = imread([Target_IMG_DIR D_Target(i).name]);
    
    for r = 1:size(imT, 1)
        for c = 1:size(imT, 2)
        
            if imT(r,c) ~= 0
               
               imT(r,c) = 128;
               
            end
        
        end
        
    
    end

    imwrite(imT, [Target_IMG_DIR D_Target(i).name]);
    
end






Target_IMG_DIR = 'Sloan/';
D_Target = dir([Target_IMG_DIR filesep '*.bmp']);

for i=1:length(D_Target)
    
    imT = imread([Target_IMG_DIR D_Target(i).name]);
    
    im_mask = ~imT;

    imwrite(im_mask, [Target_IMG_DIR D_Target(i).name]);
    
end

%%
Flanker_IMG_DIR = 'Flanker E/';
D_Flanker = dir([Flanker_IMG_DIR filesep '*.bmp']);

for i=1:length(D_Flanker)
  
    imF = imread([Flanker_IMG_DIR D_Flanker(i).name]);
    imF_mask = ~imF;
    
    imwrite(imF_mask, [Flanker_IMG_DIR  D_Flanker(i).name]);
    
end



