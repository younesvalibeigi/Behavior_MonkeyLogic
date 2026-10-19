classdef MatMul_To_AddLayer1873 < nnet.layer.Layer & nnet.layer.Formattable
    % A custom layer auto-generated while importing an ONNX network.

    %#codegen
    %#ok<*PROPLC>
    %#ok<*NBRAK>
    %#ok<*INUSL>
    %#ok<*VARARG>

    properties (Learnable)
        generator_gen_z_bias
        generator_gen_z_weig
        onnx__MatMul_1762
        onnx__MatMul_1763
    end

    properties
        ONNXParams         % An ONNXParameters object containing parameters used by this layer.
    end

    methods
        function this = MatMul_To_AddLayer1873(name, onnxParams)
            this.Name = name;
            this.NumInputs = 2;
            this.NumOutputs = 3;
            this.OutputNames = {'x_generator_laye_1', 'x_generator_Transpos', 'x_generator_TransposNumDims'};
            this.ONNXParams = onnxParams;
            this.generator_gen_z_bias = onnxParams.Learnables.generator_gen_z_bias;
            this.generator_gen_z_weig = onnxParams.Learnables.generator_gen_z_weig;
            this.onnx__MatMul_1762 = onnxParams.Learnables.onnx__MatMul_1762;
            this.onnx__MatMul_1763 = onnxParams.Learnables.onnx__MatMul_1763;
        end

        function [x_generator_laye_1, x_generator_Transpos, x_generator_TransposNumDims] = predict(this, z256, z256NumDims)
            if isdlarray(z256)
                z256 = stripdims(z256);
            end
            z256NumDims = numel(z256NumDims);
            onnxParams = this.ONNXParams;
            onnxParams.Learnables.generator_gen_z_bias = this.generator_gen_z_bias;
            onnxParams.Learnables.generator_gen_z_weig = this.generator_gen_z_weig;
            onnxParams.Learnables.onnx__MatMul_1762 = this.onnx__MatMul_1762;
            onnxParams.Learnables.onnx__MatMul_1763 = this.onnx__MatMul_1763;
            [x_generator_laye_1, x_generator_Transpos, x_generator_laye_1NumDims, x_generator_TransposNumDims] = MatMul_To_AddFcn(z256, z256NumDims, onnxParams, 'Training', false, ...
                'InputDataPermutation', {['as-is'], ['as-is']}, ...
                'OutputDataPermutation', {[3 4 2 1], ['as-is'], ['as-is'], ['as-is']});
            if any(cellfun(@(A)~isnumeric(A) && ~islogical(A), {x_generator_laye_1, x_generator_Transpos}))
                fprintf('Runtime error in network. At least one output of custom layer ''%s'' is a non-numeric, non-logical value.\n', 'MatMul_To_AddLayer1873');
                error(message('nnet_cnn_onnx:onnx:BadCustomLayerRuntimeOutput', 'MatMul_To_AddLayer1873'));
            end
            x_generator_laye_1 = dlarray(single(x_generator_laye_1), 'SSCB');
            x_generator_Transpos = dlarray(single(x_generator_Transpos), repmat('U', 1, max(2, x_generator_TransposNumDims)));
            x_generator_TransposNumDims = dlarray(ones(1,x_generator_TransposNumDims,'like',x_generator_laye_1), 'UU');
            if ~coder.target('MATLAB')
                x_generator_laye_1 = extractdata(x_generator_laye_1);
                x_generator_Transpos = extractdata(x_generator_Transpos);
                x_generator_TransposNumDims = extractdata(x_generator_TransposNumDims);
            end
        end

        function [x_generator_laye_1, x_generator_Transpos, x_generator_TransposNumDims] = forward(this, z256, z256NumDims)
            if isdlarray(z256)
                z256 = stripdims(z256);
            end
            z256NumDims = numel(z256NumDims);
            onnxParams = this.ONNXParams;
            onnxParams.Learnables.generator_gen_z_bias = this.generator_gen_z_bias;
            onnxParams.Learnables.generator_gen_z_weig = this.generator_gen_z_weig;
            onnxParams.Learnables.onnx__MatMul_1762 = this.onnx__MatMul_1762;
            onnxParams.Learnables.onnx__MatMul_1763 = this.onnx__MatMul_1763;
            [x_generator_laye_1, x_generator_Transpos, x_generator_laye_1NumDims, x_generator_TransposNumDims] = MatMul_To_AddFcn(z256, z256NumDims, onnxParams, 'Training', true, ...
                'InputDataPermutation', {['as-is'], ['as-is']}, ...
                'OutputDataPermutation', {[3 4 2 1], ['as-is'], ['as-is'], ['as-is']});
            if any(cellfun(@(A)~isnumeric(A) && ~islogical(A), {x_generator_laye_1, x_generator_Transpos}))
                fprintf('Runtime error in network. At least one output of custom layer ''%s'' is a non-numeric, non-logical value.\n', 'MatMul_To_AddLayer1873');
                error(message('nnet_cnn_onnx:onnx:BadCustomLayerRuntimeOutput', 'MatMul_To_AddLayer1873'));
            end
            x_generator_laye_1 = dlarray(single(x_generator_laye_1), 'SSCB');
            x_generator_Transpos = dlarray(single(x_generator_Transpos), repmat('U', 1, max(2, x_generator_TransposNumDims)));
            x_generator_TransposNumDims = dlarray(ones(1,x_generator_TransposNumDims,'like',x_generator_laye_1), 'UU');
            if ~coder.target('MATLAB')
                x_generator_laye_1 = extractdata(x_generator_laye_1);
                x_generator_Transpos = extractdata(x_generator_Transpos);
                x_generator_TransposNumDims = extractdata(x_generator_TransposNumDims);
            end
        end
    end
