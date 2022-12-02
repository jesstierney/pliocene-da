%% plots the plioDA output
% written by m. osman (mattosman@arizona.edu), Nov 2022

%% to run, specify the following three parameters:

saveFigs = true; % option to save output figure as .jpg's; specify true or false
season = 'annual'; % specify 'DJF' or 'JJA', 'annual'
file = 'all-models_R-osman.nc'; % specify the netCDF file to plot

%% load data

clearvars -except saveFigs season file

% check if netCDF file exists
cd ../
    if ~isfile(file)
        error(['Could not locate ',file,' in ',cd,'.']);
    end
cd plotting/

% make sure save figures is a logical index
if ~islogical(saveFigs)
    error(['Input for ''saveFigs'' is not a logical index (specify either true or false).']);
end

% make a new figures folder
if ~isfolder('figures')
	mkdir('figures');
end
    
% make a new figures/file folder
folderName = erase(file,'.nc'); 
cd figures/
    if ~(exist(folderName,'dir') == 7)
        mkdir(folderName);
    end
cd ../

% do a check on the input 'season' value
seasonOpts = ["annual"; "DJF"; "JJA"]; 
if sum(strcmp(seasonOpts,season)) == 0
	error(['Input ''season'' value is incorrect: please input either ''annual'', ''DJF'' or ''JJA'' (case-sensitive).']);
end

% upload data:
cd ../
    lon = ncread(file,'lon'); 
    lat = ncread(file,'lat'); 
    pr.annual = ncread(file,'pr_annual'); 
    pr.DJF = ncread(file,'pr_DJF'); 
    pr.JJA = ncread(file,'pr_JJA'); 
    tas.annual = ncread(file,'tas_annual') - 273.15; 
    tas.DJF = ncread(file,'tas_DJF') - 273.15; 
    tas.JJA = ncread(file,'tas_JJA') - 273.15; 
    tos.annual = ncread(file,'tos_annual'); 
    tos.DJF = ncread(file,'tos_DJF'); 
    tos.JJA = ncread(file,'tos_JJA'); 
    siconc.annual = ncread(file,'siconc_annual'); siconc.annual(siconc.annual<0.1) = NaN; 
    siconc.DJF = ncread(file,'siconc_DJF'); siconc.DJF(siconc.DJF<0.1) = NaN; 
    siconc.JJA = ncread(file,'siconc_JJA'); siconc.JJA(siconc.JJA<0.1) = NaN; 
cd plotting/

load coastlines;

%% assign colormap

cd 'cbrewer' 
    cmap1 = cbrewer('div','RdBu' ,101); cmap1(cmap1>1) = 1; cmap1(cmap1<0) = 0; 
    cmap2 = cbrewer('div','BrBG' ,25); cmap2(cmap2>1) = 1; cmap2(cmap2<0) = 0; cmap2 = flipud(cmap2);  
    cmap3 = cbrewer('seq','Blues' ,25); cmap3(cmap3>1) = 1; cmap3(cmap3<0) = 0; cmap3 = flipud(cmap3);  
cd ../

%% Plot SST's...

% PI

% set some figure params
h = figure; hold on;
set(h,'units','centimeters','position',[1.8,0.90,22,15]);
    set(h,'PaperPositionMode','auto','PaperOrientation','landscape');
    ax = gca; ax.Visible = 'off';

ax1 = axes('Position',[0.15 0.20 0.70 0.70],'LineWidth',1.0); 
    set(gca,'Visible','off'); 
    ax = axesm ('Robinson','Frame', 'on', 'Grid', 'off'); % set projection here, based on available options: https://www.mathworks.com/help/map/summary-and-guide-to-projections.html
        set(gca,'Visible','off'); 
        gridm('PLineLocation',45,'MLineLocation',60,'MLabelLocation',60); 
        ax.Clipping = 'off'; set(ax,'Fontsize',10)
        setm(gca,'FLineWidth',1.0) % https://www.mathworks.com/help/map/map-axes-properties.html
    % pcolorm(lat,lon,posterior_SST); shading flat; % <-- can change to prior_SST, or posterior_SST - prior_SST...
    CF = [tos.(sprintf('%s', season))(:,:,1);tos.(sprintf('%s', season))(end,:,1)]'; 
    lonAdj = [lon;lon(end,:)+1]; 
%     CF = tos.(sprintf('%s', season))(:,:,1)'; 
%     lonAdj = lon; 
    pcolorm(lat,lonAdj,CF); shading flat; % <-- gerryrigged version to remove annoying white strip
    % contourfm(lat,lonAdj,CF,-10:2:10,'Color',0.8.*[1 1 1]); % V2
    setm(gca,'Origin',[0 180 0]); % to center over the atlantic use [0 180 0], to center over pacific use [0 180 0] 

    % OPTION 1 FOR CONTINENTS: use matlab's modern shapefile
        land = shaperead('landareas.shp','UseGeoCoords',true);
        geoshow(land,'FaceColor', 0.4.*[1 1 1],'Linewidth',1.0,'EdgeColor',0.3.*[1 1 1]); % just setting the color of the continents, etc
    
    % OPTION 2 FOR CONTINENTS: use coastlines only
    p1 = plotm(coastlat,coastlon,'k','linewidth',1);
	    
    colormap(ax,flipud(cmap1)); % flipped the colormap vertically, so cold = blue, hot = red ... 
    cLim = [-2 30]; % set colormap lims here
	clim(cLim);  % set colormap   
    c=colorbar('southoutside'); c.LineWidth = 1.0; 
    c.Label.String = ['SST (^{\circ}C)']; set(c,'Fontsize',10); 
    c.Position = [0.40 0.275 0.20 0.025]; % positioning of colorbars in Matlab's mapping toolbox is frustrating, so I usually just set it manually:

    % title
    axt = axes('position', [0.50 0.81 0.01 0.01],'visible', 'off'); hold on; box off;
	t1 = text(axt,0,0,'PI','Fontsize',12,'Fontweight','Normal','HorizontalAlignment','center');        

    % save fig
    if saveFigs
    cd(['figures/',folderName,'/']); 
        set(gcf,'PaperOrientation','LandScape','Renderer','painters'); 
        set(gcf,'color','w');
        exportgraphics(gcf,['SST_PI_',season,'.jpg'],'Resolution',500); % print('PI_SST','-dpdf');
    cd ../../
    end
    
% midPlio

% set some figure params
h = figure; hold on;
set(h,'units','centimeters','position',[1.8,0.90,22,15]);
    set(h,'PaperPositionMode','auto','PaperOrientation','landscape');
    ax = gca; ax.Visible = 'off';

ax1 = axes('Position',[0.15 0.20 0.70 0.70],'LineWidth',1.0); 
    set(gca,'Visible','off'); 
    ax = axesm ('Robinson','Frame', 'on', 'Grid', 'off'); % set projection here, based on available options: https://www.mathworks.com/help/map/summary-and-guide-to-projections.html
        set(gca,'Visible','off'); 
        gridm('PLineLocation',45,'MLineLocation',60,'MLabelLocation',60); 
        ax.Clipping = 'off'; set(ax,'Fontsize',10)
        setm(gca,'FLineWidth',1.0) % https://www.mathworks.com/help/map/map-axes-properties.html
    % pcolorm(lat,lon,posterior_SST); shading flat; % <-- can change to prior_SST, or posterior_SST - prior_SST...
    CF = [tos.(sprintf('%s', season))(:,:,2);tos.(sprintf('%s', season))(end,:,2)]'; 
    lonAdj = [lon;lon(end,:)+1]; 
