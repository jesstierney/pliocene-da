%QC checks 
files = dir("*.csv");
latS = NaN(length(files),1);
lonS = NaN(length(files),1);
latM = NaN(length(files),1);
lonM = NaN(length(files),1);
latP1 = NaN(length(files),1);
lonP2 = NaN(length(files),1);
latP2 = NaN(length(files),1);
lonP1 = NaN(length(files),1);
depth = NaN(length(files),1);
modTEX = NaN(length(files),1);
plioTEX = NaN(length(files),1);
age = cell(length(files),1);
tex = cell(length(files),1);
bit = cell(length(files),1);
mi = cell(length(files),1);
deltaRI = cell(length(files),1);
ydate = NaN(length(files),1);
odate = NaN(length(files),1);
nDats = NaN(length(files),1);
%res = NaN(length(files),1);
%GRL paper values
%idx1=3.025;
%idx2=3.264;
%3-4 general
idx1 = 3;
idx2 = 3.5;
%pull out stuff
for i = 1:length(files)
    fileNow = files(i).name;
    T = readtable(fileNow);
    latS(i) = T.Lat(2);
    lonS(i) = T.Lon(2);
    latM(i) = T.Lat(1);
    lonM(i) = T.Lon(1);
    latP1(i) = T.pLat325(2);
    lonP1(i) = T.pLon325(2);
    latP2(i) = T.pLat475(2);
    lonP2(i) = T.pLon475(2);
    depth(i) = T.WaterDepth(2);
    modTEX(i) = T.ProxyValue(1);
    plioTEX(i) = mean(T.ProxyValue(T.Age > idx1 & T.Age < idx2 & T.QualityFlag == 0),'omitnan');
    age{i} = T.Age;
    tex{i} = T.ProxyValue;
    bit{i} = T.BIT;
    mi{i} = T.MI;
    deltaRI{i} = T.deltaRI;
    ydate(i) = min(T.Age(2:end));
    odate(i) = max(T.Age(2:end));
    nDats(i) = length(T.Age(T.Age > idx1 & T.Age < idx2));
end

%% check coretop locations vs sites
sz = 100;
figure(1); clf;
m_proj('robinson'); hold on;
m_coast('patch',[.5 .5 .5]);
m_scatter(lonM,latM,sz,modTEX,'filled');
m_plot(lonS,latS,'marker','o','color','k','markerfacecolor','k','markersize',5,'linestyle','none');
m_grid;
cptcmap('cbacRdYlBu10','flip',true);
colorbar;

%% check anomalies
figure(2); clf;
m_proj('robinson'); hold on;
m_coast('patch',[.5 .5 .5]);
m_scatter(lonS,latS,sz,(plioTEX - modTEX)/.015,'filled');
m_grid;
cptcmap('cbacRdYlBu10','flip',true);
caxis([-5 5]);
colorbar;
%% check paleolocs
sz2 = 20;
figure(3); clf;
m_proj('robinson'); hold on;
m_coast('patch',[.5 .5 .5]);
m_scatter(lonS,latS,sz2,'k','filled');
m_scatter(lonP1,latP1,sz2,[0 .5 1],'filled');
m_scatter(lonP2,latP2,sz2,[.5 .8 1],'filled');
m_grid;
%% check data
sz = 40;
f2=figure(2); clf;
set(f2,'pos',[100 500 1000 200]);
s1 = 1;
s2 = s1+3;
%int = [0 8];
for i = s1:s2
    s3 = i-s1+1;
    subplot(1,4,s3)
    ageNow = age{i};
    texNow = tex{i};
    idx1 = bit{i} > .3;
    idx2 = mi{i} > .3;
    idx3 = deltaRI{i} > .3;
    plot(age{i},tex{i},'color','k','marker','o','markersize',4); hold on;
    scatter(ageNow(idx1),texNow(idx1),sz,'filled','MarkerFaceColor','r');
    scatter(ageNow(idx2),texNow(idx2),sz,'filled','MarkerFaceColor','b');
    scatter(ageNow(idx3),texNow(idx3),sz,'filled','MarkerFaceColor','y');
    int = [min(age{i}) max(age{i})];
    set(gca,'xlim',int);
    xlabel('age Ma');
    ylabel('tex86');
    title(files(i).name);
end

