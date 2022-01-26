% name of the input file
imname = 'cathedral.png';

% read in the image
fullim = imread(fullfile('sample_images',imname));

% convert to double matrix
% this conversion also scales intensities in each channel to [0,1] range
fullim = im2double(fullim);

% compute the height of each part (just 1/3 of total)
height = floor(size(fullim,1)/3);

% separate color channels
B = fullim(1:height,:);
G = fullim(height+1:height*2,:);
R = fullim(height*2+1:height*3,:);

% create a color image (3D array)
rgbNotAligned(:,:,1) = R;
rgbNotAligned(:,:,2) = G;
rgbNotAligned(:,:,3) = B;
figure;imshow(rgbNotAligned);
saveas(gcf,imname+"notAligned.png")

% TO BE DONE: Align the channels using SSD metric

newRed = alignChannels(B,R);
newGreen = alignChannels(B,G);

rgbAligned(:,:,1) = newRed;
rgbAligned(:,:,2) = newGreen;
rgbAligned(:,:,3) = B;
figure;imshow(rgbAligned);
saveas(gcf,imname+"Aligned.png")

% TO BE DONE: Apply gamma transform

% Gamma 0.3
gRed = myGammaTransform(newRed,0.3);
gGreen =  myGammaTransform(newGreen,0.3);
gBlue = myGammaTransform(B,0.3);

rgbAligned(:,:,1) = gRed;
rgbAligned(:,:,2) = gGreen;
rgbAligned(:,:,3) = gBlue;
figure;imshow(rgbAligned);
saveas(gcf,imname+"0.3gamma.png")

%Gamma with different values green 0.8 and blue&red = 1.2
gRed = myGammaTransform(newRed,1.2);
gGreen =  myGammaTransform(newGreen,0.8);
gBlue = myGammaTransform(B,1.2);

rgbAligned(:,:,1) = gRed;
rgbAligned(:,:,2) = gGreen;
rgbAligned(:,:,3) = gBlue;
figure;imshow(rgbAligned);
saveas(gcf,imname+"gamma0.8.png")

%Gamma with different values blue 0.7 where red & green = 1.2
gRed = myGammaTransform(newRed,1.2);
gGreen =  myGammaTransform(newGreen,1.2);
gBlue = myGammaTransform(B,0.7);

rgbAligned(:,:,1) = gRed;
rgbAligned(:,:,2) = gGreen;
rgbAligned(:,:,3) = gBlue;
figure;imshow(rgbAligned);
saveas(gcf,imname+"gamma0.7.png")

%Gamme with 1.2 in all the channels
gRed = myGammaTransform(newRed,1.2);
gGreen =  myGammaTransform(newGreen,1.2);
gBlue = myGammaTransform(B,1.2);

rgbAligned(:,:,1) = gRed;
rgbAligned(:,:,2) = gGreen;
rgbAligned(:,:,3) = gBlue;
figure;imshow(rgbAligned);
saveas(gcf,imname+"gammaNormal.png")
% TO BE DONE: Apply histogram equalization after converting Lab color space

lab = rgb2lab(rgbAligned);
L = lab(:,:,1)./100;
newL = histeq(L).*100;

newLab(:,:,1) = newL;
newLab(:,:,2) = lab(:,:,2);
newLab(:,:,3) = lab(:,:,3);

newImage = lab2rgb(newLab);

figure;imshow(newImage)
saveas(gcf,imname+"histeq.png")

% Align Function
function newChannel = alignChannels(blue,channel)
    [blue_row,blue_col] = size(blue);
    [channel_row,channel_col] = size(channel);

    cropped_blue = blue(ceil((blue_row)/2) : ceil((blue_row)/2) + 50,ceil((blue_col)/2) :ceil((blue_col)/2) + 50);
    cropped_channel = channel(ceil((channel_row)/2) : ceil((channel_row)/2) + 50,ceil((channel_col)/2) :ceil((channel_col)/2) + 50);
    
    min = 1000000000000000000000000000000000000;
    rot_pos = 0;
    rot_dim = 0;
    for i = -15:15
        for j = 1:2
            score = myssd(circshift(cropped_channel,i,j),cropped_blue);
            if score<min
                min = score;
                rot_pos = i;
                rot_dim = j;
            end
        end
    end
    newChannel = circshift(channel,[rot_pos,rot_dim]);
end