%     CF = tos.(sprintf('%s', season))(:,:,2)'; 
%     lonAdj = lon; 
    pcolorm(lat,lonAdj,CF); shading flat; % <-- gerryrigged version to remove annoying white strip
    % contourfm(lat,lonAdj,CF,-10:2:10,'Color',0.8.*[1 1 1]); % V2
    setm(gca,'Origin',[0 180 0]); % to center over the atlantic use [0 180 0], to center over pacific use [0 180 0] 

    % OPTION 1 FOR CONTINENTS: use matlab's modern shapefile
        land = shaperead('landareas.shp','UseGeoCoords',true);
        geoshow(land,'FaceColor', 0.4.*[1 1 1],'Linewidth',1.0,'EdgeColor',0.3.*[1 1 1]); % just setting the color of the continents, etc
    
    % OPTION 2 FOR CONTINENTS: use coastlines only
    p1 = plotm(coastlat,coastlon,'k','linewidth',1);
	    
    colormap(ax,flipud(cmap1)); % flipped the colormap vertically, so cold = blue, hot = red ... 
    cLim = [-2 30]; % set colormap lims here
	clim(cLim);  % set colormap   
    c=colorbar('southoutside'); c.LineWidth = 1.0; 
    c.Label.String = ['SST (^{\circ}C)']; set(c,'Fontsize',10); 
    c.Position = [0.40 0.275 0.20 0.025]; % positioning of colorbars in Matlab's mapping toolbox is frustrating, so I usually just set it manually:

    % title
    axt = axes('position', [0.50 0.81 0.01 0.01],'visible', 'off'); hold on; box off;
	t1 = text(axt,0,0,'midPlio','Fontsize',12,'Fontweight','Normal','HorizontalAlignment','center');        

    % save fig
    if saveFigs
    cd(['figures/',folderName,'/']); 
        set(gcf,'PaperOrientation','LandScape','Renderer','painters'); 
        set(gcf,'color','w');
        exportgraphics(gcf,['SST_midPlio_',season,'.jpg'],'Resolution',500); % print('SST_midPlio','-dpdf');
    cd ../../
    end
    
% earlyPlio

% set some figure params
h = figure; hold on;
set(h,'units','centimeters','position',[1.8,0.90,22,15]);
    set(h,'PaperPositionMode','auto','PaperOrientation','landscape');
    ax = gca; ax.Visible = 'off';

ax1 = axes('Position',[0.15 0.20 0.70 0.70],'LineWidth',1.0); 
    set(gca,'Visible','off'); 
    ax = axesm ('Robinson','Frame', 'on', 'Grid', 'off'); % set projection here, based on available options: https://www.mathworks.com/help/map/summary-and-guide-to-projections.html
        set(gca,'Visible','off'); 
        gridm('PLineLocation',45,'MLineLocation',60,'MLabelLocation',60); 
        ax.Clipping = 'off'; set(ax,'Fontsize',10)
        setm(gca,'FLineWidth',1.0) % https://www.mathworks.com/help/map/map-axes-properties.html
    % pcolorm(lat,lon,posterior_SST); shading flat; % <-- can change to prior_SST, or posterior_SST - prior_SST...
    CF = [tos.(sprintf('%s', season))(:,:,3);tos.(sprintf('%s', season))(end,:,3)]'; 
    lonAdj = [lon;lon(end,:)+1]; 
%     CF = tos.(sprintf('%s', season))(:,:,3)'; 
%     lonAdj = lon; 
    pcolorm(lat,lonAdj,CF); shading flat; % <-- gerryrigged version to remove annoying white strip
    % contourfm(lat,lonAdj,CF,-10:2:10,'Color',0.8.*[1 1 1]); % V2
    setm(gca,'Origin',[0 180 0]); % to center over the atlantic use [0 180 0], to center over pacific use [0 180 0] 

    % OPTION 1 FOR CONTINENTS: use matlab's modern shapefile
        land = shaperead('landareas.shp','UseGeoCoords',true);
        geoshow(land,'FaceColor', 0.4.*[1 1 1],'Linewidth',1.0,'EdgeColor',0.3.*[1 1 1]); % just setting the color of the continents, etc
    
    % OPTION 2 FOR CONTINENTS: use coastlines only
    p1 = plotm(coastlat,coastlon,'k','linewidth',1);
	    
    colormap(ax,flipud(cmap1)); % flipped the colormap vertically, so cold = blue, hot = red ... 
    cLim = [-2 30]; % set colormap lims here
	clim(cLim);  % set colormap   
    c=colorbar('southoutside'); c.LineWidth = 1.0; 
    c.Label.String = ['SST (^{\circ}C)']; set(c,'Fontsize',10); 
    c.Position = [0.40 0.275 0.20 0.025]; % positioning of colorbars in Matlab's mapping toolbox is frustrating, so I usually just set it manually:

    % title
    axt = axes('position', [0.50 0.81 0.01 0.01],'visible', 'off'); hold on; box off;
	t1 = text(axt,0,0,'earlyPlio','Fontsize',12,'Fontweight','Normal','HorizontalAlignment','center');        

    % save fig
    if saveFigs
    cd(['figures/',folderName,'/']); 
        set(gcf,'PaperOrientation','LandScape','Renderer','painters'); 
        set(gcf,'color','w');
        exportgraphics(gcf,['SST_earlyPlio_',season,'.jpg'],'Resolution',500); % print('SST_earlyPlio','-dpdf');
    cd ../../
    end
    
% midPlio - PI

% set some figure params
h = figure; hold on;
set(h,'units','centimeters','position',[1.8,0.90,22,15]);
    set(h,'PaperPositionMode','auto','PaperOrientation','landscape');
    ax = gca; ax.Visible = 'off';

ax1 = axes('Position',[0.15 0.20 0.70 0.70],'LineWidth',1.0); 
    set(gca,'Visible','off'); 
    ax = axesm ('Robinson','Frame', 'on', 'Grid', 'off'); % set projection here, based on available options: https://www.mathworks.com/help/map/summary-and-guide-to-projections.html
        set(gca,'Visible','off'); 
        gridm('PLineLocation',45,'MLineLocation',60,'MLabelLocation',60); 
        ax.Clipping = 'off'; set(ax,'Fontsize',10)
        setm(gca,'FLineWidth',1.0) % https://www.mathworks.com/help/map/map-axes-properties.html
    % pcolorm(lat,lon,posterior_SST); shading flat; % <-- can change to prior_SST, or posterior_SST - prior_SST...
    CF1 = [tos.(sprintf('%s', season))(:,:,1);tos.(sprintf('%s', season))(end,:,1)]'; 
    CF2 = [tos.(sprintf('%s', season))(:,:,2);tos.(sprintf('%s', season))(end,:,2)]'; 
    lonAdj = [lon;lon(end,:)+1]; 
%     CF1 = tos.(sprintf('%s', season))(:,:,1)'; 
%     CF2 = tos.(sprintf('%s', season))(:,:,2)'; 
%     lonAdj = lon; 
    pcolorm(lat,lonAdj,CF2-CF1); shading flat; % <-- gerryrigged version to remove annoying white strip
    % contourfm(lat,lonAdj,CF2-CF1,-10:2:10,'Color',0.8.*[1 1 1]); % V2
    setm(gca,'Origin',[0 180 0]); % to center over the atlantic use [0 180 0], to center over pacific use [0 180 0] 

    % OPTION 1 FOR CONTINENTS: use matlab's modern shapefile
        land = shaperead('landareas.shp','UseGeoCoords',true);
        geoshow(land,'FaceColor', 0.4.*[1 1 1],'Linewidth',1.0,'EdgeColor',0.3.*[1 1 1]); % just setting the color of the continents, etc
    
    % OPTION 2 FOR CONTINENTS: use coastlines only
    p1 = plotm(coastlat,coastlon,'k','linewidth',1);
	    
    colormap(ax,flipud(cmap1)); % flipped the colormap vertically, so cold = blue, hot = red ... 
    cLim = [-10 10]; % set colormap lims here
	clim(cLim);  % set colormap   
    c=colorbar('southoutside'); c.LineWidth = 1.0; 
    c.Label.String = ['\DeltaSST (^{\circ}C)']; set(c,'Fontsize',10); 
    c.Position = [0.40 0.275 0.20 0.025]; % positioning of colorbars in Matlab's mapping toolbox is frustrating, so I usually just set it manually:

    % title
    axt = axes('position', [0.50 0.81 0.01 0.01],'visible', 'off'); hold on; box off;
	t1 = text(axt,0,0,'midPlio - PI','Fontsize',12,'Fontweight','Normal','HorizontalAlignment','center');        

    % save fig
    if saveFigs
    cd(['figures/',folderName,'/']); 
        set(gcf,'PaperOrientation','LandScape','Renderer','painters'); 
        set(gcf,'color','w');
        exportgraphics(gcf,['SST_midPlio-PI_',season,'.jpg'],'Resolution',500); % print('SST_midPlio-PI','-dpdf');
    cd ../../
    end
    
% earlyPlio - PI

% set some figure params
h = figure; hold on;
set(h,'units','centimeters','position',[1.8,0.90,22,15]);
    set(h,'PaperPositionMode','auto','PaperOrientation','landscape');
    ax = gca; ax.Visible = 'off';

