clf;

xlname='TOP@N';
chart_algorithms = flip(Algos);

xticks = 1:1:length(TOP_N_S);
% xticklabels = strsplit(num2str(TOP_N_S));
xticklabels = ({'1','3','5','10','15','20'});

##figure (1); 
figure_number = 1;
x      = 0;   % Screen position
y      = 0;   % Screen position
width  = 1000; % Width of figure
height = 1500; % Height of figure (by default in pixels)
figure(figure_number, 'Position', [x y width height]);
figure(figure_number,'visible','off')

values_of_exp = flip( BestResults(:,(selected_metric_for_result+2):4:length( BestResults)) );
subplot(2,1,1);
h = bar (values_of_exp', 'FaceColor','flat','BarWidth',.9,'LineWidth',.5);
set (h(9), "facecolor", "r");
set (h(8), "facecolor", "k");
set (h(7), "facecolor", "b");
set (h(6), "facecolor", "g");
set (h(5), "facecolor", [255 165 0]/255);
set (h(4), "facecolor", [155 125 0]/255);
set(gca,'title',dataset_name,'xtick',xticks,'xticklabel',xticklabels, 'fontsize', 10,'xlabel',xlname, 'ylabel',selected_metric);
hold on;

lego = legend(chart_algorithms, 'orientation', 'horizontal', "FontSize", 10, 'position', [ 0 0 .1 .01 ] );
set (lego, "location", "southoutside");
legend boxoff;
ha = axes('Position',[0.1 0.1 1 1],'Xlim',[0 1],'Ylim',[0  1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
hold off;
text(0.4, 0.98, scenario_name);

papersize = [30, 30]/2.54; 
papersize = flip(papersize); 
set (gcf, "paperorientation", "landscape") ;
%set (gcf, "papersize", papersize) ;
%set (gcf, "paperposition", [0.1 0.1, papersize-0.2]) ;
output = sprintf("../results/%s_%d.tiff",dataset, scenario);
print ("-dpng",output);


disp("Chart Drawn");