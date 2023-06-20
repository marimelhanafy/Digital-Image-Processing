function plate_num_1(img)
%img is the already segmented license plate
wait=1;
[h,w,f]=size(img);
imshow(img);
pause(wait);
[h,w,f]=size(img);
if f == 3
    img = rgb2gray(img);
end
imshow(img);
pause(wait);
%We also convert this image to a binary image
img=~(img<100);
imshow(img);
pause(wait);
% using this function, all black parts in the image that are connected
% according to 8 connectivity and that are smaller than a number of
% pixels (depending on the dimensions) are removed.
img=~bwareaopen(~img, round((h*w)*0.02));
imshow(img);
pause(wait);
%here all connected are labeled
[L Ne]=bwlabel(not(img));
gem=zeros(1);
for n=1:Ne
    %here we are looking for the number of pixels per connected region,
    % so that we can then use the average of this as a threshold
    [r,c] = find(L==n);
    n1=img(min(r):max(r),min(c):max(c));
    gem(n)=bwarea(n1);
end
gem=mean(gem);
tresh=2;
width=0;
height=0;
verhoudingtresh=1.1;
perc=0;
letters={'a','b','c','d','e','f','g','h','i','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9'};
str='';
%now we're going to go through each connected region and see if they meet the specifications of a letter
for n=1:Ne
    [r,c] = find(L==n);
    n1=img(min(r):max(r),min(c):max(c));
    height=max(r)-min(r)+1;
    width=max(c)-min(c)+1;
    perc=bwarea(n1)/(height*width);
    %if the region meets the following specifications it will be treated as a letter otherwise it will be removed
    %1. the area of the region is greater than half the average area of the regions and less than twice.
    %2. if the height is greater than the (width+10%of the width)
    %3. If the region contains more than 30% of the total area of the labeled segmentation
    if(~(bwarea(n1)<gem(1)/tresh || bwarea(n1)>gem(1)*tresh)) && height>(width*verhoudingtresh) && perc>0.3
        imshow(n1);
        perc2=0;
        bestmatch=1;
        %once the region meets the above specifications, we match the region against images of letters in the database
        for(t=1:35)
            imfile=strcat('images/ocr/',char(letters(t)),'.jpg');
            LL=imread(imfile);
            %we make the database image the same size as the region
            LL=imresize(LL,[height width]);
            LL = rgb2gray(LL);
            level = graythresh(LL);
            %we are converting the database image to a binary image
            LL = im2bw(LL,level);
            %we compare the database image with the region using a logical AND
            LL=n1 & LL;

            percv=bwarea(LL)/(height*width);
            %the region that has the most percentage of black pixels equal to the database image will be considered
            %as the letter we are looking for. We add that letter to the string that should represent the number plate
            if(percv>perc2)
                perc2=percv;
                bestmatch=t;
            end
        end
        str=strcat(char(str),char(letters(bestmatch)));
    else
        img(min(r):max(r),min(c):max(c))=1;
    end
    pause(wait);
end
o_str=str;
imshow(img);
end