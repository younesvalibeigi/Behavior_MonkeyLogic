classdef Add_To_AddLayer1913 < nnet.layer.Layer & nnet.layer.Formattable
    % A custom layer auto-generated while importing an ONNX network.

    %#codegen
    %#ok<*PROPLC>
    %#ok<*NBRAK>
    %#ok<*INUSL>
    %#ok<*VARARG>

    properties (Learnable)
    end

    properties
        ONNXParams         % An ONNXParameters object containing parameters used by this layer.
    end

    methods
        function this = Add_To_AddLayer1913(name, onnxParams)
            this.Name = name;
            this.NumInputs = 7;
            this.NumOutputs = 3;
            this.OutputNames = {'x_generator_lay_7', 'x_generator_lay_5', 'x_generator_lay_5NumDims'};
            this.ONNXParams = onnxParams;
        end

        function [x_generator_lay_7, x_generator_lay_5, x_generator_lay_5NumDims] = predict(this, x_generator_laye_924, x_generator_layers_3, x_generator_lay_8, x_generator_lay_15, x_generator_layers_3NumDims, x_generator_lay_8NumDims, x_generator_lay_15NumDims)
            if isdlarray(x_generator_laye_924)
                x_generator_laye_924 = stripdims(x_generator_laye_924);
            end
            if isdlarray(x_generator_layers_3)
                x_generator_layers_3 = stripdims(x_generator_layers_3);
            end
            if isdlarray(x_generator_lay_8)
                x_generator_lay_8 = stripdims(x_generator_lay_8);
            end
            if isdlarray(x_generator_lay_15)
                x_generator_lay_15 = stripdims(x_generator_lay_15);
            end
            x_generator_laye_924NumDims = 4;
            x_generator_layers_3NumDims = numel(x_generator_layers_3NumDims);
            x_generator_lay_8NumDims = numel(x_generator_lay_8NumDims);
            x_generator_lay_15NumDims = numel(x_generator_lay_15NumDims);
            onnxParams = this.ONNXParams;
            [x_generator_lay_7, x_generator_lay_5, x_generator_lay_7NumDims, x_generator_lay_5NumDims] = Add_To_AddFcn(x_generator_laye_924, x_generator_layers_3, x_generator_lay_8, x_generator_lay_15, x_generator_laye_924NumDims, x_generator_layers_3NumDims, x_generator_lay_8NumDims, x_generator_lay_15NumDims, onnxParams, 'Training', false, ...
                'InputDataPermutation', {[4 3 1 2], ['as-is'], ['as-is'], ['as-is'], ['as-is'], ['as-is'], ['as-is'], ['as-is']}, ...
                'OutputDataPermutation', {[3 4 2 1], ['as-is'], ['as-is'], ['as-is']});
            if any(cellfun(@(A)~isnumeric(A) && ~islogical(A), {x_generator_lay_7, x_generator_lay_5}))
                fprintf('Runtime error in network. At least one output of custom layer ''%s'' is a non-numeric, non-logical value.\n', 'Add_To_AddLayer1913');
                error(message('nnet_cnn_onnx:onnx:BadCustomLayerRuntimeOutput', 'Add_To_AddLayer1913'));
            end
            x_generator_lay_7 = dlarray(single(x_generator_lay_7), 'SSCB');
            x_generator_lay_5 = dlarray(single(x_generator_lay_5), repmat('U', 1, max(2, x_generator_lay_5NumDims)));
            x_generator_lay_5NumDims = dlarray(ones(1,x_generator_lay_5NumDims,'like',x_generator_lay_7), 'UU');
            if ~coder.target('MATLAB')
                x_generator_lay_7 = extractdata(x_generator_lay_7);
                x_generator_lay_5 = extractdata(x_generator_lay_5);
                x_generator_lay_5NumDims = extractdata(x_generator_lay_5NumDims);
            end
        end

        function [x_generator_lay_7, x_generator_lay_5, x_generator_lay_5NumDims] = forward(this, x_generator_laye_924, x_generator_layers_3, x_generator_lay_8, x_generator_lay_15, x_generator_layers_3NumDims, x_generator_lay_8NumDims, x_generator_lay_15NumDims)
            if isdlarray(x_generator_laye_924)
                x_generator_laye_924 = stripdims(x_generator_laye_924);
            end
            if isdlarray(x_generator_layers_3)
                x_generator_layers_3 = stripdims(x_generator_layers_3);
            end
            if isdlarray(x_generator_lay_8)
                x_generator_lay_8 = stripdims(x_generator_lay_8);
            end
            if isdlarray(x_generator_lay_15)
                x_generator_lay_15 = stripdims(x_generator_lay_15);
            end
            x_generator_laye_924NumDims = 4;
            x_generator_layers_3NumDims = numel(x_generator_layers_3NumDims);
            x_generator_lay_8NumDims = numel(x_generator_lay_8NumDims);
            x_generator_lay_15NumDims = numel(x_generator_lay_15NumDims);
            onnxParams = this.ONNXParams;
            [x_generator_lay_7, x_generator_lay_5, x_generator_lay_7NumDims, x_generator_lay_5NumDims] = Add_To_AddFcn(x_generator_laye_924, x_generator_layers_3, x_generator_lay_8, x_generator_lay_15, x_generator_laye_924NumDims, x_generator_layers_3NumDims, x_generator_lay_8NumDims, x_generator_lay_15NumDims, onnxParams, 'Training', true, ...
                'InputDataPermutation', {[4 3 1 2], ['as-is'], ['as-is'], ['as-is'], ['as-is'], ['as-is'], ['as-is'], ['as-is']}, ...
                'OutputDataPermutation', {[3 4 2 1], ['as-is'], ['as-is'], ['as-is']});
            if any(cellfun(@(A)~isnumeric(A) && ~islogical(A), {x_generator_lay_7, x_generator_lay_5}))
                fprintf('Runtime error in network. At least one output of custom layer ''%s'' is a non-numeric, non-logical value.\n', 'Add_To_AddLayer1913');
                error(message('nnet_cnn_onnx:onnx:BadCustomLayerRuntimeOutput', 'Add_To_AddLayer1913'));
            end
            x_generator_lay_7 = dlarray(single(x_generator_lay_7), 'SSCB');
            x_generator_lay_5 = dlarray(single(x_generator_lay_5), repmat('U', 1, max(2, x_generator_lay_5NumDims)));
            x_generator_lay_5NumDims = dlarray(ones(1,x_generator_lay_5NumDims,'like',x_generator_lay_7), 'UU');
            if ~coder.target('MATLAB')
                x_generator_lay_7 = extractdata(x_generator_lay_7);
                x_generator_lay_5 = extractdata(x_generator_lay_5);
                x_generator_lay_5NumDims = extractdata(x_generator_lay_5NumDims);
            end
        end
    end
