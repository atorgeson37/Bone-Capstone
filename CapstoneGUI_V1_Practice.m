function varargout = CapstoneGUI_V1_Practice(varargin)
% CAPSTONEGUI_V1_PRACTICE MATLAB code for CapstoneGUI_V1_Practice.fig
%      CAPSTONEGUI_V1_PRACTICE, by itself, creates a new CAPSTONEGUI_V1_PRACTICE or raises the existing
%      singleton*.
%
%      H = CAPSTONEGUI_V1_PRACTICE returns the handle to a new CAPSTONEGUI_V1_PRACTICE or the handle to
%      the existing singleton*.
%
%      CAPSTONEGUI_V1_PRACTICE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CAPSTONEGUI_V1_PRACTICE.M with the given input arguments.
%
%      CAPSTONEGUI_V1_PRACTICE('Property','Value',...) creates a new CAPSTONEGUI_V1_PRACTICE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CapstoneGUI_V1_Practice_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CapstoneGUI_V1_Practice_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CapstoneGUI_V1_Practice

% Last Modified by GUIDE v2.5 06-Dec-2021 15:51:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CapstoneGUI_V1_Practice_OpeningFcn, ...
                   'gui_OutputFcn',  @CapstoneGUI_V1_Practice_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before CapstoneGUI_V1_Practice is made visible.
function CapstoneGUI_V1_Practice_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CapstoneGUI_V1_Practice (see VARARGIN)

% Choose default command line output for CapstoneGUI_V1_Practice
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CapstoneGUI_V1_Practice wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CapstoneGUI_V1_Practice_OutputFcn(hObject, eventdata, handles) 



% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
clear all;
clc;
delete(instrfindall);

global data;
global time;
 
%User Defined Properties 
serialPort = 'COM3';            % define COM port #
plotTitle = 'Data Output';  % plot title
xLabel = 'Elapsed Time [s]';    % x-axis label
yLabel = 'Load [N], Displacement [mm]';                % y-axis label
plotGrid = 'on';                % 'off' to turn off grid
min = 0;                     % set y-min
max = 12;                      % set y-max
scrollWidth = 10;               % display period in plot, plot entire data log if <= 0
delay = .0000001;                    % make sure sample faster than resolution


%Define Function Variables
time = 0;
data = zeros(2,1);
count = 0;



%Set up Plot
plotGraph = plot(time,data(1,:),'-r',...
            'LineWidth',1,...
            'MarkerFaceColor','w',...
            'MarkerSize',2);
hold on
plotGraph1 = plot(time,data(2,:),'-b',...
            'LineWidth',1,...
            'MarkerFaceColor','w',...
            'MarkerSize',2);

title(plotTitle,'FontSize',15);
xlabel(xLabel,'FontSize',12);
ylabel(yLabel,'FontSize',12);
axis([0 10 min max]);
grid(plotGrid);
legend('Load[N]','Displacement [mm]');
%hold off


global a;
a=serial('COM3','BAUD',115200); 
fopen(a);



% --- Executes on button press in pushbutton1.Jog Out
function pushbutton1_Callback(hObject, eventdata, handles)
global a;

c = 200000000 + handles.edit6;
command = c + ">";
fprintf(a, command)

dat = 0;
while 1
    dat = fscanf(a,'%f,%f'); %Read Data from Serial as Float
    if (dat(1:1) == 1000000)
        break
    end
end

fclose(a);
fopen(a);


%stepperMotor1.RPM = 20;
%move(stepperMotor1, 50);
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.Jog In
function pushbutton2_Callback(hObject, eventdata, handles)
global a;
c = 100000000 + handles.edit6;
command = c + ">";
fprintf(a, command)

dat = 0;
while 1
    dat = fscanf(a,'%f,%f'); %Read Data from Serial as Float
    if (dat(1:1) == 1000000)
        break
    end
end

fclose(a);
fopen(a);

% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3. STOP
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fclose(a);
fopen(a);


% --- Executes on button press in pushbutton4. Pre Load
function pushbutton4_Callback(hObject, eventdata, handles)
cla reset;
global a;
c = 300000000 + handles.edit2;
command = c + ">";
fprintf(a, command)

dat = 0;
while 1
    dat = fscanf(a,'%f,%f'); %Read Data from Serial as Float
    if (dat(1:1) == 1000000)
        break
    end
end

fclose(a);
fopen(a);
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton5. Run Experiment
function pushbutton5_Callback(hObject, eventdata, handles)
cla reset;
global a;
global data;
global time;
%User Defined Properties 
plotTitle = 'Data Output';  % plot title
xLabel = 'Elapsed Time [s]';    % x-axis label
yLabel = 'Load [N], Displacement [mm]';                % y-axis label
plotGrid = 'on';                % 'off' to turn off grid
min = -2;                     % set y-min
max = 12;                      % set y-max
scrollWidth = 10;               % display period in plot, plot entire data log if <= 0
delay = .0000001;                    % make sure sample faster than resolution

%Define Function Variables
time = 0;
data = zeros(2,1);
count = 0;