ax1 = axes('Position',[0.15 0.20 0.70 0.70],'LineWidth',1.0); 
    set(gca,'Visible','off'); 
    ax = axesm ('Robinson','Frame', 'on', 'Grid', 'off'); % set projection here, based on available options: https://www.mathworks.com/help/map/summary-and-guide-to-projections.html
        set(gca,'Visible','off'); 
        gridm('PLineLocation',45,'MLineLocation',60,'MLabelLocation',60); 
        ax.Clipping = 'off'; set(ax,'Fontsize',10)
        setm(gca,'FLineWidth',1.0) % https://www.mathworks.com/help/map/map-axes-properties.html
    % pcolorm(lat,lon,posterior_SST); shading flat; % <-- can change to prior_SST, or posterior_SST - prior_SST...
    CF1 = [tos.(sprintf('%s', season))(:,:,1);tos.(sprintf('%s', season))(end,:,1)]'; 
    CF2 = [tos.(sprintf('%s', season))(:,:,3);tos.(sprintf('%s', season))(end,:,3)]'; 
    lonAdj = [lon;lon(end,:)+1]; 
%     CF1 = tos.(sprintf('%s', season))(:,:,1)'; 
%     CF2 = tos.(sprintf('%s', season))(:,:,3)'; 
%     lonAdj = lon; 
    pcolorm(lat,lonAdj,CF2-CF1); shading flat; % <-- gerryrigged version to remove annoying white strip
    % contourfm(lat,lonAdj,CF2-CF1,-10:2:10,'Color',0.8.*[1 1 1]); % V2
    setm(gca,'Origin',[0 180 0]); % to center over the atlantic use [0 180 0], to center over pacific use [0 180 0] 

    % OPTION 1 FOR CONTINENTS: use matlab's modern shapefile
        land = shaperead('landareas.shp','UseGeoCoords',true);
        geoshow(land,'FaceColor', 0.4.*[1 1 1],'Linewidth',1.0,'EdgeColor',0.3.*[1 1 1]); % just setting the color of the continents, etc
    
    % OPTION 2 FOR CONTINENTS: use coastlines only
    p1 = plotm(coastlat,coastlon,'k','linewidth',1);
	    
    colormap(ax,flipud(cmap1)); % flipped the colormap vertically, so cold = blue, hot = red ... 
    cLim = [-10 10]; % set colormap lims here
	clim(cLim);  % set colormap   
    c=colorbar('southoutside'); c.LineWidth = 1.0; 
    c.Label.String = ['\DeltaSST (^{\circ}C)']; set(c,'Fontsize',10); 
    c.Position = [0.40 0.275 0.20 0.025]; % positioning of colorbars in Matlab's mapping toolbox is frustrating, so I usually just set it manually:

    % title
    axt = axes('position', [0.50 0.81 0.01 0.01],'visible', 'off'); hold on; box off;
	t1 = text(axt,0,0,'earlyPlio - PI','Fontsize',12,'Fontweight','Normal','HorizontalAlignment','center');        

    % save fig
    if saveFigs
    cd(['figures/',folderName,'/']); 
        set(gcf,'PaperOrientation','LandScape','Renderer','painters'); 
        set(gcf,'color','w');
        exportgraphics(gcf,['SST_earlyPlio-PI_',season,'.jpg'],'Resolution',500); % print('SST_earlyPlio-PI','-dpdf');
    cd ../../
    end
    
%% Plot SAT's...

% PI

% set some figure params
h = figure; hold on;
set(h,'units','centimeters','position',[1.8,0.90,22,15]);
    set(h,'PaperPositionMode','auto','PaperOrientation','landscape');
    ax = gca; ax.Visible = 'off';

ax1 = axes('Position',[0.15 0.20 0.70 0.70],'LineWidth',1.0); 
    set(gca,'Visible','off'); 
    ax = axesm ('Robinson','Frame', 'on', 'Grid', 'off'); % set projection here, based on available options: https://www.mathworks.com/help/map/summary-and-guide-to-projections.html
        set(gca,'Visible','off'); 
        gridm('PLineLocation',45,'MLineLocation',60,'MLabelLocation',60); 
        ax.Clipping = 'off'; set(ax,'Fontsize',10)
        setm(gca,'FLineWidth',1.0) % https://www.mathworks.com/help/map/map-axes-properties.html
    % pcolorm(lat,lon,posterior_SST); shading flat; % <-- can change to prior_SST, or posterior_SST - prior_SST...
    CF = [tas.(sprintf('%s', season))(:,:,1);tas.(sprintf('%s', season))(end,:,1)]'; 
    lonAdj = [lon;lon(end,:)+1]; 
%     CF = tas.(sprintf('%s', season))(:,:,1)'; 
%     lonAdj = lon; 
    pcolorm(lat,lonAdj,CF); shading flat; % <-- gerryrigged version to remove annoying white strip
    % contourfm(lat,lonAdj,CF,-10:2:10,'Color',0.8.*[1 1 1]); % V2
    setm(gca,'Origin',[0 0 0]); % to center over the atlantic use [0 180 0], to center over pacific use [0 180 0] 
    
    % OPTION 2 FOR CONTINENTS: use coastlines only
    p1 = plotm(coastlat,coastlon,'k','linewidth',1);
	    
    colormap(ax,flipud(cmap1)); % flipped the colormap vertically, so cold = blue, hot = red ... 
    cLim = [-40 40]; % set colormap lims here
	clim(cLim);  % set colormap   
    c=colorbar('southoutside'); c.LineWidth = 1.0; 
    c.Label.String = ['SAT (^{\circ}C)']; set(c,'Fontsize',10); 
    c.Position = [0.40 0.275 0.20 0.025]; % positioning of colorbars in Matlab's mapping toolbox is frustrating, so I usually just set it manually:

    % title
    axt = axes('position', [0.50 0.81 0.01 0.01],'visible', 'off'); hold on; box off;
	t1 = text(axt,0,0,'PI','Fontsize',12,'Fontweight','Normal','HorizontalAlignment','center');        

    % save fig
    if saveFigs
    cd(['figures/',folderName,'/']); 
        set(gcf,'PaperOrientation','LandScape','Renderer','painters'); 
        set(gcf,'color','w');
        exportgraphics(gcf,['SAT_PI_',season,'.jpg'],'Resolution',500); % print('PI_SAT','-dpdf');
    cd ../../
    end
    
% midPlio

% set some figure params
h = figure; hold on;
set(h,'units','centimeters','position',[1.8,0.90,22,15]);
    set(h,'PaperPositionMode','auto','PaperOrientation','landscape');
    ax = gca; ax.Visible = 'off';

ax1 = axes('Position',[0.15 0.20 0.70 0.70],'LineWidth',1.0); 
    set(gca,'Visible','off'); 
    ax = axesm ('Robinson','Frame', 'on', 'Grid', 'off'); % set projection here, based on available options: https://www.mathworks.com/help/map/summary-and-guide-to-projections.html
        set(gca,'Visible','off'); 
        gridm('PLineLocation',45,'MLineLocation',60,'MLabelLocation',60); 
        ax.Clipping = 'off'; set(ax,'Fontsize',10)
        setm(gca,'FLineWidth',1.0) % https://www.mathworks.com/help/map/map-axes-properties.html
    % pcolorm(lat,lon,posterior_SST); shading flat; % <-- can change to prior_SST, or posterior_SST - prior_SST...
    CF = [tas.(sprintf('%s', season))(:,:,2);tas.(sprintf('%s', season))(end,:,2)]'; 
    lonAdj = [lon;lon(end,:)+1]; 
%     CF = tas.(sprintf('%s', season))(:,:,2)'; 
%     lonAdj = lon; 
    pcolorm(lat,lonAdj,CF); shading flat; % <-- gerryrigged version to remove annoying white strip
    % contourfm(lat,lonAdj,CF,-10:2:10,'Color',0.8.*[1 1 1]); % V2
    setm(gca,'Origin',[0 0 0]); % to center over the atlantic use [0 180 0], to center over pacific use [0 180 0] 
    
    % OPTION 2 FOR CONTINENTS: use coastlines only
    p1 = plotm(coastlat,coastlon,'k','linewidth',1);
	    
    colormap(ax,flipud(cmap1)); % flipped the colormap vertically, so cold = blue, hot = red ... 
    cLim = [-40 40]; % set colormap lims here
	clim(cLim);  % set colormap   
    c=colorbar('southoutside'); c.LineWidth = 1.0; 
    c.Label.String = ['SAT (^{\circ}C)']; set(c,'Fontsize',10); 
    c.Position = [0.40 0.275 0.20 0.025]; % positioning of colorbars in Matlab's mapping toolbox is frustrating, so I usually just set it manually:

    % title
    axt = axes('position', [0.50 0.81 0.01 0.01],'visible', 'off'); hold on; box off;
	t1 = text(axt,0,0,'midPlio','Fontsize',12,'Fontweight','Normal','HorizontalAlignment','center');        

    % save fig
    if saveFigs
    cd(['figures/',folderName,'/']); 
        set(gcf,'PaperOrientation','LandScape','Renderer','painters'); 
        set(gcf,'color','w');
        exportgraphics(gcf,['SAT_midPlio_',season,'.jpg'],'Resolution',500); % print('SAT_midPlio','-dpdf');
    cd ../../
    end
    
