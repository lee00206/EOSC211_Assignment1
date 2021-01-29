%%Loading Data
clear
load('Drifter_dataset.mat')

%%Data Validation
for i = 1:length(D)
    if D(i).firstLifeTime > 0           %grounded drifters
        for j = 1:length(D(i).lat)
            if D(i).mtime(j) > D(i).launchDate && D(i).mtime(j) < D(i).firstGrndDate  %time constrain
                if D(i).atSea(j) ~= 1       %delete data not at the sea
                    D(i).lat(j) = NaN;
                    D(i).lon(j) = NaN;
                end
            else                            %delete data before launch date and after first ground date
                D(i).lat(j) = NaN;
                D(i).lon(j) = NaN;
            end
        end
    else                                %drifter dies at sea
        for j = 1:length(D(i).lat)
            if D(i).mtime(j) > D(i).launchDate && D(i).mtime(j) < D(i).endDate        %time constrain
                if D(i).atSea(j) ~= 1       %delete data not at the sea
                    D(i).lat(j) = NaN;
                    D(i).lon(j) = NaN;
                end
            else                            %delete data before launch date and after end date
                D(i).lat(j) = NaN;
                D(i).lon(j) = NaN;
            end
        end
    end
end

%%Finding startpoints and endpoints
for i = 1:length(D)
    
    for j = 1:length(D(i).lat)          %finding start latitude
        s = 1;
        while isnan(D(i).lat(s))
            s = s + 1;
        end
    end
    D(i).startlat = D(i).lat(s);        %defining start latitude
    
    for j = 1:length(D(i).lon)
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