end

function [x_generator_laye_1, x_generator_Transpos, x_generator_laye_1NumDims, x_generator_TransposNumDims, state] = MatMul_To_AddFcn(z256, z256NumDims, params, varargin)
%MATMUL_TO_ADDFCN Function implementing an imported ONNX network.
%
% THIS FILE WAS AUTO-GENERATED BY importONNXFunction.
% ONNX Operator Set Version: 11
%
% Variable names in this function are taken from the original ONNX file.
%
% [X_GENERATOR_LAYE_1, X_GENERATOR_TRANSPOS] = MatMul_To_AddFcn(Z256, PARAMS)
%			- Evaluates the imported ONNX network MATMUL_TO_ADDFCN with input(s)
%			Z256 and the imported network parameters in PARAMS. Returns
%			network output(s) in X_GENERATOR_LAYE_1, X_GENERATOR_TRANSPOS.
%
% [X_GENERATOR_LAYE_1, X_GENERATOR_TRANSPOS, STATE] = MatMul_To_AddFcn(Z256, PARAMS)
%			- Additionally returns state variables in STATE. When training,
%			use this form and set TRAINING to true.
%
% [__] = MatMul_To_AddFcn(Z256, PARAMS, 'NAME1', VAL1, 'NAME2', VAL2, ...)
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
% Z256
%			- Input(s) to the ONNX network.
%			  The input size(s) expected by the ONNX file are:
%				  Z256:		[1, 256]				Type: FLOAT
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
% X_GENERATOR_LAYE_1, X_GENERATOR_TRANSPOS
%			- Output(s) of the ONNX network.
%			  Without permutation, the size(s) of the outputs are:
%				  X_GENERATOR_LAYE_1:		[Unknown, Unknown, Unknown, Unknown]				Type: FLOAT
%				  X_GENERATOR_TRANSPOS:		[1, 1]				Type: FLOAT
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
[z256, Training, outputDataPerms, anyDlarrayInputs] = preprocessInput(z256, params, varargin{:});
% Put all variables into a single struct to implement dynamic scoping:
[Vars, NumDims] = packageVariables(params, {'z256'}, {z256}, [z256NumDims]);
% Call the top-level graph function:
[x_generator_laye_1, x_generator_Transpos, x_generator_laye_1NumDims, x_generator_TransposNumDims, state] = MatMul_To_AddGraph1862(z256, NumDims.z256, Vars, NumDims, Training, params.State);
% Postprocess the output data
[x_generator_laye_1, x_generator_Transpos] = postprocessOutput(x_generator_laye_1, x_generator_Transpos, outputDataPerms, anyDlarrayInputs, Training, varargin{:});
end

