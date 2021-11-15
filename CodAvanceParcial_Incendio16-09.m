%%http://mres.uni-potsdam.de/index.php/2018/06/11/calculating-ndvi-maps-from-sentinel-2-data-with-matlab/

clear, clc, close all
%% Cargamos la banda roja e infraroja de ambas fechas

filename1 = '2021-09-01\T18LZL_20210901T145731_B04.jp2';
filename2 = '2021-09-01\T18LZL_20210901T145731_B08.jp2';
filename3 = '2021-09-26\T18LZL_20210926T145729_B04.jp2'; 
filename4 = '2021-09-26\T18LZL_20210926T145729_B08.jp2';
B04_22 = imread(filename1);
B08_22 = imread(filename2);
B04_29 = imread(filename3);
B08_29 = imread(filename4);

%% Recortamos la imagen al área de interés

clip = [8500 9500 6500 7500];
B04_22 = B04_22(8500:9500,6500:7500);
B08_22 = B08_22(clip(1):clip(2),clip(3):clip(4));
B04_29 = B04_29(clip(1):clip(2),clip(3):clip(4));
B08_29 = B08_29(clip(1):clip(2),clip(3):clip(4));

%% convert the  uint16 data to single precision for calculations.

B04_22 = single(B04_22);
B08_22 = single(B08_22);
B04_29 = single(B04_29);
B08_29 = single(B08_29);

%% Percentiles solo para fines del display

B04_22_05 = prctile(reshape(B04_22,1,numel(B04_22)), 5);
B04_22_95 = prctile(reshape(B04_22,1,numel(B04_22)),95);
B08_22_05 = prctile(reshape(B08_22,1,numel(B08_22)), 5);
B08_22_95 = prctile(reshape(B08_22,1,numel(B08_22)),95);
B04_29_05 = prctile(reshape(B04_29,1,numel(B04_29)), 5);
B04_29_95 = prctile(reshape(B04_29,1,numel(B04_29)),95);
B08_29_05 = prctile(reshape(B08_29,1,numel(B08_29)), 5);
B08_29_95 = prctile(reshape(B08_29,1,numel(B08_29)),95);

%% Calculamos el NDVI

NDVI_22 = (B08_22-B04_22)./(B08_22+B04_22);
NDVI_29 = (B08_29-B04_29)./(B08_29+B04_29);

%% Mostramos las bandas de rojo, infrarojo y el NDVI para la primera fecha 

figure('Position',[100 100 1400 400])
A1 = axes('Position',[0.025 0.1 0.4 0.8]);
imagesc(B04_22,[B04_22_05 B04_22_95])
title('Canal R')
colormap(A1,'Gray'), colorbar
set(gca,'FontSize',14)
axis square tight, axis off
A2 = axes('Position',[0.325 0.1 0.4 0.8]);
imagesc(B08_22,[B08_22_05 B08_22_95])
title('Canal NIR')
colormap(A2,'Gray'), colorbar
set(gca,'FontSize',14)
axis square tight, axis off
A3 = axes('Position',[0.625 0.1 0.4 0.8]);
imagesc(NDVI_22,[0 1])
title('NDVI 01 Sept 2021')
colormap(A3,'Jet'), colorbar
set(gca,'FontSize',14)
axis square tight, axis off

print -dpng -r300 sentinel1_ndiv_1_vs1.png

%% Ahora el grafico comparativo de ambas fechas y calculamos las diferencias

DNDVI = NDVI_22 - NDVI_29;
figure('Position',[100 800 1400 400])
A3 = axes('Position',[0.025 0.1 0.4 0.8]);
imagesc(NDVI_22,[0 1])
title('NDVI 01 Sept 2021')
colorbar, set(gca,'FontSize',14)
colormap(A3,jet)
axis square tight, axis off
A4 = axes('Position',[0.325 0.1 0.4 0.8]);
imagesc(NDVI_29,[0 1])
title('NDVI 22 Sept 2021')
colorbar, set(gca,'FontSize',14)
colormap(A4,jet)
axis square tight, axis off
A5 = axes('Position',[0.625 0.1 0.4 0.8]);
imagesc(DNDVI,[-0.2 0.2])
title('Difference NDVI 01 - 22 Sept 2021')
colormap(A5,'Jet'), colorbar
set(gca,'FontSize',14)
axis square tight, axis off

print -dpng -r300 sentinel1_ndiv_2_vs1.png


%% Vegetation percentange:
threshold = 0.1; 
im_mask_Vegetation = NDVI_22 > threshold;
im_mask_Vegetation2 = NDVI_29 > threshold;

vegetation_percent = 100 * numel(NDVI_22(im_mask_Vegetation(:))) / numel(NDVI_22);
vegetation_percent2 = 100 * numel(NDVI_29(im_mask_Vegetation2(:))) / numel(NDVI_29);

figure,
subplot(1,2,1),imshow(im_mask_Vegetation,[]), title(['Vegetation percentange 01 Sept: ' ,  num2str(vegetation_percent)]);
subplot(1,2,2),imshow(im_mask_Vegetation2,[]), title(['Vegetation percentange 22 Sept:  ' , num2str(vegetation_percent2)]);