end

function [x_generator_lay_7, x_generator_lay_5, x_generator_lay_7NumDims, x_generator_lay_5NumDims, state] = Add_To_AddFcn(x_generator_laye_924, x_generator_layers_3, x_generator_lay_8, x_generator_lay_15, x_generator_laye_924NumDims, x_generator_layers_3NumDims, x_generator_lay_8NumDims, x_generator_lay_15NumDims, params, varargin)
%ADD_TO_ADDFCN Function implementing an imported ONNX network.
%
% THIS FILE WAS AUTO-GENERATED BY importONNXFunction.
% ONNX Operator Set Version: 11
%
% Variable names in this function are taken from the original ONNX file.
%
% [X_GENERATOR_LAY_7, X_GENERATOR_LAY_5] = Add_To_AddFcn(X_GENERATOR_LAYE_924, X_GENERATOR_LAYERS_3, X_GENERATOR_LAY_8, X_GENERATOR_LAY_15, PARAMS)
%			- Evaluates the imported ONNX network ADD_TO_ADDFCN with input(s)
%			X_GENERATOR_LAYE_924, X_GENERATOR_LAYERS_3, X_GENERATOR_LAY_8, X_GENERATOR_LAY_15 and the imported network parameters in PARAMS. Returns
%			network output(s) in X_GENERATOR_LAY_7, X_GENERATOR_LAY_5.
%
% [X_GENERATOR_LAY_7, X_GENERATOR_LAY_5, STATE] = Add_To_AddFcn(X_GENERATOR_LAYE_924, X_GENERATOR_LAYERS_3, X_GENERATOR_LAY_8, X_GENERATOR_LAY_15, PARAMS)
%			- Additionally returns state variables in STATE. When training,
%			use this form and set TRAINING to true.
%
% [__] = Add_To_AddFcn(X_GENERATOR_LAYE_924, X_GENERATOR_LAYERS_3, X_GENERATOR_LAY_8, X_GENERATOR_LAY_15, PARAMS, 'NAME1', VAL1, 'NAME2', VAL2, ...)
%			- Specifies additional name-value pairs described below:
%
% 'Training'
% 			Boolean indicating whether the network is being evaluated for
%			prediction or training. If TRAINING is true, state variables
%			will be updated.
%
% 'InputDataPermutation'
%			'auto' - Automatically attempt to determine the permutation
%			 between the dimensions of the input data and the dimensions of
%			the ONNX model input. For example, the permutation from HWCN
%			(MATLAB standard) to NCHW (ONNX standard) uses the vector
%			[4 3 1 2]. See the documentation for IMPORTONNXFUNCTION for
%			more information about automatic permutation.
%
%			'none' - Input(s) are passed in the ONNX model format. See 'Inputs'.
%
%			numeric vector - The permutation vector describing the
%			transformation between input data dimensions and the expected
%			ONNX input dimensions.%
%			cell array - If the network has multiple inputs, each cell
%			contains 'auto', 'none', or a numeric vector.
%
% 'OutputDataPermutation'
%			'auto' - Automatically attempt to determine the permutation
%			between the dimensions of the output and a conventional MATLAB
%			dimension ordering. For example, the permutation from NC (ONNX
%			standard) to CN (MATLAB standard) uses the vector [2 1]. See
%			the documentation for IMPORTONNXFUNCTION for more information
%			about automatic permutation.
%
%			'none' - Return output(s) as given by the ONNX model. See 'Outputs'.
%
%			numeric vector - The permutation vector describing the
%			transformation between the ONNX output dimensions and the
%			desired output dimensions.%
%			cell array - If the network has multiple outputs, each cell
%			contains 'auto', 'none' or a numeric vector.
%
% Inputs:
% -------
% X_GENERATOR_LAYE_924, X_GENERATOR_LAYERS_3, X_GENERATOR_LAY_8, X_GENERATOR_LAY_15
%			- Input(s) to the ONNX network.
%			  The input size(s) expected by the ONNX file are:
%				  X_GENERATOR_LAYE_924:		[Unknown, Unknown, Unknown, Unknown]				Type: FLOAT
%				  X_GENERATOR_LAYERS_3:		[1, 1]				Type: FLOAT
%				  X_GENERATOR_LAY_8:		[1, 1]				Type: FLOAT
%				  X_GENERATOR_LAY_15:		[1, 1]				Type: FLOAT
%			  By default, the function will try to permute the input(s)
%			  into this dimension ordering. If the default is incorrect,
%			  use the 'InputDataPermutation' argument to control the
%			  permutation.
%
%
% PARAMS	- Network parameters returned by 'importONNXFunction'.
%
%
% Outputs:
% --------
% X_GENERATOR_LAY_7, X_GENERATOR_LAY_5
%			- Output(s) of the ONNX network.
%			  Without permutation, the size(s) of the outputs are:
%				  X_GENERATOR_LAY_7:		[Unknown, Unknown, Unknown, Unknown]				Type: FLOAT
%				  X_GENERATOR_LAY_5:		[1, 1]				Type: FLOAT
%			  By default, the function will try to permute the output(s)
%			  from this dimension ordering into a conventional MATLAB
%			  ordering. If the default is incorrect, use the
%			  'OutputDataPermutation' argument to control the permutation.
%
% STATE		- (Optional) State variables. When TRAINING is true, these will
% 			  have been updated from the original values in PARAMS.State.
%
%
%  See also importONNXFunction

