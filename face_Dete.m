

%理论上采用函数来表示各个公式，代码逻辑会更清晰，但实际测试发现，若采用函数调用的方法
%代码运行效率将严重降低，原因是代码中循环很多，若每次循环都进行函数调用，将占用大量时间

%个人认为，通过循环来对每个像素点进行处理，着实不是一个好方法，若图片很大时，采用循环的方式，其运行效率将很受影响
%理论上采用数组运算的方式相对于循环的方式将大大提高运行效率，但是很遗憾，我的基于数组运算的代码没有写成功，所以不得不采用循环的方式

clc
clear all;
close all;

%%一些衡量值
Wcb     =   46.97;
Wcr     =   38.76;
WLcb    =   23;
WHcb    =   14;
WLcr    =   20;
WHcr    =   10;
Kl      =   125;%125;
Kh      =   255;%测试发现，这里用255比用188效果好，这里用255
Ymin    =   70;%测试发现，这里用70比用16效果好，这里选择70
Ymax    =   235;%235;

Cx      =   109.38;
Cy      =   152.02;
thera   =   2.53;
ECx     =   1.60;
ECy     =   2.41;
a       =   25.39;
b       =   14.03;

%%first----->读入图片并进行空间转换
%Image       =   imread('5.jpg');                %读入图片
%figure(1);                                      %显示原图
%imshow(Image);
obj=videoinput('winvideo',1,'YUY2_320x240')
h1=preview(obj);
h2=figure(2);
while ishandle(h1)&&ishandle(h2)
    Image=getsnapshot(obj);
    Image=ycbcr2rgb(Image);
   
Image       =   rgb2ycbcr(Image);               %颜色空间转换
Image       =   double(Image);                  %类型转换

Y           =   Image(:,:,1);                   %取出YCbCr的值
Cb          =   Image(:,:,2);
Cr          =   Image(:,:,3);

%%second----->一些准备条件
[width,heigth,~]    =   size(Image);            %取出长宽

Center_B_Kh         =   108;
Center_R_Kh         =   154;

deteMatrix          =   zeros(width,heigth);             %用来保存最后结果的矩阵

%%thred------>CbCr转换成Cb'Cr',并利用椭圆进行判断
for i=1:width                                  
    for j=1:heigth
        
            % 套用论文里的公式，得到新的CbCr
            if( Y(i,j) < Kl )
                
                 CenterB        =   108+( Kl-Y(i,j) ) * (118-108)/(Kl-Ymin);            %公式（7）   
                 CenterR        =   154-( Kl-Y(i,j) ) * (154-144)/(Kl-Ymin);
                 
                 W_Cb           =   WLcb+( Y(i,j)-Ymin ) * (Wcb-WLcb)/(Kl-Ymin);        %公式（6）
                 W_Cr           =   WLcr+( Y(i,j)-Ymin ) * (Wcr-WLcr)/(Kl-Ymin);
                 
                 new_Cb         =   ( Cb(i,j)-CenterB ) * Wcb / W_Cb + Center_B_Kh;     %测试发现，这里用CenterB比用Center_B_Kh效果好
                 new_Cr         =   ( Cr(i,j)-CenterR ) * Wcr / W_Cr + Center_R_Kh;     %公式（5）
                
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
            
            %利用椭圆模型进行判断
            temp = [cos(thera) sin(thera);-sin(thera) cos(thera)]*[new_Cb-Cx,new_Cr-Cy]';   %求出x和y
            x    = temp(1);
            y    = temp(2);
            
            ellipse=(x-ECx).^2/a.^2 + (y-ECy).^2/b.^2;                                      %判断是在椭圆内还是椭圆外
            
            if(ellipse >1)
                deteMatrix(i,j) = 0;
            else
                deteMatrix(i,j) = 1;
            end
            
    end
end

% se           =   strel('disk',2);                          %腐蚀膨胀
% deteMatrix   =   imdilate(deteMatrix,se);
figure(2);
imshow(deteMatrix);
    drawnow;
end
clear all;