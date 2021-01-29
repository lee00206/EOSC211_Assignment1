%%Loading Data
clear
load('Drifter_dataset.mat')

%%Data Validation
for i = 1:length(D)
    if D(i).firstLifeTime > 0           %grounded drifters
        for s = 1:length(D(i).lat)
            if D(i).mtime(s) >= D(i).launchDate && D(i).mtime(s) <= D(i).firstGrndDate  %time constrain
                if D(i).atSea(s) ~= 1       %delete data not at the sea
                    D(i).lat(s) = NaN;
                    D(i).lon(s) = NaN;
                    D(i).drifttime(s) = NaN;
                else
%                     D(i).drifttime(s) = D(i).mtime(s) - D(i).mtime(1);
                    D(i).drifttime(s) = D(i).mtime(s) - D(i).launchDate;      %setting up vectors of drift time for part 2
%For D(i).drifttime, we tried using the difference with launchDate, but later
%on we found that we should use the difference from the first time recorded
%by the drifter instead so that we get all the tracks to start at x = 0.
%(But we found that it does not make a great difference) 
                end
            else                            %delete data before launch date and after first ground date
                D(i).lat(s) = NaN;
                D(i).lon(s) = NaN;
                D(i).drifttime(s) = NaN;
            end
        end
    else                                %drifter dies at sea
        for s = 1:length(D(i).lat)
            if D(i).mtime(s) >= D(i).launchDate && D(i).mtime(s) <= D(i).endDate        %time constrain
                if D(i).atSea(s) ~= 1       %delete data not at the sea
                    D(i).lat(s) = NaN;
                    D(i).lon(s) = NaN;
                    D(i).drifttime(s) = NaN;
                else
%                     D(i).drifttime(s) = D(i).mtime(s) - D(i).mtime(1);
                    D(i).drifttime(s) = D(i).mtime(s) - D(i).launchDate;      %setting up vectors of drift time for part 2
                end
            else                            %delete data before launch date and after end date
                D(i).lat(s) = NaN;
                D(i).lon(s) = NaN;
                D(i).drifttime(s) = NaN;
            end
        end
    end
end

%%Finding startpoints and endpoints
for i = 1:length(D)
    for s = 1:length(D(i).lat)          %finding start latitude
        s = 1;
        while isnan(D(i).lat(s))
            s = s + 1;
        end
    end
    D(i).startlat = D(i).lat(s);        %defining start latitude
    
    for s = 1:length(D(i).lon)
        s = 1;
        while isnan(D(i).lon(s))        %finding start longitude
            s = s + 1;
        end
    end
    D(i).startlon = D(i).lon(s);        %defining start longitude
    
    
    for r = length(D(i).lat):-1:1       %finding end latitude
        e = length(D(i).lat);
        while isnan(D(i).lat(e))
            e = e - 1;
        end
    end
    D(i).endlat = D(i).lat(e);          %defining end latitude
    D(i).driftendtime = D(i).drifttime(e);
    
    for r = length(D(i).lon):-1:1       %finding end longitude
        e = length(D(i).lon);
        while isnan(D(i).lon(e))
            e = e - 1;
        end
    end
    D(i).endlon = D(i).lon(e);          %defining end longitude
end

%%Plotting the map
C = load('BCcstlne.mat');               %plotting base map with BCcstline.mat
hold on;
for k = 1:length(C.k)-1
    ii = C.k(k)+1:C.k(k+1)-1;
    patch(C.ncst(ii,1),C.ncst(ii,2),[1, 0.8840, 0.550], 'edgecolor', 'none');
end

Grounded = 0;                           %setting up initial counter values = 0
ExitSouth = 0;
ExitNorth = 0;

for i = 1:length(D)
    if D(i).endlon<-125.19 && D(i).endlat>50
        P1=plot(D(i).lon,D(i).lat,'g'); %green tracks: drifters that exit SoG to the North
        ExitNorth = ExitNorth + 1;      %counting drifters that exit SoG to the North
    elseif D(i).endlat<48.78
        P2=plot(D(i).lon,D(i).lat,'r'); %red tracks: drifters that exit SoG to the South
        ExitSouth = ExitSouth + 1;      %counting drifters that exit SoG to the South
    else                                %blue tracks: drifters that stay in SoG
        P3=plot(D(i).lon,D(i).lat,'Color',[0.2 0.6 1]);
    end
                                        %labelling starting points
    ST=plot(D(i).startlon,D(i).startlat,'bo','MarkerEdgeColor','y','MarkerFaceColor','b','MarkerSize',5);

    if D(i).firstLifeTime>0
        EG=plot(D(i).endlon,D(i).endlat, 'go','MarkerEdgeColor','r','MarkerFaceColor','g','MarkerSize',5);
        Grounded = Grounded + 1;        %counting grounded drifters
    else                                %drifters that end at sea
        ER=plot(D(i).endlon,D(i).endlat,'ro','MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',5);
    end
end
%printing out the text on the graph
text(-123.9,49.85,{[num2str(Grounded) ' tracks ground'],...
                [num2str(ExitSouth) ' tracks leave the SoG to the South'],...
                [num2str(ExitNorth) ' tracks leave the SoG to the North']},'FontSize',9);
    