% Preprocess the input data and arguments:
[x_generator_laye_924, x_generator_layers_3, x_generator_lay_8, x_generator_lay_15, Training, outputDataPerms, anyDlarrayInputs] = preprocessInput(x_generator_laye_924, x_generator_layers_3, x_generator_lay_8, x_generator_lay_15, params, varargin{:});
% Put all variables into a single struct to implement dynamic scoping:
[Vars, NumDims] = packageVariables(params, {'x_generator_laye_924', 'x_generator_layers_3', 'x_generator_lay_8', 'x_generator_lay_15'}, {x_generator_laye_924, x_generator_layers_3, x_generator_lay_8, x_generator_lay_15}, [x_generator_laye_924NumDims x_generator_layers_3NumDims x_generator_lay_8NumDims x_generator_lay_15NumDims]);
% Call the top-level graph function:
[x_generator_lay_7, x_generator_lay_5, x_generator_lay_7NumDims, x_generator_lay_5NumDims, state] = Add_To_AddGraph1906(x_generator_laye_924, x_generator_layers_3, x_generator_lay_8, x_generator_lay_15, NumDims.x_generator_laye_924, NumDims.x_generator_layers_3, NumDims.x_generator_lay_8, NumDims.x_generator_lay_15, Vars, NumDims, Training, params.State);
% Postprocess the output data
[x_generator_lay_7, x_generator_lay_5] = postprocessOutput(x_generator_lay_7, x_generator_lay_5, outputDataPerms, anyDlarrayInputs, Training, varargin{:});
end