% earlyPlio

% set some figure params
h = figure; hold on;
set(h,'units','centimeters','position',[1.8,0.90,22,15]);
    set(h,'PaperPositionMode','auto','PaperOrientation','landscape');
    ax = gca; ax.Visible = 'off';

ax1 = axes('Position',[0.15 0.20 0.70 0.70],'LineWidth',1.0); 
    set(gca,'Visible','off'); 
    ax = axesm ('Robinson','Frame', 'on', 'Grid', 'off'); % set projection here, based on available options: https://www.mathworks.com/help/map/summary-and-guide-to-projections.html
        set(gca,'Visible','off'); 
        gridm('PLineLocation',45,'MLineLocation',60,'MLabelLocation',60); 
        ax.Clipping = 'off'; set(ax,'Fontsize',10)
        setm(gca,'FLineWidth',1.0) % https://www.mathworks.com/help/map/map-axes-properties.html
    % pcolorm(lat,lon,posterior_SST); shading flat; % <-- can change to prior_SST, or posterior_SST - prior_SST...
    CF = [tas.(sprintf('%s', season))(:,:,3);tas.(sprintf('%s', season))(end,:,3)]'; 
    lonAdj = [lon;lon(end,:)+1]; 
%     CF = tas.(sprintf('%s', season))(:,:,3)'; 
%     lonAdj = lon; 
    pcolorm(lat,lonAdj,CF); shading flat; % <-- gerryrigged version to remove annoying white strip
    % contourfm(lat,lonAdj,CF,-10:2:10,'Color',0.8.*[1 1 1]); % V2
    setm(gca,'Origin',[0 0 0]); % to center over the atlantic use [0 180 0], to center over pacific use [0 180 0] 
    
    % OPTION 2 FOR CONTINENTS: use coastlines only
    p1 = plotm(coastlat,coastlon,'k','linewidth',1);
	    
    colormap(ax,flipud(cmap1)); % flipped the colormap vertically, so cold = blue, hot = red ... 
    cLim = [-40 40]; % set colormap lims here
	clim(cLim);  % set colormap   
    c=colorbar('southoutside'); c.LineWidth = 1.0; 
    c.Label.String = ['SAT (^{\circ}C)']; set(c,'Fontsize',10); 
    c.Position = [0.40 0.275 0.20 0.025]; % positioning of colorbars in Matlab's mapping toolbox is frustrating, so I usually just set it manually:

    % title
    axt = axes('position', [0.50 0.81 0.01 0.01],'visible', 'off'); hold on; box off;
	t1 = text(axt,0,0,'earlyPlio','Fontsize',12,'Fontweight','Normal','HorizontalAlignment','center');        

    % save fig
    if saveFigs
    cd(['figures/',folderName,'/']); 
        set(gcf,'PaperOrientation','LandScape','Renderer','painters'); 
        set(gcf,'color','w');
        exportgraphics(gcf,['SAT_earlyPlio_',season,'.jpg'],'Resolution',500); % print('SAT_earlyPlio','-dpdf');
    cd ../../
    end
    
% midPlio - PI

% set some figure params
h = figure; hold on;
set(h,'units','centimeters','position',[1.8,0.90,22,15]);
    set(h,'PaperPositionMode','auto','PaperOrientation','landscape');
    ax = gca; ax.Visible = 'off';

ax1 = axes('Position',[0.15 0.20 0.70 0.70],'LineWidth',1.0); 
    set(gca,'Visible','off'); 
    ax = axesm ('Robinson','Frame', 'on', 'Grid', 'off'); % set projection here, based on available options: https://www.mathworks.com/help/map/summary-and-guide-to-projections.html
        set(gca,'Visible','off'); 
        gridm('PLineLocation',45,'MLineLocation',60,'MLabelLocation',60); 
        ax.Clipping = 'off'; set(ax,'Fontsize',10)
        setm(gca,'FLineWidth',1.0) % https://www.mathworks.com/help/map/map-axes-properties.html
    % pcolorm(lat,lon,posterior_SST); shading flat; % <-- can change to prior_SST, or posterior_SST - prior_SST...
    CF1 = [tas.(sprintf('%s', season))(:,:,1);tas.(sprintf('%s', season))(end,:,1)]'; 
    CF2 = [tas.(sprintf('%s', season))(:,:,2);tas.(sprintf('%s', season))(end,:,2)]'; 
    lonAdj = [lon;lon(end,:)+1]; 
%     CF1 = tas.(sprintf('%s', season))(:,:,1)'; 
%     CF2 = tas.(sprintf('%s', season))(:,:,2)'; 
%     lonAdj = lon; 
    pcolorm(lat,lonAdj,CF2-CF1); shading flat; % <-- gerryrigged version to remove annoying white strip
    % contourfm(lat,lonAdj,CF2-CF1,-10:2:10,'Color',0.8.*[1 1 1]); % V2
    setm(gca,'Origin',[0 0 0]); % to center over the atlantic use [0 180 0], to center over pacific use [0 180 0] 
    
    % OPTION 2 FOR CONTINENTS: use coastlines only
    p1 = plotm(coastlat,coastlon,'k','linewidth',1);
	    
    colormap(ax,flipud(cmap1)); % flipped the colormap vertically, so cold = blue, hot = red ... 
    cLim = [-20 20]; % set colormap lims here
	clim(cLim);  % set colormap   
    c=colorbar('southoutside'); c.LineWidth = 1.0; 
    c.Label.String = ['\DeltaSAT (^{\circ}C)']; set(c,'Fontsize',10); 
    c.Position = [0.40 0.275 0.20 0.025]; % positioning of colorbars in Matlab's mapping toolbox is frustrating, so I usually just set it manually:

    % title
    axt = axes('position', [0.50 0.81 0.01 0.01],'visible', 'off'); hold on; box off;
	t1 = text(axt,0,0,'midPlio - PI','Fontsize',12,'Fontweight','Normal','HorizontalAlignment','center');        

    % save fig
    if saveFigs
    cd(['figures/',folderName,'/']); 
        set(gcf,'PaperOrientation','LandScape','Renderer','painters'); 
        set(gcf,'color','w');
        exportgraphics(gcf,['SAT_midPlio-PI_',season,'.jpg'],'Resolution',500); % print('SAT_midPlio-PI','-dpdf');
    cd ../../
    end
    
% earlyPlio - PI

% set some figure params
h = figure; hold on;
set(h,'units','centimeters','position',[1.8,0.90,22,15]);
    set(h,'PaperPositionMode','auto','PaperOrientation','landscape');
    ax = gca; ax.Visible = 'off';

ax1 = axes('Position',[0.15 0.20 0.70 0.70],'LineWidth',1.0); 
    set(gca,'Visible','off'); 
    ax = axesm ('Robinson','Frame', 'on', 'Grid', 'off'); % set projection here, based on available options: https://www.mathworks.com/help/map/summary-and-guide-to-projections.html
        set(gca,'Visible','off'); 
        gridm('PLineLocation',45,'MLineLocation',60,'MLabelLocation',60); 
        ax.Clipping = 'off'; set(ax,'Fontsize',10)
        setm(gca,'FLineWidth',1.0) % https://www.mathworks.com/help/map/map-axes-properties.html
    % pcolorm(lat,lon,posterior_SST); shading flat; % <-- can change to prior_SST, or posterior_SST - prior_SST...
    CF1 = [tas.(sprintf('%s', season))(:,:,1);tas.(sprintf('%s', season))(end,:,1)]'; 
    CF2 = [tas.(sprintf('%s', season))(:,:,3);tas.(sprintf('%s', season))(end,:,3)]'; 
    lonAdj = [lon;lon(end,:)+1]; 