function [x_generator_laye_1, x_generator_Transpos, x_generator_laye_1NumDims1871, x_generator_TransposNumDims1872, state] = MatMul_To_AddGraph1862(z256, z256NumDims1870, Vars, NumDims, Training, state)
% Function implementing the graph 'MatMul_To_AddGraph1862'
% Update Vars and NumDims from the graph's formal input parameters. Note that state variables are already in Vars.
Vars.z256 = z256;
NumDims.z256 = z256NumDims1870;

% Execute the operators:
% Gemm:
[A, B, C, alpha, beta, NumDims.x_generator_gen_z_Ge] = prepareGemmArgs(Vars.z256, Vars.generator_gen_z_weig, Vars.generator_gen_z_bias, Vars.Gemmalpha1863, Vars.Gemmbeta1864, 0, 1, NumDims.generator_gen_z_bias);
Vars.x_generator_gen_z_Ge = alpha*B*A + beta*C;

% Reshape:
[shape, NumDims.x_generator_Reshape_] = prepareReshapeArgs(Vars.x_generator_gen_z_Ge, Vars.x_generator_Consta_4, NumDims.x_generator_gen_z_Ge, 0);
Vars.x_generator_Reshape_ = reshape(Vars.x_generator_gen_z_Ge, shape{:});

% Transpose:
[perm, NumDims.x_generator_Transpos] = prepareTransposeArgs(Vars.TransposePerm1865, NumDims.x_generator_Reshape_);
if ~isempty(perm)
    Vars.x_generator_Transpos = permute(Vars.x_generator_Reshape_, perm);
end

% MatMul:
[Vars.x_generator_laye_12, NumDims.x_generator_laye_12] = onnxMatMul(Vars.z256, Vars.onnx__MatMul_1762, NumDims.z256, NumDims.onnx__MatMul_1762);

% Unsqueeze:
[shape, NumDims.x_generator_laye_10] = prepareUnsqueezeArgs(Vars.x_generator_laye_12, Vars.UnsqueezeAxes1866, NumDims.x_generator_laye_12);
Vars.x_generator_laye_10 = reshape(Vars.x_generator_laye_12, shape);

% Unsqueeze:
[shape, NumDims.x_generator_laye_7] = prepareUnsqueezeArgs(Vars.x_generator_laye_10, Vars.UnsqueezeAxes1867, NumDims.x_generator_laye_10);
Vars.x_generator_laye_7 = reshape(Vars.x_generator_laye_10, shape);

% Add:
Vars.x_generator_laye_2 = Vars.x_generator_laye_7 + Vars.x_generator_laye_3;
NumDims.x_generator_laye_2 = max(NumDims.x_generator_laye_7, NumDims.x_generator_laye_3);

% MatMul:
[Vars.x_generator_laye_11, NumDims.x_generator_laye_11] = onnxMatMul(Vars.z256, Vars.onnx__MatMul_1763, NumDims.z256, NumDims.onnx__MatMul_1763);

% Unsqueeze:
[shape, NumDims.x_generator_laye_8] = prepareUnsqueezeArgs(Vars.x_generator_laye_11, Vars.UnsqueezeAxes1868, NumDims.x_generator_laye_11);
Vars.x_generator_laye_8 = reshape(Vars.x_generator_laye_11, shape);

% Unsqueeze:
[shape, NumDims.x_generator_laye_9] = prepareUnsqueezeArgs(Vars.x_generator_laye_8, Vars.UnsqueezeAxes1869, NumDims.x_generator_laye_8);
Vars.x_generator_laye_9 = reshape(Vars.x_generator_laye_8, shape);