function [x_generator_lay_7, x_generator_lay_5, x_generator_lay_7NumDims1911, x_generator_lay_5NumDims1912, state] = Add_To_AddGraph1906(x_generator_laye_924, x_generator_layers_3, x_generator_lay_8, x_generator_lay_15, x_generator_laye_924NumDims1907, x_generator_layers_3NumDims1908, x_generator_lay_8NumDims1909, x_generator_lay_15NumDims1910, Vars, NumDims, Training, state)
% Function implementing the graph 'Add_To_AddGraph1906'
% Update Vars and NumDims from the graph's formal input parameters. Note that state variables are already in Vars.
Vars.x_generator_laye_924 = x_generator_laye_924;
NumDims.x_generator_laye_924 = x_generator_laye_924NumDims1907;
Vars.x_generator_layers_3 = x_generator_layers_3;
NumDims.x_generator_layers_3 = x_generator_layers_3NumDims1908;
Vars.x_generator_lay_8 = x_generator_lay_8;
NumDims.x_generator_lay_8 = x_generator_lay_8NumDims1909;
Vars.x_generator_lay_15 = x_generator_lay_15;
NumDims.x_generator_lay_15 = x_generator_lay_15NumDims1910;

% Execute the operators:
% Add:
Vars.x_generator_layers_4 = Vars.x_generator_laye_924 + Vars.x_generator_layers_3;
NumDims.x_generator_layers_4 = max(NumDims.x_generator_laye_924, NumDims.x_generator_layers_3);

% Sub:
Vars.x_generator_lay_12 = Vars.x_generator_layers_4 - Vars.onnx__Sub_2006;
NumDims.x_generator_lay_12 = max(NumDims.x_generator_layers_4, NumDims.onnx__Sub_2006);