c = 500000000 + handles.edit3 + handles.edit4 + handles.edit5;
command = c + ">";
fprintf(a, command)
dat = 0;
tic
while 1

    dat = fscanf(a,'%f,%f'); %Read Data from Serial as Float

    if (dat(1:1) == 1000000)
        %pause(delay*4)
        break
    end

    if(~isempty(dat) && isfloat(dat)) %Make sure Data Type is Correct        
    count = count + 1;    
    time(count) = toc;    %Extract Elapsed Time in seconds
    data(:,count) = dat(:,1); %Extract 1st Data Element 
    end
end

    
    %Set Axis according to Scroll Width
%     if(scrollWidth > 0)
%     set(plotGraph1,'XData',time(time > time(count)-scrollWidth),...
%         'YData', data(2,time > time(count)-scrollWidth));
%     set(plotGraph,'XData',time(time > time(count)-scrollWidth),...
%         'YData', data(1,time > time(count)-scrollWidth));
% 
%     axis([time(count)-scrollWidth time(count) min max]);
%     else
%     set(plotGraph1,'XData',time,'YData',data(2,:));
%     set(plotGraph2,'XData',time,'YData',data(1,:));
% 
%     axis([0 time(count) min max]);
%     end

    %Allow MATLAB to Update Plot
%    pause(delay);
    for p = 1:count
         data(1,p) = (data(1,p)+24822)/(461.43*98.0665)
         data(2,p) = (data(2,p)/400)
         if (data(1,p) < 0)
             data(1,p) = 0;
         end
    end

%Set up Plot
plotGraph = plot(time,data(1,:),'-r',...
            'LineWidth',1,...
            'MarkerFaceColor','w',...
            'MarkerSize',2);
hold on
plotGraph1 = plot(time,data(2,:),'-b',...
            'LineWidth',1,...
            'MarkerFaceColor','w',...
            'MarkerSize',2);

title(plotTitle,'FontSize',15);
xlabel(xLabel,'FontSize',12);
ylabel(yLabel,'FontSize',12);
axis([0 10 min max]);
grid(plotGrid);
legend('Load[N]','Displacement [mm]');

pause(3);
fclose(a);
fopen(a);
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Gets number for Pre Load Value
function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
num = str2double(get(hObject,'String'));
if isnan(num)
    num = 0;
    set(hObject,'String',num);
    errordlg('Input must be a number', 'Error')
end
handles.edit2 = num*1000000;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties. 
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton7. Calibration
function pushbutton7_Callback(hObject, eventdata, handles)
global a;
fprintf(a, '400000000>')
%pause(10);
fclose(a);
fopen(a);
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Gets number for LOAD VALUE
function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
num = str2double(get(hObject,'String'));
if isnan(num)
    num = 0;
    set(hObject,'String',num);
    errordlg('Input must be a number', 'Error')
end
handles.edit3 = num * 1000000;
guidata(hObject,handles) 

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% Gets number for LOAD RATE VALUE
function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double
num = str2double(get(hObject,'String'));
if isnan(num)
    num = 0;
    set(hObject,'String',num);
    errordlg('Input must be a number', 'Error')
end
handles.edit4 = num*100;
guidata(hObject,handles) 



% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% Gets number for LOAD TIME VALUE
function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double
num = str2double(get(hObject,'String'));
if isnan(num)
    num = 0;
    set(hObject,'String',num);
    errordlg('Input must be a number', 'Error')
end
handles.edit5 = num;
guidata(hObject,handles) 



% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global a;
c = 700000000 + handles.edit6;
command = c + ">";
fprintf(a, command)

dat = 0;
while 1
    dat = fscanf(a,'%f,%f'); %Read Data from Serial as Float
    if (dat(1:1) == 1000000)
        break
    end
end
fclose(a);
fopen(a);

% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global a;
c = 600000000 + handles.edit6;
command = c + ">";
fprintf(a, command)

dat = 0;
while 1
    dat = fscanf(a,'%f,%f'); %Read Data from Serial as Float
    if (dat(1:1) == 1000000)
        break
    end
end
fclose(a);
fopen(a);


function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double
num = str2double(get(hObject,'String'));
if isnan(num)
    num = 0;
    set(hObject,'String',num);
    errordlg('Input must be a number', 'Error')
end
handles.edit6 = num * 100000;
guidata(hObject,handles) 


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global time;
global data;

t = rot90(time,3);
lo = data(1,:);
l = rot90(lo,3);
dis = data(2,:);
d = rot90(dis, 3);

fileName = 'Export_Data.xlsx';
H1 = ["Load Rate" "Cycles " "Time [s]" "Load [N]" "Displacement [mm]"];

writematrix(H1, fileName, 'Range','A2:J2')
%writematrix(loadRate, fileName, 'Range','A3:A4')
%writematrix(c, fileName, 'Range','B3:A4')
writematrix(t, fileName, 'Range','C3:C1000')
writematrix(l, fileName, 'Range','D3:D1000')
writematrix(d, fileName, 'Range','E3:E1000')

winopen('Export_Data.xlsx')



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double
num = str2double(get(hObject,'String'));
if isnan(num)
    num = 0;
    set(hObject,'String',num);
    errordlg('Input must be a number', 'Error')
end
handles.edit7 = num;
guidata(hObject,handles) 

% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
