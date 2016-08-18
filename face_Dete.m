

%�����ϲ��ú�������ʾ������ʽ�������߼������������ʵ�ʲ��Է��֣������ú������õķ���
%��������Ч�ʽ����ؽ��ͣ�ԭ���Ǵ�����ѭ���ܶ࣬��ÿ��ѭ�������к������ã���ռ�ô���ʱ��

%������Ϊ��ͨ��ѭ������ÿ�����ص���д�����ʵ����һ���÷�������ͼƬ�ܴ�ʱ������ѭ���ķ�ʽ��������Ч�ʽ�����Ӱ��
%�����ϲ�����������ķ�ʽ�����ѭ���ķ�ʽ������������Ч�ʣ����Ǻ��ź����ҵĻ�����������Ĵ���û��д�ɹ������Բ��ò�����ѭ���ķ�ʽ

clc
clear all;
close all;

%%һЩ����ֵ
Wcb     =   46.97;
Wcr     =   38.76;
WLcb    =   23;
WHcb    =   14;
WLcr    =   20;
WHcr    =   10;
Kl      =   125;%125;
Kh      =   255;%���Է��֣�������255����188Ч���ã�������255
Ymin    =   70;%���Է��֣�������70����16Ч���ã�����ѡ��70
Ymax    =   235;%235;

Cx      =   109.38;
Cy      =   152.02;
thera   =   2.53;
ECx     =   1.60;
ECy     =   2.41;
a       =   25.39;
b       =   14.03;

%%first----->����ͼƬ�����пռ�ת��
%Image       =   imread('5.jpg');                %����ͼƬ
%figure(1);                                      %��ʾԭͼ
%imshow(Image);
obj=videoinput('winvideo',1,'YUY2_320x240')
h1=preview(obj);
h2=figure(2);
while ishandle(h1)&&ishandle(h2)
    Image=getsnapshot(obj);
    Image=ycbcr2rgb(Image);
   
Image       =   rgb2ycbcr(Image);               %��ɫ�ռ�ת��
Image       =   double(Image);                  %����ת��

Y           =   Image(:,:,1);                   %ȡ��YCbCr��ֵ
Cb          =   Image(:,:,2);
Cr          =   Image(:,:,3);

%%second----->һЩ׼������
[width,heigth,~]    =   size(Image);            %ȡ������

Center_B_Kh         =   108;
Center_R_Kh         =   154;

deteMatrix          =   zeros(width,heigth);             %��������������ľ���

%%thred------>CbCrת����Cb'Cr',��������Բ�����ж�
for i=1:width                                  
    for j=1:heigth
        
            % ����������Ĺ�ʽ���õ��µ�CbCr
            if( Y(i,j) < Kl )
                
                 CenterB        =   108+( Kl-Y(i,j) ) * (118-108)/(Kl-Ymin);            %��ʽ��7��   
                 CenterR        =   154-( Kl-Y(i,j) ) * (154-144)/(Kl-Ymin);
                 
                 W_Cb           =   WLcb+( Y(i,j)-Ymin ) * (Wcb-WLcb)/(Kl-Ymin);        %��ʽ��6��
                 W_Cr           =   WLcr+( Y(i,j)-Ymin ) * (Wcr-WLcr)/(Kl-Ymin);
                 
                 new_Cb         =   ( Cb(i,j)-CenterB ) * Wcb / W_Cb + Center_B_Kh;     %���Է��֣�������CenterB����Center_B_KhЧ����
                 new_Cr         =   ( Cr(i,j)-CenterR ) * Wcr / W_Cr + Center_R_Kh;     %��ʽ��5��
                
            else if( Y(i,j) > Kh )
                    
                 CenterB        =   108+( Y(i,j)-Kh ) * (118-108)/(Ymax - Kh);      
                 CenterR        =   154-( Y(i,j)-Kh ) * (154-132)/(Ymax - Kh);
                 
                 W_Cb           =   WHcb+( Ymax-Y(i,j) ) * (Wcb-WHcb)/(Ymax - Kh);
                 W_Cr           =   WHcr+( Ymax-Y(i,j) ) * (Wcr-WHcr)/(Ymax - Kh);
                 
                 new_Cb         =   ( Cb(i,j)-CenterB ) * Wcb / W_Cb + Center_B_Kh;
                 new_Cr         =   ( Cr(i,j)-CenterR ) * Wcr / W_Cr + Center_R_Kh;
                    
                else
                    
                    new_Cb      =   Cb(i,j);
                    new_Cr      =   Cr(i,j);
                    
                end
              
            end
            
            %������Բģ�ͽ����ж�
            temp = [cos(thera) sin(thera);-sin(thera) cos(thera)]*[new_Cb-Cx,new_Cr-Cy]';   %���x��y
            x    = temp(1);
            y    = temp(2);
            
            ellipse=(x-ECx).^2/a.^2 + (y-ECy).^2/b.^2;                                      %�ж�������Բ�ڻ�����Բ��
            
            if(ellipse >1)
                deteMatrix(i,j) = 0;
            else
                deteMatrix(i,j) = 1;
            end
            
    end
end

% se           =   strel('disk',2);                          %��ʴ����
% deteMatrix   =   imdilate(deteMatrix,se);
figure(2);
imshow(deteMatrix);
    drawnow;
end
clear all;