% Div:
Vars.x_generator_lay_10 = Vars.x_generator_lay_12 ./ Vars.onnx__Div_2013;
NumDims.x_generator_lay_10 = max(NumDims.x_generator_lay_12, NumDims.onnx__Div_2013);

% Mul:
Vars.x_generator_lay_11 = Vars.x_generator_lay_10 .* Vars.x_generator_lay_8;
NumDims.x_generator_lay_11 = max(NumDims.x_generator_lay_10, NumDims.x_generator_lay_8);

% Add:
Vars.x_generator_lay_7 = Vars.x_generator_lay_11 + Vars.x_generator_lay_15;
NumDims.x_generator_lay_7 = max(NumDims.x_generator_lay_11, NumDims.x_generator_lay_15);

% Resize:
[DLTScales, DLTSizes, dataFormat, Method, GeometricTransformMode, NearestRoundingMode, NumDims.x_generator_lay_5] = prepareResize11Args(Vars.x_generator_lay_3, Vars.x_generator_lay_2, dlarray([]), "asymmetric", "nearest", "floor", NumDims.x_generator_layers_4);
if isempty(DLTScales)
    Vars.x_generator_lay_5 = dlresize(Vars.x_generator_layers_4, 'OutputSize', DLTSizes, 'DataFormat', dataFormat, 'Method', Method, 'GeometricTransformMode', GeometricTransformMode, 'NearestRoundingMode', NearestRoundingMode);
else
    Vars.x_generator_lay_5 = dlresize(Vars.x_generator_layers_4, 'Scale', DLTScales, 'DataFormat', dataFormat, 'Method', Method, 'GeometricTransformMode', GeometricTransformMode, 'NearestRoundingMode', NearestRoundingMode);
end

% Set graph output arguments from Vars and NumDims:
x_generator_lay_7 = Vars.x_generator_lay_7;
x_generator_lay_7NumDims1911 = NumDims.x_generator_lay_7;
x_generator_lay_5 = Vars.x_generator_lay_5;
x_generator_lay_5NumDims1912 = NumDims.x_generator_lay_5;
% Set output state from Vars:
state = updateStruct(state, Vars);
end

function [inputDataPerms, outputDataPerms, Training] = parseInputs(x_generator_laye_924, x_generator_layers_3, x_generator_lay_8, x_generator_lay_15, numDataOutputs, params, varargin)
% Function to validate inputs to Add_To_AddFcn:
p = inputParser;
isValidArrayInput = @(x)isnumeric(x) || isstring(x);
isValidONNXParameters = @(x)isa(x, 'ONNXParameters');
addRequired(p, 'x_generator_laye_924', isValidArrayInput);
addRequired(p, 'x_generator_layers_3', isValidArrayInput);
addRequired(p, 'x_generator_lay_8', isValidArrayInput);
addRequired(p, 'x_generator_lay_15', isValidArrayInput);
addRequired(p, 'params', isValidONNXParameters);
addParameter(p, 'InputDataPermutation', 'auto');
addParameter(p, 'OutputDataPermutation', 'auto');
addParameter(p, 'Training', false);
parse(p, x_generator_laye_924, x_generator_layers_3, x_generator_lay_8, x_generator_lay_15, params, varargin{:});
inputDataPerms = p.Results.InputDataPermutation;
outputDataPerms = p.Results.OutputDataPermutation;
Training = p.Results.Training;
if isnumeric(inputDataPerms)
    inputDataPerms = {inputDataPerms};
end
if isstring(inputDataPerms) && isscalar(inputDataPerms) || ischar(inputDataPerms)
    inputDataPerms = repmat({inputDataPerms},1,4);
end
if isnumeric(outputDataPerms)
    outputDataPerms = {outputDataPerms};
end
if isstring(outputDataPerms) && isscalar(outputDataPerms) || ischar(outputDataPerms)
    outputDataPerms = repmat({outputDataPerms},1,numDataOutputs);