% Sub:
Vars.x_generator_laye_6 = Vars.x_generator_Transpos - Vars.onnx__Sub_1758;
NumDims.x_generator_laye_6 = max(NumDims.x_generator_Transpos, NumDims.onnx__Sub_1758);

% Div:
Vars.x_generator_laye_4 = Vars.x_generator_laye_6 ./ Vars.onnx__Div_1765;
NumDims.x_generator_laye_4 = max(NumDims.x_generator_laye_6, NumDims.onnx__Div_1765);

% Mul:
Vars.x_generator_laye_5 = Vars.x_generator_laye_4 .* Vars.x_generator_laye_2;
NumDims.x_generator_laye_5 = max(NumDims.x_generator_laye_4, NumDims.x_generator_laye_2);

% Add:
Vars.x_generator_laye_1 = Vars.x_generator_laye_5 + Vars.x_generator_laye_9;
NumDims.x_generator_laye_1 = max(NumDims.x_generator_laye_5, NumDims.x_generator_laye_9);

% Set graph output arguments from Vars and NumDims:
x_generator_laye_1 = Vars.x_generator_laye_1;
x_generator_laye_1NumDims1871 = NumDims.x_generator_laye_1;
x_generator_Transpos = Vars.x_generator_Transpos;
x_generator_TransposNumDims1872 = NumDims.x_generator_Transpos;
% Set output state from Vars:
state = updateStruct(state, Vars);
end

function [inputDataPerms, outputDataPerms, Training] = parseInputs(z256, numDataOutputs, params, varargin)
% Function to validate inputs to MatMul_To_AddFcn:
p = inputParser;
isValidArrayInput = @(x)isnumeric(x) || isstring(x);
isValidONNXParameters = @(x)isa(x, 'ONNXParameters');
addRequired(p, 'z256', isValidArrayInput);
addRequired(p, 'params', isValidONNXParameters);
addParameter(p, 'InputDataPermutation', 'auto');
addParameter(p, 'OutputDataPermutation', 'auto');
addParameter(p, 'Training', false);
parse(p, z256, params, varargin{:});
inputDataPerms = p.Results.InputDataPermutation;
outputDataPerms = p.Results.OutputDataPermutation;
Training = p.Results.Training;
if isnumeric(inputDataPerms)
    inputDataPerms = {inputDataPerms};
end
if isstring(inputDataPerms) && isscalar(inputDataPerms) || ischar(inputDataPerms)
    inputDataPerms = repmat({inputDataPerms},1,1);
end
if isnumeric(outputDataPerms)
    outputDataPerms = {outputDataPerms};
end
if isstring(outputDataPerms) && isscalar(outputDataPerms) || ischar(outputDataPerms)
    outputDataPerms = repmat({outputDataPerms},1,numDataOutputs);
end
end

function [z256, Training, outputDataPerms, anyDlarrayInputs] = preprocessInput(z256, params, varargin)
% Parse input arguments
[inputDataPerms, outputDataPerms, Training] = parseInputs(z256, 2, params, varargin{:});
anyDlarrayInputs = any(cellfun(@(x)isa(x, 'dlarray'), {z256}));
% Make the input variables into unlabelled dlarrays:
z256 = makeUnlabeledDlarray(z256);
% Permute inputs if requested:
z256 = permuteInputVar(z256, inputDataPerms{1}, 2);
end

function [x_generator_laye_1, x_generator_Transpos] = postprocessOutput(x_generator_laye_1, x_generator_Transpos, outputDataPerms, anyDlarrayInputs, Training, varargin)
% Set output type:
if ~anyDlarrayInputs && ~Training
    if isdlarray(x_generator_laye_1)
        x_generator_laye_1 = extractdata(x_generator_laye_1);
    end
    if isdlarray(x_generator_Transpos)
        x_generator_Transpos = extractdata(x_generator_Transpos);
    end
end
% Permute outputs if requested:
x_generator_laye_1 = permuteOutputVar(x_generator_laye_1, outputDataPerms{1}, 4);
end


%% dlarray functions implementing ONNX operators:

