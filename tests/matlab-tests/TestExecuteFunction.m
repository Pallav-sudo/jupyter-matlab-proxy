% Copyright 2024 The MathWorks, Inc.
classdef TestExecuteFunction < matlab.unittest.TestCase
    % TestExecuteFunction contains unit tests for the execute function
    properties
        TestPaths
    end

    methods (TestClassSetup)
        function addFunctionPath(testCase)
            testCase.TestPaths = cellfun(@(relative_path)(fullfile(pwd, relative_path)), {"../../src/jupyter_matlab_kernel/matlab", "../../tests/matlab-tests/"}, 'UniformOutput', false);
            cellfun(@addpath, testCase.TestPaths)
        end
        function suppressWarnings(testCase)
            warning('off', 'all');
            testCase.addTeardown(@() warning('on', 'all'));
        end        
    end

    methods (TestClassTeardown)
        function removeFunctionPath(testCase)
            cellfun(@rmpath, testCase.TestPaths)
        end
    end
    methods (Test)
        function testMatrixOutput(testCase)
            % Test execution of a code that generates a matrix output
            code = 'repmat([1 2 3 4],5,1)';
            kernelId = 'test_kernel_id';
            result = jupyter.execute(code, kernelId);
            disp("matrix");
            disp(struct(result{1}));
            testCase.verifyEqual(result{1}.type, 'execute_result', 'Expected execute_result type');
            testCase.verifyTrue(any(strcmp(result{1}.mimetype{1}, 'text/html')), 'Expected HTML output');
            testCase.verifyTrue(any(strcmp(result{1}.mimetype{2}, 'text/plain')), 'Expected HTML output');
        end

        function testVariableOutput(testCase)
            % Test execution of a code that generates a variable output
            code = 'var x';
            kernelId = 'test_kernel_id';
            result = jupyter.execute(code, kernelId);
            % disp("variableoutput");
            % disp(struct(result{1}));
            testCase.verifyEqual(result{1}.type, 'execute_result', 'Expected execute_result type');
            testCase.verifyTrue(any(strcmp(result{1}.mimetype{1}, 'text/html')), 'Expected HTML output');
            testCase.verifyTrue(any(strcmp(result{1}.mimetype{2}, 'text/plain')), 'Expected HTML output');
        end

        % function testVariableStringOutput(testCase)
        %     % Test execution of a code that generates a variable string output
        %     code = "a='variable string'; sprintf('Text %f of type variable string', a)";
        %     % code = "A = 1/eps;sprintf('%0.5f',A)"
        %     kernelId = 'test_kernel_id';
        %     result = jupyter.execute(code, kernelId);
        %     % disp("varstring");
        %     % disp(struct(result{1}.content));
        %     testCase.verifyEqual(result{1}.type, 'execute_result', 'Expected execute_result type');
        %     testCase.verifyTrue(any(strcmp(result{1}.mimetype{1}, 'text/html')), 'Expected HTML output');
        %     testCase.verifyTrue(any(strcmp(result{1}.mimetype{2}, 'text/plain')), 'Expected HTML output');
        % end
        function testSymbolicOutput(testCase)
            %Test execution of a code that generates a symbolic output
            % code = 'setenv("DISPLAY","99"); sym(1/3); disp(x);';
            % code ='sym(1/3)';
            code = 'syms x; y = x^2 + 2*x + 1; disp(y)';
            kernelId = 'test_kernel_id';
            result = jupyter.execute(code, kernelId);
            disp("symbolicoutput");
            disp(struct(result{1}));
            testCase.verifyEqual(result{1}.type, 'execute_result', 'Expected execute_result type');
            testCase.verifyTrue(any(strcmp(result{1}.mimetype{1}, "text/latex")), 'Expected LaTeX output');
        end

        function testErrorOutput(testCase)
            % Test execution of a code that generates an error
            code = 'error(''Test error'');';
            kernelId = 'test_kernel_id';
            result = jupyter.execute(code, kernelId);
            disp("erroroutput");
            disp(struct(result{1}));
            testCase.verifyEqual(result{1}.type, 'stream', 'Expected stream type');
            testCase.verifyEqual(result{1}.content.name, 'stderr', 'Expected stderr stream');
            testCase.verifyTrue(contains(result{1}.content.text, 'Test error'), 'Expected error message');
        end

        function testFigureOutput(testCase)
            % Test execution of a code that generates a figure output
            %code = 'moon = imread("moon.tif"); imshow(moon);';
            code = 'figure; plot(1:10); title(''Test Figure'');';
            kernelId = 'test_kernel_id';
            result = jupyter.execute(code, kernelId);
            disp("figoutput");
            disp(struct(result{1}));
            testCase.verifyEqual(result{1}.type, 'execute_result', 'Expected execute_result type');
            testCase.verifyTrue(any(strcmp(result{1}.mimetype, 'image/png')), 'Expected PNG image output');
        end
    end
end