end
end

function [x_generator_laye_924, x_generator_layers_3, x_generator_lay_8, x_generator_lay_15, Training, outputDataPerms, anyDlarrayInputs] = preprocessInput(x_generator_laye_924, x_generator_layers_3, x_generator_lay_8, x_generator_lay_15, params, varargin)
% Parse input arguments
[inputDataPerms, outputDataPerms, Training] = parseInputs(x_generator_laye_924, x_generator_layers_3, x_generator_lay_8, x_generator_lay_15, 2, params, varargin{:});
anyDlarrayInputs = any(cellfun(@(x)isa(x, 'dlarray'), {x_generator_laye_924, x_generator_layers_3, x_generator_lay_8, x_generator_lay_15}));
% Make the input variables into unlabelled dlarrays:
x_generator_laye_924 = makeUnlabeledDlarray(x_generator_laye_924);
x_generator_layers_3 = makeUnlabeledDlarray(x_generator_layers_3);
x_generator_lay_8 = makeUnlabeledDlarray(x_generator_lay_8);
x_generator_lay_15 = makeUnlabeledDlarray(x_generator_lay_15);
% Permute inputs if requested:
x_generator_laye_924 = permuteInputVar(x_generator_laye_924, inputDataPerms{1}, 4);
x_generator_layers_3 = permuteInputVar(x_generator_layers_3, inputDataPerms{2}, 0);
x_generator_lay_8 = permuteInputVar(x_generator_lay_8, inputDataPerms{3}, 0);
x_generator_lay_15 = permuteInputVar(x_generator_lay_15, inputDataPerms{4}, 0);
end

function [x_generator_lay_7, x_generator_lay_5] = postprocessOutput(x_generator_lay_7, x_generator_lay_5, outputDataPerms, anyDlarrayInputs, Training, varargin)
% Set output type:
if ~anyDlarrayInputs && ~Training
    if isdlarray(x_generator_lay_7)
        x_generator_lay_7 = extractdata(x_generator_lay_7);
    end
    if isdlarray(x_generator_lay_5)
        x_generator_lay_5 = extractdata(x_generator_lay_5);
    end
end
% Permute outputs if requested:
x_generator_lay_7 = permuteOutputVar(x_generator_lay_7, outputDataPerms{1}, 4);
end


%% dlarray functions implementing ONNX operators:

function [DLTScales, DLTSizes, dataFormat, Method, GeometricTransformMode, NearestRoundingMode, numDimsY] = prepareResize11Args(...
    ONNXRoi, ONNXScales, ONNXSizes, coordinate_transformation_mode, mode, nearest_mode, numDimsX)
% Prepares arguments for implementing the ONNX Resize-11 operator

%   Copyright 2020-2024 The MathWorks, Inc.