%     CF1 = tas.(sprintf('%s', season))(:,:,1)'; 
%     CF2 = tas.(sprintf('%s', season))(:,:,3)'; 
%     lonAdj = lon; 
    pcolorm(lat,lonAdj,CF2-CF1); shading flat; % <-- gerryrigged version to remove annoying white strip
    % contourfm(lat,lonAdj,CF2-CF1,-10:2:10,'Color',0.8.*[1 1 1]); % V2
    setm(gca,'Origin',[0 0 0]); % to center over the atlantic use [0 180 0], to center over pacific use [0 180 0] 
    
    % OPTION 2 FOR CONTINENTS: use coastlines only
    p1 = plotm(coastlat,coastlon,'k','linewidth',1);
	    
    colormap(ax,flipud(cmap1)); % flipped the colormap vertically, so cold = blue, hot = red ... 
    cLim = [-20 20]; % set colormap lims here
	clim(cLim);  % set colormap   
    c=colorbar('southoutside'); c.LineWidth = 1.0; 
    c.Label.String = ['\DeltaSAT (^{\circ}C)']; set(c,'Fontsize',10); 
    c.Position = [0.40 0.275 0.20 0.025]; % positioning of colorbars in Matlab's mapping toolbox is frustrating, so I usually just set it manually:

    % title
    axt = axes('position', [0.50 0.81 0.01 0.01],'visible', 'off'); hold on; box off;
	t1 = text(axt,0,0,'earlyPlio - PI','Fontsize',12,'Fontweight','Normal','HorizontalAlignment','center');        

    % save fig
    if saveFigs
    cd(['figures/',folderName,'/']); 
        set(gcf,'PaperOrientation','LandScape','Renderer','painters'); 
        set(gcf,'color','w');
        exportgraphics(gcf,['SAT_earlyPlio-PI_',season,'.jpg'],'Resolution',500); % print('SAT_earlyPlio-PI','-dpdf');
    cd ../../
    end
    
%% Plot Precip...

% PI

% set some figure params
h = figure; hold on;
set(h,'units','centimeters','position',[1.8,0.90,22,15]);
    set(h,'PaperPositionMode','auto','PaperOrientation','landscape');
    ax = gca; ax.Visible = 'off';

ax1 = axes('Position',[0.15 0.20 0.70 0.70],'LineWidth',1.0); 
    set(gca,'Visible','off'); 
    ax = axesm ('Robinson','Frame', 'on', 'Grid', 'off'); % set projection here, based on available options: https://www.mathworks.com/help/map/summary-and-guide-to-projections.html
        set(gca,'Visible','off'); 
        gridm('PLineLocation',45,'MLineLocation',60,'MLabelLocation',60); 
        ax.Clipping = 'off'; set(ax,'Fontsize',10)
        setm(gca,'FLineWidth',1.0) % https://www.mathworks.com/help/map/map-axes-properties.html
    % pcolorm(lat,lon,posterior_SST); shading flat; % <-- can change to prior_SST, or posterior_SST - prior_SST...
    CF = [pr.(sprintf('%s', season))(:,:,1);pr.(sprintf('%s', season))(end,:,1)]'; 
    lonAdj = [lon;lon(end,:)+1]; 
%     CF = pr.(sprintf('%s', season))(:,:,1)'; 
%     lonAdj = lon; 
    pcolorm(lat,lonAdj,CF); shading flat; % <-- gerryrigged version to remove annoying white strip
    % contourfm(lat,lonAdj,CF,-10:2:10,'Color',0.8.*[1 1 1]); % V2
    setm(gca,'Origin',[0 0 0]); % to center over the atlantic use [0 180 0], to center over pacific use [0 180 0] 
    
    % OPTION 2 FOR CONTINENTS: use coastlines only
    p1 = plotm(coastlat,coastlon,'k','linewidth',1);
	    
    colormap(ax,flipud(cmap2)); % flipped the colormap vertically, so cold = blue, hot = red ... 
    cLim = [0 10]; % set colormap lims here
	clim(cLim);  % set colormap   
    c=colorbar('southoutside'); c.LineWidth = 1.0; 
    c.Label.String = ['Precip. (mm day^{-1})']; set(c,'Fontsize',10); 
    c.Position = [0.40 0.275 0.20 0.025]; % positioning of colorbars in Matlab's mapping toolbox is frustrating, so I usually just set it manually:

    % title
    axt = axes('position', [0.50 0.81 0.01 0.01],'visible', 'off'); hold on; box off;
	t1 = text(axt,0,0,'PI','Fontsize',12,'Fontweight','Normal','HorizontalAlignment','center');        

    % save fig
    if saveFigs
    cd(['figures/',folderName,'/']); 
        set(gcf,'PaperOrientation','LandScape','Renderer','painters'); 
        set(gcf,'color','w');
        exportgraphics(gcf,['Precip_PI_',season,'.jpg'],'Resolution',500); % print('Precip_PI','-dpdf');
    cd ../../
    end
    
% midPlio

% set some figure params
h = figure; hold on;
set(h,'units','centimeters','position',[1.8,0.90,22,15]);
    set(h,'PaperPositionMode','auto','PaperOrientation','landscape');
    ax = gca; ax.Visible = 'off';

ax1 = axes('Position',[0.15 0.20 0.70 0.70],'LineWidth',1.0); 
    set(gca,'Visible','off'); 
    ax = axesm ('Robinson','Frame', 'on', 'Grid', 'off'); % set projection here, based on available options: https://www.mathworks.com/help/map/summary-and-guide-to-projections.html
        set(gca,'Visible','off'); 
        gridm('PLineLocation',45,'MLineLocation',60,'MLabelLocation',60); 
        ax.Clipping = 'off'; set(ax,'Fontsize',10)
        setm(gca,'FLineWidth',1.0) % https://www.mathworks.com/help/map/map-axes-properties.html
    % pcolorm(lat,lon,posterior_SST); shading flat; % <-- can change to prior_SST, or posterior_SST - prior_SST...
    CF = [pr.(sprintf('%s', season))(:,:,2);pr.(sprintf('%s', season))(end,:,2)]'; 
    lonAdj = [lon;lon(end,:)+1]; 
%     CF = pr.(sprintf('%s', season))(:,:,2)'; 
%     lonAdj = lon; 
    pcolorm(lat,lonAdj,CF); shading flat; % <-- gerryrigged version to remove annoying white strip
    % contourfm(lat,lonAdj,CF,-10:2:10,'Color',0.8.*[1 1 1]); % V2
    setm(gca,'Origin',[0 0 0]); % to center over the atlantic use [0 180 0], to center over pacific use [0 180 0] 
    
    % OPTION 2 FOR CONTINENTS: use coastlines only
    p1 = plotm(coastlat,coastlon,'k','linewidth',1);
	    
    colormap(ax,flipud(cmap2)); % flipped the colormap vertically, so cold = blue, hot = red ... 
    cLim = [0 10]; % set colormap lims here
	clim(cLim);  % set colormap   
    c=colorbar('southoutside'); c.LineWidth = 1.0; 
    c.Label.String = ['Precip. (mm day^{-1})']; set(c,'Fontsize',10); 
    c.Position = [0.40 0.275 0.20 0.025]; % positioning of colorbars in Matlab's mapping toolbox is frustrating, so I usually just set it manually:

    % title
    axt = axes('position', [0.50 0.81 0.01 0.01],'visible', 'off'); hold on; box off;
	t1 = text(axt,0,0,'midPlio','Fontsize',12,'Fontweight','Normal','HorizontalAlignment','center');        

    % save fig
    if saveFigs
    cd(['figures/',folderName,'/']); 
        set(gcf,'PaperOrientation','LandScape','Renderer','painters'); 
        set(gcf,'color','w');
        exportgraphics(gcf,['Precip_midPlio_',season,'.jpg'],'Resolution',500); % print('Precip_midPlio','-dpdf');
    cd ../../
    end
    
% earlyPlio

% set some figure params
h = figure; hold on;
set(h,'units','centimeters','position',[1.8,0.90,22,15]);
    set(h,'PaperPositionMode','auto','PaperOrientation','landscape');
    ax = gca; ax.Visible = 'off';