function [D, numDimsD] = onnxMatMul(A, B, numDimsA, numDimsB)
% Implements the ONNX MatMul operator.

% Copyright 2020-2023 The MathWorks, Inc.

% If B is 1-D, temporarily extend it to a row vector
if numDimsB==1
    B = B(:)';
end
maxNumDims = max(numDimsA, numDimsB);
numDimsD = maxNumDims;
if maxNumDims > 2
    % Removes dlarray formats if only one of the input dlarrays is formatted.
    if sum([isempty(dims(A)), isempty(dims(B))]) == 1
        D = pagemtimes(stripdims(B), stripdims(A));
    else
        %computes matrix product of corresponding pages of input arrays A and
        %B.
        D = pagemtimes(B, A);
    end
else
    D = B * A;
    if numDimsA==1 || numDimsB==1
        D = D(:);
        numDimsD = 1;
    end
end
end

function [A, B, C, alpha, beta, numDimsY] = prepareGemmArgs(A, B, C, alpha, beta, transA, transB, numDimsC)

%   Copyright 2020 The MathWorks, Inc.

% Prepares arguments for implementing the ONNX Gemm operator
if transA
    A = A';
end
if transB
    B = B';
end
if numDimsC < 2
    C = C(:);   % C can be broadcast to [N M]. Make C a col vector ([N 1])
end
numDimsY = 2;
% Y=B*A because we want (AB)'=B'A', and B and A are already transposed.
end

function [DLTShape, numDimsY] = prepareReshapeArgs(X, ONNXShape, numDimsX, allowzero)
% Prepares arguments for implementing the ONNX Reshape operator

%   Copyright 2020-2024 The MathWorks, Inc.

ONNXShape = flip(extractdata(ONNXShape));            % First flip the shape to make it correspond to the dimensions of X.
% In ONNX, 0 means "unchanged" if allowzero is false, and -1 means "infer". In DLT, there is no
% "unchanged", and [] means "infer".
DLTShape = num2cell(ONNXShape);                      % Make a cell array so we can include [].
% Replace zeros with the actual size if allowzero is false
if any(ONNXShape==0) && allowzero==0
    i0 = find(ONNXShape==0);
    DLTShape(i0) = num2cell(size(X, numDimsX - numel(ONNXShape) + i0));  % right-align the shape vector and dims
end
if any(ONNXShape == -1)
    % Replace -1 with []
    i = ONNXShape == -1;
    DLTShape{i} = [];
end
if numel(DLTShape)==1
    DLTShape = [DLTShape 1];
end
numDimsY = numel(ONNXShape);
end

function [perm, numDimsA] = prepareTransposeArgs(ONNXPerm, numDimsA)
% Prepares arguments for implementing the ONNX Transpose operator

%   Copyright 2020 The MathWorks, Inc.

if numDimsA <= 1        % Tensors of numDims 0 or 1 are unchanged by ONNX Transpose.
    perm = [];
else
    if isempty(ONNXPerm)        % Empty ONNXPerm means reverse the dimensions.
        perm = numDimsA:-1:1;
    else
        perm = numDimsA-flip(ONNXPerm);
    end
end
end

function [newShape, numDimsY] = prepareUnsqueezeArgs(X, ONNXAxes, numDimsX)
% Prepares arguments for implementing the ONNX Unsqueeze operator

%   Copyright 2020-2021 The MathWorks, Inc.

numDimsY = numDimsX + numel(ONNXAxes);
ONNXAxes = extractdata(ONNXAxes);
ONNXAxes(ONNXAxes<0) = ONNXAxes(ONNXAxes<0) + numDimsY;
ONNXAxes = sort(ONNXAxes);                                              % increasing order
if numDimsY == 1
    newShape = size(X);
else
    DLTAxes  = flip(numDimsY - ONNXAxes);                                  % increasing order
    newShape = ones(1, numDimsY);
    posToSet = setdiff(1:numDimsY, DLTAxes, 'stable');
    newShape(posToSet) = size(X, 1:numel(posToSet));
end
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