% ONNXScales and ONNXSizes are in ONNX dimension ordering. ONNXRoi is
% ignored because it only takes effect when coordinate_transformation_mode
% is "tf_crop_and_resize", which is not supported.
DLTScales = flip(extractdata(ONNXScales(:)'));
DLTSizes = flip(extractdata(ONNXSizes(:)'));
switch coordinate_transformation_mode
    case "half_pixel"
        GeometricTransformMode = "half-pixel";
    case "asymmetric"
        GeometricTransformMode = "asymmetric";
    otherwise
        assert(false);
end
switch mode
    case "nearest"
        Method = "nearest";
    case "linear"
        Method = "linear";
    otherwise
        assert(false);
end
switch nearest_mode
    case "floor"
        NearestRoundingMode = "floor";
    otherwise
        NearestRoundingMode = "round";
end
dataFormat = repmat('S', [1 numDimsX]);
numDimsY = numDimsX;
end

%% Utility functions:

function s = appendStructs(varargin)
% s = appendStructs(s1, s2,...). Assign all fields in s1, s2,... into s.

%   Copyright 2020 The MathWorks, Inc.

if isempty(varargin)
    s = struct;
else
    s = varargin{1};
    for i = 2:numel(varargin)
        fromstr = varargin{i};
        fs = fieldnames(fromstr);
        for j = 1:numel(fs)
            s.(fs{j}) = fromstr.(fs{j});
        end
    end
end
end

function checkInputSize(inputShape, expectedShape, inputName)

%   Copyright 2020-2021 The MathWorks, Inc.

if numel(expectedShape)==0
    % The input is a scalar
    if ~isequal(inputShape, [1 1])
        inputSizeStr = makeSizeString(inputShape);
        error(message('nnet_cnn_onnx:onnx:InputNeedsResize',inputName, "[1,1]", inputSizeStr));
    end
elseif numel(expectedShape)==1
    % The input is a vector
    if ~shapeIsColumnVector(inputShape) || ~iSizesMatch({inputShape(1)}, expectedShape)
        expectedShape{2} = 1;
        expectedSizeStr = makeSizeString(expectedShape);
        inputSizeStr = makeSizeString(inputShape);
        error(message('nnet_cnn_onnx:onnx:InputNeedsResize',inputName, expectedSizeStr, inputSizeStr));
    end
else
    % The input has 2 dimensions or more

    % The input dimensions have been reversed; flip them back to compare to the
    % expected ONNX shape.
    inputShape = fliplr(inputShape);

    % If the expected shape has fewer dims than the input shape, error.
    if numel(expectedShape) < numel(inputShape)
        expectedSizeStr = strjoin(["[", strjoin(string(expectedShape), ","), "]"], "");
        error(message('nnet_cnn_onnx:onnx:InputHasGreaterNDims', inputName, expectedSizeStr));
    end

    % Prepad the input shape with trailing ones up to the number of elements in
    % expectedShape
    inputShape = num2cell([ones(1, numel(expectedShape) - length(inputShape)) inputShape]);

    % Find the number of variable size dimensions in the expected shape
    numVariableInputs = sum(cellfun(@(x) isa(x, 'char') || isa(x, 'string'), expectedShape));

    % Find the number of input dimensions that are not in the expected shape
    % and cannot be represented by a variable dimension
    nonMatchingInputDims = setdiff(string(inputShape), string(expectedShape));
    numNonMatchingInputDims  = numel(nonMatchingInputDims) - numVariableInputs;

    expectedSizeStr = makeSizeString(expectedShape);
    inputSizeStr = makeSizeString(inputShape);
    if numNonMatchingInputDims == 0 && ~iSizesMatch(inputShape, expectedShape)
        % The actual and expected input dimensions match, but in
        % a different order. The input needs to be permuted.
        error(message('nnet_cnn_onnx:onnx:InputNeedsPermute',inputName, expectedSizeStr, inputSizeStr));
    elseif numNonMatchingInputDims > 0
        % The actual and expected input sizes do not match.
        error(message('nnet_cnn_onnx:onnx:InputNeedsResize',inputName, expectedSizeStr, inputSizeStr));
    end
end
end

function doesMatch = iSizesMatch(inputShape, expectedShape)
% Check whether the input and expected shapes match, in order.
% Size elements match if (1) the elements are equal, or (2) the expected
% size element is a variable (represented by a character vector or string)
doesMatch = true;
for i=1:numel(inputShape)
    if ~(isequal(inputShape{i},expectedShape{i}) || ischar(expectedShape{i}) || isstring(expectedShape{i}))
        doesMatch = false;
        return
    end
end
end

function sizeStr = makeSizeString(shape)
sizeStr = strjoin(["[", strjoin(string(shape), ","), "]"], "");
end

function isVec = shapeIsColumnVector(shape)
if numel(shape) == 2 && shape(2) == 1
    isVec = true;
else
    isVec = false;
end
end
function X = makeUnlabeledDlarray(X)
% Make numeric X into an unlabelled dlarray

%   Copyright 2020-2021 The MathWorks, Inc.

if isa(X, 'dlarray')
    X = stripdims(X);
elseif isnumeric(X)
    if isinteger(X)
        % Make ints double so they can combine with anything without
        % reducing precision
        X = double(X);
    end
    X = dlarray(X);
end
end

function [Vars, NumDims] = packageVariables(params, inputNames, inputValues, inputNumDims)

%   Copyright 2020 The MathWorks, Inc.

% inputNames, inputValues are cell arrays. inputRanks is a numeric vector.
Vars = appendStructs(params.Learnables, params.Nonlearnables, params.State);
NumDims = params.NumDimensions;
% Add graph inputs
for i = 1:numel(inputNames)
    Vars.(inputNames{i}) = inputValues{i};
    NumDims.(inputNames{i}) = inputNumDims(i);
end
end

function X = permuteInputVar(X, userDataPerm, onnxNDims)

%   Copyright 2020-2021 The MathWorks, Inc.
% Returns reverse-ONNX ordering
if onnxNDims == 0
    return;
elseif onnxNDims == 1 && isvector(X)
    X = X(:);
    return;
elseif isnumeric(userDataPerm)
    % Permute into reverse ONNX ordering
    if numel(userDataPerm) ~= onnxNDims
        error(message('nnet_cnn_onnx:onnx:InputPermutationSize', numel(userDataPerm), onnxNDims));
    end
    perm = fliplr(userDataPerm);
elseif isequal(userDataPerm, 'auto') && onnxNDims == 4
    % Permute MATLAB HWCN to reverse onnx (WHCN)
    perm = [2 1 3 4];
elseif isequal(userDataPerm, 'as-is')
    % Do not permute the input
    perm = 1:ndims(X);
else
    % userDataPerm is either 'none' or 'auto' with no default, which means
    % it's already in onnx ordering, so just make it reverse onnx
    perm = max(2,onnxNDims):-1:1;
end
X = permute(X, perm);
end

function Y = permuteOutputVar(Y, userDataPerm, onnxNDims)

%   Copyright 2020-2021 The MathWorks, Inc.
switch onnxNDims
    case 0
        perm = [];
    case 1
        if isnumeric(userDataPerm)
            % Use the user's permutation because Y is a column vector which
            % already matches ONNX.
            perm = userDataPerm;
        elseif isequal(userDataPerm, 'auto')
            % Treat the 1D onnx vector as a 2D column and transpose it
            perm = [2 1];
        else
            % userDataPerm is 'none'. Leave Y alone because it already
            % matches onnx.
            perm = [];
        end
    otherwise
        % ndims >= 2
        if isnumeric(userDataPerm)
            % Use the inverse of the user's permutation. This is not just the
            % flip of the permutation vector.
            perm = onnxNDims + 1 - userDataPerm;
        elseif isequal(userDataPerm, 'auto')
            if onnxNDims == 2
                % Permute reverse ONNX CN to DLT CN (do nothing)
                perm = [];
            elseif onnxNDims == 4
                % Permute reverse onnx (WHCN) to MATLAB HWCN
                perm = [2 1 3 4];
            else
                % User wants the output in ONNX ordering, so just reverse it from
                % reverse onnx
                perm = onnxNDims:-1:1;
            end
        elseif isequal(userDataPerm, 'as-is')
            % Do not permute the input
            perm = 1:ndims(Y);
        else
            % userDataPerm is 'none', so just make it reverse onnx
            perm = onnxNDims:-1:1;
        end
end
if ~isempty(perm)
    Y = permute(Y, perm);
end
end

function s = updateStruct(s, t)
% Set all existing fields in s from fields in t, ignoring extra fields in
% t.
%   Copyright 2020 The MathWorks, Inc.

for name = transpose(fieldnames(s))
    s.(name{1}) = t.(name{1});
end
end