ax1 = axes('Position',[0.15 0.20 0.70 0.70],'LineWidth',1.0); 
    set(gca,'Visible','off'); 
    ax = axesm ('Robinson','Frame', 'on', 'Grid', 'off'); % set projection here, based on available options: https://www.mathworks.com/help/map/summary-and-guide-to-projections.html
        set(gca,'Visible','off'); 
        gridm('PLineLocation',45,'MLineLocation',60,'MLabelLocation',60); 
        ax.Clipping = 'off'; set(ax,'Fontsize',10)
        setm(gca,'FLineWidth',1.0) % https://www.mathworks.com/help/map/map-axes-properties.html
    % pcolorm(lat,lon,posterior_SST); shading flat; % <-- can change to prior_SST, or posterior_SST - prior_SST...
    CF = [pr.(sprintf('%s', season))(:,:,3);pr.(sprintf('%s', season))(end,:,3)]'; 
    lonAdj = [lon;lon(end,:)+1]; 
%     CF = pr.(sprintf('%s', season))(:,:,3)'; 
%     lonAdj = lon; 
    pcolorm(lat,lonAdj,CF); shading flat; % <-- gerryrigged version to remove annoying white strip
    % contourfm(lat,lonAdj,CF,-10:2:10,'Color',0.8.*[1 1 1]); % V2
    setm(gca,'Origin',[0 0 0]); % to center over the atlantic use [0 180 0], to center over pacific use [0 180 0] 
    
    % OPTION 2 FOR CONTINENTS: use coastlines only
    p1 = plotm(coastlat,coastlon,'k','linewidth',1);
	    
    colormap(ax,flipud(cmap2)); % flipped the colormap vertically, so cold = blue, hot = red ... 
    cLim = [0 10]; % set colormap lims here
	clim(cLim);  % set colormap   
    c=colorbar('southoutside'); c.LineWidth = 1.0; 
    c.Label.String = ['Precip. (mm day^{-1})']; set(c,'Fontsize',10); 
    c.Position = [0.40 0.275 0.20 0.025]; % positioning of colorbars in Matlab's mapping toolbox is frustrating, so I usually just set it manually:

    % title
    axt = axes('position', [0.50 0.81 0.01 0.01],'visible', 'off'); hold on; box off;
	t1 = text(axt,0,0,'earlyPlio','Fontsize',12,'Fontweight','Normal','HorizontalAlignment','center');        

    % save fig
    if saveFigs
    cd(['figures/',folderName,'/']); 
        set(gcf,'PaperOrientation','LandScape','Renderer','painters'); 
        set(gcf,'color','w');
        exportgraphics(gcf,['Precip_earlyPlio_',season,'.jpg'],'Resolution',500); % print('Precip_earlyPlio','-dpdf');
    cd ../../
    end
    
% midPlio - PI

% set some figure params
h = figure; hold on;
set(h,'units','centimeters','position',[1.8,0.90,22,15]);
    set(h,'PaperPositionMode','auto','PaperOrientation','landscape');
    ax = gca; ax.Visible = 'off';

ax1 = axes('Position',[0.15 0.20 0.70 0.70],'LineWidth',1.0); 
    set(gca,'Visible','off'); 
    ax = axesm ('Robinson','Frame', 'on', 'Grid', 'off'); % set projection here, based on available options: https://www.mathworks.com/help/map/summary-and-guide-to-projections.html
        set(gca,'Visible','off'); 
        gridm('PLineLocation',45,'MLineLocation',60,'MLabelLocation',60); 
        ax.Clipping = 'off'; set(ax,'Fontsize',10)
        setm(gca,'FLineWidth',1.0) % https://www.mathworks.com/help/map/map-axes-properties.html
    % pcolorm(lat,lon,posterior_SST); shading flat; % <-- can change to prior_SST, or posterior_SST - prior_SST...
    CF1 = [pr.(sprintf('%s', season))(:,:,1);pr.(sprintf('%s', season))(end,:,1)]'; 
    CF2 = [pr.(sprintf('%s', season))(:,:,2);pr.(sprintf('%s', season))(end,:,2)]'; 
    lonAdj = [lon;lon(end,:)+1]; 
%     CF1 = pr.(sprintf('%s', season))(:,:,1)'; 
%     CF2 = pr.(sprintf('%s', season))(:,:,2)'; 
%     lonAdj = lon; 
    pcolorm(lat,lonAdj,CF2-CF1); shading flat; % <-- gerryrigged version to remove annoying white strip
    % contourfm(lat,lonAdj,CF2-CF1,-10:2:10,'Color',0.8.*[1 1 1]); % V2
    setm(gca,'Origin',[0 0 0]); % to center over the atlantic use [0 180 0], to center over pacific use [0 180 0] 
    
    % OPTION 2 FOR CONTINENTS: use coastlines only
    p1 = plotm(coastlat,coastlon,'k','linewidth',1);
	    
    colormap(ax,flipud(cmap2)); % flipped the colormap vertically, so cold = blue, hot = red ... 
    cLim = [-7.5 7.5]; % set colormap lims here
	clim(cLim);  % set colormap   
    c=colorbar('southoutside'); c.LineWidth = 1.0; 
    c.Label.String = ['\DeltaPrecip. (mm day^{-1})']; set(c,'Fontsize',10); 
    c.Position = [0.40 0.275 0.20 0.025]; % positioning of colorbars in Matlab's mapping toolbox is frustrating, so I usually just set it manually:

    % title
    axt = axes('position', [0.50 0.81 0.01 0.01],'visible', 'off'); hold on; box off;
	t1 = text(axt,0,0,'midPlio - PI','Fontsize',12,'Fontweight','Normal','HorizontalAlignment','center');        

    % save fig
    if saveFigs
    cd(['figures/',folderName,'/']); 
        set(gcf,'PaperOrientation','LandScape','Renderer','painters'); 
        set(gcf,'color','w');
        exportgraphics(gcf,['Precip_midPlio-PI_',season,'.jpg'],'Resolution',500); % print('Precip_midPlio-PI','-dpdf');
    cd ../../
    end
    
% earlyPlio - PI

% set some figure params
h = figure; hold on;
set(h,'units','centimeters','position',[1.8,0.90,22,15]);
    set(h,'PaperPositionMode','auto','PaperOrientation','landscape');
    ax = gca; ax.Visible = 'off';

ax1 = axes('Position',[0.15 0.20 0.70 0.70],'LineWidth',1.0); 
    set(gca,'Visible','off'); 
    ax = axesm ('Robinson','Frame', 'on', 'Grid', 'off'); % set projection here, based on available options: https://www.mathworks.com/help/map/summary-and-guide-to-projections.html
        set(gca,'Visible','off'); 
        gridm('PLineLocation',45,'MLineLocation',60,'MLabelLocation',60); 
        ax.Clipping = 'off'; set(ax,'Fontsize',10)
        setm(gca,'FLineWidth',1.0) % https://www.mathworks.com/help/map/map-axes-properties.html
    % pcolorm(lat,lon,posterior_SST); shading flat; % <-- can change to prior_SST, or posterior_SST - prior_SST...
    CF1 = [pr.(sprintf('%s', season))(:,:,1);pr.(sprintf('%s', season))(end,:,1)]'; 
    CF2 = [pr.(sprintf('%s', season))(:,:,3);pr.(sprintf('%s', season))(end,:,3)]'; 
    lonAdj = [lon;lon(end,:)+1]; 
%     CF1 = pr.(sprintf('%s', season))(:,:,1)'; 
%     CF2 = pr.(sprintf('%s', season))(:,:,3)'; 
%     lonAdj = lon; 
    pcolorm(lat,lonAdj,CF2-CF1); shading flat; % <-- gerryrigged version to remove annoying white strip
    % contourfm(lat,lonAdj,CF2-CF1,-10:2:10,'Color',0.8.*[1 1 1]); % V2
    setm(gca,'Origin',[0 0 0]); % to center over the atlantic use [0 180 0], to center over pacific use [0 180 0] 
    
    % OPTION 2 FOR CONTINENTS: use coastlines only
    p1 = plotm(coastlat,coastlon,'k','linewidth',1);
	    
    colormap(ax,flipud(cmap2)); % flipped the colormap vertically, so cold = blue, hot = red ... 
    cLim = [-7.5 7.5]; % set colormap lims here
	clim(cLim);  % set colormap   
    c=colorbar('southoutside'); c.LineWidth = 1.0; 
    c.Label.String = ['\DeltaPrecip. (mm day^{-1})']; set(c,'Fontsize',10); 
    c.Position = [0.40 0.275 0.20 0.025]; % positioning of colorbars in Matlab's mapping toolbox is frustrating, so I usually just set it manually:

    % title
    axt = axes('position', [0.50 0.81 0.01 0.01],'visible', 'off'); hold on; box off;
	t1 = text(axt,0,0,'earlyPlio - PI','Fontsize',12,'Fontweight','Normal','HorizontalAlignment','center');        

    % save fig
    if saveFigs
    cd(['figures/',folderName,'/']); 
        set(gcf,'PaperOrientation','LandScape','Renderer','painters'); 
        set(gcf,'color','w');
        exportgraphics(gcf,['Precip_earlyPlio-PI_',season,'.jpg'],'Resolution',500); % print('Precip_earlyPlio-PI','-dpdf');
    cd ../../
    end
    
    