%More Map-like
axis([-125.5 -122 48 50.5]);
xticks([-125.5:0.5:-122]);
xticklabels({['30'''], ['125' char(176) 'W'], ['30'''], ['124' char(176) 'W'], ['30'''], ['123' char(176) 'W'], ['30'''], ['122' char(176) 'W']});
yticks([48:0.5:50.5]);
yticklabels({['48' char(176) 'N'], ['30'''], ['49' char(176) 'N'], ['30'''], ['50' char(176) 'N'], ['30''']});
xlabel('Longitude');
ylabel('Latitude');
daspect([1.25 1 1]);                    %makes sure the map is in the right Data Aspect Ratio
lgd.NumColumns = 2;                     %formatting legend
legend([ST EG ER P1 P2 P3],{'Starting Point','Ends on Land','Ends at Sea','Exit North','Exit South','SoG'},'Location','northeast','NumColumns',2);

set(gca,'box','on');                    %formatting the edges
set(gca,'Layer','top');                 %makes sure the boundaries of the map is on top of the basemap
set(gca,'linewidth',2);
set(gca,'tickdir','out');

%%plotting statistics
figure(2);
hold on;
%plotting the histogram
subplot(2,1,1);

for u=1:length(D)
    A(u)=D(u).firstLifeTime;
end

A(A==0)=[];
L=0:2:30;
histogram(A,L);
xlabel('Days');
xlim([0 30]);
ylabel('Number');
ylim([0 40]);
title('Time to Grounding');

M=mean(A);
S=std(A);
str=sprintf('Time to grounding = %0.1f %c %0.1f days',M,char(177),S);

text(10,25,str);
hold on;
set(gca,'box','off');
set(gca,'tickdir','out');

s=0;
zlat=[];
zmad=[];
for ztime=0.5:0.5:15;
    s=s+1;
    z=1;
    for i=1:length(D)
        if D(i).firstLifeTime>=ztime
            dtime=abs(D(i).drifttime-ztime);
            [~,ix]=min(dtime);
            C(s).medlat(z)=D(i).lat(ix);
            z=z+1;
        end
    end
    zlat(s)=median(C(s).medlat);
    zmad(s)=mad(C(s).medlat,1);
end

medlat1=zlat+zmad;
medlat2=zlat-zmad;

ztime=0.5:0.5:15;

% Efforts we have put: we tried putting the median latitudes at different
% ztime values into a matrix and eliminated points where drifters are no
% longer afloat. However, using this method, we have got very different
% median lines. Then we changed to another method above.

% %plotting latitude against time
% 
% %finding the median
% ztime=[0.5:0.5:15];
% for t=1:length(ztime)
%     for i = 1:length(D)
%         zm = abs(D(i).drifttime - t);
%         if ztime(t) - max(D(i).drifttime) <= 0.25
%             [~,it] = min(zm);
%             Q(t,i) = D(i).lat(it);
%         else
%             Q(t,i) = NaN;
%         end
%     end
%     medlat(t) = nanmedian(Q(t,:));
%     MAD(t) = mad(Q(t),1);
% end
% 
% medlat1 = medlat + MAD;
% medlat2 = medlat - MAD;

% After switching to the new method, we still do not see the large change
% in the median lines at days approx. = 11 days. We do believe we are
% computing it the right way for the thick median line, as we have tried
% two methods already and we still get the same thick median line, but not
% the one shown on the pdf. We tried a lot of methods to plot the same
% figure as the pdf, but when we got the exact same figure, we found that
% the data was not validated enough (the drifttime was not considered
% separately for grounded and landed cases). Therefore, we believe that the
% working method we have above is more validated and should be correct.

%We also found that on the graph of the pdf, there are two points which the
%MAD lines converge onto the thick median line. In order for this to
%happen, the MAD at that time instant would be zero, which means nearly all
%of the data of the tracks are the same (which is clearly not the case!).
%Knowing that, we are still not sure why we still get one point where MAD
%=0, like the pdf (but not 2 points). Even if we changed the method of
%getting drifttime, it was still present.

subplot(2,1,2);
hold on;
for i = 1:length(D)
    if D(i).endlon<-125.19 && D(i).endlat>50
        plot(D(i).drifttime,D(i).lat,'g'); %green tracks: drifters that exit SoG to the North
    elseif D(i).endlat<48.78
        plot(D(i).drifttime,D(i).lat,'r'); %red   tracks: drifters that exit SoG to the South
    else                                   %blue  tracks: drifters that stay in SoG
        plot(D(i).drifttime,D(i).lat,'Color',[0.2 0.6 1]);
    end
  
    if D(i).firstLifeTime>0
        plot(D(i).driftendtime(end),D(i).endlat, 'go','MarkerEdgeColor','r','MarkerFaceColor','g','MarkerSize',5);
    else
        plot(D(i).driftendtime(end),D(i).endlat, 'ro','MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',5);
    end
end
plot([0 30],[50 50],'k--');
plot([0 30],[48.78 48.78],'k--');
plot(ztime,zlat,'w','LineWidth',4);
plot(ztime,zlat,'k','LineWidth',2);
plot(ztime,medlat1,'w','Linewidth',4);
plot(ztime,medlat1,'k','Linewidth',1);
plot(ztime,medlat2,'w','Linewidth',4);
plot(ztime,medlat2,'k','Linewidth',1);
xlabel('Days');
ylabel('Latitude');
ylim([48 50.5]);
set(gca,'tickdir','out');
hold on;

%%Answers to the last questions

%Question (a) NO. From figure 2, we do not see that the latitude of the
%drifters change a lot. Most drifters are staying at the same latitude, or
%even moving a bit northward (moving inland instead of towards the Pacific)

%Question (b) If we follow the drifter that travels all the way to the
%Pacific in figure 1, we can find out how long does it take. From the graph
%we plotted in figure 2, we see that that drifter took roughly 19 days to 
%travel all the way to Pacific.