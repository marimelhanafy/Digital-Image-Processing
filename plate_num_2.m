function plate_num_2(extractedPlate)
extractedPlate(abs(extractedPlate) < 150) = 0;
f = fspecial('laplacian');
q = imfilter(extractedPlate, f);
% figure, imshow(q);
q = extractedPlate - q;
% figure, imshow(q);
f = fspecial('average', 2);
q = imfilter(q, f);
% figure, imshow(q);
q = edge(q, 'sobel');
% % figure, imshow(q);
w=imerode(q, strel('line',20,0));
% figure, imshow(w);
q = q-w;
% figure, imshow(q);
q = imfill(q, 'holes');
% figure, imshow(q);
q = logical(q);
% Measure properties of image regions
propied=regionprops(q,'BoundingBox');
qwer = struct2cell(propied);
[n m] = size(propied);
numberPlate = '';
for i=1:n
    if qwer{i}(4) > qwer{i}(3) & qwer{i}(4) >= 25 & qwer{i}(3) >= 5 & qwer{i}(3) < 25
        % rectangle('Position',propied(i).BoundingBox,'EdgeColor','g','LineWidth',2)
        a = qwer{i}(1);
        b = qwer{i}(2);
        c = qwer{i}(3);
        d = qwer{i}(4);
        if qwer{i}(3) < 10
            a = qwer{i}(1) - 10;
            c = qwer{i}(3) + 20;
        end
        e = imcrop(q, [a b c d]);
        result = identify_character(e);
        numberPlate = strcat(numberPlate, result);
    end
end
disp(['The plate number is ' num2str(numberPlate)]);
end