%% Plot SIC..

% PI

% set some figure params
h = figure; hold on;
set(h,'units','centimeters','position',[1.8,0.90,22,15]);
    set(h,'PaperPositionMode','auto','PaperOrientation','landscape');
    ax = gca; ax.Visible = 'off';

ax1 = axes('Position',[0.15 0.20 0.70 0.70],'LineWidth',1.0); 
    set(gca,'Visible','off'); 
    ax = axesm ('Robinson','Frame', 'on', 'Grid', 'off'); % set projection here, based on available options: https://www.mathworks.com/help/map/summary-and-guide-to-projections.html
        set(gca,'Visible','off'); 
        gridm('PLineLocation',45,'MLineLocation',60,'MLabelLocation',60); 
        ax.Clipping = 'off'; set(ax,'Fontsize',10)
        setm(gca,'FLineWidth',1.0) % https://www.mathworks.com/help/map/map-axes-properties.html
    % pcolorm(lat,lon,posterior_SST); shading flat; % <-- can change to prior_SST, or posterior_SST - prior_SST...
    CF = [siconc.(sprintf('%s', season))(:,:,1);siconc.(sprintf('%s', season))(end,:,1)]'; 
    lonAdj = [lon;lon(end,:)+1]; 
%     CF = siconc.(sprintf('%s', season))(:,:,1)'; 
%     lonAdj = lon; 
    pcolorm(lat,lonAdj,CF); shading flat; % <-- gerryrigged version to remove annoying white strip
    % contourfm(lat,lonAdj,CF,-10:2:10,'Color',0.8.*[1 1 1]); % V2
    setm(gca,'Origin',[0 0 0]); % to center over the atlantic use [0 180 0], to center over pacific use [0 180 0] 
    
    % OPTION 2 FOR CONTINENTS: use coastlines only
    p1 = plotm(coastlat,coastlon,'k','linewidth',1);
	    
    colormap(ax,flipud(cmap3)); % flipped the colormap vertically, so cold = blue, hot = red ... 
    cLim = [0 100]; % set colormap lims here
	clim(cLim);  % set colormap   
    c=colorbar('southoutside'); c.LineWidth = 1.0; 
    c.Label.String = ['SIC (%)']; set(c,'Fontsize',10); 
    c.Position = [0.40 0.275 0.20 0.025]; % positioning of colorbars in Matlab's mapping toolbox is frustrating, so I usually just set it manually:

    % title
    axt = axes('position', [0.50 0.81 0.01 0.01],'visible', 'off'); hold on; box off;
	t1 = text(axt,0,0,'PI','Fontsize',12,'Fontweight','Normal','HorizontalAlignment','center');        

    % save fig
    if saveFigs
    cd(['figures/',folderName,'/']); 
        set(gcf,'PaperOrientation','LandScape','Renderer','painters'); 
        set(gcf,'color','w');
        exportgraphics(gcf,['SIC_PI_',season,'.jpg'],'Resolution',500); % print('SIC_PI','-dpdf');
    cd ../../
    end
    
% midPlio

% set some figure params
h = figure; hold on;
set(h,'units','centimeters','position',[1.8,0.90,22,15]);
    set(h,'PaperPositionMode','auto','PaperOrientation','landscape');
    ax = gca; ax.Visible = 'off';

ax1 = axes('Position',[0.15 0.20 0.70 0.70],'LineWidth',1.0); 
    set(gca,'Visible','off'); 
    ax = axesm ('Robinson','Frame', 'on', 'Grid', 'off'); % set projection here, based on available options: https://www.mathworks.com/help/map/summary-and-guide-to-projections.html
        set(gca,'Visible','off'); 
        gridm('PLineLocation',45,'MLineLocation',60,'MLabelLocation',60); 
        ax.Clipping = 'off'; set(ax,'Fontsize',10)
        setm(gca,'FLineWidth',1.0) % https://www.mathworks.com/help/map/map-axes-properties.html
    % pcolorm(lat,lon,posterior_SST); shading flat; % <-- can change to prior_SST, or posterior_SST - prior_SST...
    CF = [siconc.(sprintf('%s', season))(:,:,2);siconc.(sprintf('%s', season))(end,:,2)]'; 
    lonAdj = [lon;lon(end,:)+1]; 
%     CF = siconc.(sprintf('%s', season))(:,:,2)'; 
%     lonAdj = lon; 
    pcolorm(lat,lonAdj,CF); shading flat; % <-- gerryrigged version to remove annoying white strip
    % contourfm(lat,lonAdj,CF,-10:2:10,'Color',0.8.*[1 1 1]); % V2
    setm(gca,'Origin',[0 0 0]); % to center over the atlantic use [0 180 0], to center over pacific use [0 180 0] 
    
    % OPTION 2 FOR CONTINENTS: use coastlines only
    p1 = plotm(coastlat,coastlon,'k','linewidth',1);
	    
    colormap(ax,flipud(cmap3)); % flipped the colormap vertically, so cold = blue, hot = red ... 
    cLim = [0 100]; % set colormap lims here
	clim(cLim);  % set colormap   
    c=colorbar('southoutside'); c.LineWidth = 1.0; 
    c.Label.String = ['SIC (%)']; set(c,'Fontsize',10); 
    c.Position = [0.40 0.275 0.20 0.025]; % positioning of colorbars in Matlab's mapping toolbox is frustrating, so I usually just set it manually:

    % title
    axt = axes('position', [0.50 0.81 0.01 0.01],'visible', 'off'); hold on; box off;
	t1 = text(axt,0,0,'midPlio','Fontsize',12,'Fontweight','Normal','HorizontalAlignment','center');        

    % save fig
    if saveFigs
    cd(['figures/',folderName,'/']); 
        set(gcf,'PaperOrientation','LandScape','Renderer','painters'); 
        set(gcf,'color','w');
        exportgraphics(gcf,['SIC_midPlio_',season,'.jpg'],'Resolution',500); % print('SIC_midPlio','-dpdf');
    cd ../../
    end
    
% earlyPlio

% set some figure params
h = figure; hold on;
set(h,'units','centimeters','position',[1.8,0.90,22,15]);
    set(h,'PaperPositionMode','auto','PaperOrientation','landscape');
    ax = gca; ax.Visible = 'off';

ax1 = axes('Position',[0.15 0.20 0.70 0.70],'LineWidth',1.0); 
    set(gca,'Visible','off'); 
    ax = axesm ('Robinson','Frame', 'on', 'Grid', 'off'); % set projection here, based on available options: https://www.mathworks.com/help/map/summary-and-guide-to-projections.html
        set(gca,'Visible','off'); 
        gridm('PLineLocation',45,'MLineLocation',60,'MLabelLocation',60); 
        ax.Clipping = 'off'; set(ax,'Fontsize',10)
        setm(gca,'FLineWidth',1.0) % https://www.mathworks.com/help/map/map-axes-properties.html
    % pcolorm(lat,lon,posterior_SST); shading flat; % <-- can change to prior_SST, or posterior_SST - prior_SST...
    CF = [siconc.(sprintf('%s', season))(:,:,3);siconc.(sprintf('%s', season))(end,:,3)]'; 
    lonAdj = [lon;lon(end,:)+1]; 
