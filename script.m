%%%%%%%%%%%%%%%%%%%
%% Shayan Fazeli %%
%% 91102171      %%
%%%%%%%%%%%%%%%%%%%

%preparing the script:
close all;
clear all;
clc;

%reading the picture, could be earth.jpg instead of tasbih:
img = (imread('tasbih.jpg'));
%reading the layers, performing noise removal filter on them:
img(:,:,1) = medfilt2(img(:,:,1));
img(:,:,2) = medfilt2(img(:,:,2));
img(:,:,3) = medfilt2(img(:,:,3));
%sharpening the picture, making the "gradient holes" a little deeper
%in where they need to be:
%img = imsharpen(img);
img = im2double(img);
%computing the gradients:
[gx1, gy1] = gradient(img(:,:,1));
[gx2, gy2] = gradient(img(:,:,2));
[gx3, gy3] = gradient(img(:,:,3));
%and the cost defined by the gradients
g1 = sqrt(gx1.*gx1 + gy1.*gy1);
g2 = sqrt(gx2.*gx2 + gy2.*gy2);
g3 = sqrt(gx3.*gx3 + gy3.*gy3);
%again some improvements will be done on the gradients...
mygradient = max(g1,g2);
mygradient = max(mygradient,g3);
mygradient = medfilt2(mygradient);
mygradient = mygradient*255;
mygradient = mygradient*10;
%finally, showing the picture, asking the user to insert his points:
imshow(img);
hold on;
[X Y] = getpts;
for l = 1:size(X,1)
    plot(X(l,1), Y(l,1), 'gx');
end
%now we have plotted user defined coordinates with green xs.

%the transitions, alpha, and number of iterations:
transitions = zeros(size(X,1),9);
alpha = 10;
num_of_iterations = 1000;

%initializing a wait bar:
prcnt = 0;
h=waitbar(prcnt, 'initializing...');
out = VideoWriter('hw5-q1-video.avi');
open(out);
for iteration = 0:num_of_iterations
    if mod(iteration,num_of_iterations/10)==1
        %in this "if", first we update our wait bur, which would fill
        %10 percent by 10 percent.
        prcnt = (iteration)/(num_of_iterations);
        waitbar(prcnt, h, sprintf('please wait... \n%d%%',floor(100*prcnt) ));
        %in order to save the video, we plot an invisible figure:
        fig=figure('Visible','off');
        %showing the picture in that:
        imshow(img);
        hold on;
        %plotting the points:
        for l = 1:size(X,1)
            plot(X(l,1), Y(l,1), 'rx');
        end
        %using spline interpolation to draw the contour:
        t = 1:size(X,1);
        ts = 1: 0.1: size(X,1);
        xys = spline(t,cat(1,X',Y'),ts);
        xs = xys(1,:);
        ys = xys(2,:);
        xs=xs';
        ys=ys';
        plot([xs; xs(1)], [ys; ys(1)], 'r--');
        %getting the frame from the figure:
        frame = getframe(fig);
        %writing that on the video:
        for kk = 1:60
            writeVideo(out, (frame));
        end
        %closing the figure:
        close(fig);
    end
    %defining minimum values:
    min_vals = zeros(1,9);
    %X and Y:
    X = cat(1,X(2:size(X),1),X(1));
    Y = cat(1,Y(2:size(Y),1),Y(1));
    %for the other points, performing the dynamic programming:
    for i = 2:size(Y,1)
        %first, we define a temporary minimum:
        min_temp = zeros(1,9);
        %obtaining previous coordinates:
        xold = X(i-1,1);
        yold = Y(i-1,1);
        xnew = X(i,1);
        ynew = Y(i,1);
        %minimum energy to the points before will be initialized:
        min_energy_to_past_points = zeros(1,9);
        for j = 1:9
            %computing the new coordinates:
            [x2, y2] = newpoint(xnew, ynew, j);
            tmp = zeros(1,9);
            %bring in the energy:
            for k = 1:9
                [x1, y1] = newpoint(xold,yold,k);
                energy = -1*mygradient(uint16(y1),uint16(x1))^2;
                energy = energy + alpha*(((x2-x1)^2) + ((y2-y1)^2));
                energy = energy + min_vals(1,k);
                tmp(1,k) = energy;
            end
            [a, b] = min(tmp);
            %now that we know the minimum, time to set:
            min_energy_to_past_points(1,j)=a;
            transitions(i,j)=b;
        end
        %updating the minimum values:
        min_vals = min_energy_to_past_points;
        if i == size(Y,1)
            %finding the minimum:
            [useless, pos] = min(min_vals);
            %going backwards:
            [a, b] = newpoint(X(i,1), Y(i,1), pos);
            X(i,1) = a;
            Y(i,1) = b;
            %going back and updating:
            for k = (i-1):-1:1
                pos = transitions(k+1, pos);
                [a, b] = newpoint(X(k,1), Y(k,1), pos);
                X(k,1) = a;
                Y(k,1) = b;
            end
        end
    end
end
%it's all done:
waitbar(1, h, sprintf('Active contour is done. \n%d%%',floor(100) ));
close(h);
%now plotting the final points:
for l = 1:size(X,1)
    plot(X(l,1), Y(l,1), 'rx');
end

%one more time cubic spline interpolation:
t = 1:size(X,1);
ts = 1: 0.1: size(X,1);
xys = spline(t,cat(1,X',Y'),ts);
xs = xys(1,:);
ys = xys(2,:);
xs=xs';
ys=ys';
close(out);
%plotting the approximation contour:
plot([xs; xs(1)], [ys; ys(1)], 'r--');
%The end