%     CF = siconc.(sprintf('%s', season))(:,:,3)'; 
%     lonAdj = lon; 
    pcolorm(lat,lonAdj,CF); shading flat; % <-- gerryrigged version to remove annoying white strip
    % contourfm(lat,lonAdj,CF,-10:2:10,'Color',0.8.*[1 1 1]); % V2
    setm(gca,'Origin',[0 0 0]); % to center over the atlantic use [0 180 0], to center over pacific use [0 180 0] 
    
    % OPTION 2 FOR CONTINENTS: use coastlines only
    p1 = plotm(coastlat,coastlon,'k','linewidth',1);
	    
    colormap(ax,flipud(cmap3)); % flipped the colormap vertically, so cold = blue, hot = red ... 
    cLim = [0 100]; % set colormap lims here
	clim(cLim);  % set colormap   
    c=colorbar('southoutside'); c.LineWidth = 1.0; 
    c.Label.String = ['SIC (%)']; set(c,'Fontsize',10); 
    c.Position = [0.40 0.275 0.20 0.025]; % positioning of colorbars in Matlab's mapping toolbox is frustrating, so I usually just set it manually:

    % title
    axt = axes('position', [0.50 0.81 0.01 0.01],'visible', 'off'); hold on; box off;
	t1 = text(axt,0,0,'earlyPlio','Fontsize',12,'Fontweight','Normal','HorizontalAlignment','center');        

    % save fig
    if saveFigs
    cd(['figures/',folderName,'/']); 
        set(gcf,'PaperOrientation','LandScape','Renderer','painters'); 
        set(gcf,'color','w');
        exportgraphics(gcf,['SIC_earlyPlio_',season,'.jpg'],'Resolution',500); % print('SIC_earlyPlio','-dpdf');
    cd ../../
    end
    
% midPlio - PI

% set some figure params
h = figure; hold on;
set(h,'units','centimeters','position',[1.8,0.90,22,15]);
    set(h,'PaperPositionMode','auto','PaperOrientation','landscape');
    ax = gca; ax.Visible = 'off';

ax1 = axes('Position',[0.15 0.20 0.70 0.70],'LineWidth',1.0); 
    set(gca,'Visible','off'); 
    ax = axesm ('Robinson','Frame', 'on', 'Grid', 'off'); % set projection here, based on available options: https://www.mathworks.com/help/map/summary-and-guide-to-projections.html
        set(gca,'Visible','off'); 
        gridm('PLineLocation',45,'MLineLocation',60,'MLabelLocation',60); 
        ax.Clipping = 'off'; set(ax,'Fontsize',10)
        setm(gca,'FLineWidth',1.0) % https://www.mathworks.com/help/map/map-axes-properties.html
    % pcolorm(lat,lon,posterior_SST); shading flat; % <-- can change to prior_SST, or posterior_SST - prior_SST...
    CF1 = [siconc.(sprintf('%s', season))(:,:,1);siconc.(sprintf('%s', season))(end,:,1)]'; 
    CF2 = [siconc.(sprintf('%s', season))(:,:,2);siconc.(sprintf('%s', season))(end,:,2)]'; 
    lonAdj = [lon;lon(end,:)+1]; 
%     CF1 = siconc.(sprintf('%s', season))(:,:,1)'; 
%     CF2 = siconc.(sprintf('%s', season))(:,:,2)'; 
%     lonAdj = lon; 
    pcolorm(lat,lonAdj,CF2-CF1); shading flat; % <-- gerryrigged version to remove annoying white strip
    % contourfm(lat,lonAdj,CF2-CF1,-10:2:10,'Color',0.8.*[1 1 1]); % V2
    setm(gca,'Origin',[0 0 0]); % to center over the atlantic use [0 180 0], to center over pacific use [0 180 0] 
    
    % OPTION 2 FOR CONTINENTS: use coastlines only
    p1 = plotm(coastlat,coastlon,'k','linewidth',1);
	    
    colormap(ax,(cmap1)); % flipped the colormap vertically, so cold = blue, hot = red ... 
    cLim = [-100 100]; % set colormap lims here
	clim(cLim);  % set colormap   
    c=colorbar('southoutside'); c.LineWidth = 1.0; 
    c.Label.String = ['\DeltaSIC (%)']; set(c,'Fontsize',10); 
    c.Position = [0.40 0.275 0.20 0.025]; % positioning of colorbars in Matlab's mapping toolbox is frustrating, so I usually just set it manually:

    % title
    axt = axes('position', [0.50 0.81 0.01 0.01],'visible', 'off'); hold on; box off;
	t1 = text(axt,0,0,'midPlio - PI','Fontsize',12,'Fontweight','Normal','HorizontalAlignment','center');        

    % save fig
    if saveFigs
    cd(['figures/',folderName,'/']); 
        set(gcf,'PaperOrientation','LandScape','Renderer','painters'); 
        set(gcf,'color','w');
        exportgraphics(gcf,['SIC_midPlio-PI_',season,'.jpg'],'Resolution',500); % print('SIC_midPlio-PI','-dpdf');
    cd ../../
    end
    
% earlyPlio - PI

% set some figure params
h = figure; hold on;
set(h,'units','centimeters','position',[1.8,0.90,22,15]);
    set(h,'PaperPositionMode','auto','PaperOrientation','landscape');
    ax = gca; ax.Visible = 'off';

ax1 = axes('Position',[0.15 0.20 0.70 0.70],'LineWidth',1.0); 
    set(gca,'Visible','off'); 
    ax = axesm ('Robinson','Frame', 'on', 'Grid', 'off'); % set projection here, based on available options: https://www.mathworks.com/help/map/summary-and-guide-to-projections.html
        set(gca,'Visible','off'); 
        gridm('PLineLocation',45,'MLineLocation',60,'MLabelLocation',60); 
        ax.Clipping = 'off'; set(ax,'Fontsize',10)
        setm(gca,'FLineWidth',1.0) % https://www.mathworks.com/help/map/map-axes-properties.html
    % pcolorm(lat,lon,posterior_SST); shading flat; % <-- can change to prior_SST, or posterior_SST - prior_SST...
    CF1 = [siconc.(sprintf('%s', season))(:,:,1);siconc.(sprintf('%s', season))(end,:,1)]'; 
    CF2 = [siconc.(sprintf('%s', season))(:,:,3);siconc.(sprintf('%s', season))(end,:,3)]'; 
    lonAdj = [lon;lon(end,:)+1]; 
%     CF1 = siconc.(sprintf('%s', season))(:,:,1)'; 
%     CF2 = siconc.(sprintf('%s', season))(:,:,3)'; 
%     lonAdj = lon; 
    pcolorm(lat,lonAdj,CF2-CF1); shading flat; % <-- gerryrigged version to remove annoying white strip
    % contourfm(lat,lonAdj,CF2-CF1,-10:2:10,'Color',0.8.*[1 1 1]); % V2
    setm(gca,'Origin',[0 0 0]); % to center over the atlantic use [0 180 0], to center over pacific use [0 180 0] 
    
    % OPTION 2 FOR CONTINENTS: use coastlines only
    p1 = plotm(coastlat,coastlon,'k','linewidth',1);
	    
    colormap(ax,(cmap1)); % flipped the colormap vertically, so cold = blue, hot = red ... 
    cLim = [-100 100]; % set colormap lims here
	clim(cLim);  % set colormap   
    c=colorbar('southoutside'); c.LineWidth = 1.0; 
    c.Label.String = ['\DeltaSIC (%)']; set(c,'Fontsize',10); 
    c.Position = [0.40 0.275 0.20 0.025]; % positioning of colorbars in Matlab's mapping toolbox is frustrating, so I usually just set it manually:

    % title
    axt = axes('position', [0.50 0.81 0.01 0.01],'visible', 'off'); hold on; box off;
	t1 = text(axt,0,0,'earlyPlio - PI','Fontsize',12,'Fontweight','Normal','HorizontalAlignment','center');        

    % save fig
    if saveFigs
    cd(['figures/',folderName,'/']); 
        set(gcf,'PaperOrientation','LandScape','Renderer','painters'); 
        set(gcf,'color','w');
        exportgraphics(gcf,['SIC_earlyPlio-PI_',season,'.jpg'],'Resolution',500); % print('SIC_earlyPlio-PI','-dpdf');
    cd ../../
    end

%% Compute global mean temperature

% compute area-weighted global mean 
latWeight = repmat(cos(lat*4.0*atan(1.0)/180),[1, 360])';
for i = 1:size(tas.(sprintf('%s', season)),3)
    cf = tas.(sprintf('%s', season))(:,:,i); 
    gmst(i,1) = nansum(latWeight(:).*cf(:)) ./ nansum(latWeight(:)); 
end

disp(['mid-Pliocene warming: ',num2str(round(gmst(2) - gmst(1),2)),'C']); 
disp(['early-Pliocene warming: ',num2str(round(gmst(3) - gmst(1),2)),'C']); 
